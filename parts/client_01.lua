-- SCRIPTLY - 628 | CLIENT HUB SOURCE
-- Can run as an authorised LocalScript or through a client executor in your own experience.
-- Local tools do not require remotes. Server-authoritative features require ScriptlyServer.server.lua.

--[[
    SCRIPTLY - 628 | CLIENT HUB
    Place this LocalScript in StarterPlayer > StarterPlayerScripts.

    This client works with ScriptlyServer.server.lua in ServerScriptService.
    It deliberately exposes only fixed, allowlisted developer commands; it does not
    execute arbitrary Lua or attempt to control other Roblox experiences.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
if not player then
    warn("[Scriptly 628] LocalPlayer is unavailable. Run this from a client context.")
    return
end
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- The UI and local anti-cheat test tools must still open when the server bridge
-- has not been installed. Server-only actions are guarded by sendServerCommand.
local remotes = nil
local commandEvent = nil
local accessFunction = nil
local serverAuthorized = false
local userOwnsExperience = game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId
local notifyUser = nil

local function refreshServerLink()
    remotes = ReplicatedStorage:FindFirstChild("Scriptly628Remotes")
    commandEvent = remotes and remotes:FindFirstChild("Command") or nil
    accessFunction = remotes and remotes:FindFirstChild("CheckAccess") or nil
    serverAuthorized = false

    if commandEvent and commandEvent:IsA("RemoteEvent") and accessFunction and accessFunction:IsA("RemoteFunction") then
        local ok, allowed = pcall(function()
            return accessFunction:InvokeServer()
        end)
        serverAuthorized = ok and allowed == true
    end
    return serverAuthorized
end

refreshServerLink()

local function clientFeaturesAllowed()
    -- User-owned experiences can use local test features without a server bridge.
    -- Group-owned experiences require the server to confirm the developer allowlist.
    return userOwnsExperience or serverAuthorized
end

local function sendServerCommand(action, data)
    if not commandEvent or not serverAuthorized then
        warn("[Scriptly 628] Server action unavailable. Install ScriptlyServer.server.lua in ServerScriptService and authorize your UserId.")
        if notifyUser then
            notifyUser("SERVER LINK OFFLINE / install the Scriptly server controller in your own experience.")
        end
        task.spawn(function()
            task.wait(0.5)
            refreshServerLink()
        end)
        return false
    end

    local ok, err = pcall(function()
        commandEvent:FireServer(action, data or {})
    end)
    if not ok then
        warn("[Scriptly 628] Could not send server command:", err)
        if notifyUser then notifyUser("Could not contact the server controller.") end
        return false
    end
    return true
end

local DARK = Color3.fromRGB(5, 10, 8)
local PANEL = Color3.fromRGB(9, 18, 14)
local PANEL2 = Color3.fromRGB(13, 27, 20)
local TEXT = Color3.fromRGB(214, 255, 227)
local MUTED = Color3.fromRGB(113, 155, 128)
local ACCENT_A = Color3.fromRGB(0, 255, 125)
local ACCENT_B = Color3.fromRGB(0, 85, 48)

local previousGui = playerGui:FindFirstChild("Scriptly628")
if previousGui then previousGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Scriptly628"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 900
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or ACCENT_A
    stroke.Transparency = transparency or 0.35
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function addGradient(parent, firstColor, secondColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, firstColor),
        ColorSequenceKeypoint.new(1, secondColor),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function makeLabel(parent, text, size, position, font, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or TEXT
    label.Font = font or Enum.Font.Code
    label.TextSize = size or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Position = position or UDim2.new()
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Parent = parent
    return label
end

local function makeButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.BackgroundColor3 = PANEL2
    button.Text = text
    button.TextColor3 = TEXT
    button.Font = Enum.Font.Code
    button.TextSize = 13
    button.Size = size or UDim2.fromOffset(100, 32)
    button.Position = position or UDim2.new()
    button.Parent = parent
    addCorner(button, 6)
    addStroke(button, ACCENT_B, 0.15, 1)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(17, 48, 31) }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = PANEL2 }):Play()
    end)
    return button
end

-- Full-screen boot sequence.
local loading = Instance.new("Frame")
loading.Name = "BootScreen"
loading.Size = UDim2.fromScale(1, 1)
loading.BackgroundColor3 = DARK
loading.BorderSizePixel = 0
loading.Parent = gui
addGradient(loading, Color3.fromRGB(2, 15, 9), Color3.fromRGB(0, 0, 0), 35)

local bootTitle = Instance.new("TextLabel")
bootTitle.BackgroundTransparency = 1
bootTitle.AnchorPoint = Vector2.new(0.5, 0.5)
bootTitle.Position = UDim2.fromScale(0.5, 0.40)
bootTitle.Size = UDim2.new(0.9, 0, 0, 60)
bootTitle.Font = Enum.Font.Code
bootTitle.Text = "SCRIPTLY - 628"
bootTitle.TextColor3 = ACCENT_A
bootTitle.TextSize = 38
bootTitle.TextXAlignment = Enum.TextXAlignment.Center
bootTitle.Parent = loading

local bootSubtitle = Instance.new("TextLabel")
bootSubtitle.BackgroundTransparency = 1
bootSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
bootSubtitle.Position = UDim2.fromScale(0.5, 0.48)
bootSubtitle.Size = UDim2.new(0.9, 0, 0, 28)
bootSubtitle.Font = Enum.Font.Code
bootSubtitle.Text = "MADE BY 628  //  DEVELOPER ENVIRONMENT"
bootSubtitle.TextColor3 = MUTED
bootSubtitle.TextSize = 14
bootSubtitle.TextXAlignment = Enum.TextXAlignment.Center
bootSubtitle.Parent = loading

local bootStatus = Instance.new("TextLabel")
bootStatus.BackgroundTransparency = 1
bootStatus.AnchorPoint = Vector2.new(0.5, 0.5)
bootStatus.Position = UDim2.fromScale(0.5, 0.57)
bootStatus.Size = UDim2.new(0.9, 0, 0, 24)
bootStatus.Font = Enum.Font.Code
bootStatus.Text = "INITIALISING MODULES..."
bootStatus.TextColor3 = TEXT
bootStatus.TextSize = 13
bootStatus.TextXAlignment = Enum.TextXAlignment.Center
bootStatus.Parent = loading

local progressBack = Instance.new("Frame")