const { getConfig } = require("./lib/config");
const { getSupabase } = require("./lib/supabase");
const {
  handleOptions,
  json,
  readJsonBody,
  generateKey,
  hashIp,
  getClientIp,
} = require("./lib/http");

async function createKey(supabase, durationHours) {
  const expiresAt = new Date(Date.now() + durationHours * 60 * 60 * 1000).toISOString();

  for (let attempt = 0; attempt < 5; attempt += 1) {
    const key = generateKey();
    const { data, error } = await supabase
      .from("keys")
      .insert({ key, expires_at: expiresAt })
      .select("key, expires_at")
      .single();

    if (!error) return data;
    if (error.code !== "23505") throw new Error(error.message);
  }

  throw new Error("Could not generate unique key");
}

async function getChallenge(supabase, challengeId) {
  const { data, error } = await supabase
    .from("gate_challenges")
    .select("id, created_at, used, ip_hash")
    .eq("id", challengeId)
    .single();

  if (error || !data) return null;
  return data;
}

async function validateChallenge(supabase, challengeId, gateWaitSeconds, ipHash) {
  const data = await getChallenge(supabase, challengeId);

  if (!data) {
    return { ok: false, message: "ไม่พบ challenge กรุณากดเริ่มรับ Key ใหม่" };
  }

  if (data.used) {
    return { ok: false, message: "Challenge นี้ใช้ไปแล้ว กรุณากดเริ่มรับ Key ใหม่" };
  }

  if (data.ip_hash !== ipHash) {
    return { ok: false, message: "IP ไม่ตรงกัน กรุณากดเริ่มรับ Key ใหม่" };
  }

  const { data: claimed, error: rpcError } = await supabase.rpc("claim_gate_challenge", {
    p_challenge_id: challengeId,
    p_ip_hash: ipHash,
    p_wait_seconds: gateWaitSeconds,
  });

  if (rpcError) {
    if (rpcError.message && rpcError.message.includes("claim_gate_challenge")) {
      return {
        ok: false,
        message: "ยังไม่ได้รัน SQL function ใน Supabase ดูไฟล์ supabase/migration-claim-rpc.sql",
      };
    }
    return { ok: false, message: "ตรวจสอบ challenge ไม่สำเร็จ" };
  }

  if (claimed === true) {
    return { ok: true };
  }

  const createdAt = new Date(data.created_at).getTime();
  const elapsedSec = Math.max(0, Math.floor((Date.now() - createdAt) / 1000));
  const remaining = Math.max(1, gateWaitSeconds - elapsedSec + 2);

  return {
    ok: false,
    message: `รออีกประมาณ ${Math.min(remaining, gateWaitSeconds)} วินาที`,
    retry_after_seconds: Math.min(remaining, gateWaitSeconds),
  };
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== "POST") {
    return json(res, 405, { ok: false, message: "Method not allowed" });
  }

  try {
    const config = getConfig();
    const supabase = getSupabase();
    const body = await readJsonBody(req);
    const authHeader = req.headers.authorization || "";
    const isAdmin = config.adminSecret && authHeader === `Bearer ${config.adminSecret}`;

    let keyData;

    if (isAdmin) {
      keyData = await createKey(supabase, config.keyDurationHours);
    } else {
      const challengeId = body.challenge_id;
      if (!challengeId) {
        return json(res, 400, { ok: false, message: "challenge_id is required" });
      }

      const ipHash = hashIp(getClientIp(req));
      const challenge = await validateChallenge(
        supabase,
        challengeId,
        config.gateWaitSeconds,
        ipHash
      );

      if (!challenge.ok) {
        return json(res, 400, {
          ok: false,
          message: challenge.message,
          retry_after_seconds: challenge.retry_after_seconds || 0,
        });
      }

      keyData = await createKey(supabase, config.keyDurationHours);
    }

    return json(res, 200, {
      ok: true,
      key: keyData.key,
      expires_at: keyData.expires_at,
      duration_hours: config.keyDurationHours,
    });
  } catch (err) {
    return json(res, 500, { ok: false, message: err.message });
  }
};
