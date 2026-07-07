-- ============================================================
-- Migration : confirmation d'email manuelle par l'admin
-- A executer dans le SQL Editor de Supabase.
--
-- Contournement pour les utilisateurs dont le lien de confirmation
-- par email ne fonctionne pas (probleme observe avec l'app Gmail
-- sur iOS qui bloque silencieusement la redirection vers l'app,
-- meme via une page de rebond https). L'admin peut confirmer
-- manuellement l'email d'un utilisateur pour debloquer sa connexion.
-- ============================================================

-- Vue reservee a l'admin : ajoute l'email et son statut de
-- confirmation (colonnes de auth.users, normalement inaccessibles
-- directement) aux profils. La clause "where public.is_admin()"
-- fait qu'un non-admin ne recoit aucune ligne (comme une RLS).
create or replace view public.admin_users_view as
select p.*, u.email, (u.email_confirmed_at is not null) as email_confirmed
from public.profiles p
join auth.users u on u.id = p.id
where public.is_admin();

grant select on public.admin_users_view to authenticated;

-- L'admin confirme manuellement l'email d'un utilisateur.
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
