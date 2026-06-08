const crypto = require("crypto");

function json(res, status, body) {
  res.statusCode = status;
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.end(JSON.stringify(body));
}

function handleOptions(req, res) {
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    res.end();
    return true;
  }
  return false;
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(chunk);
  }
  const raw = Buffer.concat(chunks).toString("utf8");
  if (!raw) return {};
  return JSON.parse(raw);
}

function hashIp(ip) {
  return crypto.createHash("sha256").update(ip || "unknown").digest("hex");
}

function normalizeIp(ip) {
  if (!ip || ip === "unknown") return "unknown";
  if (ip === "::1" || ip === "::ffff:127.0.0.1") return "127.0.0.1";
  if (ip.startsWith("::ffff:")) return ip.slice(7);
  return ip;
}

function getClientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return normalizeIp(forwarded.split(",")[0].trim());
  }
  return normalizeIp(req.socket?.remoteAddress || "unknown");
}

function generateKey() {
  const part = () => crypto.randomBytes(4).toString("hex").toUpperCase();
  return `HUB-${part()}-${part()}-${part()}`;
}

module.exports = {
  json,
  handleOptions,
  readJsonBody,
  hashIp,
  normalizeIp,
  getClientIp,
  generateKey,
};
