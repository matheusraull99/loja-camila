-- Loja da Camila: rode este arquivo inteiro no Supabase (SQL Editor > New query > Run).

create table if not exists produtos (
  id bigint generated always as identity primary key,
  nome text not null,
  preco numeric(10,2) not null,
  cores text[] not null default '{}',
  tamanhos text[] not null default '{}',
  ultima_peca boolean not null default false,
  destaque boolean not null default false,
  ativo boolean not null default true,
  foto_url text,
  criado_em timestamptz not null default now()
);

create table if not exists config (
  chave text primary key,
  valor text not null default ''
);

alter table produtos enable row level security;
alter table config enable row level security;

-- Visitantes só leem produtos ativos; a Camila (logada) vê e edita tudo.
create policy "ler produtos ativos" on produtos for select using (ativo or auth.role() = 'authenticated');
create policy "camila altera produtos" on produtos for all to authenticated using (true) with check (true);
create policy "ler textos" on config for select using (true);
create policy "camila altera textos" on config for all to authenticated using (true) with check (true);

-- Pasta pública de fotos
insert into storage.buckets (id, name, public) values ('fotos', 'fotos', true) on conflict (id) do nothing;
create policy "fotos publicas" on storage.objects for select using (bucket_id = 'fotos');
create policy "camila envia fotos" on storage.objects for insert to authenticated with check (bucket_id = 'fotos');
create policy "camila troca fotos" on storage.objects for update to authenticated using (bucket_id = 'fotos');
create policy "camila apaga fotos" on storage.objects for delete to authenticated using (bucket_id = 'fotos');

-- Textos iniciais
insert into config (chave, valor) values
  ('marca', 'Camila'),
  ('chamada', 'É nova por aqui?'),
  ('titulo', 'Bem-vinda à minha loja'),
  ('cupom_pct', '5'),
  ('cupom_codigo', 'BEMVINDA'),
  ('cupom_texto', 'No seu primeiro pedido, com desconto aplicado no carrinho.'),
  ('quem_somos', 'Conte aqui a história, o estilo e o que torna a loja especial.'),
  ('instagram', '@camila'),
  ('whatsapp', '5511900000000')
on conflict (chave) do nothing;
