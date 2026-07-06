-- ============================================================
-- Migration : affiche (image de la une) + PDF complet par edition
-- A executer dans le SQL Editor de Supabase (idempotent).
-- ============================================================

-- 1. Nouvelles colonnes
--    cover_path  : image de couverture (la une), visible par tous
--    pdf_complet : edition complete (PDF), reservee aux abonnes
alter table public.editions add column if not exists cover_path text;
alter table public.editions add column if not exists pdf_complet text;

-- 2. pdf_path (legacy) n'est plus obligatoire
alter table public.editions alter column pdf_path drop not null;

-- 3. Migrer les editions existantes : l'ancien PDF payant devient la
--    version complete. (Les affiches seront ajoutees en republiant.)
update public.editions
   set pdf_complet = pdf_path
 where gratuit = false and pdf_complet is null and pdf_path is not null;

-- 4. Metadonnees des editions visibles par tous (affiche + invitation
--    a s'abonner). L'acces aux FICHIERS reste protege par Storage :
--    - affiche dans le dossier gratuit/  -> lisible par tous
--    - PDF complet dans le dossier abonnes/ -> abonnes / admin
drop policy if exists "editions_select" on public.editions;
create policy "editions_select" on public.editions
  for select using (true);
