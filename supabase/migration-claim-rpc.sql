-- รันไฟล์นี้ใน Supabase SQL Editor ถ้าสร้างตารางไปแล้วก่อนหน้านี้

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
