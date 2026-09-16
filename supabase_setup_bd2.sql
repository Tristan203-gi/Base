-- ══════════════════════════════════════════
-- SETUP SUPABASE — Portafolio BD2
-- Ejecutar completo en: Supabase > tu proyecto > SQL Editor > New query > Run
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
-- 1) TABLA: archivos (documentos subidos por semana)
-- ══════════════════════════════════════════
create table if not exists archivos (
  id uuid default gen_random_uuid() primary key,
  semana_key text not null,
  nombre text not null,
  storage_path text not null,
  url text not null,
  size bigint,
  created_at timestamptz default now()
);
alter table archivos enable row level security;
drop policy if exists "acceso publico archivos" on archivos;
create policy "acceso publico archivos" on archivos for all using (true) with check (true);

-- ══════════════════════════════════════════
-- 2) TABLA: enlaces (links agregados por semana)
-- ══════════════════════════════════════════
create table if not exists enlaces (
  id uuid default gen_random_uuid() primary key,
  semana_key text not null,
  label text not null,
  url text not null,
  created_at timestamptz default now()
);
alter table enlaces enable row level security;
drop policy if exists "acceso publico enlaces" on enlaces;
create policy "acceso publico enlaces" on enlaces for all using (true) with check (true);

-- ══════════════════════════════════════════
-- 3) TABLA: notificaciones (aviso al admin cuando "user" sube tarea)
-- ══════════════════════════════════════════
create table if not exists notificaciones (
  id uuid default gen_random_uuid() primary key,
  semana_key text not null,
  usuario text not null,
  nombre_archivo text not null,
  leida boolean default false,
  created_at timestamptz default now()
);
alter table notificaciones enable row level security;
drop policy if exists "acceso publico notificaciones" on notificaciones;
create policy "acceso publico notificaciones" on notificaciones for all using (true) with check (true);

-- ══════════════════════════════════════════
-- 4) BUCKET DE STORAGE (archivos subidos: PDF, Word, imágenes, etc.)
-- ══════════════════════════════════════════
insert into storage.buckets (id, name, public)
values ('bd2-archivos', 'bd2-archivos', true)
on conflict (id) do nothing;

drop policy if exists "lectura publica bd2-archivos" on storage.objects;
create policy "lectura publica bd2-archivos"
on storage.objects for select
using (bucket_id = 'bd2-archivos');

drop policy if exists "subida publica bd2-archivos" on storage.objects;
create policy "subida publica bd2-archivos"
on storage.objects for insert
with check (bucket_id = 'bd2-archivos');

drop policy if exists "eliminar publica bd2-archivos" on storage.objects;
create policy "eliminar publica bd2-archivos"
on storage.objects for delete
using (bucket_id = 'bd2-archivos');
