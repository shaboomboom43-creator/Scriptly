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

local accessTag = makeLabel(top, "● CHECKING", 10, UDim2.new(1, -228, 0, 18), Enum.Font.Code, ACCENT_A)
accessTag.Size = UDim2.fromOffset(178, 22)
accessTag.TextXAlignment = Enum.TextXAlignment.Right

local function updateServerStatusBadge()
    if serverAuthorized then
        accessTag.Text = "● SERVER ONLINE"
        accessTag.TextColor3 = ACCENT_A
    elseif userOwnsExperience then
        accessTag.Text = "● CLIENT MODE / SERVER OFFLINE"
        accessTag.TextColor3 = Color3.fromRGB(255, 190, 70)
    else
        accessTag.Text = "● NOT AUTHORISED"
        accessTag.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end
updateServerStatusBadge()
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
    local function runAction(value)
        if not clientFeaturesAllowed() then
            local message = "Scriptly tools are restricted to the experience owner / authorised developer testers."
            warn("[Scriptly 628] " .. message)
            if notifyUser then notifyUser(message) end
            return false
        end
        callback(value)
        return true
    end

    if toggle then
        local state = false
        button.Text = "OFF"
        button.MouseButton1Click:Connect(function()
            local nextState = not state
            if not runAction(nextState) then return end
            state = nextState
            button.Text = state and "ON" or "OFF"
            button.BackgroundColor3 = state and Color3.fromRGB(8, 73, 39) or PANEL2
        end)
    else
        button.MouseButton1Click:Connect(function()
            runAction()
        end)
    end
    return row, button
end

