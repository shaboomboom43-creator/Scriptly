-- SIX-SCRIPTLY | CLIENT-WIDE EFFECT RECEIVER
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "SixScriptlyEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 950
gui.Parent = playerGui

local GREEN = Color3.fromRGB(0, 255, 145)

local function corner(parent, radius)
    local object = Instance.new("UICorner")
    object.CornerRadius = UDim.new(0, radius or 8)
    object.Parent = parent
end

local function stroke(parent)
    local object = Instance.new("UIStroke")
    object.Color = GREEN
    object.Thickness = 1.5
    object.Parent = parent
end

local function announce(message, by)
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, -80)
    frame.Size = UDim2.fromOffset(460, 66)
    frame.BackgroundColor3 = Color3.fromRGB(4, 19, 11)
    frame.Parent = gui
    corner(frame, 8)
    stroke(frame)

    local author = Instance.new("TextLabel")
    author.BackgroundTransparency = 1
    author.Position = UDim2.fromOffset(12, 4)
    author.Size = UDim2.new(1, -24, 0, 18)
    author.Font = Enum.Font.GothamSemibold
    author.TextSize = 10
    author.TextColor3 = GREEN
    author.TextXAlignment = Enum.TextXAlignment.Left
    author.Text = tostring(by or "SIX-SCRIPTLY SERVER")
    author.Parent = frame

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(12, 24)
    body.Size = UDim2.new(1, -24, 0, 34)
    body.Font = Enum.Font.Gotham
    body.TextSize = 13
    body.TextWrapped = true
    body.TextColor3 = Color3.fromRGB(225, 255, 235)
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.Text = tostring(message or "")
    body.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.25), {
        Position = UDim2.new(0.5, 0, 0, 18),
    }):Play()
    task.delay(3.2, function()
        if frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.2), {
                Position = UDim2.new(0.5, 0, 0, -80),
            }):Play()
            task.wait(0.25)
            frame:Destroy()
        end
    end)
end

local function jumpscare()
    local frame = Instance.new("Frame")
    frame.Name = "SixScriptlyJumpscare"
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(30, 0, 4)
    frame.Parent = gui
    local face = Instance.new("TextLabel")
    face.BackgroundTransparency = 1
    face.Size = UDim2.fromScale(1, 1)
    face.Font = Enum.Font.GothamBold
    face.TextSize = 48
    face.TextColor3 = Color3.fromRGB(255, 230, 230)
    face.Text = "◉     ◉\n\n   ▄▄▄\n  ▀█████▀\n\nSIX-SCRIPTLY TEST EVENT"
    face.TextWrapped = true
    face.Parent = frame
    task.delay(1.8, function()
        if frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.35)
            frame:Destroy()
        end
    end)
end

local function confetti()
    local colours = {
        Color3.fromRGB(0, 255, 130), Color3.fromRGB(120, 255, 190),
        Color3.fromRGB(0, 150, 90), Color3.fromRGB(210, 255, 225),
    }
    for _ = 1, 42 do
        local piece = Instance.new("Frame")
        piece.BorderSizePixel = 0
        piece.BackgroundColor3 = colours[math.random(1, #colours)]
        piece.Size = UDim2.fromOffset(math.random(4, 9), math.random(7, 15))
        piece.Position = UDim2.new(math.random(), 0, -0.08, 0)
        piece.Parent = gui
        local destination = UDim2.new(piece.Position.X.Scale + math.random(-15, 15) / 100, 0, 1.1, 0)
        TweenService:Create(piece, TweenInfo.new(2.4), {
            Position = destination, Rotation = math.random(240, 620),
        }):Play()
        task.delay(3, function() if piece.Parent then piece:Destroy() end end)
    end
end

local remotes = ReplicatedStorage:WaitForChild("SixScriptlyRemotes", 30)
if not remotes then
    warn("[Six-Scriptly Effects] Server bridge not found.")
    return
end
local command = remotes:WaitForChild("Command", 10)
if not command then
    warn("[Six-Scriptly Effects] Command event missing.")
    return
end

command.OnClientEvent:Connect(function(action, data)
    if typeof(data) ~= "table" then data = {} end
    if action == "Announcement" then
        announce(data.message, data.by)
    elseif action == "Jumpscare" then
        jumpscare()
    elseif action == "Confetti" then
        confetti()
    end
end)

print("[Six-Scriptly Effects] Receiver ready for " .. player.Name)
