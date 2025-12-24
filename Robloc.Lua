local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Secret Hub | Premium V2",
   LoadingTitle = "Secret Hub Loading...",
   LoadingSubtitle = "by mystery man",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "Secret Hub | Key System",
      Subtitle = "Key: Secret123",
      Note = "Key is: Secret123",
      FileName = "SecretKey",
      SaveKey = true,
      Key = {"Secret123"}
   }
})

-- Services
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Global Config
_G.Config = {
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    InfZoom = false,
    AntiGrab = false,
    Fling = false,
    ESP = false,
    TeleActive = false,    GrabMode = "None",
    GrabRange = 50,
    GrabPower = 500
}

local angle = 0

-- TABS
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AuraTab = Window:CreateTab("Grab Auras", 10952479675)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- ================= PLAYER SETTINGS =================PlayerTab:CreateToggle({
    Name = "Fly (No Falling)",
    CurrentValue = false,
    Callback = function(v) _G.Config.Fly = v end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,    CurrentValue = 50,
    Callback = function(v) _G.Config.FlySpeed = v end,
})

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) _G.Config.WalkSpeed = v end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) _G.Config.JumpPower = v end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Zoom",
    CurrentValue = false,
    Callback = function(v) _G.Config.InfZoom = v end,
})

-- ================= GRAB AURAS =================
AuraTab:CreateDropdown({
    Name = "Aura Mode",
    Options = {"None", "Magnet", "Void", "Kill", "Massive Grab", "Throw", "Space"},
    CurrentOption = "None",
    Callback = function(v) _G.Config.GrabMode = v end,
})

AuraTab:CreateToggle({
    Name = "Telekinesis (Orbit)",
    CurrentValue = false,
    Callback = function(v) _G.Config.TeleActive = v end,
})

AuraTab:CreateSlider({
    Name = "Range",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(v) _G.Config.GrabRange = v end,
})

-- ================= COMBAT =================
CombatTab:CreateToggle({
    Name = "Anti-Grab (Fixed)",
    CurrentValue = false,
    Callback = function(v) _G.Config.AntiGrab = v end,
})

CombatTab:CreateToggle({    Name = "Spin Fling",
    CurrentValue = false,
    Callback = function(v) _G.Config.Fling = v end,
})

-- ================= VISUALS =================
VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(v) 
        _G.Config.ESP = v 
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("SecretESP") then                    p.Character.SecretESP:Destroy()
                end
            end
        end
    end,
})-- ================= CORE LOOP =================
RS.Heartbeat:Connect(function(dt)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- 1. WalkSpeed & JumpPower
    hum.WalkSpeed = _G.Config.WalkSpeed
    hum.JumpPower = _G.Config.JumpPower

    -- 2. Fly (Stable)
    if _G.Config.Fly then
        hum.PlatformStand = true
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        
        hrp.CFrame = hrp.CFrame + (moveDir * _G.Config.FlySpeed * dt)
        hrp.Velocity = Vector3.new(0, 0, 0)
    else
        hum.PlatformStand = false    end

    -- 3. Anti-Grab (Strong)
    if _G.Config.AntiGrab then        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Constraint") or v:IsA("Weld") or v:IsA("ManualWeld") then
                v:Destroy()
            end
        end
    end

    -- 4. Spin Fling
    if _G.Config.Fling then
        hrp.Velocity = Vector3.new(0, 5000, 0)
        hrp.RotVelocity = Vector3.new(0, 10000, 0)
    end

    -- 5. Grab Auras & Telekinesis
    angle = angle + 0.05
    local count = 0
    if _G.Config.GrabMode ~= "None" or _G.Config.TeleActive then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist <= _G.Config.GrabRange then
                    count = count + 1
                    LP.SimulationRadius = 1000 -- Network ownership
                    
                    if _G.Config.TeleActive then
                        local offset = Vector3.new(math.cos(angle + count)*15, 5, math.sin(angle + count)*15)
                        obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(offset), 0.1)
                        obj.Velocity = Vector3.new(0,0,0)
                    elseif _G.Config.GrabMode == "Magnet" then
                        obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
                    elseif _G.Config.GrabMode == "Void" then
                        obj.CFrame = CFrame.new(obj.Position.X, -500, obj.Position.Z)                    elseif _G.Config.GrabMode == "Kill" then
                        obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                        obj.RotVelocity = Vector3.new(0, 10000, 0)
                    elseif _G.Config.GrabMode == "Throw" then
                        obj.Velocity = Camera.CFrame.LookVector * _G.Config.GrabPower
                    end
                end
            end
        end
    end

    -- 6. ESP (Clean)
    if _G.Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("SecretESP") then
                    local hl = Instance.new("Highlight")                    hl.Name = "SecretESP"
                    hl.Parent = p.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end

    if _G.Config.InfZoom then LP.CameraMaxZoomDistance = 100000 end
end)

Rayfield:Notify({Title = "Secret Hub", Content = "Loaded & Fixed!", Duration = 5})
