# Key Hub (Zero Budget MVP)

ระบบ Key สำหรับ Script Hub ใช้ฟรีทั้งหมด:
- **Supabase** = Database
- **Vercel** = API + หน้าเว็บ
- **GitHub** = เก็บโค้ด

## โครงสร้าง

```
key-hub/
  api/                 # API endpoints (Vercel serverless)
  public/index.html    # หน้ารับ Key
  scripts/loader.lua   # Loader สำหรับ executor
  scripts/main.lua     # ตัวอย่าง main script
  supabase/schema.sql  # SQL สร้างตาราง
```

## API

| Endpoint | Method | หน้าที่ |
|----------|--------|---------|
| `/api/health` | GET | เช็คว่า server ทำงาน |
| `/api/gate-start` | POST | เริ่ม gate (รอ X วินาที) |
| `/api/generate-key` | POST | สร้าง key หลังรอครบ |
| `/api/verify` | POST | ตรวจ key + hwid |

### Verify body

```json
{
  "key": "HUB-XXXX-XXXX-XXXX",
  "hwid": "executor-hwid"
}
```

### Generate key (public)

```json
{
  "challenge_id": "uuid-from-gate-start"
}
```

### Generate key (admin)

```http
POST /api/generate-key
Authorization: Bearer YOUR_ADMIN_SECRET
```

## ติดตั้ง (ครั้งแรก)

### 1) Supabase

1. สมัคร https://supabase.com
2. สร้าง Project ใหม่
3. ไปที่ **SQL Editor** แล้วรันไฟล์ `supabase/schema.sql`
4. คัดลอกค่า:
   - Project URL → `SUPABASE_URL`
   - service_role key → `SUPABASE_SERVICE_ROLE_KEY`

### 2) ตั้งค่า .env

```bash
cd key-hub
copy .env.example .env
```

แก้ค่าใน `.env` ให้ครบ

### 3) รันทดสอบบนเครื่อง

```bash
npm install
npm install dotenv --save-dev
node scripts/local-server.js
```

เปิด http://localhost:3000

### 4) Deploy ฟรีบน Vercel

```bash
npm i -g vercel
vercel login
vercel
```

ตั้ง Environment Variables ใน Vercel Dashboard ให้เหมือน `.env`

จากนั้น deploy production:

```bash
vercel --prod
```

### 5) ตั้งค่า Loader

แก้ `scripts/loader.lua`:

```lua
local API_URL = "https://your-project.vercel.app/api/verify"
```

อัปโหลด `scripts/main.lua` ไป GitHub Gist / repo แล้วใส่ URL ใน `SCRIPT_URL`

## เปลี่ยนจาก Gate จำลอง → Ad จริง

ตอนนี้หน้าเว็บใช้ระบบรอ 15 วินาทีแทน ad (ฟรี ไม่ต้องมีทุน)

เมื่อพร้อม ให้เปลี่ยน flow ใน `public/index.html`:
- ปุ่ม "เริ่มรับ Key" → เปิดลิงก์ Work.ink / Linkvertise
- หลังทำ ad ครบ redirect กลับมาพร้อม token
- เรียก `/api/generate-key` โดยส่ง token แทน `challenge_id`

## จัดการ Key

ใช้ Supabase Table Editor:
- ปิด key: ตั้ง `is_active = false`
- ดูวันหมดอายุ: คอลัมน์ `expires_at`
- รีเซ็ต HWID: ลบค่าใน `hwid`

## หมายเหตุ

- อย่า commit ไฟล์ `.env`
- อย่าแชร์ `SUPABASE_SERVICE_ROLE_KEY`
- Script hub ใน Roblox อาจขัด Terms of Service ของ Roblox
