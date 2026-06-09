/**
 * Local dev server (no Vercel required)
 * Usage: node scripts/local-server.js
 * Requires .env in key-hub root
 */

require("dotenv").config({ path: require("path").join(__dirname, "..", ".env") });

const http = require("http");
const fs = require("fs");
const path = require("path");

const health = require("../api/health");
const gateStart = require("../api/gate-start");
const generateKey = require("../api/generate-key");
const verify = require("../api/verify");

const PORT = process.env.PORT || 3000;
const publicDir = path.join(__dirname, "..", "public");

const routes = {
  "/api/health": health,
  "/api/gate-start": gateStart,
  "/api/generate-key": generateKey,
  "/api/verify": verify,
};

function serveStatic(req, res) {
  const filePath = req.url === "/" ? "/index.html" : req.url;
  const fullPath = path.join(publicDir, filePath);

  if (!fullPath.startsWith(publicDir)) {
    res.statusCode = 403;
    res.end("Forbidden");
    return;
  }

  if (!fs.existsSync(fullPath) || fs.statSync(fullPath).isDirectory()) {
    res.statusCode = 404;
    res.end("Not found");
    return;
  }

  const ext = path.extname(fullPath);
  const type = ext === ".html" ? "text/html; charset=utf-8" : "text/plain";
  res.statusCode = 200;
  res.setHeader("Content-Type", type);
  res.end(fs.readFileSync(fullPath));
}

const server = http.createServer(async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  const handler = routes[req.url?.split("?")[0]];
  if (handler) {
    try {
      await handler(req, res);
    } catch (err) {
      res.statusCode = 500;
      res.end(JSON.stringify({ ok: false, message: err.message }));
    }
    return;
  }

  serveStatic(req, res);
});

server.listen(PORT, () => {
  console.log(`Key Hub running at http://localhost:${PORT}`);
});
