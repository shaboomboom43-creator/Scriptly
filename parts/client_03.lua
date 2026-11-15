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

local function setLocalMovement(speed, jumpPower)
    local humanoid = select(1, getHumanoidAndRoot())
    if not humanoid then
        if notifyUser then notifyUser("Character is not ready yet.") end
        return
    end
    humanoid.UseJumpPower = true
    humanoid.WalkSpeed = math.clamp(tonumber(speed) or 16, 0, 150)
    humanoid.JumpPower = math.clamp(tonumber(jumpPower) or 50, 0, 200)
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
