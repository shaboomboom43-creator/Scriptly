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
        actionRow("DOUBLE SPEED TEST", "Local client movement override for anti-cheat simulation.", "RUN", function()
            setLocalMovement(32, 50)
            showAnnouncement("Local speed test set to 32.", "SCRIPTLY TEST")
        end)
        actionRow("SUPER JUMP TEST", "Local jump override for anti-cheat simulation.", "JUMP", function()
            setLocalMovement(16, 110)
            showAnnouncement("Local jump test set to 110.", "SCRIPTLY TEST")
        end)
        actionRow("RESET MOVEMENT", "Restore local default speed and jump values.", "RESET", function()
            setLocalMovement(16, 50)
            sendServerCommand("ResetMovement")
            if flyEnabled then stopFly() end
            if noclipEnabled then setNoclip(false) end
            if bunnyEnabled then setBunny(false) end
            if spinEnabled then setSpin(false) end
        end)
        actionRow("LAUNCH SELF", "Local physics impulse test for your own character.", "YEET", function()
            local _, root = getHumanoidAndRoot()
            if root then root:ApplyImpulse(Vector3.new(0, root.AssemblyMass * 125, 0)) end
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
            sendServerCommand("Heal")
        end)
        actionRow("TELEPORT TO SPAWN", "Server moves your character to a SpawnLocation.", "TELEPORT", function()
            sendServerCommand("TeleportSpawn")
        end)
        actionRow("RESPAWN SELF", "Server reloads your character.", "RESPAWN", function()
            sendServerCommand("Respawn")
        end)
        actionRow("FREEZE SELF", "Toggle server-side movement freeze.", "OFF", function(state)
            sendServerCommand(state and "FreezeSelf" or "UnfreezeSelf")
        end, true)
        actionRow("GHOST SELF", "Server changes your character transparency for everyone.", "OFF", function(state)
            sendServerCommand(state and "GhostSelf" or "UnghostSelf")
        end, true)
        actionRow("TEMP FORCEFIELD", "Server grants you a 12-second ForceField.", "GIVE", function()
            sendServerCommand("ForceField")
        end)
        actionRow("FLOP TEST", "Server briefly puts your Humanoid into Physics state.", "FLOP", function()
            sendServerCommand("FlopSelf")
        end)
        local targetBox = textInputRow("TELEPORT TO PLAYER", "Enter exact username or display name, then press GO", 300)
        local targetGo = makeButton(targetBox.Parent, "GO", UDim2.fromOffset(56, 27), UDim2.new(1, -66, 0, 27))
        targetBox.Size = UDim2.new(1, -86, 0, 27)
