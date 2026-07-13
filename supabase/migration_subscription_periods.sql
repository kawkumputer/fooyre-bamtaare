-- ============================================================
-- Migration : abonnements par periodes multiples
--
-- Remplace le modele a une seule periode continue
-- (profiles.subscription_start/subscription_end/is_active) par une
-- table de periodes (subscription_periods), permettant plusieurs
-- abonnements non contigus dans le temps pour un meme utilisateur.
--
-- Regle d'acces : un numero (edition) est accessible a un lecteur si
-- sa date de parution tombe dans AU MOINS UNE de ses periodes
-- d'abonnement (passee ou en cours) - acces archive conserve meme
-- apres l'expiration de la periode.
--
-- A executer dans SQL Editor du dashboard Supabase, apres schema.sql.
-- ============================================================

create table if not exists public.subscription_periods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  created_at timestamptz not null default now(),
  constraint subscription_periods_valid_range check (end_date >= start_date)
);

create index if not exists subscription_periods_user_id_idx
  on public.subscription_periods(user_id);

-- Reprise des donnees existantes : une periode par profil ayant deja
-- un abonnement enregistre dans l'ancien modele.
insert into public.subscription_periods (user_id, start_date, end_date)
select id, subscription_start::date, subscription_end::date
from public.profiles
where subscription_start is not null
  and subscription_end is not null
  and subscription_end::date >= subscription_start::date;

alter table public.subscription_periods enable row level security;

-- Lecture : chacun voit ses propres periodes, l'admin voit tout.
drop policy if exists "subscription_periods_select" on public.subscription_periods;
create policy "subscription_periods_select" on public.subscription_periods
  for select using (user_id = auth.uid() or public.is_admin());

-- Ecriture (insert/update/delete) : admin uniquement.
drop policy if exists "subscription_periods_admin_write" on public.subscription_periods;
create policy "subscription_periods_admin_write" on public.subscription_periods
  for all using (public.is_admin()) with check (public.is_admin());

-- ------------------------------------------------------------
-- has_active_subscription() : abonnement actif AUJOURD'HUI (une
-- periode couvre la date du jour). Utilise pour le badge de statut
-- et l'affichage de la banniere d'abonnement.
-- ------------------------------------------------------------
create or replace function public.has_active_subscription()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.subscription_periods
    where user_id = auth.uid()
      and start_date <= current_date
      and end_date >= current_date
  );
$$;

-- ------------------------------------------------------------
-- has_access_to_storage_path(path) : acces a un fichier abonnes/ si
-- une periode (passee ou en cours) de l'utilisateur couvre la date
-- de parution de l'edition correspondante. Le chemin storage suit
-- le format 'abonnes/fooyre_{numero}.pdf' (voir AdminService.publishEdition).
-- ------------------------------------------------------------
create or replace function public.has_access_to_storage_path(path text)
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1
    from public.editions e
    join public.subscription_periods sp on sp.user_id = auth.uid()
    where path = 'abonnes/fooyre_' || e.numero || '.pdf'
      and e.date_publication between sp.start_date and sp.end_date
  );
$$;

drop policy if exists "storage_editions_read" on storage.objects;
create policy "storage_editions_read" on storage.objects
  for select using (
    bucket_id = 'editions'
    and (
      (storage.foldername(name))[1] = 'gratuit'
      or public.is_admin()
      or public.has_access_to_storage_path(name)
    )
  );

-- ------------------------------------------------------------
-- Les colonnes profiles.subscription_start / subscription_end /
-- is_active ne sont plus la source de verite (remplacees par
-- subscription_periods) mais restent en base sans etre supprimees,
-- par prudence (pas de perte de donnees, pas de cassure si un
-- ancien build les lit encore).
-- ------------------------------------------------------------
