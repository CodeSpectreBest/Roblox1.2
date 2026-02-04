local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()local Window = Rayfield:CreateWindow({
   Name = "Secret Hub | Premium V2",
   LoadingTitle = "Secret Hub Loading...",
   LoadingSubtitle = "by mystery man",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "Secret Hub | Key System",
      Subtitle = "Key: Secret123",
      Note = "Key is Secret123",
      FileName = "SecretKey",
      SaveKey = true,
      Key = {"Secret123"}
   }
})

-- Ayarlar
local Config = {
    Fly = false,    FlySpeed = 70,
    WalkSpeed = 16,
    JumpPower = 50,
    InfZoom = false,
    AntiGrab = false,
    Fling = false,
    ESP = false,
    TeleActive = false,
    GrabMode = "None",
    GrabRange = 50,
    GrabPower = 500
}

-- Servisler
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- SEKMELER
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AuraTab = Window:CreateTab("Grab Auras", 10952479675)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- ================= PLAYER =================
local FlyToggle = PlayerTab:CreateToggle({    Name = "Fly (Stable) [F]",
    CurrentValue = false,
    Callback = function(v) 
        Config.Fly = v 
        if not v and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 70,
    Callback = function(v) Config.FlySpeed = v end,
})PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) Config.WalkSpeed = v end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) Config.JumpPower = v end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Zoom",
    CurrentValue = false,
    Callback = function(v) Config.InfZoom = v end,
})

-- ================= GRAB AURAS =================
AuraTab:CreateDropdown({
    Name = "Aura Mode",
    Options = {"None", "Magnet", "Void", "Kill", "Massive Grab", "Throw", "Space"},
    CurrentOption = "None",
    Callback = function(v) Config.GrabMode = v end,
})

AuraTab:CreateToggle({
    Name = "Telekinesis (Orbit)",
    CurrentValue = false,
    Callback = function(v) Config.TeleActive = v end,
})AuraTab:CreateSlider({
    Name = "Range",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(v) Config.GrabRange = v end,
})

-- ================= COMBAT =================
CombatTab:CreateToggle({
    Name = "Anti-Grab (Aggressive)",
    CurrentValue = false,
    Callback = function(v) Config.AntiGrab = v end,
})

CombatTab:CreateToggle({
    Name = "Spin Fling",
    CurrentValue = false,
    Callback = function(v) Config.Fling = v end,
})

-- ================= VISUALS =================
VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(v) 
        Config.ESP = v 
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("SecretESP") then
                    p.Character.SecretESP:Destroy()
                end
            end
        end
    end,
})

-- ================= CORE LOGIC =================

-- F Tuşu ile Fly Aç/Kapat
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F then
        Config.Fly = not Config.Fly
        FlyToggle:Set(Config.Fly)
    end
end)

local angle = 0
RS.Heartbeat:Connect(function(dt)
    local char = LP.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        -- Speed & Jump (Normal moddayken)
        if not Config.Fly then
            hum.WalkSpeed = Config.WalkSpeed
            hum.JumpPower = Config.JumpPower
        end

        -- Uçma Mantığı (PlatformStand ile düşme engellenir)
        if Config.Fly then
            hum.PlatformStand = true
            local moveDir = Vector3.new(0,0,0)            
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
            
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.CFrame = hrp.CFrame + (moveDir * Config.FlySpeed * dt)        end

        -- Anti-Grab
        if Config.AntiGrab then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("Constraint") then
                    v:Destroy()
                end
            end
        end

        -- Spin Fling
        if Config.Fling then
            hrp.RotVelocity = Vector3.new(0, 10000, 0)
            hrp.Velocity = Vector3.new(0, 5000, 0)
        end

        -- Grab Auras
        angle = angle + 0.05
        if Config.GrabMode ~= "None" or Config.TeleActive then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("BasePart") and not obj.Anchored then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist <= Config.GrabRange then
                        LP.SimulationRadius = 1000
                        if Config.TeleActive then
                            local x = math.cos(angle) * 15
                            local z = math.sin(angle) * 15
                            obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(x, 5, z), 0.2)
                        elseif Config.GrabMode == "Magnet" then
                            obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
                        elseif Config.GrabMode == "Void" then
                            obj.CFrame = CFrame.new(obj.Position.X, -500, obj.Position.Z)
                        end
                    end
                end            end
        end

        -- ESP
        if Config.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and not p.Character:FindFirstChild("SecretESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "SecretESP"
                    hl.Parent = p.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end

        -- Inf Zoom
        if Config.InfZoom then LP.CameraMaxZoomDistance = 100000 end
    endend)

Rayfield:Notify({Title = "Secret Hub", Content = "Hub Başarıyla Yüklendi!", Duration = 5})
