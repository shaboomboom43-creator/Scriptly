        targetGo.MouseButton1Click:Connect(function()
            if not clientFeaturesAllowed() then return end
            sendServerCommand("TeleportToPlayer", { target = targetBox.Text })
        end)

    elseif tabName == "WORLD + FUN" then
        sectionLabel("LOCAL EFFECTS / CLIENT TESTS")
        actionRow("LOCAL JUMPSCARE", "Shows the jumpscare only on your own screen.", "SCARE ME", function()
            showJumpscare(player.DisplayName)
        end)
        actionRow("LOCAL CONFETTI", "Confetti effect visible only to you.", "PARTY", confettiBurst)
        actionRow("LOCAL ANNOUNCEMENT", "Display a local test notification.", "TEST", function()
            showAnnouncement("Scriptly client effects are working.", "LOCAL TEST")
        end)

        sectionLabel("SERVER-WIDE WORLD CONTROLS / REQUIRES SERVER LINK")
        actionRow("LOW GRAVITY", "Changes workspace gravity for every player in this server.", "ACTIVATE", function()
            sendServerCommand("LowGravityGlobal")
        end)
        actionRow("RESET GRAVITY", "Restores the gravity value saved at server startup.", "RESET", function()
            sendServerCommand("ResetGravityGlobal")
        end)
        actionRow("SET DAY", "Changes Lighting.ClockTime server-side.", "DAY", function()
            sendServerCommand("Day")
        end)
        actionRow("SET NIGHT", "Changes Lighting.ClockTime server-side.", "NIGHT", function()
            sendServerCommand("Night")
        end)
        actionRow("RESET TIME", "Restores the clock time saved at server startup.", "RESET", function()
            sendServerCommand("ResetTime")
        end)
        actionRow("SERVER JUMPSCARE", "Shows the Scriptly jumpscare to every player in this server.", "SCARE ALL", function()
            sendServerCommand("ServerJumpscare")
        end)
        actionRow("SERVER CONFETTI", "Displays a confetti burst on every player's screen.", "PARTY", function()
            sendServerCommand("ServerConfetti")
        end)
        local announcementBox = textInputRow("SERVER ANNOUNCEMENT", "Type a message to show to every player...", 300)
        local announceButton = makeButton(announcementBox.Parent, "SEND", UDim2.fromOffset(56, 27), UDim2.new(1, -66, 0, 27))
        announcementBox.Size = UDim2.new(1, -86, 0, 27)
        announceButton.MouseButton1Click:Connect(function()
            if not clientFeaturesAllowed() then return end
            if sendServerCommand("ServerAnnouncement", { message = announcementBox.Text }) then
                announcementBox.Text = ""
            end
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
            if not clientFeaturesAllowed() then return end
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

-- Poll briefly so a server bridge which starts just after the client can be detected.
task.spawn(function()
    for _ = 1, 12 do
        if refreshServerLink() then
            updateServerStatusBadge()
            break
        end
        updateServerStatusBadge()
        task.wait(1)
    end
end)

print("[Scriptly 628] Client hub loaded. Press RightShift to toggle.")
print("[Scriptly 628] Owner client mode:", userOwnsExperience, "| Server bridge:", serverAuthorized)
