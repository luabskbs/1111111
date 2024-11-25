-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game.Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local TargetPlayer = nil

-- Settings
local Settings = {
    AimbotEnabled = true,
    AimbotSmoothing = 0.2, -- Smoothness (0 = instant, 1 = very slow)
    ESPEnabled = true,
    HitboxEnabled = true,
    HighlightColor = Color3.fromRGB(0, 255, 0), -- Green
    HighlightOutline = Color3.fromRGB(255, 255, 255), -- White
    HitboxSize = Vector3.new(5, 5, 5), -- Expanded size
    FPSBoostEnabled = true,
}

-- FPS Booster Function
local function boostFPS()
    if Settings.FPSBoostEnabled then
        -- Optimize Lighting
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        
        -- Reduce Details
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
    end
end

-- Aimbot Function
local function getClosestEnemy()
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local distance = (Camera.CFrame.Position - head.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function aimbot()
    RunService.RenderStepped:Connect(function()
        if Settings.AimbotEnabled and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
            local targetHead = TargetPlayer.Character.Head.Position
            local currentCameraCFrame = Camera.CFrame.Position

            -- Smoothly adjust the camera to the target
            Camera.CFrame = CFrame.new(currentCameraCFrame, targetHead):Lerp(
                Camera.CFrame,
                Settings.AimbotSmoothing
            )
        end
    end)
end

-- ESP Function
local function applyHighlights(player)
    if player.Character then
        for _, part in ipairs(player.Character:GetChildren()) do
            if not part:FindFirstChildOfClass("Highlight") and part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = Settings.HighlightColor
                highlight.OutlineColor = Settings.HighlightOutline
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = part
            end
        end
    end
end

-- Hitbox Function
local function applyHitbox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        root.Size = Settings.HitboxSize
        root.Transparency = 0.5
        root.CanCollide = false
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        if Settings.ESPEnabled then
            applyHighlights(player)
        end
        if Settings.HitboxEnabled then
            applyHitbox(player)
        end
    end)
end

-- Main
Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        onPlayerAdded(player)
    end
end

if Settings.AimbotEnabled then
    TargetPlayer = getClosestEnemy()
    aimbot()
end

if Settings.FPSBoostEnabled then
    boostFPS()
end

-- GUI Setup for Toggling Features
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "OptimizedMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.1, 0)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "Utility Menu"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local ToggleAimbot = Instance.new("TextButton", Frame)
ToggleAimbot.Text = "Aimbot: ON"
ToggleAimbot.Size = UDim2.new(1, -20, 0, 40)
ToggleAimbot.Position = UDim2.new(0, 10, 0, 40)
ToggleAimbot.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleAimbot.TextColor3 = Color3.new(1, 1, 1)
ToggleAimbot.Font = Enum.Font.Gotham
ToggleAimbot.TextScaled = true

local ToggleESP = Instance.new("TextButton", Frame)
ToggleESP.Text = "ESP: ON"
ToggleESP.Size = UDim2.new(1, -20, 0, 40)
ToggleESP.Position = UDim2.new(0, 10, 0, 90)
ToggleESP.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleESP.TextColor3 = Color3.new(1, 1, 1)
ToggleESP.Font = Enum.Font.Gotham
ToggleESP.TextScaled = true

local ToggleFPSBoost = Instance.new("TextButton", Frame)
ToggleFPSBoost.Text = "FPS Boost: ON"
ToggleFPSBoost.Size = UDim2.new(1, -20, 0, 40)
ToggleFPSBoost.Position = UDim2.new(0, 10, 0, 140)
ToggleFPSBoost.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleFPSBoost.TextColor3 = Color3.new(1, 1, 1)
ToggleFPSBoost.Font = Enum.Font.Gotham
ToggleFPSBoost.TextScaled = true

-- Minimize Button
local MinimizeButton = Instance.new("TextButton", Frame)
MinimizeButton.Text = "_"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.Gotham
MinimizeButton.TextScaled = true

local IsMinimized = false

MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        Frame.Size = UDim2.new(0, 300, 0, 30)
    else
        Frame.Size = UDim2.new(0, 300, 0, 200)
    end
end)

-- Toggle Buttons
ToggleAimbot.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleAimbot.Text = Settings.AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

ToggleESP.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    ToggleESP.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

ToggleFPSBoost.MouseButton1Click:Connect(function()
    Settings.FPSBoostEnabled = not Settings.FPSBoostEnabled
    ToggleFPSBoost.Text = Settings.FPSBoostEnabled and "FPS Boost: ON" or "FPS Boost: OFF"
    if Settings.FPSBoostEnabled then
        boostFPS()
    end
end)