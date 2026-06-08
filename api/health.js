const { handleOptions, json } = require("./lib/http");

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== "GET") {
    return json(res, 405, { ok: false, message: "Method not allowed" });
  }

  return json(res, 200, {
    ok: true,
    service: "key-hub",
    time: new Date().toISOString(),
  });
};
