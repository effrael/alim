-- Migration: create public.waitlist with RLS
-- Created: 2026-07-01

-- 1) Tabla (esquema public, ya expuesto en la API)
create table if not exists public.waitlist (
  id          uuid         primary key default gen_random_uuid(),
  email       text         not null,
  source      text         not null default 'landing',
  created_at  timestamptz  not null default now(),
  constraint waitlist_email_unique unique (email),
  constraint waitlist_email_valido check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

create index if not exists waitlist_created_at_idx on public.waitlist (created_at desc);

-- 2) Permisos: el rol anónimo debe poder insertar
grant insert on public.waitlist to anon, authenticated;
-- (No damos SELECT/UPDATE/DELETE a anon: nadie puede leer la lista desde el cliente)

-- 3) Row Level Security
alter table public.waitlist enable row level security;

drop policy if exists "waitlist_insert_anon" on public.waitlist;
create policy "waitlist_insert_anon"
  on public.waitlist
  for insert
  to anon, authenticated
  with check (true);
