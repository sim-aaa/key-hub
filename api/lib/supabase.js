const { createClient } = require("@supabase/supabase-js");
const { getConfig } = require("./config");

let client;

function getSupabase() {
  if (!client) {
    const { supabaseUrl, supabaseServiceRoleKey } = getConfig();
    client = createClient(supabaseUrl, supabaseServiceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }
  return client;
}

module.exports = { getSupabase };
