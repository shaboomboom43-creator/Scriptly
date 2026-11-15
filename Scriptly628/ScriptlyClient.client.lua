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
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local remotes = ReplicatedStorage:WaitForChild("Scriptly628Remotes", 15)
if not remotes then
    warn("[Scriptly 628] Remotes not found. Install ScriptlyServer.server.lua in ServerScriptService.")
    return
end

local commandEvent = remotes:WaitForChild("Command", 10)
local accessFunction = remotes:WaitForChild("CheckAccess", 10)
if not commandEvent or not accessFunction then
    warn("[Scriptly 628] Scriptly remotes are incomplete.")
    return
end

local accessOk, isAllowed = pcall(function()
    return accessFunction:InvokeServer()
end)
if not accessOk or isAllowed ~= true then
    warn("[Scriptly 628] You are not on the developer allowlist. Add your UserId to DEVELOPER_IDS in the server script.")
    return
end

local DARK = Color3.fromRGB(5, 10, 8)
local PANEL = Color3.fromRGB(9, 18, 14)
local PANEL2 = Color3.fromRGB(13, 27, 20)
local TEXT = Color3.fromRGB(214, 255, 227)
local MUTED = Color3.fromRGB(113, 155, 128)
local ACCENT_A = Color3.fromRGB(0, 255, 125)
local ACCENT_B = Color3.fromRGB(0, 85, 48)

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
progressBack.AnchorPoint = Vector2.new(0.5, 0.5)
progressBack.Position = UDim2.fromScale(0.5, 0.64)
progressBack.Size = UDim2.new(0.42, 0, 0, 8)
progressBack.BackgroundColor3 = Color3.fromRGB(17, 33, 24)
progressBack.BorderSizePixel = 0
progressBack.Parent = loading
addCorner(progressBack, 6)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = ACCENT_A
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBack
addCorner(progressFill, 6)
addGradient(progressFill, ACCENT_A, ACCENT_B, 0)

local bootFooter = Instance.new("TextLabel")
bootFooter.BackgroundTransparency = 1
bootFooter.AnchorPoint = Vector2.new(0.5, 0.5)
bootFooter.Position = UDim2.fromScale(0.5, 0.94)
bootFooter.Size = UDim2.new(0.9, 0, 0, 20)
bootFooter.Font = Enum.Font.Code
bootFooter.Text = "628 SYSTEMS  //  PRIVATE TEST BUILD"
bootFooter.TextColor3 = Color3.fromRGB(71, 106, 83)
bootFooter.TextSize = 11
bootFooter.TextXAlignment = Enum.TextXAlignment.Center
bootFooter.Parent = loading

local scanlines = Instance.new("Folder")
scanlines.Name = "Scanlines"
scanlines.Parent = loading
for i = 1, 34 do
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Color3.fromRGB(80, 255, 150)
    line.BackgroundTransparency = 0.965
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, (i - 1) / 34, 0)
    line.Parent = scanlines
end

local statusMessages = {
    "CHECKING DEVELOPER ACCESS...",
    "LOADING CLIENT MODULES...",
    "CONNECTING TO SERVER CONTROLLER...",
    "CALIBRATING INTERFACE...",
    "SCRIPTLY - 628 READY.",
}
for i = 1, 100 do
    progressFill.Size = UDim2.new(i / 100, 0, 1, 0)
    local statusIndex = math.clamp(math.ceil(i / 20), 1, #statusMessages)
    bootStatus.Text = statusMessages[statusIndex]
    task.wait(0.018)
end

local fade = TweenService:Create(loading, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
fade:Play()
for _, descendant in ipairs(loading:GetDescendants()) do
    if descendant:IsA("TextLabel") then
        TweenService:Create(descendant, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
    elseif descendant:IsA("Frame") then
        TweenService:Create(descendant, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
    end
end
task.wait(0.4)
loading:Destroy()

-- Main window.
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.52)
main.Size = UDim2.fromOffset(790, 520)
main.BackgroundColor3 = PANEL
main.BorderSizePixel = 0
main.Parent = gui
addCorner(main, 10)
addStroke(main, ACCENT_B, 0.05, 1.5)

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 58)
top.BackgroundColor3 = Color3.fromRGB(4, 26, 15)
top.BorderSizePixel = 0
top.Parent = main
addCorner(top, 10)
local topGradient = addGradient(top, ACCENT_B, Color3.fromRGB(3, 13, 8), 0)

local title = makeLabel(top, "SCRIPTLY  //  628", 21, UDim2.fromOffset(18, 7), Enum.Font.Code, ACCENT_A)
title.Size = UDim2.new(0.6, 0, 0, 26)
local subtitle = makeLabel(top, "DEVELOPER TEST CONSOLE  |  BUILD 628.04", 10, UDim2.fromOffset(19, 31), Enum.Font.Code, MUTED)
subtitle.Size = UDim2.new(0.7, 0, 0, 17)

local accessTag = makeLabel(top, "● AUTHORIZED", 11, UDim2.new(1, -168, 0, 18), Enum.Font.Code, ACCENT_A)
accessTag.Size = UDim2.fromOffset(115, 22)
accessTag.TextXAlignment = Enum.TextXAlignment.Right
local closeButton = makeButton(top, "×", UDim2.fromOffset(32, 30), UDim2.new(1, -43, 0, 14))
closeButton.TextSize = 20

local nav = Instance.new("Frame")
nav.Name = "Navigation"
nav.Position = UDim2.fromOffset(12, 70)
nav.Size = UDim2.new(0, 150, 1, -108)
nav.BackgroundColor3 = Color3.fromRGB(6, 14, 10)
nav.BorderSizePixel = 0
nav.Parent = main
addCorner(nav, 8)
addStroke(nav, Color3.fromRGB(19, 63, 39), 0.25, 1)

local navTitle = makeLabel(nav, "// MODULES", 11, UDim2.fromOffset(13, 9), Enum.Font.Code, MUTED)
navTitle.Size = UDim2.new(1, -20, 0, 22)

local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.fromOffset(174, 70)
content.Size = UDim2.new(1, -186, 1, -108)
content.BackgroundColor3 = Color3.fromRGB(7, 15, 11)
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = ACCENT_B
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main
addCorner(content, 8)
addStroke(content, Color3.fromRGB(19, 63, 39), 0.35, 1)

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 12)
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.PaddingLeft = UDim.new(0, 12)
contentPadding.PaddingRight = UDim.new(0, 12)
contentPadding.Parent = content

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

local footer = makeLabel(main, "MADE BY 628  //  RIGHT SHIFT: TOGGLE HUB  //  STUDIO DEV BUILD", 10, UDim2.new(0, 15, 1, -28), Enum.Font.Code, MUTED)
footer.Size = UDim2.new(1, -30, 0, 17)

local activeTab = "MOVEMENT"
local navButtons = {}
local activeConnections = {}

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= contentPadding and child ~= contentLayout then
            child:Destroy()
        end
    end
end

local function sectionLabel(text)
    local label = makeLabel(content, "// " .. text, 12, UDim2.new(), Enum.Font.Code, ACCENT_A)
    label.Size = UDim2.new(1, -8, 0, 24)
    return label
end

local function actionRow(labelText, description, buttonText, callback, toggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 58)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = content
    addCorner(row, 7)
    addStroke(row, Color3.fromRGB(20, 62, 39), 0.45, 1)

    local label = makeLabel(row, labelText, 13, UDim2.fromOffset(12, 7), Enum.Font.Code, TEXT)
    label.Size = UDim2.new(1, -130, 0, 21)
    local desc = makeLabel(row, description, 10, UDim2.fromOffset(12, 29), Enum.Font.Code, MUTED)
    desc.Size = UDim2.new(1, -130, 0, 18)

    local button = makeButton(row, buttonText, UDim2.fromOffset(102, 32), UDim2.new(1, -113, 0.5, -16))
    if toggle then
        local state = false
        button.Text = "OFF"
        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = state and "ON" or "OFF"
            button.BackgroundColor3 = state and Color3.fromRGB(8, 73, 39) or PANEL2
            callback(state)
        end)
    else
        button.MouseButton1Click:Connect(callback)
    end
    return row, button
end

local function textInputRow(labelText, placeholder, width)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 62)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = content
    addCorner(row, 7)
    addStroke(row, Color3.fromRGB(20, 62, 39), 0.45, 1)

    local label = makeLabel(row, labelText, 12, UDim2.fromOffset(12, 4), Enum.Font.Code, TEXT)
    label.Size = UDim2.new(1, -20, 0, 18)

    local box = Instance.new("TextBox")
    box.ClearTextOnFocus = false
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.Code
    box.TextSize = 12
    box.TextColor3 = TEXT
    box.PlaceholderColor3 = MUTED
    box.BackgroundColor3 = Color3.fromRGB(4, 11, 7)
    box.BorderSizePixel = 0
    box.Position = UDim2.fromOffset(10, 27)
    box.Size = UDim2.new(1, -20, 0, 27)
    box.Parent = row
    addCorner(box, 5)
    addStroke(box, ACCENT_B, 0.3, 1)
    return box
end

local function applyTheme(firstColor, secondColor)
    ACCENT_A = firstColor
    ACCENT_B = secondColor
    topGradient.Color = ColorSequence.new(firstColor, secondColor)
    title.TextColor3 = firstColor
    accessTag.TextColor3 = firstColor
    for _, descendant in ipairs(main:GetDescendants()) do
        if descendant:IsA("UIStroke") then
            descendant.Color = secondColor
        elseif descendant:IsA("TextLabel") and descendant.Text:sub(1, 2) == "//" then
            descendant.TextColor3 = firstColor
        end
    end
end

-- Local movement systems.
local flyEnabled = false
local flyAttachment, flyVelocity, flyOrientation
local flyAutoRotate = true
local flyKeys = {}
local noclipEnabled = false
local noclipConnection
local noclipOriginal = {}
local bunnyEnabled = false
local bunnyConnection
local spinEnabled = false
local spinAttachment, spinAngular

local function getCharacter()
    return player.Character
end

local function getHumanoidAndRoot()
    local character = getCharacter()
    if not character then return nil, nil end
    return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function stopFly()
    flyEnabled = false
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    if flyOrientation then flyOrientation:Destroy() flyOrientation = nil end
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    local humanoid = select(1, getHumanoidAndRoot())
    if humanoid then
        humanoid.AutoRotate = flyAutoRotate
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    local humanoid, root = getHumanoidAndRoot()
    if not humanoid or not root then return end
    stopFly()
    flyEnabled = true
    flyAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "ScriptlyFlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "ScriptlyFlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.MaxForce = 1000000
    flyVelocity.Parent = root

    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Name = "ScriptlyFlyOrientation"
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.Responsiveness = 18
    flyOrientation.MaxTorque = 1000000
    flyOrientation.Parent = root

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

local flyRenderConnection = RunService.RenderStepped:Connect(function()
    if not flyEnabled or not flyVelocity or not flyOrientation then return end
    camera = workspace.CurrentCamera
    if not camera then return end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(0, 0, -1) end
    flatLook = flatLook.Unit
    local flatRight = Vector3.new(right.X, 0, right.Z)
    if flatRight.Magnitude < 0.01 then flatRight = Vector3.new(1, 0, 0) end
    flatRight = flatRight.Unit

    local direction = Vector3.zero
    if flyKeys[Enum.KeyCode.W] then direction += flatLook end
    if flyKeys[Enum.KeyCode.S] then direction -= flatLook end
    if flyKeys[Enum.KeyCode.D] then direction += flatRight end
    if flyKeys[Enum.KeyCode.A] then direction -= flatRight end
    if flyKeys[Enum.KeyCode.Space] then direction += Vector3.yAxis end
    if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.LeftShift] then direction -= Vector3.yAxis end

    if direction.Magnitude > 0 then
        direction = direction.Unit * 58
    end
    flyVelocity.VectorVelocity = direction
    flyOrientation.CFrame = CFrame.lookAt(Vector3.zero, flatLook)
end)

local function setNoclip(enabled)
    noclipEnabled = enabled
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if enabled then
        table.clear(noclipOriginal)
        noclipConnection = RunService.Stepped:Connect(function()
            local character = getCharacter()
            if not character then return end
            for _, item in ipairs(character:GetDescendants()) do
                if item:IsA("BasePart") then
                    if noclipOriginal[item] == nil then
                        noclipOriginal[item] = item.CanCollide
                    end
                    item.CanCollide = false
                end
            end
        end)
    else
        for part, oldValue in pairs(noclipOriginal) do
            if part and part.Parent then
                part.CanCollide = oldValue
            end
        end
        table.clear(noclipOriginal)
    end
end

local function setBunny(enabled)
    bunnyEnabled = enabled
    if bunnyConnection then bunnyConnection:Disconnect() bunnyConnection = nil end
    if enabled then
        local lastJump = 0
        bunnyConnection = RunService.Heartbeat:Connect(function()
            if not bunnyEnabled then return end
            local humanoid = select(1, getHumanoidAndRoot())
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air and os.clock() - lastJump > 0.22 then
                humanoid.Jump = true
                lastJump = os.clock()
            end
        end)
    end
end

local function setSpin(enabled)
    spinEnabled = enabled
    if spinAngular then spinAngular:Destroy() spinAngular = nil end
    if spinAttachment then spinAttachment:Destroy() spinAttachment = nil end
    if enabled then
        local _, root = getHumanoidAndRoot()
        if not root then return end
        spinAttachment = Instance.new("Attachment")
        spinAttachment.Parent = root
        spinAngular = Instance.new("AngularVelocity")
        spinAngular.Attachment0 = spinAttachment
        spinAngular.RelativeTo = Enum.ActuatorRelativeTo.World
        spinAngular.AngularVelocity = Vector3.new(0, 13, 0)
        spinAngular.MaxTorque = 1000000
        spinAngular.Parent = root
    end
end

-- Local visual systems.
local playerHighlights = {}
local npcHighlights = {}
local playerEspEnabled = false
local npcEspEnabled = false
local aimEnabled = false
local aimConnection
local fullbrightEnabled = false
local savedLighting
local defaultFov = camera and camera.FieldOfView or 70

local function clearHighlights(map)
    for instance, highlight in pairs(map) do
        if highlight then highlight:Destroy() end
        map[instance] = nil
    end
end

local function addCharacterHighlight(targetPlayer)
    local character = targetPlayer.Character
    if not character or playerHighlights[character] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ScriptlyPlayerESP"
    highlight.Adornee = character
    highlight.FillColor = ACCENT_B
    highlight.OutlineColor = ACCENT_A
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0.05
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gui
    playerHighlights[character] = highlight
end

local function setPlayerEsp(enabled)
    playerEspEnabled = enabled
    clearHighlights(playerHighlights)
    if enabled then
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player then addCharacterHighlight(targetPlayer) end
        end
    end
end

local function refreshNpcEsp()
    clearHighlights(npcHighlights)
    if not npcEspEnabled then return end
    for _, target in ipairs(CollectionService:GetTagged("ScriptlyTarget")) do
        local model = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
        if model and not npcHighlights[model] then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ScriptlyNpcESP"
            highlight.Adornee = model
            highlight.FillColor = Color3.fromRGB(0, 180, 255)
            highlight.OutlineColor = Color3.fromRGB(150, 235, 255)
            highlight.FillTransparency = 0.82
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = gui
            npcHighlights[model] = highlight
        end
    end
end

local function setNpcEsp(enabled)
    npcEspEnabled = enabled
    refreshNpcEsp()
end

local function setAimTest(enabled)
    aimEnabled = enabled
    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
    if not enabled then return end

    aimConnection = RunService.RenderStepped:Connect(function()
        camera = workspace.CurrentCamera
        if not camera then return end
        local bestPart = nil
        local bestAngle = math.rad(24)
        local origin = camera.CFrame.Position
        local currentLook = camera.CFrame.LookVector

        -- Only models/parts explicitly tagged ScriptlyTarget are considered. Player characters are not.
        for _, target in ipairs(CollectionService:GetTagged("ScriptlyTarget")) do
            local model = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
            local part = nil
            if model then
                part = model:FindFirstChild("Head") or model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
            elseif target:IsA("BasePart") then
                part = target
            end

            if part and part:IsA("BasePart") then
                local offset = part.Position - origin
                if offset.Magnitude <= 350 and offset.Magnitude > 0 then
                    local angle = math.acos(math.clamp(currentLook:Dot(offset.Unit), -1, 1))
                    if angle < bestAngle then
                        bestAngle = angle
                        bestPart = part
                    end
                end
            end
        end

        if bestPart then
            local desired = CFrame.lookAt(origin, bestPart.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, 0.16)
        end
    end)
end

local function setFullbright(enabled)
    fullbrightEnabled = enabled
    if enabled then
        if not savedLighting then
            savedLighting = {
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
            }
        end
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(210, 255, 225)
        Lighting.OutdoorAmbient = Color3.fromRGB(210, 255, 225)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    elseif savedLighting then
        for property, value in pairs(savedLighting) do
            Lighting[property] = value
        end
        savedLighting = nil
    end
end

local function flashbang()
    local flash = Instance.new("Frame")
    flash.Name = "ScriptlyFlash"
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundColor3 = Color3.new(1, 1, 1)
    flash.BackgroundTransparency = 0.02
    flash.BorderSizePixel = 0
    flash.ZIndex = 100
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(1.1), { BackgroundTransparency = 1 }):Play()
    task.delay(1.2, function()
        if flash then flash:Destroy() end
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
        local tween = TweenService:Create(piece, TweenInfo.new(math.random(18, 32) / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = destination,
            Rotation = piece.Rotation + math.random(240, 620),
        })
        tween:Play()
        task.delay(3.4, function()
            if piece then piece:Destroy() end
        end)
    end
end

local function showAnnouncement(message, by)
    local toast = Instance.new("Frame")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, -80)
    toast.Size = UDim2.fromOffset(460, 66)
    toast.BackgroundColor3 = Color3.fromRGB(4, 19, 11)
    toast.BorderSizePixel = 0
    toast.ZIndex = 110
    toast.Parent = gui
    addCorner(toast, 8)
    addStroke(toast, ACCENT_A, 0.1, 1.5)

    local byLabel = makeLabel(toast, tostring(by or "SCRIPTLY SERVER"), 10, UDim2.fromOffset(13, 5), Enum.Font.Code, ACCENT_A)
    byLabel.ZIndex = 111
    byLabel.Size = UDim2.new(1, -25, 0, 17)
    local messageLabel = makeLabel(toast, tostring(message or ""), 13, UDim2.fromOffset(13, 25), Enum.Font.Code, TEXT)
    messageLabel.ZIndex = 111
    messageLabel.Size = UDim2.new(1, -25, 0, 28)
    messageLabel.TextWrapped = true

    TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 18),
    }):Play()
    task.delay(3.4, function()
        if toast then
            TweenService:Create(toast, TweenInfo.new(0.25), { Position = UDim2.new(0.5, 0, 0, -85) }):Play()
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
    addStroke(glow, Color3.fromRGB(255, 25, 45), 0, 5)

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

-- Refresh ESP when player characters spawn or tagged NPCs change.
Players.PlayerAdded:Connect(function(otherPlayer)
    otherPlayer.CharacterAdded:Connect(function()
        task.wait(0.6)
        if playerEspEnabled and otherPlayer ~= player then
            addCharacterHighlight(otherPlayer)
        end
    end)
end)
for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player then
        otherPlayer.CharacterAdded:Connect(function()
            task.wait(0.6)
            if playerEspEnabled then addCharacterHighlight(otherPlayer) end
        end)
    end
end
CollectionService:GetInstanceAddedSignal("ScriptlyTarget"):Connect(function()
    if npcEspEnabled then task.wait(0.1) refreshNpcEsp() end
end)
CollectionService:GetInstanceRemovedSignal("ScriptlyTarget"):Connect(function()
    if npcEspEnabled then refreshNpcEsp() end
end)

local function buildTab(tabName)
    activeTab = tabName
    clearContent()
    for name, button in pairs(navButtons) do
        button.BackgroundColor3 = name == tabName and Color3.fromRGB(10, 65, 38) or PANEL2
        button.TextColor3 = name == tabName and ACCENT_A or TEXT
    end

    if tabName == "MOVEMENT" then
        sectionLabel("MOVEMENT / PHYSICS TESTS")
        actionRow("FLIGHT MODE", "WASD to move, Space to rise, Ctrl/Shift to descend.", "OFF", function(state)
            if state then startFly() else stopFly() end
        end, true)
        actionRow("NOCLIP", "Locally disables character-part collisions for movement testing.", "OFF", setNoclip, true)
        actionRow("BUNNY HOP", "Automatically jumps when you touch the ground.", "OFF", setBunny, true)
        actionRow("SPIN TEST", "Applies a local rotation force to your character.", "OFF", setSpin, true)
        actionRow("DOUBLE SPEED", "Server sets your WalkSpeed to 32.", "RUN", function()
            commandEvent:FireServer("SetMovement", { speed = 32, jump = 50 })
        end)
        actionRow("SUPER JUMP", "Server sets your JumpPower to 110.", "JUMP", function()
            commandEvent:FireServer("SetMovement", { speed = 16, jump = 110 })
        end)
        actionRow("RESET MOVEMENT", "Restore default speed and jump values.", "RESET", function()
            commandEvent:FireServer("ResetMovement")
            if flyEnabled then stopFly() end
            if noclipEnabled then setNoclip(false) end
            if bunnyEnabled then setBunny(false) end
            if spinEnabled then setSpin(false) end
        end)
        actionRow("LAUNCH SELF", "Server applies an upward impulse to your character.", "YEET", function()
            commandEvent:FireServer("LaunchSelf")
        end)

    elseif tabName == "VISUALS" then
        sectionLabel("VISUAL / TARGETING TESTS")
        actionRow("PLAYER ESP", "Local outlines for other player characters.", "OFF", setPlayerEsp, true)
        actionRow("NPC TARGET ESP", "Highlights only NPCs tagged ScriptlyTarget.", "OFF", setNpcEsp, true)
        actionRow("NPC AIM TEST", "Camera assist locks only onto tagged NPC test dummies, never players.", "OFF", setAimTest, true)
        actionRow("FULLBRIGHT", "Local lighting override. Toggle off to restore saved lighting.", "OFF", setFullbright, true)
        actionRow("FOV 90", "Changes your local camera field of view.", "APPLY", function()
            camera = workspace.CurrentCamera
            if camera then camera.FieldOfView = 90 end
        end)
        actionRow("RESET FOV", "Restore the camera's default field of view (70).", "RESET", function()
            camera = workspace.CurrentCamera
            if camera then camera.FieldOfView = defaultFov end
        end)
        actionRow("FLASH TEST", "Brief local white-screen flash effect.", "FLASH", flashbang)

    elseif tabName == "SERVER" then
        sectionLabel("SERVER-AUTHORITATIVE ACTIONS")
        actionRow("HEAL SELF", "Server restores your character to maximum health.", "HEAL", function()
            commandEvent:FireServer("Heal")
        end)
        actionRow("TELEPORT TO SPAWN", "Server moves your character to a SpawnLocation.", "TELEPORT", function()
            commandEvent:FireServer("TeleportSpawn")
        end)
        actionRow("RESPAWN SELF", "Server reloads your character.", "RESPAWN", function()
            commandEvent:FireServer("Respawn")
        end)
        actionRow("FREEZE SELF", "Toggle server-side movement freeze.", "OFF", function(state)
            commandEvent:FireServer(state and "FreezeSelf" or "UnfreezeSelf")
        end, true)
        actionRow("GHOST SELF", "Server changes your character transparency for everyone.", "OFF", function(state)
            commandEvent:FireServer(state and "GhostSelf" or "UnghostSelf")
        end, true)
        actionRow("TEMP FORCEFIELD", "Server grants you a 12-second ForceField.", "GIVE", function()
            commandEvent:FireServer("ForceField")
        end)
        actionRow("FLOP TEST", "Server briefly puts your Humanoid into Physics state.", "FLOP", function()
            commandEvent:FireServer("FlopSelf")
        end)
        local targetBox = textInputRow("TELEPORT TO PLAYER", "Enter exact username or display name, then press GO", 300)
        local targetGo = makeButton(targetBox.Parent, "GO", UDim2.fromOffset(56, 27), UDim2.new(1, -66, 0, 27))
        targetBox.Size = UDim2.new(1, -86, 0, 27)
        targetGo.MouseButton1Click:Connect(function()
            commandEvent:FireServer("TeleportToPlayer", { target = targetBox.Text })
        end)

    elseif tabName == "WORLD + FUN" then
        sectionLabel("SERVER-WIDE WORLD CONTROLS")
        actionRow("LOW GRAVITY", "Changes workspace gravity for every player in this server.", "ACTIVATE", function()
            commandEvent:FireServer("LowGravityGlobal")
        end)
        actionRow("RESET GRAVITY", "Restores the gravity value saved at server startup.", "RESET", function()
            commandEvent:FireServer("ResetGravityGlobal")
        end)
        actionRow("SET DAY", "Changes Lighting.ClockTime server-side.", "DAY", function()
            commandEvent:FireServer("Day")
        end)
        actionRow("SET NIGHT", "Changes Lighting.ClockTime server-side.", "NIGHT", function()
            commandEvent:FireServer("Night")
        end)
        actionRow("RESET TIME", "Restores the clock time saved at server startup.", "RESET", function()
            commandEvent:FireServer("ResetTime")
        end)
        actionRow("SERVER JUMPSCARE", "Shows the Scriptly jumpscare to every player in this server.", "SCARE ALL", function()
            commandEvent:FireServer("ServerJumpscare")
        end)
        actionRow("SERVER CONFETTI", "Displays a confetti burst on every player's screen.", "PARTY", function()
            commandEvent:FireServer("ServerConfetti")
        end)
        local announcementBox = textInputRow("SERVER ANNOUNCEMENT", "Type a message to show to every player...", 300)
        local announceButton = makeButton(announcementBox.Parent, "SEND", UDim2.fromOffset(56, 27), UDim2.new(1, -66, 0, 27))
        announcementBox.Size = UDim2.new(1, -86, 0, 27)
        announceButton.MouseButton1Click:Connect(function()
            commandEvent:FireServer("ServerAnnouncement", { message = announcementBox.Text })
            announcementBox.Text = ""
        end)

    elseif tabName == "THEMES" then
        sectionLabel("INTERFACE / COLOR CUSTOMISATION")
        actionRow("MATRIX GREEN", "Classic terminal green gradient.", "APPLY", function()
            applyTheme(Color3.fromRGB(0, 255, 125), Color3.fromRGB(0, 74, 40))
        end)
        actionRow("TOXIC LIME", "Bright lime with a deep forest finish.", "APPLY", function()
            applyTheme(Color3.fromRGB(190, 255, 0), Color3.fromRGB(38, 82, 0))
        end)
        actionRow("CYBER TEAL", "Cool neon teal with a dark blue-green finish.", "APPLY", function()
            applyTheme(Color3.fromRGB(0, 255, 220), Color3.fromRGB(0, 63, 78))
        end)
        actionRow("AMBER TERMINAL", "Retro amber terminal palette.", "APPLY", function()
            applyTheme(Color3.fromRGB(255, 190, 55), Color3.fromRGB(105, 48, 0))
        end)

        local firstHex = textInputRow("CUSTOM GRADIENT START", "Hex colour, for example #00FF88", 300)
        local secondHex = textInputRow("CUSTOM GRADIENT END", "Hex colour, for example #003322", 300)
        local applyCustom = makeButton(content, "APPLY CUSTOM GRADIENT", UDim2.new(1, -8, 0, 34), UDim2.new())
        applyCustom.MouseButton1Click:Connect(function()
            local function parseHex(value)
                value = string.gsub(value or "", "#", "")
                if #value ~= 6 or not string.match(value, "^%x%x%x%x%x%x$") then
                    return nil
                end
                local r = tonumber(string.sub(value, 1, 2), 16)
                local g = tonumber(string.sub(value, 3, 4), 16)
                local b = tonumber(string.sub(value, 5, 6), 16)
                return Color3.fromRGB(r, g, b)
            end
            local first = parseHex(firstHex.Text)
            local second = parseHex(secondHex.Text)
            if first and second then
                applyTheme(first, second)
                showAnnouncement("Custom gradient applied.", "SCRIPTLY THEMES")
            else
                showAnnouncement("Invalid hex. Use six digits, e.g. #00FF88", "SCRIPTLY THEMES")
            end
        end)
    end
end

local tabs = { "MOVEMENT", "VISUALS", "SERVER", "WORLD + FUN", "THEMES" }
for index, tabName in ipairs(tabs) do
    local button = makeButton(nav, tabName, UDim2.new(1, -16, 0, 36), UDim2.fromOffset(8, 40 + ((index - 1) * 43)))
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 11
    button.Text = "  " .. tabName
    navButtons[tabName] = button
    button.MouseButton1Click:Connect(function()
        buildTab(tabName)
    end)
end

closeButton.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local hubVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        hubVisible = not hubVisible
        main.Visible = hubVisible
        return
    end

    if flyEnabled then
        flyKeys[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    flyKeys[input.KeyCode] = nil
end)

player.CharacterAdded:Connect(function()
    task.wait(0.8)
    if flyEnabled then startFly() end
    if noclipEnabled then setNoclip(true) end
    if spinEnabled then setSpin(true) end
end)

buildTab("MOVEMENT")
print("[Scriptly 628] Client hub loaded. Press RightShift to toggle.")
