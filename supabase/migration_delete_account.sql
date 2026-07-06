-- ============================================================
-- Migration : suppression de compte (self-service + admin)
-- A executer dans le SQL Editor de Supabase.
--
-- Supprimer une ligne auth.users cascade automatiquement vers
-- public.profiles (voir "on delete cascade" dans schema.sql).
-- Ces fonctions "security definer" s'executent avec les privileges
-- du proprietaire (postgres), qui a acces au schema auth - c'est ce
-- qui permet de supprimer un compte sans exposer la cle service_role
-- cote app.
-- ============================================================

-- Un utilisateur supprime son propre compte.
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

-- L'admin supprime le compte d'un utilisateur quelconque.
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
