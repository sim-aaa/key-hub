const { getConfig } = require("./lib/config");
const { getSupabase } = require("./lib/supabase");
const { handleOptions, json, hashIp, getClientIp } = require("./lib/http");

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== "POST") {
    return json(res, 405, { ok: false, message: "Method not allowed" });
  }

  try {
    const { gateWaitSeconds, gateAdUrl } = getConfig();
    const supabase = getSupabase();
    const ipHash = hashIp(getClientIp(req));

    const { data, error } = await supabase
      .from("gate_challenges")
      .insert({ ip_hash: ipHash })
      .select("id, created_at")
      .single();

    if (error) {
      return json(res, 500, { ok: false, message: "Failed to start gate" });
    }

    const createdAtMs = new Date(data.created_at).getTime();
    const readyAtMs = createdAtMs + gateWaitSeconds * 1000;

    return json(res, 200, {
      ok: true,
      challenge_id: data.id,
      wait_seconds: gateWaitSeconds,
      ad_url: gateAdUrl,
      created_at: data.created_at,
      ready_at: new Date(readyAtMs).toISOString(),
      message: `เปิด work.ink ดู ads ก่อน แล้วกลับมารับ Key`,
    });
  } catch (err) {
    return json(res, 500, { ok: false, message: err.message });
  }
};
