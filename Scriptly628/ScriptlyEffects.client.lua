--[[
    SCRIPTLY - 628 | CLIENT-WIDE SERVER EFFECT RECEIVER
    Place this LocalScript in StarterPlayer > StarterPlayerScripts.

    Keep this script enabled for EVERY player in the experience. The hub itself is
    developer-only, but server-wide announcements, confetti, and jumpscares must be
    rendered by all clients to be visible to everyone.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Scriptly628Remotes", 30)
if not remotes then
    warn("[Scriptly 628 Effects] Remote folder not found.")
    return
end

local commandEvent = remotes:WaitForChild("Command", 10)
if not commandEvent then
    warn("[Scriptly 628 Effects] Command RemoteEvent not found.")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "Scriptly628Effects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 950
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local GREEN = Color3.fromRGB(0, 255, 125)
local TEXT = Color3.fromRGB(225, 255, 235)

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.1
    stroke.Parent = parent
end

local function showAnnouncement(message, by)
    local toast = Instance.new("Frame")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, -85)
    toast.Size = UDim2.fromOffset(460, 66)
    toast.BackgroundColor3 = Color3.fromRGB(4, 19, 11)
    toast.BorderSizePixel = 0
    toast.ZIndex = 110
    toast.Parent = gui
    addCorner(toast, 8)
    addStroke(toast, GREEN, 1.5)

    local byLabel = Instance.new("TextLabel")
    byLabel.BackgroundTransparency = 1
    byLabel.Position = UDim2.fromOffset(13, 5)
    byLabel.Size = UDim2.new(1, -25, 0, 17)
    byLabel.Font = Enum.Font.Code
    byLabel.Text = tostring(by or "SCRIPTLY SERVER")
    byLabel.TextColor3 = GREEN
    byLabel.TextSize = 10
    byLabel.TextXAlignment = Enum.TextXAlignment.Left
    byLabel.ZIndex = 111
    byLabel.Parent = toast

    local messageLabel = Instance.new("TextLabel")
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.fromOffset(13, 25)
    messageLabel.Size = UDim2.new(1, -25, 0, 28)
    messageLabel.Font = Enum.Font.Code
    messageLabel.Text = tostring(message or "")
    messageLabel.TextColor3 = TEXT
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.ZIndex = 111
    messageLabel.Parent = toast

    TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 18),
    }):Play()

    task.delay(3.4, function()
        if toast then
            TweenService:Create(toast, TweenInfo.new(0.25), {
                Position = UDim2.new(0.5, 0, 0, -85),
            }):Play()
            task.wait(0.3)
            if toast then toast:Destroy() end
        end
    end)
end

local function showJumpscare(by)
    local scare = Instance.new("Frame")
    scare.Name = "ScriptlyJumpscare"
    scare.Size = UDim2.fromScale(1, 1)
    scare.BackgroundColor3 = Color3.fromRGB(30, 0, 4)
    scare.BackgroundTransparency = 0.02
    scare.BorderSizePixel = 0
    scare.ZIndex = 150
    scare.Parent = gui

    local glow = Instance.new("Frame")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.48)
    glow.Size = UDim2.fromOffset(320, 250)
    glow.BackgroundColor3 = Color3.fromRGB(85, 0, 10)
    glow.BorderSizePixel = 0
    glow.ZIndex = 151
    glow.Parent = scare
    addCorner(glow, 120)
    addStroke(glow, Color3.fromRGB(255, 25, 45), 5)

    local face = Instance.new("TextLabel")
    face.BackgroundTransparency = 1
    face.AnchorPoint = Vector2.new(0.5, 0.5)
    face.Position = UDim2.fromScale(0.5, 0.46)
    face.Size = UDim2.fromScale(0.9, 0.85)
    face.Font = Enum.Font.Code
    face.Text = "◉     ◉\n\n   ▄▄▄\n  ▀█████▀"
    face.TextColor3 = Color3.fromRGB(255, 235, 235)
    face.TextSize = 46
    face.TextXAlignment = Enum.TextXAlignment.Center
    face.TextYAlignment = Enum.TextYAlignment.Center
    face.ZIndex = 152
    face.Parent = glow

    local warning = Instance.new("TextLabel")
    warning.BackgroundTransparency = 1
    warning.AnchorPoint = Vector2.new(0.5, 0.5)
    warning.Position = UDim2.fromScale(0.5, 0.82)
    warning.Size = UDim2.new(1, -30, 0, 50)
    warning.Font = Enum.Font.Code
    warning.Text = "YOU HAVE BEEN SCRIPTLY'D  //  628"
    warning.TextColor3 = Color3.fromRGB(255, 65, 65)
    warning.TextSize = 22
    warning.TextWrapped = true
    warning.ZIndex = 153
    warning.Parent = scare

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.Position = UDim2.fromScale(0.5, 0.92)
    sub.Size = UDim2.new(1, -30, 0, 25)
    sub.Font = Enum.Font.Code
    sub.Text = "TRIGGERED BY " .. string.upper(tostring(by or "628"))
    sub.TextColor3 = Color3.fromRGB(190, 95, 105)
    sub.TextSize = 11
    sub.ZIndex = 153
    sub.Parent = scare

    task.delay(1.75, function()
        if scare then
            TweenService:Create(scare, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
            task.wait(0.38)
            if scare then scare:Destroy() end
        end
    end)
end

local function confettiBurst()
    local colors = {
        Color3.fromRGB(0, 255, 130),
        Color3.fromRGB(120, 255, 190),
        Color3.fromRGB(0, 150, 90),
        Color3.fromRGB(210, 255, 225),
    }

    for i = 1, 42 do
        local piece = Instance.new("Frame")
        piece.BorderSizePixel = 0
        piece.BackgroundColor3 = colors[math.random(1, #colors)]
        piece.Size = UDim2.fromOffset(math.random(4, 9), math.random(7, 15))
        piece.Position = UDim2.new(math.random(), 0, -0.08, 0)
        piece.Rotation = math.random(0, 180)
        piece.ZIndex = 80
        piece.Parent = gui

        local destination = UDim2.new(piece.Position.X.Scale + (math.random(-15, 15) / 100), 0, 1.12, 0)
        TweenService:Create(piece, TweenInfo.new(math.random(18, 32) / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = destination,
            Rotation = piece.Rotation + math.random(240, 620),
        }):Play()

        task.delay(3.4, function()
            if piece then piece:Destroy() end
        end)
    end
end

commandEvent.OnClientEvent:Connect(function(action, data)
    if typeof(data) ~= "table" then data = {} end

    if action == "Jumpscare" then
        showJumpscare(data.by)
    elseif action == "Confetti" then
        confettiBurst()
    elseif action == "Announcement" then
        showAnnouncement(data.message, data.by)
    end
end)

print("[Scriptly 628 Effects] Server effect receiver ready for " .. player.Name)
