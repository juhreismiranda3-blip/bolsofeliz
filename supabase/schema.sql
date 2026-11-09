-- =========================================================
--  BOLSO FELIZ — estrutura do banco de dados (Supabase)
--  Cole tudo no SQL Editor do Supabase e clique em "Run".
--  Pode rodar de novo sem medo: não apaga dados existentes.
-- =========================================================

-- 1) Quem pode usar o app (só os e-mails desta lista enxergam os dados)
create table if not exists public.membros (
  email text primary key
);

-- 2) Dinheiro que entrou
create table if not exists public.entradas (
  id         text primary key,
  mes        text not null check (mes ~ '^\d{4}-\d{2}$'),
  descricao  text not null,
  valor      numeric(12,2) not null check (valor > 0),
  criado_por uuid default auth.uid(),
  criado_em  timestamptz not null default now()
);

-- 3) Contas do mês
create table if not exists public.contas (
  id         text primary key,
  mes        text not null check (mes ~ '^\d{4}-\d{2}$'),
  descricao  text not null,
  categoria  text not null default 'outros',
  vencimento date,
  valor      numeric(12,2) not null check (valor > 0),
  pago       boolean not null default false,
  criado_por uuid default auth.uid(),
  criado_em  timestamptz not null default now()
);

-- 4) Dívidas
create table if not exists public.dividas (
  id         text primary key,
  nome       text not null,
  total      numeric(12,2) not null check (total > 0),
  pago       numeric(12,2) not null default 0 check (pago >= 0),
  criado_por uuid default auth.uid(),
  criado_em  timestamptz not null default now()
);

-- 5) Configuração (uma linha só)
create table if not exists public.config (
  id        int primary key default 1 check (id = 1),
  valor_bom numeric(12,2) not null default 2000
);
insert into public.config (id) values (1) on conflict (id) do nothing;

-- Índices para filtrar por mês
create index if not exists entradas_mes_idx on public.entradas (mes);
create index if not exists contas_mes_idx   on public.contas (mes);

-- 6) Função que diz se quem está logado é do casal
create or replace function public.eh_membro()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.membros
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.eh_membro() from public, anon;
grant execute on function public.eh_membro() to authenticated;

-- 7) Segurança: liga o RLS e só deixa membros lerem e gravarem
alter table public.membros  enable row level security;
alter table public.entradas enable row level security;
alter table public.contas   enable row level security;
alter table public.dividas  enable row level security;
alter table public.config   enable row level security;

-- (a tabela membros não tem política: ninguém lê nem altera pelo app,
--  só você pelo painel do Supabase)

drop policy if exists "membros acessam entradas" on public.entradas;
create policy "membros acessam entradas" on public.entradas
  for all to authenticated using (public.eh_membro()) with check (public.eh_membro());

drop policy if exists "membros acessam contas" on public.contas;
create policy "membros acessam contas" on public.contas
  for all to authenticated using (public.eh_membro()) with check (public.eh_membro());

drop policy if exists "membros acessam dividas" on public.dividas;
create policy "membros acessam dividas" on public.dividas
  for all to authenticated using (public.eh_membro()) with check (public.eh_membro());

drop policy if exists "membros leem config" on public.config;
create policy "membros leem config" on public.config
  for select to authenticated using (public.eh_membro());

drop policy if exists "membros alteram config" on public.config;
create policy "membros alteram config" on public.config
  for update to authenticated using (public.eh_membro()) with check (public.eh_membro());

-- 8) Atualização ao vivo (um vê na hora o que o outro anotou)
do $$
declare t text;
begin
  foreach t in array array['entradas','contas','dividas','config'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- =========================================================
--  ÚLTIMO PASSO: troque os e-mails abaixo pelos de vocês dois
--  e rode só estas linhas (selecione e clique em "Run").
-- =========================================================
-- insert into public.membros (email) values
--   ('seu-email@gmail.com'),
--   ('email-dele@gmail.com')
-- on conflict do nothing;
