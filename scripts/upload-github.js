/**
 * upload-github.js
 * รัน: node scripts/upload-github.js
 */

const fs    = require("fs");
const path  = require("path");
const https = require("https");

const OWNER  = "sim-aaa";
const REPO   = "key-hub";
const BRANCH = "main";
const FILES  = [
  "scripts/main.lua",
  "scripts/loader.lua",
  "public/index.html",
  "public/claim.html",
  "api/generate-key.js",
];

const TOKEN = (() => {
  if (process.env.GITHUB_TOKEN) {
    return process.env.GITHUB_TOKEN.trim();
  }

  const tokenPath = "D:\\mytt.txt";
  if (fs.existsSync(tokenPath)) {
    return fs.readFileSync(tokenPath, "utf8").trim();
  }

  throw new Error("Missing GitHub token: set GITHUB_TOKEN or create D:\\mytt.txt");
})();

function githubRequest(method, endpoint, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const options = {
      hostname: "api.github.com",
      path: endpoint,
      method,
      headers: {
        "Authorization": `token ${TOKEN}`,
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "key-hub-uploader",
        "Content-Type": "application/json",
        ...(data ? { "Content-Length": Buffer.byteLength(data) } : {}),
      },
    };
    const req = https.request(options, (res) => {
      let raw = "";
      res.on("data", (chunk) => (raw += chunk));
      res.on("end", () => {
        try { resolve(JSON.parse(raw)); } catch (e) { resolve(raw); }
      });
    });
    req.on("error", reject);
    if (data) req.write(data);
    req.end();
  });
}

async function uploadFile(filePath) {
  const fullPath = path.join(__dirname, "..", filePath);
  const content  = fs.readFileSync(fullPath);
  const encoded  = content.toString("base64");
  const endpoint = `/repos/${OWNER}/${REPO}/contents/${filePath}`;

  let sha;
  try {
    const existing = await githubRequest("GET", endpoint);
    sha = existing.sha;
  } catch (_) {}

  const body = {
    message: `update: ${filePath}`,
    content: encoded,
    branch: BRANCH,
    ...(sha ? { sha } : {}),
  };

  const result = await githubRequest("PUT", endpoint, body);

  if (result.commit) {
    console.log(`✅ ${filePath} — commit ${result.commit.sha.slice(0, 7)}`);
  } else {
    console.error(`❌ ${filePath} — ${result.message || JSON.stringify(result)}`);
  }
}

(async () => {
  console.log(`📤 กำลังอัปโหลดไปที่ ${OWNER}/${REPO} ...\n`);
  for (const f of FILES) {
    await uploadFile(f);
  }
  console.log("\n🎉 เสร็จแล้ว!");
})();
