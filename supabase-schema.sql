-- Run this entire script in Supabase > SQL Editor.
create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('Mobile','Accessory')),
  brand text,
  model text,
  color text,
  sku text unique,
  quantity integer not null default 0 check (quantity >= 0),
  reorder_level integer not null default 3 check (reorder_level >= 0),
  purchase_price numeric(12,2) not null default 0 check (purchase_price >= 0),
  selling_price numeric(12,2) not null default 0 check (selling_price >= 0),
  image_url text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references public.inventory(id) on delete set null,
  item_name text not null,
  action text not null,
  change_amount integer not null,
  note text,
  created_at timestamptz not null default now()
);
-- Admin role is assigned only by the project owner in SQL Editor.
create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin'))
);
create or replace function public.is_inventory_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.user_roles where user_id = auth.uid() and role = 'admin'); $$;
create or replace function public.set_inventory_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists inventory_updated_at on public.inventory;
create trigger inventory_updated_at before update on public.inventory
for each row execute function public.set_inventory_updated_at();

alter table public.inventory enable row level security;
alter table public.stock_movements enable row level security;
alter table public.user_roles enable row level security;
drop policy if exists "Admins manage inventory" on public.inventory;
create policy "Admins manage inventory" on public.inventory for all to authenticated
using (public.is_inventory_admin()) with check (public.is_inventory_admin());
drop policy if exists "Admins manage stock movements" on public.stock_movements;
create policy "Admins manage stock movements" on public.stock_movements for all to authenticated
using (public.is_inventory_admin()) with check (public.is_inventory_admin());
drop policy if exists "Users read own role" on public.user_roles;
create policy "Users read own role" on public.user_roles for select to authenticated using (user_id = auth.uid());
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.inventory to authenticated;
grant select, insert, update, delete on public.stock_movements to authenticated;
grant select on public.user_roles to authenticated;
-- After creating an admin user under Authentication > Users, run this with their UUID:
-- insert into public.user_roles (user_id, role) values ('PASTE-AUTH-USER-UUID-HERE', 'admin');
-- Enable Realtime for inventory and stock_movements:
alter publication supabase_realtime add table public.inventory;
alter publication supabase_realtime add table public.stock_movements;
