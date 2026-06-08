function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
}

function getConfig() {
  return {
    supabaseUrl: requireEnv("SUPABASE_URL"),
    supabaseServiceRoleKey: requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    adminSecret: process.env.ADMIN_SECRET || "",
    scriptUrl: process.env.SCRIPT_URL || "",
    keyDurationHours: Number(process.env.KEY_DURATION_HOURS || 24),
    gateWaitSeconds: Number(process.env.GATE_WAIT_SECONDS || 15),
  };
}

module.exports = { getConfig };
