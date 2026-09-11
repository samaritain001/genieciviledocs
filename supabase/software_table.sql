-- ═══════════════════════════════════════════════════════════════════
--  GenieCivil Docs — table "software" (section Logiciels)
--
--  À exécuter une seule fois dans Supabase :
--    Dashboard → SQL Editor → New query → coller → Run
--
--  Tant que cette migration n'est pas exécutée, le site continue de
--  fonctionner normalement : il affiche la liste de 12 logiciels
--  intégrée au code. Une fois exécutée, la section devient gérable
--  depuis le site (bouton « ➕ Publier un logiciel » en mode admin).
-- ═══════════════════════════════════════════════════════════════════

create table if not exists public.software (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  domain      text not null,
  icon        text default '💻',
  color       text default 'blue',
  description text,
  tags        text[] default '{}',
  url         text not null,
  created_at  timestamptz not null default now()
);

alter table public.software enable row level security;

-- Lecture publique : tout le monde voit les fiches logiciels.
drop policy if exists "Public read software" on public.software;
create policy "Public read software"
  on public.software for select
  to public
  using (true);

-- Écriture réservée aux administrateurs (même règle que documents / offres).
drop policy if exists "Admin insert software" on public.software;
create policy "Admin insert software"
  on public.software for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists "Admin update software" on public.software;
create policy "Admin update software"
  on public.software for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "Admin delete software" on public.software;
create policy "Admin delete software"
  on public.software for delete
  to authenticated
  using (public.is_admin());

-- Reprise des 12 logiciels déjà présents sur le site.
-- Ne fait rien si la table contient déjà des lignes (ré-exécution sans risque).
insert into public.software (name, domain, icon, color, description, tags, url)
select * from (values
  ('AutoCAD', 'BIM / CAO', '📐', 'red', 'Dessin technique 2D/3D de référence : plans, coupes, détails d''exécution.', ARRAY['Autodesk','Payant · essai gratuit']::text[], 'https://www.autodesk.com/products/autocad/'),
  ('Revit', 'BIM / CAO', '🏢', 'blue', 'Modélisation BIM du bâtiment : structure, architecture, MEP en maquette unique.', ARRAY['Autodesk','Payant · essai gratuit']::text[], 'https://www.autodesk.com/products/revit/'),
  ('Civil 3D', 'BIM / CAO', '🛣', 'orange', 'Conception routière, terrassements, réseaux et projets VRD.', ARRAY['Autodesk','Payant · essai gratuit']::text[], 'https://www.autodesk.com/products/civil-3d/'),
  ('ETABS', 'Structures', '🏗', 'purple', 'Analyse et dimensionnement des structures de bâtiments (statique/sismique).', ARRAY['CSI','Payant']::text[], 'https://www.csiamerica.com/products/etabs'),
  ('SAP2000', 'Structures', '🌉', 'green', 'Analyse par éléments finis pour structures générales (bâtiments, ponts, ouvrages).', ARRAY['CSI','Payant']::text[], 'https://www.csiamerica.com/products/sap2000'),
  ('SAFE', 'Structures', '🧱', 'teal', 'Dimensionnement de dalles et fondations en béton armé.', ARRAY['CSI','Payant']::text[], 'https://www.csiamerica.com/products/safe'),
  ('Robot Structural Analysis', 'Structures', '🤖', 'pink', 'Analyse structurelle avancée intégrée à l''écosystème Autodesk.', ARRAY['Autodesk','Payant']::text[], 'https://www.autodesk.com/products/robot-structural-analysis/'),
  ('PLAXIS', 'Géotechnique', '⛏', 'orange', 'Modélisation géotechnique par éléments finis (sols, fondations, soutènements).', ARRAY['Bentley','Payant']::text[], 'https://www.bentley.com/software/plaxis/'),
  ('GeoStudio', 'Géotechnique', '🌍', 'green', 'Suite de logiciels pour la stabilité des pentes, infiltration, contraintes.', ARRAY['Seequent','Payant']::text[], 'https://www.seequent.com/products-solutions/geostudio/'),
  ('MS Project', 'Gestion de projet', '📊', 'blue', 'Planification et suivi de projets de construction (plannings, ressources).', ARRAY['Microsoft','Payant']::text[], 'https://www.microsoft.com/microsoft-365/project/project-management-software'),
  ('QGIS', 'Topographie', '🗺', 'teal', 'Système d''information géographique libre et gratuit pour la topographie.', ARRAY['Open source','Gratuit']::text[], 'https://qgis.org/'),
  ('FreeCAD', 'BIM / CAO', '⚙️', 'purple', 'Alternative libre et gratuite pour la modélisation 3D paramétrique.', ARRAY['Open source','Gratuit']::text[], 'https://www.freecad.org/')
) as seed(name, domain, icon, color, description, tags, url)
where not exists (select 1 from public.software);
