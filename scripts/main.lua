-- OBFUSCATED BUILD (fallback minify)
-- Set LUA_OBFUSCATOR_CMD to use an external obfuscator.

local API_VERIFY_URL ="https://key-hub-three.vercel.app/api/verify" local KEY_PAGE_URL ="https://key-hub-three.vercel.app" local HUB_NAME ="Script Hub" local SCRIPTS ={{name ="Monster Bring",desc ="ดึงมอนสเตอร์มาหาตัวละครของคุณ รองรับ Anti-Kick",isToggle =true,enabled =false,onToggle =function(self,state)_G.MonsterBringEnabled =state return state end },}
local Players =game:GetService("Players")local HttpService =game:GetService("HttpService")local TweenService =game:GetService("TweenService")local UserInputService =game:GetService("UserInputService")local RunService =game:GetService("RunService")local player =Players.LocalPlayer local playerGui =player:WaitForChild("PlayerGui")
if _G.MonsterBringHeartbeat then _G.MonsterBringHeartbeat:Disconnect()_G.MonsterBringHeartbeat =nil end _G.MonsterBringEnabled =false local currentSession ={}_G.MonsterBringSession =currentSession 
local monsterCache ={}local MAX_TARGETS =12 local function updateMonsterCache()if not _G.MonsterBringEnabled then return end table.clear(monsterCache)local counter =0 for _,obj in ipairs(workspace:GetDescendants())do if counter >=MAX_TARGETS then break end if obj:IsA("Model")and obj ~=player.Character and obj:FindFirstChild("Humanoid")then if not Players:GetPlayerFromCharacter(obj)then local hum =obj:FindFirstChildOfClass("Humanoid")local rootPart =obj:FindFirstChild("HumanoidRootPart")or obj:FindFirstChild("Torso")if hum and rootPart and hum.Health >0 then table.insert(monsterCache,{part =rootPart,hum =hum})counter =counter +1 end end end end end 
_G.MonsterBringHeartbeat =RunService.Heartbeat:Connect(function()if _G.MonsterBringEnabled then local myChar =player.Character local myRoot =myChar and (myChar:FindFirstChild("HumanoidRootPart")or myChar:FindFirstChild("Torso"))if myRoot then if not myRoot:FindFirstChild("AntiGravity")then local bv =Instance.new("BodyVelocity")bv.Name ="AntiGravity" bv.Velocity =Vector3.new(0,0,0)bv.MaxForce =Vector3.new(0,math.huge,0)bv.Parent =myRoot end end else local myChar =player.Character local myRoot =myChar and (myChar:FindFirstChild("HumanoidRootPart")or myChar:FindFirstChild("Torso"))if myRoot and myRoot:FindFirstChild("AntiGravity")then myRoot.AntiGravity:Destroy()end end end)
task.spawn(function()while _G.MonsterBringSession ==currentSession do task.wait(2.0)if _G.MonsterBringEnabled then updateMonsterCache()end end end)
task.spawn(function()while _G.MonsterBringSession ==currentSession do task.wait(0.15)if _G.MonsterBringEnabled then local myChar =player.Character local myRoot =myChar and (myChar:FindFirstChild("HumanoidRootPart")or myChar:FindFirstChild("Torso"))if myRoot then local basePosition =myRoot.CFrame *CFrame.new(0,-6,-5)for i =#monsterCache,1,-1 do local monster =monsterCache[i]
local part = monster.part
local hum = monster.hum
if part and part.Parent and hum and hum.Health > 0 then
local randomOffset = Vector3.new(math.random(-10, 10)/10, 0, math.random(-10, 10)/10)
part.CFrame = CFrame.lookAt(basePosition.Position + randomOffset, basePosition.Position + myRoot.CFrame.LookVector)
part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
if hum.WalkSpeed ~= 0 then
hum.WalkSpeed = 0
end
else
table.remove(monsterCache, i)
end
end
end
end
end
end)

-- ---------- HTTP helper (Xeno / Delta / Synapse / KRNL) ----------

local function httpRequest(options)
if http_request then return http_request(options) end
if request then return request(options) end
if syn and syn.request then return syn.request(options) end
if http and http.request then return http.request(options) end
return nil
end

local function httpGet(url)
if syn and syn.request then
local res = syn.request({ Url = url, Method = "GET" })
return res and res.Body
end
if http_request then
local res = http_request({ Url = url, Method = "GET" })
return res and res.Body
end
if request then
local res = request({ Url = url, Method = "GET" })
return res and res.Body
end
if http and http.request then
local res = http.request({ Url = url, Method = "GET" })
return res and res.Body
end
return nil
end

-- ---------- HWID ----------

local function getHwid()
if gethwid then return tostring(gethwid()) end
if syn and syn.get_hwid then return tostring(syn.get_hwid()) end
return HttpService:GenerateGUID(false)
end

-- ---------- Verify Key ----------

local function verifyKey(key)
local hwid = getHwid()
local body = HttpService:JSONEncode({ key = key, hwid = hwid })

local response = httpRequest({
Url = API_VERIFY_URL,
Method = "POST",
Headers = { ["Content-Type"]="application/json" },Body =body,})if not response or not response.Body then return false,"เชื่อมต่อ server ไม่ได้",nil end local ok,data =pcall(HttpService.JSONDecode,HttpService,response.Body)if not ok or type(data)~="table" then return false,"ข้อมูลจาก server ผิดรูปแบบ",nil end if data.valid then return true,data.message or "ยืนยัน Key สำเร็จ",data.script_url,data.expires_at end local msg =data.message or "Key ไม่ถูกต้อง" if msg =="Invalid key" then msg ="Key ไม่ถูกต้อง" elseif msg =="Key expired" then msg ="Key หมดอายุแล้ว กรุณารับ Key ใหม่จากเว็บ" elseif msg =="HWID mismatch" then msg ="Key นี้ถูกใช้บนเครื่องอื่นแล้ว" elseif msg =="Key is disabled" then msg ="Key ถูกปิดการใช้งาน" end return false,msg,nil,nil end 
local COLORS ={bg =Color3.fromRGB(11,16,32),card =Color3.fromRGB(20,27,45),accent =Color3.fromRGB(108,140,255),accent2 =Color3.fromRGB(79,209,197),text =Color3.fromRGB(232,238,252),muted =Color3.fromRGB(154,167,199),danger =Color3.fromRGB(255,107,107),ok =Color3.fromRGB(81,207,102),border =Color3.fromRGB(40,50,80),}local function corner(parent,radius)local c =Instance.new("UICorner")c.CornerRadius =UDim.new(0,radius)c.Parent =parent return c end local function stroke(parent,color,thickness)local s =Instance.new("UIStroke")s.Color =color or COLORS.border s.Thickness =thickness or 1 s.Transparency =0.4 s.Parent =parent return s end local function padding(parent,t,r,b,l)local p =Instance.new("UIPadding")p.PaddingTop =UDim.new(0,t)p.PaddingRight =UDim.new(0,r)p.PaddingBottom =UDim.new(0,b)p.PaddingLeft =UDim.new(0,l)p.Parent =parent return p end local function label(parent,props)local lbl =Instance.new("TextLabel")lbl.BackgroundTransparency =1 lbl.Font =Enum.Font.GothamMedium lbl.TextColor3 =COLORS.text lbl.TextXAlignment =Enum.TextXAlignment.Left lbl.TextYAlignment =Enum.TextYAlignment.Center for k,v in pairs(props)do lbl[k] = v end
lbl.Parent = parent
return lbl
end

local function button(parent, props)
local btn = Instance.new("TextButton")
btn.AutoButtonColor = false
btn.Font = Enum.Font.GothamBold
btn.TextColor3 = COLORS.text
btn.BackgroundColor3 = COLORS.accent
btn.Active = true
btn.Selectable = true
for k, v in pairs(props) do btn[k]=v end corner(btn,10)btn.Parent =parent local baseColor =props.BackgroundColor3 or COLORS.accent btn:SetAttribute("BaseColor",baseColor)btn.MouseEnter:Connect(function()local currentBase =btn:GetAttribute("BaseColor")or baseColor local r =math.min(currentBase.R +0.12,1)local g =math.min(currentBase.G +0.12,1)local b =math.min(currentBase.B +0.12,1)TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3 =Color3.new(r,g,b),}):Play()end)btn.MouseLeave:Connect(function()local currentBase =btn:GetAttribute("BaseColor")or baseColor TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3 =currentBase,}):Play()end)return btn end 
local old =playerGui:FindFirstChild("KeyHubGui")if old then old:Destroy()end local screenGui =Instance.new("ScreenGui")screenGui.Name ="KeyHubGui" screenGui.ResetOnSpawn =false screenGui.ZIndexBehavior =Enum.ZIndexBehavior.Sibling screenGui.DisplayOrder =999 screenGui.Parent =playerGui local root =Instance.new("Frame")root.Name ="Root" root.AnchorPoint =Vector2.new(0.5,0.5)root.Position =UDim2.fromScale(0.5,0.5)root.Size =UDim2.fromOffset(420,500)root.BackgroundColor3 =COLORS.card root.BorderSizePixel =0 root.Active =true root.Parent =screenGui corner(root,18)stroke(root,COLORS.accent,1.2)
local dragging,dragStart,startPos root.InputBegan:Connect(function(input)if input.UserInputType ==Enum.UserInputType.MouseButton1 then dragging =true dragStart =input.Position startPos =root.Position end end)root.InputEnded:Connect(function(input)if input.UserInputType ==Enum.UserInputType.MouseButton1 then dragging =false end end)UserInputService.InputChanged:Connect(function(input)if dragging and input.UserInputType ==Enum.UserInputType.MouseMovement then local delta =input.Position -dragStart root.Position =UDim2.new(startPos.X.Scale,startPos.X.Offset +delta.X,startPos.Y.Scale,startPos.Y.Offset +delta.Y )end end)local closeBtn =button(root,{Size =UDim2.fromOffset(30,30),Position =UDim2.new(1,-40,0,10),BackgroundColor3 =COLORS.card,Text ="X",TextSize =16,})stroke(closeBtn,COLORS.danger,1)closeBtn.MouseButton1Click:Connect(function()screenGui:Destroy()end)
local keyScreen =Instance.new("Frame")keyScreen.Name ="KeyScreen" keyScreen.Size =UDim2.fromScale(1,1)keyScreen.BackgroundTransparency =1 keyScreen.Parent =root padding(keyScreen,28,28,28,28)label(keyScreen,{Size =UDim2.new(1,0,0,36),Text =HUB_NAME,TextSize =26,Font =Enum.Font.GothamBold,TextXAlignment =Enum.TextXAlignment.Center,})label(keyScreen,{Position =UDim2.fromOffset(0,44),Size =UDim2.new(1,0,0,40),Text ="กรอก Key ที่รับจากเว็บ",TextSize =14,TextColor3 =COLORS.muted,TextXAlignment =Enum.TextXAlignment.Center,TextWrapped =true,})local keyBox =Instance.new("TextBox")keyBox.Position =UDim2.fromOffset(0,100)keyBox.Size =UDim2.new(1,0,0,46)keyBox.BackgroundColor3 =Color3.fromRGB(13,20,36)keyBox.TextColor3 =COLORS.accent2 keyBox.PlaceholderText ="HUB-XXXX-XXXX-XXXX" keyBox.PlaceholderColor3 =COLORS.muted keyBox.Font =Enum.Font.Code keyBox.TextSize =15 keyBox.ClearTextOnFocus =false keyBox.Text ="" keyBox.Parent =keyScreen corner(keyBox,10)stroke(keyBox,COLORS.border,1)padding(keyBox,0,12,0,12)local statusLabel =label(keyScreen,{Position =UDim2.fromOffset(0,156),Size =UDim2.new(1,0,0,36),Text =" ",TextSize =13,TextColor3 =COLORS.muted,TextXAlignment =Enum.TextXAlignment.Center,TextWrapped =true,})local verifyBtn =button(keyScreen,{Name ="Primary",Position =UDim2.fromOffset(0,204),Size =UDim2.new(1,0,0,46),Text ="ยืนยัน Key",TextSize =16,})label(keyScreen,{Position =UDim2.new(0,0,1,-48),Size =UDim2.new(1,0,0,40),Text ="ยังไม่มี Key? เปิดเว็บรับ Key ก่อน → " .. KEY_PAGE_URL,TextSize =11,TextColor3 =COLORS.muted,TextXAlignment =Enum.TextXAlignment.Center,TextWrapped =true,})local openKeyBtn =button(keyScreen,{Position =UDim2.fromOffset(0,244),Size =UDim2.new(1,0,0,36),Text ="เปิดเว็บรับ Key",TextSize =13,BackgroundColor3 =COLORS.accent2,})openKeyBtn.MouseButton1Click:Connect(function()if setclipboard then pcall(setclipboard,KEY_PAGE_URL)setStatus("ลิงก์เว็บถูกคัดลอกไปยังคลิปบอร์ด",COLORS.ok)else setStatus("เปิดเว็บด้วยเบราว์เซอร์: " .. KEY_PAGE_URL,COLORS.muted)end end)
local hubScreen =Instance.new("Frame")hubScreen.Name ="HubScreen" hubScreen.Size =UDim2.fromScale(1,1)hubScreen.BackgroundTransparency =1 hubScreen.Visible =false hubScreen.Parent =root padding(hubScreen,24,24,24,24)label(hubScreen,{Size =UDim2.new(1,0,0,30),Text =HUB_NAME,TextSize =22,Font =Enum.Font.GothamBold,TextXAlignment =Enum.TextXAlignment.Center,})label(hubScreen,{Position =UDim2.fromOffset(0,34),Size =UDim2.new(1,0,0,22),Text ="ยินดีต้อนรับ!",TextSize =13,TextColor3 =COLORS.ok,TextXAlignment =Enum.TextXAlignment.Center,})local expireLabel =label(hubScreen,{Position =UDim2.fromOffset(0,56),Size =UDim2.new(1,0,0,18),Text ="",TextSize =11,TextColor3 =COLORS.muted,TextXAlignment =Enum.TextXAlignment.Center,})local scriptList =Instance.new("ScrollingFrame")scriptList.Position =UDim2.fromOffset(0,88)scriptList.Size =UDim2.new(1,0,1,-130)scriptList.BackgroundTransparency =1 scriptList.BorderSizePixel =0 scriptList.ScrollBarThickness =4 scriptList.CanvasSize =UDim2.fromOffset(0,0)scriptList.AutomaticCanvasSize =Enum.AutomaticSize.Y scriptList.ZIndex =2 scriptList.Parent =hubScreen local listLayout =Instance.new("UIListLayout")listLayout.Padding =UDim.new(0,10)listLayout.SortOrder =Enum.SortOrder.LayoutOrder listLayout.Parent =scriptList local logoutBtn =button(hubScreen,{Position =UDim2.new(0,0,1,-38),Size =UDim2.new(1,0,0,36),Text ="ออกจากระบบ",TextSize =14,BackgroundColor3 =Color3.fromRGB(31,41,66),})
local function setStatus(text,color)statusLabel.Text =text statusLabel.TextColor3 =color or COLORS.muted end local function showHub(expiresAt)keyScreen.Visible =false hubScreen.Visible =true root.Size =UDim2.fromOffset(420,520)if expiresAt then expireLabel.Text ="Key หมดอายุ: " .. tostring(expiresAt):sub(1,10)end for i,scriptInfo in ipairs(SCRIPTS)do local card =Instance.new("Frame")card.Size =UDim2.new(1,-4,0,72)card.BackgroundColor3 =Color3.fromRGB(13,20,36)card.BorderSizePixel =0 card.LayoutOrder =i card.ZIndex =3 card.Parent =scriptList corner(card,12)stroke(card,COLORS.border,1)padding(card,12,12,12,12)label(card,{Size =UDim2.new(1,-90,0,22),Text =scriptInfo.name,TextSize =15,Font =Enum.Font.GothamBold,ZIndex =4,})label(card,{Position =UDim2.fromOffset(0,24),Size =UDim2.new(1,-90,0,32),Text =scriptInfo.desc,TextSize =11,TextColor3 =COLORS.muted,TextWrapped =true,ZIndex =4,})local loadBtn if scriptInfo.isToggle then loadBtn =button(card,{Position =UDim2.new(1,-76,0.5,-16),Size =UDim2.fromOffset(72,32),Text =scriptInfo.enabled and "เปิด" or "ปิด",TextSize =13,BackgroundColor3 =scriptInfo.enabled and COLORS.ok or Color3.fromRGB(80,80,80),ZIndex =5,})if scriptInfo.enabled then loadBtn.TextColor3 =Color3.fromRGB(10,20,30)end loadBtn.Activated:Connect(function()scriptInfo.enabled =not scriptInfo.enabled scriptInfo:onToggle(scriptInfo.enabled)loadBtn.Text =scriptInfo.enabled and "เปิด" or "ปิด" local targetColor =scriptInfo.enabled and COLORS.ok or Color3.fromRGB(80,80,80)loadBtn:SetAttribute("BaseColor",targetColor)TweenService:Create(loadBtn,TweenInfo.new(0.2),{BackgroundColor3 =targetColor,}):Play()if scriptInfo.enabled then TweenService:Create(loadBtn,TweenInfo.new(0.2),{TextColor3 =Color3.fromRGB(10,20,30),}):Play()else TweenService:Create(loadBtn,TweenInfo.new(0.2),{TextColor3 =COLORS.text,}):Play()end end)else loadBtn =button(card,{Position =UDim2.new(1,-76,0.5,-16),Size =UDim2.fromOffset(72,32),Text ="โหลด",TextSize =13,BackgroundColor3 =COLORS.accent2,ZIndex =5,})loadBtn.TextColor3 =Color3.fromRGB(10,20,30)loadBtn.Activated:Connect(function()loadBtn.Text ="..." task.spawn(function()local success,err =pcall(function()if scriptInfo.url then local src =httpGet(scriptInfo.url)if not src or src =="" then error("โหลดสคริปต์ไม่ได้ ตรวจ URL")end local fn,loadErr =loadstring(src)if not fn then error(loadErr)end fn()elseif scriptInfo.run then scriptInfo.run()end end)loadBtn.Text =success and "✓" or "!" if not success then warn("[Hub] " .. scriptInfo.name .. ": " .. tostring(err))end task.wait(1.5)loadBtn.Text ="โหลด" end)end)end end end verifyBtn.MouseButton1Click:Connect(function()local key =string.match(keyBox.Text,"^%s*(.-)%s*$")if key =="" then setStatus("กรุณากรอก Key",COLORS.danger)return end verifyBtn.Text ="กำลังตรวจสอบ..." setStatus("กำลังเชื่อมต่อ server...",COLORS.muted)task.spawn(function()local ok,msg,scriptUrl,expiresAt =verifyKey(key)verifyBtn.Text ="ยืนยัน Key" if ok then setStatus("ยืนยัน Key สำเร็จ!",COLORS.ok)task.wait(0.4)showHub(expiresAt)else setStatus(msg,COLORS.danger)end end)end)keyBox.FocusLost:Connect(function(enter)if enter then verifyBtn:Activate()end end)logoutBtn.MouseButton1Click:Connect(function()for _,child in ipairs(scriptList:GetChildren())do if child:IsA("Frame")then child:Destroy()end end hubScreen.Visible =false keyScreen.Visible =true root.Size =UDim2.fromOffset(420,500)keyBox.Text ="" setStatus(" ",COLORS.muted)end)print("[" .. HUB_NAME .. "] UI loaded — กรอก Key เพื่อเข้าใช้งาน")
