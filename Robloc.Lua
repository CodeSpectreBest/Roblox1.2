local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Secret Hub | Premium",
   LoadingTitle = "Secret Hub Loading...",
   LoadingSubtitle = "by mystery man",
   ConfigurationSaving = {
      Enabled = true,
      Folder = "SecretHubConfigs"
   },
   KeySystem = true, -- Key sistemi aktif edildi
   KeySettings = {
      Title = "Secret Hub | Key System",
      Subtitle = "Enter the Key",
      Note = "Key is: Secret123",      FileName = "SecretHubKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Secret123"} -- Belirlediğin şifre
   }
})-- Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayerlocal runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Ayarlar
local Config = {
    FlyEnabled = false,
    FlySpeed = 50,
    InfZoom = false,
    AntiGrab = false,    Fling = false,
    FlingPower = 10000,
    GrabMode = "None",
    GrabRange = 30,
    GrabPower = 100,
    ESP = false
}

-- SEKMELER
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AuraTab = Window:CreateTab("Grab Auras", 10952479675)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- ================= PLAYER =================
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Toggled)
        Config.FlyEnabled = Toggled
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if Toggled then
            if hum then hum.PlatformStand = true end            _G.FlyCon = runService.RenderStepped:Connect(function(dt)
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
                if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end            end)
        else
            if _G.FlyCon then _G.FlyCon:Disconnect() end
            if hum then hum.PlatformStand = false end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Config.FlySpeed = v end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Zoom",
    CurrentValue = false,
    Callback = function(v) Config.InfZoom = v end,
})

-- ================= GRAB AURAS =================
AuraTab:CreateDropdown({
    Name = "Aura Mode",
    Options = {"None", "Magnet", "Void", "Kill", "Massive Grab", "Glitch Grab", "Kick Grab", "Throw Grab", "Space Grab"},
    CurrentOption = "None",
    Callback = function(v) Config.GrabMode = v end,
})

AuraTab:CreateSlider({
    Name = "Range",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = 30,
    Callback = function(v) Config.GrabRange = v end,
})

-- ================= COMBAT =================
CombatTab:CreateToggle({
    Name = "Anti-Grab",
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
    Callback = function(v) Config.ESP = v end,
})

-- ================= MAIN LOOP =================
runService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Config.AntiGrab then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("BallSocketConstraint") then v:Destroy() end
        end
    end

    if Config.Fling then
        hrp.Velocity = Vector3.new(0, 5000, 0)
        hrp.RotVelocity = Vector3.new(0, 10000, 0)
    end

    if Config.GrabMode ~= "None" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                if (obj.Position - hrp.Position).Magnitude <= Config.GrabRange then
                    if Config.GrabMode == "Magnet" then obj.CFrame = obj.CFrame:Lerp(hrp.CFrame * CFrame.new(0, 0, -5), 0.2)
                    elseif Config.GrabMode == "Void" then obj.CFrame = CFrame.new(obj.Position.X, -500, obj.Position.Z)
                    elseif Config.GrabMode == "Kill" then obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -5) obj.RotVelocity = Vector3.new(0, 10000, 0)
                    elseif Config.GrabMode == "Massive Grab" then obj.CFrame = hrp.CFrame * CFrame.new(0, 15, 0)
                    elseif Config.GrabMode == "Glitch Grab" then obj.CFrame = obj.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1)) obj.RotVelocity = Vector3.new(500, 500, 500)
                    elseif Config.GrabMode == "Kick Grab" then obj.Velocity = (obj.Position - hrp.Position).unit * Config.GrabPower
                    elseif Config.GrabMode == "Throw Grab" then obj.CFrame = hrp.CFrame * CFrame.new(0, 0, -5) obj.Velocity = camera.CFrame.LookVector * Config.GrabPower
                    elseif Config.GrabMode == "Space Grab" then obj.Velocity = Vector3.new(0, Config.GrabPower, 0)
                    end
                end
            end
        end
    end

    if Config.InfZoom then LocalPlayer.CameraMaxZoomDistance = 100000 end
end)

Rayfield:Notify({Title = "Secret Hub", Content = "Loaded Successfully!", Duration = 5})
