--[[
  Script Hub — Main UI
  1) แก้ API_VERIFY_URL ให้ตรงกับ server ของคุณ
  2) รันไฟล์นี้ใน executor โดยตรง หรือผ่าน loader.lua
]]

-- ============ CONFIG ============
-- หลัง deploy Vercel แล้ว แก้ 2 บรรทัดนี้ให้ตรง URL จริง (เช่น https://key-hub-xxx.vercel.app)
local API_VERIFY_URL = "https://key-hub.vercel.app/api/verify"
local KEY_PAGE_URL = "https://key-hub.vercel.app"

local HUB_NAME = "Script Hub"

local SCRIPTS = {
	{
		name = "Universal Aimbot",
		desc = "ตัวอย่างสคริปต์ — แก้เป็น URL จริงของคุณ",
		url = nil,
		run = function()
			print("[Hub] Universal Aimbot loaded (demo)")
		end,
	},
	{
		name = "ESP Player",
		desc = "ตัวอย่างสคริปต์ — แก้เป็น URL จริงของคุณ",
		url = nil,
		run = function()
			print("[Hub] ESP Player loaded (demo)")
		end,
	},
	{
		name = "Auto Farm",
		desc = "ตัวอย่างสคริปต์ — แก้เป็น URL จริงของคุณ",
		url = nil,
		run = function()
			print("[Hub] Auto Farm loaded (demo)")
		end,
	},
}
-- ================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ---------- API helpers ----------

local function getHwid()
	if gethwid then
		return tostring(gethwid())
	end
	if syn and syn.get_hwid then
		return tostring(syn.get_hwid())
	end
	return HttpService:GenerateGUID(false)
end

local function httpRequest(options)
	if request then
		return request(options)
	end
	if syn and syn.request then
		return syn.request(options)
	end
	if http and http.request then
		return http.request(options)
	end
	return nil
end

local function verifyKey(key)
	local hwid = getHwid()
	local body = HttpService:JSONEncode({ key = key, hwid = hwid })

	local response = httpRequest({
		Url = API_VERIFY_URL,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = body,
	})

	if not response or not response.Body then
		return false, "เชื่อมต่อ server ไม่ได้"
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(response.Body)
	end)

	if not ok or not data then
		return false, "ข้อมูลจาก server ผิดรูปแบบ"
	end

	if data.valid then
		return true, data.message or "ยืนยัน Key สำเร็จ", data.expires_at
	end

	local msg = data.message or "Key ไม่ถูกต้อง"
	if msg == "Invalid key" then
		msg = "Key ไม่ถูกต้อง"
	elseif msg == "Key expired" then
		msg = "Key หมดอายุแล้ว กรุณารับ Key ใหม่จากเว็บ"
	elseif msg == "HWID mismatch" then
		msg = "Key นี้ถูกใช้บนเครื่องอื่นแล้ว"
	elseif msg == "Key is disabled" then
		msg = "Key ถูกปิดการใช้งาน"
	end

	return false, msg
end

-- ---------- UI helpers ----------

local COLORS = {
	bg = Color3.fromRGB(11, 16, 32),
	card = Color3.fromRGB(20, 27, 45),
	accent = Color3.fromRGB(108, 140, 255),
	accent2 = Color3.fromRGB(79, 209, 197),
	text = Color3.fromRGB(232, 238, 252),
	muted = Color3.fromRGB(154, 167, 199),
	danger = Color3.fromRGB(255, 107, 107),
	ok = Color3.fromRGB(81, 207, 102),
	border = Color3.fromRGB(40, 50, 80),
}

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COLORS.border
	s.Thickness = thickness or 1
	s.Transparency = 0.4
	s.Parent = parent
	return s
end

local function padding(parent, t, r, b, l)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t)
	p.PaddingRight = UDim.new(0, r)
	p.PaddingBottom = UDim.new(0, b)
	p.PaddingLeft = UDim.new(0, l)
	p.Parent = parent
	return p
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamMedium
	l.TextColor3 = COLORS.text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	for k, v in pairs(props) do
		l[k] = v
	end
	l.Parent = parent
	return l
end

local function button(parent, props)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = COLORS.text
	b.BackgroundColor3 = COLORS.accent
	for k, v in pairs(props) do
		b[k] = v
	end
	corner(b, 10)
	b.Parent = parent

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(130, 155, 255),
		}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {
			BackgroundColor3 = b.Name == "Primary" and COLORS.accent or COLORS.card,
		}):Play()
	end)

	return b
end

local function destroyOldGui()
	local old = playerGui:FindFirstChild("KeyHubGui")
	if old then
		old:Destroy()
	end
end

-- ---------- Build UI ----------

destroyOldGui()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyHubGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromOffset(420, 500)
root.BackgroundColor3 = COLORS.card
root.BorderSizePixel = 0
root.Active = true
root.Parent = screenGui
corner(root, 18)
stroke(root, COLORS.accent, 1.2)

-- drag
local dragging, dragStart, startPos
root.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = root.Position
	end
end)
root.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		root.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local closeBtn = button(root, {
	Size = UDim2.fromOffset(30, 30),
	Position = UDim2.new(1, -40, 0, 10),
	BackgroundColor3 = COLORS.card,
	Text = "X",
	TextSize = 16,
})
stroke(closeBtn, COLORS.danger, 1)
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- ===== KEY SCREEN =====

local keyScreen = Instance.new("Frame")
keyScreen.Name = "KeyScreen"
keyScreen.Size = UDim2.fromScale(1, 1)
keyScreen.BackgroundTransparency = 1
keyScreen.Parent = root
padding(keyScreen, 28, 28, 28, 28)

label(keyScreen, {
	Size = UDim2.new(1, 0, 0, 36),
	Text = HUB_NAME,
	TextSize = 26,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Center,
})

label(keyScreen, {
	Position = UDim2.fromOffset(0, 44),
	Size = UDim2.new(1, 0, 0, 40),
	Text = "กรอก Key ที่รับจากเว็บ",
	TextSize = 14,
	TextColor3 = COLORS.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
})

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Position = UDim2.fromOffset(0, 100)
keyBox.Size = UDim2.new(1, 0, 0, 46)
keyBox.BackgroundColor3 = Color3.fromRGB(13, 20, 36)
keyBox.TextColor3 = COLORS.accent2
keyBox.PlaceholderText = "HUB-XXXX-XXXX-XXXX"
keyBox.PlaceholderColor3 = COLORS.muted
keyBox.Font = Enum.Font.Code
keyBox.TextSize = 15
keyBox.ClearTextOnFocus = false
keyBox.Text = ""
keyBox.Parent = keyScreen
corner(keyBox, 10)
stroke(keyBox, COLORS.border, 1)
padding(keyBox, 0, 12, 0, 12)

local statusLabel = label(keyScreen, {
	Position = UDim2.fromOffset(0, 156),
	Size = UDim2.new(1, 0, 0, 36),
	Text = " ",
	TextSize = 13,
	TextColor3 = COLORS.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
})

local verifyBtn = button(keyScreen, {
	Name = "Primary",
	Position = UDim2.fromOffset(0, 204),
	Size = UDim2.new(1, 0, 0, 46),
	Text = "ยืนยัน Key",
	TextSize = 16,
})

local webHint = label(keyScreen, {
	Position = UDim2.new(0, 0, 1, -48),
	Size = UDim2.new(1, 0, 0, 40),
	Text = "ยังไม่มี Key? เปิดเว็บรับ Key ก่อน",
	TextSize = 12,
	TextColor3 = COLORS.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
})

-- ===== HUB SCREEN (hidden) =====

local hubScreen = Instance.new("Frame")
hubScreen.Name = "HubScreen"
hubScreen.Size = UDim2.fromScale(1, 1)
hubScreen.BackgroundTransparency = 1
hubScreen.Visible = false
hubScreen.Parent = root
padding(hubScreen, 24, 24, 24, 24)

label(hubScreen, {
	Size = UDim2.new(1, 0, 0, 30),
	Text = HUB_NAME,
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local welcomeLabel = label(hubScreen, {
	Position = UDim2.fromOffset(0, 34),
	Size = UDim2.new(1, 0, 0, 22),
	Text = "ยินดีต้อนรับ!",
	TextSize = 13,
	TextColor3 = COLORS.ok,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local expireLabel = label(hubScreen, {
	Position = UDim2.fromOffset(0, 56),
	Size = UDim2.new(1, 0, 0, 18),
	Text = "",
	TextSize = 11,
	TextColor3 = COLORS.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local scriptList = Instance.new("ScrollingFrame")
scriptList.Name = "ScriptList"
scriptList.Position = UDim2.fromOffset(0, 88)
scriptList.Size = UDim2.new(1, 0, 1, -130)
scriptList.BackgroundTransparency = 1
scriptList.BorderSizePixel = 0
scriptList.ScrollBarThickness = 4
scriptList.CanvasSize = UDim2.fromOffset(0, 0)
scriptList.AutomaticCanvasSize = Enum.AutomaticSize.Y
scriptList.Parent = hubScreen

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scriptList

local logoutBtn = button(hubScreen, {
	Position = UDim2.new(0, 0, 1, -38),
	Size = UDim2.new(1, 0, 0, 36),
	Text = "ออกจากระบบ",
	TextSize = 14,
	BackgroundColor3 = Color3.fromRGB(31, 41, 66),
})

-- ---------- Logic ----------

local function setStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color or COLORS.muted
end

local function showHub(expiresAt)
	keyScreen.Visible = false
	hubScreen.Visible = true
	root.Size = UDim2.fromOffset(420, 520)

	if expiresAt then
		expireLabel.Text = "Key หมดอายุ: " .. tostring(expiresAt)
	end

	for i, scriptInfo in ipairs(SCRIPTS) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -4, 0, 72)
		card.BackgroundColor3 = Color3.fromRGB(13, 20, 36)
		card.BorderSizePixel = 0
		card.LayoutOrder = i
		card.Parent = scriptList
		corner(card, 12)
		stroke(card, COLORS.border, 1)
		padding(card, 12, 12, 12, 12)

		label(card, {
			Size = UDim2.new(1, -90, 0, 22),
			Text = scriptInfo.name,
			TextSize = 15,
			Font = Enum.Font.GothamBold,
		})

		label(card, {
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, -90, 0, 32),
			Text = scriptInfo.desc,
			TextSize = 11,
			TextColor3 = COLORS.muted,
			TextWrapped = true,
		})

		local loadBtn = button(card, {
			Position = UDim2.new(1, -76, 0.5, -16),
			Size = UDim2.fromOffset(72, 32),
			Text = "โหลด",
			TextSize = 13,
			BackgroundColor3 = COLORS.accent2,
		})
		loadBtn.TextColor3 = Color3.fromRGB(10, 20, 30)

		loadBtn.MouseButton1Click:Connect(function()
			loadBtn.Text = "..."
			loadBtn.AutoButtonColor = false

			task.spawn(function()
				local ok, err = pcall(function()
					if scriptInfo.url then
						local src
						if game.HttpGet then
							src = game:HttpGet(scriptInfo.url)
						else
							local res = httpRequest({ Url = scriptInfo.url, Method = "GET" })
							src = res and res.Body
						end
						if not src then
							error("โหลดสคริปต์ไม่ได้")
						end
						local fn, loadErr = loadstring(src)
						if not fn then
							error(loadErr)
						end
						fn()
					elseif scriptInfo.run then
						scriptInfo.run()
					end
				end)

				loadBtn.Text = ok and "✓" or "!"
				task.wait(1.2)
				loadBtn.Text = "โหลด"

				if not ok then
					warn("[Hub] " .. scriptInfo.name .. ": " .. tostring(err))
				end
			end)
		end)
	end
end

verifyBtn.MouseButton1Click:Connect(function()
	local key = string.gsub(keyBox.Text, "^%s*(.-)%s*$", "%1")
	if key == "" then
		setStatus("กรุณากรอก Key", COLORS.danger)
		return
	end

	verifyBtn.Text = "กำลังตรวจสอบ..."
	verifyBtn.AutoButtonColor = false
	setStatus("กำลังเชื่อมต่อ server...", COLORS.muted)

	task.spawn(function()
		local ok, msg, expiresAt = verifyKey(key)
		verifyBtn.Text = "ยืนยัน Key"

		if ok then
			setStatus("ยืนยัน Key สำเร็จ!", COLORS.ok)
			task.wait(0.4)
			showHub(expiresAt)
		else
			setStatus(msg, COLORS.danger)
		end
	end)
end)

keyBox.FocusLost:Connect(function(enter)
	if enter then
		verifyBtn:Activate()
	end
end)

logoutBtn.MouseButton1Click:Connect(function()
	for _, child in ipairs(scriptList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	hubScreen.Visible = false
	keyScreen.Visible = true
	root.Size = UDim2.fromOffset(420, 500)
	keyBox.Text = ""
	setStatus(" ", COLORS.muted)
end)

print("[" .. HUB_NAME .. "] UI loaded — กรอก Key เพื่อเข้าใช้งาน")
