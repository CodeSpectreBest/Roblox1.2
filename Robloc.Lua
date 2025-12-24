local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Secret Hub | Premium Edition",
   LoadingTitle = "Secret Hub Loading...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = { Enabled = true, Folder = "SecretHubConfigs" },
   KeySystem = false
})

-- SERVİSLERlocal Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- AYARLAR (CONFIG)
local Config = {
    FlyEnabled = false,    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    InfZoom = false,
    AntiGrab = false,
    Fling = false,    FlingPower = 10000,
    -- Grab Auras
    GrabMode = "None",
    GrabRange = 30,
    GrabPower = 100,
    -- Telekinesis
    TeleEnabled = false,
    TeleMode = "Tornado",
    -- Visuals
    ESP = false
}

local flyConnection = nil
local angle = 0

-- SEKMELER
local MainTab = Window:CreateTab("Ana Menü", 4483362458)
local PlayerTab = Window:CreateTab("Oyuncu", 4483362458)
local AuraTab = Window:CreateTab("Grab Auraları", 10952479675)
local CombatTab = Window:CreateTab("Savaş & Fling", 4483362458)
local TeleTab = Window:CreateTab("Telekinesis", 10952479675)
local VisualsTab = Window:CreateTab("Görsel & ESP", 4483362458)

-- ================= OYUNCU SEKMESİ =================
PlayerTab:CreateToggle({
    Name = "Uçma (Fly)",    CurrentValue = false,
    Callback = function(Toggled)
        Config.FlyEnabled = Toggled
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if Toggled then
            if hum then hum.PlatformStand = true end
            flyConnection = runService.RenderStepped:Connect(function(dt)
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
                if moveDir.Magnitude > 0 and hrp then
                    hrp.CFrame = hrp.CFrame + (moveDir.unit * Config.FlySpeed * dt)
                end
                if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if hum then hum.PlatformStand = false end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Hızı",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Config.FlySpeed = v end,
})

PlayerTab:CreateToggle({
    Name = "Sınırsız Zoom",
    CurrentValue = false,
    Callback = function(v) Config.InfZoom = v end,
})

-- ================= GRAB AURAS SEKMESİ =================
AuraTab:CreateDropdown({
    Name = "Aura Modu",
    Options = {"None", "Magnet", "Void", "Kill", "Massive Grab", "Glitch Grab", "Kick Grab", "Throw Grab", "Space Grab"},
    CurrentOption = "None",
    Callback = function(v) Config.GrabMode = v end,
})

AuraTab:CreateSlider({
    Name = "Aura Menzili",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = 30,
    Callback = function(v) Config.GrabRange = v end,
})

AuraTab:CreateSlider({
    Name = "Aura Gücü (Power)",
    Range = {50, 2000},
    Increment = 50,
    CurrentValue = 100,
    Callback = function(v) Config.GrabPower = v end,
})

-- ================= SAVAŞ & FLING SEKMESİ =================
CombatTab:CreateToggle({
    Name = "Anti-Grab (Seni Tutamazlar)",
    CurrentValue = false,
    Callback = function(v) Config.AntiGrab = v end,
})

CombatTab:CreateToggle({
    Name = "Spin Fling (Dokunduğunu Uçur)",
    CurrentValue = false,
    Callback = function(v) Config.Fling = v end,
})

-- ================= TELEKINESIS SEKMESİ =================
TeleTab:CreateToggle({
    Name = "Telekinesis Aktif",
    CurrentValue = false,
    Callback = function(v) Config.TeleEnabled = v end,
})

TeleTab:CreateDropdown({
    Name = "Tele Modu",
    Options = {"Tornado", "Ring"},
    CurrentOption = "Tornado",
    Callback = function(v) Config.TeleMode = v end,
})

-- ================= GÖRSEL (ESP) SEKMESİ =================
VisualsTab:CreateToggle({
    Name = "Oyuncu ESP",
    CurrentValue = false,
    Callback = function(v)
        Config.ESP = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
            end
        end
    end,
})

-- ================= ANA DÖNGÜ (MAIN LOOP) =================
runService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 1. Anti-Grab
    if Config.AntiGrab then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("BallSocketConstraint") then v:Destroy() end
        end
    end

    -- 2. Spin Fling
    if Config.Fling then
        hrp.Velocity = Vector3.new(0, 5000, 0)
        hrp.RotVelocity = Vector3.new(0, Config.FlingPower, 0)
    end

    -- 3. Grab Auras & Telekinesis Logic
    angle = angle + 0.1
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= Config.GrabRange then
                count = count + 1
                
                -- GRAB MODLARI
                if Config.GrabMode == "Magnet" then
                    obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(0, 0, -5), 0.2)
                elseif Config.GrabMode == "Void" then
                    obj.CFrame = CFrame.new(obj.Position.X, -500, obj.Position.Z)
                elseif Config.GrabMode == "Kill" then
                    obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                    obj.RotVelocity = Vector3.new(0, 10000, 0)
                elseif Config.GrabMode == "Massive Grab" then
                    obj.CFrame = hrp.CFrame * CFrame.new(0, 15, 0)
                elseif Config.GrabMode == "Glitch Grab" then                    obj.CFrame = obj.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                    obj.RotVelocity = Vector3.new(500, 500, 500)
                elseif Config.GrabMode == "Kick Grab" then
                    obj.Velocity = (obj.Position - hrp.Position).unit * Config.GrabPower                elseif Config.GrabMode == "Throw Grab" then
                    obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                    obj.Velocity = camera.CFrame.LookVector * Config.GrabPower
                elseif Config.GrabMode == "Space Grab" then
                    obj.Velocity = Vector3.new(0, Config.GrabPower, 0)
                end

                -- TELEKINESIS MODLARI (Eğer Aura None ise çalışır)
                if Config.TeleEnabled and Config.GrabMode == "None" then
                    if Config.TeleMode == "Tornado" then
                        local offset = Vector3.new(math.cos(angle + count)*15, count, math.sin(angle + count)*15)
                        obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(offset), 0.1)
                    elseif Config.TeleMode == "Ring" then
                        local offset = Vector3.new(math.cos(angle + count)*20, 0, math.sin(angle + count)*20)
                        obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(offset), 0.1)
                    end
                end
            end
        end
    end

    -- 4. Infinite Zoom
    if Config.InfZoom then LocalPlayer.CameraMaxZoomDistance = 100000 end

    -- 5. ESP
    if Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                Instance.new("Highlight", p.Character)
            end
        end
    end
end)

Rayfield:Notify({Title = "Secret Hub", Content = "Premium Sistem Hazır!", Duration = 5})
