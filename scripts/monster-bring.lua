local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local v1 = Players.LocalPlayer

local _G = _G or {}
_G.MonsterBringEnabled = false

------------------------------------------------------------------------
-- [ส่วนเสริมพิเศษ: ระบบล็อคตัวละครลอยฟ้ากลางอากาศ]
------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if _G.MonsterBringEnabled then
        local myChar = v1.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        
        if myRoot then
            if not myRoot:FindFirstChild("AntiGravity") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "AntiGravity"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Parent = myRoot
            end
        end
    else
        local myChar = v1.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if myRoot and myRoot:FindFirstChild("AntiGravity") then
            myRoot.AntiGravity:Destroy()
        end
    end
end)

------------------------------------------------------------------------
-- [ส่วนที่ 1: UI เปิด/ปิด ประสิทธิภาพสูง]
------------------------------------------------------------------------
if CoreGui:FindFirstChild("MonsterBringUI") then
    CoreGui.MonsterBringUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonsterBringUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 160, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "Bring Monster: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    _G.MonsterBringEnabled = not _G.MonsterBringEnabled
    if _G.MonsterBringEnabled then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 180, 50)}):Play()
        ToggleButton.Text = "Bring Monster: ON"
        
        local myChar = v1.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
        if myRoot then
            myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 6, 0)
        end
    else
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        ToggleButton.Text = "Bring Monster: OFF"
    end
end)

------------------------------------------------------------------------
-- [ส่วนที่ 2: ระบบจัดการเป้าหมายแบบกินทรัพยากรต่ำ (Target Caching)]
------------------------------------------------------------------------
local monsterCache = {}
local MAX_TARGETS = 12

local function updateMonsterCache()
    if not _G.MonsterBringEnabled then return end
    table.clear(monsterCache)
    local counter = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if counter >= MAX_TARGETS then break end
        if obj:IsA("Model") and obj ~= v1.Character and obj:FindFirstChild("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if hum and rootPart and hum.Health > 0 then
                    table.insert(monsterCache, {part = rootPart, hum = hum})
                    counter = counter + 1
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2.0)
        if _G.MonsterBringEnabled then
            updateMonsterCache()
        end
    end
end)

------------------------------------------------------------------------
-- [ส่วนที่ 3: ลูปวาร์ปมอนสเตอร์เวอร์ชันเสถียร (Anti-Kick Adjustments)]
------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.15) do
        if _G.MonsterBringEnabled then
            local myChar = v1.Character
            local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
            if myRoot then
                local basePosition = myRoot.CFrame * CFrame.new(0, -6, -5)
                for i = #monsterCache, 1, -1 do
                    local monster = monsterCache[i]
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
