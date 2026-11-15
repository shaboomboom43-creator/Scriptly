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

notifyUser = function(message)
    showAnnouncement(message, "SCRIPTLY 628")
end
