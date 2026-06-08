-- Run this in Supabase SQL Editor (Dashboard → SQL → New query)

create table if not exists keys (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  hwid text,
  expires_at timestamptz not null,
  created_at timestamptz default now(),
  is_active boolean default true
);

create index if not exists idx_keys_key on keys (key);
create index if not exists idx_keys_expires_at on keys (expires_at);

create table if not exists gate_challenges (
  id uuid primary key default gen_random_uuid(),
  ip_hash text,
  created_at timestamptz default now(),
  used boolean default false
);

create index if not exists idx_gate_challenges_id_used on gate_challenges (id, used);

-- ใช้เวลาจาก database ตรวจว่ารอครบแล้ว (แก้ปัญหานาฬิกาเครื่องไม่ตรงกับ Supabase)
create or replace function claim_gate_challenge(
  p_challenge_id uuid,
  p_ip_hash text,
  p_wait_seconds int
)
returns boolean
language plpgsql
security definer
as $$
declare
  updated_count int;
begin
  update gate_challenges
  set used = true
  where id = p_challenge_id
    and used = false
    and ip_hash = p_ip_hash
    and created_at <= now() - make_interval(secs => p_wait_seconds);

  get diagnostics updated_count = row_count;
  return updated_count > 0;
end;
$$;

-- Optional: auto-delete expired keys (run manually or via cron)
-- delete from keys where expires_at < now();
