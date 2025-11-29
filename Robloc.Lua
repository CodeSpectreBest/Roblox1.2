local TeleTab = Window:CreateTab("Telekinesis", 10952479675)

-- Settings (defaults)
local Tele = {
    Enabled = false,
    Mode = "Tornado",            -- "Tornado", "Ring", "Portal", "Orbit"
    Range = 50,                  -- 1-200
    SphereSize = 20,             -- 1-200
    Force = 30,                  -- 0-100 (visual speed)
    MaxTargets = 80
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- internal state
local spherePart = nil
local grabbed = {}               -- list of parts currently controlled
local updateConn = nil
local angle = 0

-- helper: create sphere visual
local function createSphere()
    if spherePart and spherePart.Parent then return end
    if spherePart then pcall(function() spherePart:Destroy() end) end
    spherePart = Instance.new("Part")
    spherePart.Name = "TeleSphere_" .. tostring(LocalPlayer.UserId)
    spherePart.Shape = Enum.PartType.Ball
    spherePart.Anchored = true
    spherePart.CanCollide = false
    spherePart.Material = Enum.Material.Neon
    spherePart.Transparency = 0.5
    spherePart.Color = Color3.fromRGB(255, 50, 50)
    spherePart.Size = Vector3.new(Tele.SphereSize, Tele.SphereSize, Tele.SphereSize)
    spherePart.Parent = workspace
end

local function destroySphere()
    if spherePart then
        pcall(function() spherePart:Destroy() end)
        spherePart = nil
    end
end

-- helper: collect parts (Anchored == false) within range, exclude player chars
local function collectParts()
    grabbed = {}
    local char = LocalPlayer.Character
    local charDescendants = {}
    if char then
        for _, d in pairs(char:GetDescendants()) do charDescendants[d] = true end
    end

    local pos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or nil
    if not pos then return end

    local cnt = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if cnt >= Tele.MaxTargets then break end
        if obj:IsA("BasePart") then
            if obj ~= spherePart and not charDescendants[obj] and obj.Parent and not obj:IsDescendantOf(LocalPlayer.Character) then
                if obj.Anchored == false then
                    local ok, mag = pcall(function() return (obj.Position - pos).Magnitude end)
                    if ok and mag and mag <= Tele.Range then
                        cnt = cnt + 1
                        grabbed[cnt] = obj
                    end
                end
            end
        end
    end
end

-- helper: release grabbed parts (restore anchored = false)
local function releaseAll()
    for _, p in pairs(grabbed) do
        if p and p.Parent then
            p.Anchored = false
        end
    end
    grabbed = {}
end

-- mode behaviours
local Modes = {}

-- Tornado: vertical spiral upward around player
Modes["Tornado"] = function(hrp, t)
    angle = angle + (Tele.Force * 0.02)
    for i, part in ipairs(grabbed) do
        if part and part.Parent then
            local idx = i
            local theta = angle + idx * 0.6
            local height = ((idx-1) % math.max(1, math.floor(#grabbed/6)+1)) * (Tele.SphereSize/4) + math.sin(t*2 + idx) * 0.5
            local radius = math.max(1, Tele.SphereSize/4)
            local offset = Vector3.new(math.cos(theta) * radius, height, math.sin(theta) * radius)
            local targetCFrame = hrp.CFrame * CFrame.new(0, 0, 0) * CFrame.new(offset)
            -- smooth move by lerping CFrame
            pcall(function()
                part.Anchored = true
                part.CFrame = targetCFrame
            end)
        end
    end
end

-- Ring: horizontal ring at specified height
Modes["Ring"] = function(hrp, t)
    angle = angle + (Tele.Force * 0.015)
    local n = #grabbed
    if n == 0 then return end
    for i, part in ipairs(grabbed) do
        if part and part.Parent then
            local theta = angle + (i / n) * math.pi * 2
            local radius = math.max(1, Tele.SphereSize/2)
            local y = Tele.SphereSize * 0.1 -- small offset; sphere sits at hrp + sphereHeight below
            local offset = Vector3.new(math.cos(theta) * radius, y + Tele.SphereSize * 0.0, math.sin(theta) * radius + Tele.SphereSize/6)
            local targetCFrame = hrp.CFrame * CFrame.new(offset)
            pcall(function()
                part.Anchored = true
                part.CFrame = targetCFrame
            end)
        end
    end
end

-- Portal: swirling blob in front of player
Modes["Portal"] = function(hrp, t)
    angle = angle + (Tele.Force * 0.02)
    for i, part in ipairs(grabbed) do
        if part and part.Parent then
            local theta = angle + i * 0.4
            local r = math.max(1, Tele.SphereSize/3)
            local x = math.sin(theta) * r
            local y = math.cos(theta * 0.7) * (Tele.SphereSize/2)
            local z = math.cos(theta) * (r/2)
            local offset = Vector3.new(x, y, -Tele.SphereSize*0.2 + z)
            local targetCFrame = hrp.CFrame * CFrame.new(offset)
            pcall(function()
                part.Anchored = true
                part.CFrame = targetCFrame
            end)
        end
    end
end

Modes["Orbit"] = function(hrp, t)
    angle = angle + (Tele.Force * 0.02)
    for i, part in ipairs(grabbed) do
        if part and part.Parent then
            local theta = angle + i * 0.5
            local r = math.max(1, Tele.SphereSize/3)
            local offset = Vector3.new(math.cos(theta)*r, Tele.SphereSize*0.1, math.sin(theta)*r)
            local targetCFrame = hrp.CFrame * CFrame.new(offset)
            pcall(function()
                part.Anchored = true
                part.CFrame = targetCFrame
            end)
        end
    end
end

-- start/stop update loop
local function startUpdate()
    if updateConn then return end
    angle = 0
    updateConn = RunService.RenderStepped:Connect(function(dt)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if Tele.Enabled then
            -- update sphere
            if not spherePart then createSphere() end
            spherePart.Size = Vector3.new(Tele.SphereSize, Tele.SphereSize, Tele.SphereSize)
            spherePart.Position = hrp.Position + Vector3.new(0, Tele.SphereSize * 0.2, 0)

            -- collect targets periodically
            collectParts()

            -- apply mode
            local modeFn = Modes[Tele.Mode]
            if modeFn and #grabbed > 0 then
                modeFn(hrp, tick())
            end
        else
            -- ensure cleanup if disabled
            if spherePart then destroySphere() end
            releaseAll()
        end
    end)
end

local function stopUpdate()
    if updateConn then
        updateConn:Disconnect()
        updateConn = nil
    end
    destroySphere()
    releaseAll()
end

-- start the updater now (keeps UI responsive)
startUpdate()

-- ========= RAYFIELD UI CREATION =========

-- big toggle
TeleTab:CreateToggle({
    Name = "Telekinesis Aç/Kapa",
    CurrentValue = false,
    Flag = "TeleToggle",
    Callback = function(state)
        Tele.Enabled = state
        if not state then
            -- releasing everything when turned off
            releaseAll()
            destroySphere()
        else
            createSphere()
            collectParts()
        end
    end,
})

-- Mode dropdown
TeleTab:CreateDropdown({
    Name = "Mode",
    Options = {"Tornado", "Ring", "Portal", "Orbit"},
    CurrentOption = Tele.Mode,
    Flag = "TeleMode",
    Callback = function(opt)
        Tele.Mode = opt
    end,
})

-- Range slider 1-200
TeleTab:CreateSlider({
    Name = "Range",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = Tele.Range,
    Flag = "TeleRange",
    Callback = function(v)
        Tele.Range = math.clamp(math.floor(v), 1, 200)
    end,
})

-- Sphere size slider 1-200
TeleTab:CreateSlider({
    Name = "Sphere Size",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = Tele.SphereSize,
    Flag = "TeleSphereSize",
    Callback = function(v)
        Tele.SphereSize = math.clamp(math.floor(v), 1, 200)
        if spherePart then spherePart.Size = Vector3.new(Tele.SphereSize, Tele.SphereSize, Tele.SphereSize) end
    end,
})

-- Force slider 0-100
TeleTab:CreateSlider({
    Name = "Force (Speed)",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = Tele.Force,
    Flag = "TeleForce",
    Callback = function(v)
        Tele.Force = math.clamp(v, 0, 100)
    end,
})

-- Disconnect all button
TeleTab:CreateButton({
    Name = "Disconnect All Objects",
    Callback = function()
        releaseAll()
        destroySphere()
        Tele.Enabled = false
        -- update toggle state in UI (if saved in config)
        pcall(function() Rayfield:Notify({Title="Telekinesis", Content="All objects released", Duration=2}) end)
    end,
})

-- Done
