-- ============================================================
-- Fooyre Tonngoode - Schema Supabase
-- A executer dans SQL Editor du dashboard Supabase
-- ============================================================

-- ------------------------------------------------------------
-- 1. Table profiles (etend auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null default '',
  telephone text,
  role text not null default 'reader' check (role in ('reader', 'admin')),
  subscription_start timestamptz,
  subscription_end timestamptz,
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

-- Creation automatique du profil a l'inscription
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nom, telephone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nom', ''),
    new.raw_user_meta_data ->> 'telephone'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- 2. Table editions (numeros du journal)
-- ------------------------------------------------------------
create table if not exists public.editions (
  id uuid primary key default gen_random_uuid(),
  numero int not null unique,
  titre text not null,
  date_publication date not null default current_date,
  pdf_path text,                   -- legacy (remplace par cover/complet)
  cover_path text,                 -- affiche / la une (image) : dossier gratuit/
  pdf_complet text,                -- edition complete (abonnes) : dossier abonnes/
  gratuit boolean not null default false,  -- legacy
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. Fonctions utilitaires (security definer pour eviter la
--    recursion RLS dans les policies)
-- ------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.has_active_subscription()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and is_active = true
      and subscription_end > now()
  );
$$;

-- ------------------------------------------------------------
-- 4. Row Level Security
-- ------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.editions enable row level security;

-- Profiles : chacun voit son profil, l'admin voit tout
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (id = auth.uid() or public.is_admin());

-- Profiles : l'utilisateur modifie son nom/telephone uniquement.
-- Les colonnes d'abonnement sont protegees par le trigger ci-dessous.
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid() or public.is_admin());

-- Empeche un lecteur de modifier lui-meme son abonnement ou son role.
-- N'agit que lorsqu'il y a une session applicative (auth.uid() non nul) :
-- l'acces direct a la base (SQL Editor, cle service_role) reste libre,
-- ce qui permet de promouvoir le tout premier admin.
create or replace function public.protect_subscription_columns()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    new.role := old.role;
    new.subscription_start := old.subscription_start;
    new.subscription_end := old.subscription_end;
    new.is_active := old.is_active;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_subscription on public.profiles;
create trigger protect_subscription
  before update on public.profiles
  for each row execute function public.protect_subscription_columns();

-- Editions : metadonnees visibles par tous (la une / apercu + invitation
-- a s'abonner). L'acces aux FICHIERS reste protege par les policies
-- Storage (dossier gratuit/ accessible a tous, abonnes/ aux abonnes).
drop policy if exists "editions_select" on public.editions;
create policy "editions_select" on public.editions
  for select using (true);

-- Editions : seul l'admin cree / modifie / supprime
drop policy if exists "editions_admin_insert" on public.editions;
create policy "editions_admin_insert" on public.editions
  for insert with check (public.is_admin());

drop policy if exists "editions_admin_update" on public.editions;
create policy "editions_admin_update" on public.editions
  for update using (public.is_admin());

drop policy if exists "editions_admin_delete" on public.editions;
create policy "editions_admin_delete" on public.editions
  for delete using (public.is_admin());

-- ------------------------------------------------------------
-- 5. Storage : bucket prive "editions"
--    (creer le bucket dans le dashboard : Storage > New bucket
--     nom "editions", Public = OFF, puis executer ceci)
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('editions', 'editions', false)
on conflict (id) do nothing;

-- Lecture des PDF : meme logique que la table editions.
-- Un PDF gratuit est reperable par son chemin "gratuit/..."
drop policy if exists "storage_editions_read" on storage.objects;
create policy "storage_editions_read" on storage.objects
  for select using (
    bucket_id = 'editions'
    and (
      (storage.foldername(name))[1] = 'gratuit'
      or public.has_active_subscription()
      or public.is_admin()
    )
  );

-- Upload / suppression : admin uniquement
drop policy if exists "storage_editions_write" on storage.objects;
create policy "storage_editions_write" on storage.objects
  for insert with check (bucket_id = 'editions' and public.is_admin());

drop policy if exists "storage_editions_delete" on storage.objects;
create policy "storage_editions_delete" on storage.objects
  for delete using (bucket_id = 'editions' and public.is_admin());

-- ------------------------------------------------------------
-- 6. Suppression de compte (self-service + admin)
--    Supprimer une ligne auth.users cascade vers public.profiles
--    (on delete cascade). Ces fonctions "security definer" tournent
--    avec les privileges du proprietaire (postgres), qui a acces au
--    schema auth - permet de supprimer un compte sans exposer la
--    cle service_role cote app.
-- ------------------------------------------------------------
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

grant execute on function public.delete_my_account() to authenticated;

create or replace function public.admin_delete_user(target_user_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Not authorized';
  end if;
  delete from auth.users where id = target_user_id;
end;
$$;

grant execute on function public.admin_delete_user(uuid) to authenticated;

-- ------------------------------------------------------------
-- 7. Confirmation d'email manuelle par l'admin (contournement pour
--    les cas ou le lien de confirmation ne fonctionne pas cote
--    client mail, ex: Gmail sur iOS).
-- ------------------------------------------------------------
create or replace view public.admin_users_view as
select p.*, u.email, (u.email_confirmed_at is not null) as email_confirmed
from public.profiles p
join auth.users u on u.id = p.id
where public.is_admin();

grant select on public.admin_users_view to authenticated;

create or replace function public.admin_confirm_user_email(target_user_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Not authorized';
  end if;
  update auth.users
     set email_confirmed_at = now()
   where id = target_user_id
     and email_confirmed_at is null;
end;
$$;

grant execute on function public.admin_confirm_user_email(uuid) to authenticated;

-- ------------------------------------------------------------
-- 8. Pour promouvoir un utilisateur en admin (a faire une fois,
--    manuellement, avec l'email de l'editeur) :
--
--   update public.profiles set role = 'admin'
--   where id = (select id from auth.users where email = 'EMAIL_EDITEUR');
-- ------------------------------------------------------------
