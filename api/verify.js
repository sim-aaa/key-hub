const { getConfig } = require("./lib/config");
const { getSupabase } = require("./lib/supabase");
const { handleOptions, json, readJsonBody } = require("./lib/http");

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== "POST") {
    return json(res, 405, { valid: false, message: "Method not allowed" });
  }

  try {
    const { scriptUrl } = getConfig();
    const supabase = getSupabase();
    const body = await readJsonBody(req);

    const key = String(body.key || "").trim();
    const hwid = String(body.hwid || "").trim();

    if (!key) {
      return json(res, 400, { valid: false, message: "key is required" });
    }

    if (!hwid) {
      return json(res, 400, { valid: false, message: "hwid is required" });
    }

    const { data: record, error } = await supabase
      .from("keys")
      .select("id, key, hwid, expires_at, is_active")
      .eq("key", key)
      .single();

    if (error || !record) {
      return json(res, 200, { valid: false, message: "Invalid key" });
    }

    if (!record.is_active) {
      return json(res, 200, { valid: false, message: "Key is disabled" });
    }

    if (new Date(record.expires_at).getTime() <= Date.now()) {
      return json(res, 200, { valid: false, message: "Key expired" });
    }

    if (!record.hwid) {
      const { error: bindError } = await supabase
        .from("keys")
        .update({ hwid })
        .eq("id", record.id)
        .is("hwid", null);

      if (bindError) {
        return json(res, 500, { valid: false, message: "Failed to bind HWID" });
      }
    } else if (record.hwid !== hwid) {
      return json(res, 200, { valid: false, message: "HWID mismatch" });
    }

    if (!scriptUrl) {
      return json(res, 500, { valid: false, message: "SCRIPT_URL is not configured" });
    }

    return json(res, 200, {
      valid: true,
      message: "Key verified",
      script_url: scriptUrl,
      expires_at: record.expires_at,
    });
  } catch (err) {
    return json(res, 500, { valid: false, message: err.message });
  }
};
