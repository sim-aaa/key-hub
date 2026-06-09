--[[
  Key Hub Loader (ตัวบootstrap)
  โหลด main.lua แล้วรัน — ระบบกรอก Key อยู่ใน main.lua แล้ว
  แก้ MAIN_SCRIPT_URL ให้ตรงกับที่โฮสต์ main.lua
]]

local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/sim-aaa/key-hub/main/scripts/main.lua"
-- ถ้าทดสอบบนเครื่อง อาจใช้ ngrok หรือ deploy ก่อน

local function notify(title, text)
	if rconsoleprint then
		rconsoleprint("\n[" .. title .. "] " .. text .. "\n")
	end
	print("[" .. title .. "] " .. text)
end

local function httpGet(url)
	if game.HttpGet then
		return game:HttpGet(url)
	end
	if request then
		local res = request({ Url = url, Method = "GET" })
		return res and res.Body
	end
	if syn and syn.request then
		local res = syn.request({ Url = url, Method = "GET" })
		return res and res.Body
	end
	return nil
end

notify("Key Hub", "Loading main script...")
local source = httpGet(MAIN_SCRIPT_URL .. "?t=" .. tostring(math.random(1, 999999)))

if not source then
	notify("Error", "โหลด main.lua ไม่ได้ — ตรวจ MAIN_SCRIPT_URL")
	return
end

local fn, err = loadstring(source)
if not fn then
	notify("Error", "loadstring failed: " .. tostring(err))
	return
end

fn()
notify("Key Hub", "Main script started")
