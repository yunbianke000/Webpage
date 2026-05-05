local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local PlayerESP = {
    labels = {},
    localPlayer = nil,
    enabled = true,
    rays = {},
    boxes = {},
    screenGui = nil,
    mainFrame = nil,
    toggleButton = nil,
    rayToggleButton = nil,
    boxToggleButton = nil,
    statusLabel = nil,
    showRays = true,
    showBoxes = true,
    isExpanded = true,
    isDragging = false,
    dragStartPos = nil,
    frameStartPos = nil,
    sitTarget = nil,
    isSitting = false,
    sitConnection = nil,
    originalCFrame = nil,
    colors = {
        label = Color3.new(1, 0, 0),
        ray = Color3.fromRGB(0, 255, 0),
        box = Color3.fromRGB(156, 39, 176),
        teamBased = false
    },
    playerListFrame = nil,
    playerButtons = {},
    aimbotEnabled = false,
    aimbotKey = "q",
    aimbotRange = 100,
    aimbotFov = 360,
    aimbotStrength = 10,
    wallCheck = true,
    teamCheck = true,
    aimbotTarget = nil,
    aimbotConnection = nil,

    inputChangedConnection = nil,
    aimbotKeyBeganConnection = nil,
    aimbotKeyEndedConnection = nil,

    triggerbotEnabled = false,
    triggerbotKey = "e",
    triggerbotAlwaysOn = true, -- 设为true则无需按键，始终自动开火
    triggerbotFiring = false,
    triggerbotConnection = nil,
    triggerbotBeganConn = nil,
    triggerbotEndedConn = nil,
    triggerKeyHeld = false,
}

function PlayerESP:createColorPicker(parent, position, defaultColor, colorName, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Name = colorName .. "ColorFrame"
    colorFrame.Size = UDim2.new(0.9, 0, 0, 30)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = parent

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    colorLabel.Position = UDim2.new(0, 0, 0, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = colorName .. "颜色"
    colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorLabel.TextSize = 12
    colorLabel.Font = Enum.Font.SourceSans
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorFrame

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.4, 0, 0.7, 0)
    colorButton.Position = UDim2.new(0.55, 0, 0.15, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.BorderSizePixel = 1
    colorButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
    colorButton.Text = ""
    colorButton.Parent = colorFrame

    colorButton.MouseButton1Click:Connect(function()
        self:showColorPicker(defaultColor, function(newColor)
            colorButton.BackgroundColor3 = newColor
            callback(newColor)
        end)
    end)

    return colorFrame
end

function PlayerESP:showColorPicker(defaultColor, callback)
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("ColorPickerGui")
    if existing then existing:Destroy() end

    local colorPickerGui = Instance.new("ScreenGui")
    colorPickerGui.Name = "ColorPickerGui"
    colorPickerGui.Parent = playerGui

    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 200, 0, 250)
    colorFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
    colorFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    colorFrame.BorderSizePixel = 2
    colorFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    colorFrame.Parent = colorPickerGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    titleLabel.Text = "选择颜色"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = colorFrame

    local colorGrid = {
        Color3.new(1, 0, 0), Color3.new(1, 0.5, 0.5), Color3.new(0.5, 0, 0),
        Color3.new(0, 1, 0), Color3.new(0.5, 1, 0.5), Color3.new(0, 0.5, 0),
        Color3.new(0, 0, 1), Color3.new(0.5, 0.5, 1), Color3.new(0, 0, 0.5),
        Color3.new(1, 1, 0), Color3.new(1, 0, 1), Color3.new(0, 1, 1),
        Color3.new(1, 0.5, 0), Color3.new(0.5, 0, 0.5), Color3.new(0.5, 0.5, 0),
        Color3.new(1, 1, 1), Color3.new(0.5, 0.5, 0.5), Color3.new(0, 0, 0)
    }
    for i, color in ipairs(colorGrid) do
        local row = math.floor((i - 1) / 5)
        local col = (i - 1) % 5
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 30, 0, 30)
        colorBtn.Position = UDim2.new(0, 10 + col * 35, 0, 40 + row * 35)
        colorBtn.BackgroundColor3 = color
        colorBtn.BorderSizePixel = 1
        colorBtn.BorderColor3 = Color3.fromRGB(200, 200, 200)
        colorBtn.Text = ""
        colorBtn.Parent = colorFrame
        colorBtn.MouseButton1Click:Connect(function()
            callback(color)
            colorPickerGui:Destroy()
        end)
    end

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.8, 0, 0, 30)
    closeButton.Position = UDim2.new(0.1, 0, 0, 210)
    closeButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "关闭"
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 14
    closeButton.Parent = colorFrame
    closeButton.MouseButton1Click:Connect(function()
        colorPickerGui:Destroy()
    end)
end

function PlayerESP:createPlayerList(parent)
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(0.9, 0, 0, 80)
    playerListFrame.Position = UDim2.new(0, 0, 0, 0)
    playerListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    playerListFrame.BorderSizePixel = 1
    playerListFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    playerListFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = playerListFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 2)
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = Enum.SortOrder.Name
    uiListLayout.Parent = scrollFrame

    self.playerListFrame = scrollFrame
    self:updatePlayerList()
    return playerListFrame
end

function PlayerESP:updatePlayerList()
    if not self.playerListFrame then return end
    for _, button in pairs(self.playerButtons) do
        if button then button:Destroy() end
    end
    self.playerButtons = {}
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= self.localPlayer then
            table.insert(players, player)
        end
    end
    table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
    local buttonHeight = 20
    local totalHeight = #players * (buttonHeight + 2)
    self.playerListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    for i, player in ipairs(players) do
        local playerButton = Instance.new("TextButton")
        playerButton.Size = UDim2.new(0.95, 0, 0, buttonHeight)
        playerButton.Position = UDim2.new(0.025, 0, 0, (i-1) * (buttonHeight + 2))
        playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        playerButton.BorderSizePixel = 0
        playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        playerButton.Text = player.Name
        playerButton.Font = Enum.Font.SourceSans
        playerButton.TextSize = 12
        playerButton.Parent = self.playerListFrame

        playerButton.MouseEnter:Connect(function()
            if not self.sitTarget or self.sitTarget ~= player then
                playerButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            end
        end)
        playerButton.MouseLeave:Connect(function()
            if not self.sitTarget or self.sitTarget ~= player then
                playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end)
        playerButton.MouseButton1Click:Connect(function()
            self.playerNameBox.Text = player.Name
            for _, btn in pairs(self.playerButtons) do
                if btn then btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end
            end
            playerButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
        end)
        table.insert(self.playerButtons, playerButton)
    end
end

function PlayerESP:isPlayerVisible(player)
    if not self.wallCheck then return true end
    local localCharacter = self.localPlayer.Character
    if not localCharacter then return false end
    local targetCharacter = player.Character
    if not targetCharacter then return false end
    local localHead = localCharacter:FindFirstChild("Head")
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not localHead or not targetHead then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localCharacter, targetCharacter}
    raycastParams.IgnoreWater = true

    local direction = (targetHead.Position - localHead.Position)
    local raycastResult = Workspace:Raycast(localHead.Position, direction, raycastParams)
    if not raycastResult then return true end
    local hitPart = raycastResult.Instance
    if hitPart and hitPart:IsDescendantOf(targetCharacter) then return true end
    return false
end

function PlayerESP:isEnemy(player)
    if not self.teamCheck then return true end
    local localTeam = self.localPlayer.Team
    local targetTeam = player.Team
    if not localTeam or not targetTeam then return true end
    return localTeam ~= targetTeam
end

function PlayerESP:getNearestVisiblePlayer()
    local localCharacter = self.localPlayer.Character
    if not localCharacter then return nil end
    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return nil end

    local nearestPlayer = nil
    local nearestDistance = self.aimbotRange
    local camera = workspace.CurrentCamera

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= self.localPlayer and player.Character then
            if not self:isEnemy(player) then continue end
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local distance = (head.Position - localHead.Position).Magnitude
                local isVisible = self:isPlayerVisible(player)
                if isVisible and distance <= nearestDistance then
                    if self.aimbotFov >= 360 then
                        nearestPlayer = player
                        nearestDistance = distance
                    else
                        local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local viewportSize = camera.ViewportSize
                            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                            local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                            local distanceToCenter = (screenPos - center).Magnitude
                            local fovRadius = (viewportSize.Y / 2) * math.tan(math.rad(self.aimbotFov / 2))
                            if distanceToCenter <= fovRadius then
                                nearestPlayer = player
                                nearestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPlayer
end

function PlayerESP:aimAtPlayer(player)
    if not player or not player.Character then return end
    local localCharacter = self.localPlayer.Character
    if not localCharacter then return end
    local localHead = localCharacter:FindFirstChild("Head")
    local targetHead = player.Character:FindFirstChild("Head")
    if not localHead or not targetHead then return end

    local camera = workspace.CurrentCamera
    local currentCFrame = camera.CFrame
    local targetPosition = targetHead.Position
    local direction = (targetPosition - currentCFrame.Position).Unit
    local smoothFactor = math.max(0.1, 1 - (self.aimbotStrength / 20))
    local currentLookVector = currentCFrame.LookVector
    local smoothDirection = currentLookVector:Lerp(direction, smoothFactor)

    if self.aimbotStrength >= 15 then
        camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + direction)
    else
        camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + smoothDirection)
    end
end

function PlayerESP:startAimbotHeartbeat()
    if self.aimbotConnection then return end
    self.aimbotConnection = RunService.Heartbeat:Connect(function()
        if self.aimbotEnabled then
            local nearestPlayer = self:getNearestVisiblePlayer()
            if nearestPlayer then
                self.aimbotTarget = nearestPlayer
                self:aimAtPlayer(nearestPlayer)
            else
                self.aimbotTarget = nil
            end
        end
    end)
end

function PlayerESP:stopAimbotHeartbeat()
    if self.aimbotConnection then
        self.aimbotConnection:Disconnect()
        self.aimbotConnection = nil
    end
end

function PlayerESP:toggleAimbot()
    self.aimbotEnabled = not self.aimbotEnabled
    if self.aimbotEnabled then
        self:startAimbotHeartbeat()
        self.aimbotToggleButton.Text = "自瞄: 开启"
        self.aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    else
        self:stopAimbotHeartbeat()
        self.aimbotTarget = nil
        self.aimbotToggleButton.Text = "自瞄: 关闭"
        self.aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    end
end

function PlayerESP:setupAimbotKey()
    if self.aimbotKeyBeganConnection then self.aimbotKeyBeganConnection:Disconnect() end
    if self.aimbotKeyEndedConnection then self.aimbotKeyEndedConnection:Disconnect() end

    self.aimbotKeyBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.aimbotKey:upper()] then
            if not self.aimbotEnabled then
                self.aimbotEnabled = true
                self:startAimbotHeartbeat()
                self.aimbotToggleButton.Text = "自瞄: 按键中"
                self.aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
            end
        end
    end)

    self.aimbotKeyEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.aimbotKey:upper()] then
            if self.aimbotEnabled then
                self.aimbotEnabled = false
                self:stopAimbotHeartbeat()
                self.aimbotTarget = nil
                self.aimbotToggleButton.Text = "自瞄: 关闭"
                self.aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
            end
        end
    end)
end

function PlayerESP:getCrosshairTarget()
    local camera = workspace.CurrentCamera
    local rayOrigin = camera.CFrame.Position
    local rayDirection = camera.CFrame.LookVector * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    if self.localPlayer and self.localPlayer.Character then
        raycastParams.FilterDescendantsInstances = {self.localPlayer.Character}
    end
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorWhichIsA("Model")
        if model then
            local hitPlayer = Players:GetPlayerFromCharacter(model)
            if hitPlayer and hitPlayer ~= self.localPlayer then
                return hitPlayer
            end
        end
    end
    return nil
end

function PlayerESP:pressFire()
    self.triggerbotFiring = true
    pcall(function()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    end)
end

function PlayerESP:releaseFire()
    self.triggerbotFiring = false
    pcall(function()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

function PlayerESP:updateTriggerbot()
    if not self.triggerbotEnabled then
        if self.triggerbotFiring then self:releaseFire() end
        return
    end

    local shouldFire = false
    if self.triggerbotAlwaysOn or self.triggerKeyHeld then
        local target = self:getCrosshairTarget()
        if target then
            if (not self.teamCheck or self:isEnemy(target)) and
               (not self.wallCheck or self:isPlayerVisible(target)) then
                shouldFire = true
            end
        end
    end

    if shouldFire and not self.triggerbotFiring then
        self:pressFire()
    elseif not shouldFire and self.triggerbotFiring then
        self:releaseFire()
    end
end

function PlayerESP:setupTriggerbotKey()
    if self.triggerbotBeganConn then self.triggerbotBeganConn:Disconnect() end
    if self.triggerbotEndedConn then self.triggerbotEndedConn:Disconnect() end

    self.triggerbotBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.triggerbotKey:upper()] then
            self.triggerKeyHeld = true
        end
    end)
    self.triggerbotEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[self.triggerbotKey:upper()] then
            self.triggerKeyHeld = false
        end
    end)
end

function PlayerESP:toggleTriggerbot()
    self.triggerbotEnabled = not self.triggerbotEnabled
    if self.triggerbotEnabled then
        if not self.triggerbotConnection then
            self.triggerbotConnection = RunService.Heartbeat:Connect(function()
                self:updateTriggerbot()
            end)
        end
        self.triggerbotToggleButton.Text = "扳机: 开启"
        self.triggerbotToggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        self:setupTriggerbotKey()
    else
        if self.triggerbotConnection then
            self.triggerbotConnection:Disconnect()
            self.triggerbotConnection = nil
        end
        self:releaseFire()
        self.triggerbotToggleButton.Text = "扳机: 关闭"
        self.triggerbotToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    end
end

function PlayerESP:lockToPlayer()
    local targetName = self.playerNameBox.Text:gsub("%s+", "")
    if targetName == "" then
        self.sitStatusLabel.Text = "状态: 请输入玩家名"
        self.sitStatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        return
    end
    local targetPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) or player.DisplayName:lower():find(targetName:lower()) then
            targetPlayer = player
            break
        end
    end
    if not targetPlayer then
        self.sitStatusLabel.Text = "状态: 玩家不存在"
        self.sitStatusLabel.TextColor3 = Color3.fromRGB(244, 67, 54)
        return
    end
    if targetPlayer == self.localPlayer then
        self.sitStatusLabel.Text = "状态: 不能锁定自己"
        self.sitStatusLabel.TextColor3 = Color3.fromRGB(244, 67, 54)
        return
    end
    self:cancelLock()
    self.sitTarget = targetPlayer
    self.isSitting = true
    local character = self.localPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        self.originalCFrame = character.HumanoidRootPart.CFrame
    end
    self.sitConnection = RunService.Heartbeat:Connect(function()
        self:updateSitting()
    end)
    self.sitStatusLabel.Text = "状态: 锁定到 " .. targetPlayer.Name
    self.sitStatusLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
    self.lockButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self:updatePlayerList()
end

function PlayerESP:cancelLock()
    if self.sitConnection then
        self.sitConnection:Disconnect()
        self.sitConnection = nil
    end
    self.isSitting = false
    self.sitTarget = nil
    if self.originalCFrame then
        local character = self.localPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = self.originalCFrame
        end
        self.originalCFrame = nil
    end
    self.sitStatusLabel.Text = "状态: 未锁定"
    self.sitStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.lockButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    self:updatePlayerList()
end

function PlayerESP:updateSitting()
    if not self.isSitting or not self.sitTarget then return end
    local localCharacter = self.localPlayer.Character
    local targetCharacter = self.sitTarget.Character
    if not localCharacter or not targetCharacter then return end
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not localRoot or not targetHead then return end
    local headPosition = targetHead.Position
    local sitPosition = headPosition + Vector3.new(0, 3, 0)
    localRoot.CFrame = CFrame.new(sitPosition, targetHead.Position)
end

function PlayerESP:getPlayerColor(player, elementType)
    if self.colors.teamBased then
        if player.Team then return player.Team.TeamColor.Color
        else return self.colors.label end
    else
        if elementType == "label" then return self.colors.label
        elseif elementType == "ray" then return self.colors.ray
        elseif elementType == "box" then return self.colors.box
        else return self.colors.label end
    end
end

function PlayerESP:createLabel(player)
    if not player or self.labels[player] then return end
    local drawing = Drawing.new("Text")
    drawing.Text = player.Name
    drawing.Color = self:getPlayerColor(player, "label")
    drawing.Size = 14
    drawing.Center = true
    drawing.Outline = true
    drawing.OutlineColor = Color3.new(0, 0, 0)
    drawing.Visible = self.enabled
    self.labels[player] = { player = player, drawing = drawing }
end

function PlayerESP:createRay(player)
    if not player or self.rays[player] then return end
    local ray = Drawing.new("Line")
    ray.Color = self:getPlayerColor(player, "ray")
    ray.Thickness = 2
    ray.Visible = self.showRays
    self.rays[player] = { player = player, drawing = ray }
end

function PlayerESP:createBox(player)
    if not player or self.boxes[player] then return end
    local box = {
        top = Drawing.new("Line"),
        bottom = Drawing.new("Line"),
        left = Drawing.new("Line"),
        right = Drawing.new("Line")
    }
    local color = self:getPlayerColor(player, "box")
    for _, line in pairs(box) do
        line.Color = color
        line.Thickness = 1
        line.Visible = self.showBoxes
    end
    self.boxes[player] = { player = player, drawing = box }
end

function PlayerESP:removeLabel(player)
    if self.labels[player] and self.labels[player].drawing then
        self.labels[player].drawing:Remove()
        self.labels[player] = nil
    end
end

function PlayerESP:removeRay(player)
    if self.rays[player] and self.rays[player].drawing then
        self.rays[player].drawing:Remove()
        self.rays[player] = nil
    end
end

function PlayerESP:removeBox(player)
    if self.boxes[player] and self.boxes[player].drawing then
        for _, line in pairs(self.boxes[player].drawing) do
            line:Remove()
        end
        self.boxes[player] = nil
    end
end

function PlayerESP:updateCrosshairRays()
    if not self.localPlayer or not self.showRays then return end
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local centerScreen = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    for player, rayData in pairs(self.rays) do
        local ray = rayData.drawing
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                local headPos = head.Position + Vector3.new(0, 1, 0)
                local screenPos, onScreen = camera:WorldToViewportPoint(headPos)

                if onScreen then
                    ray.From = centerScreen
                    ray.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    local direction = Vector2.new(screenPos.X - centerScreen.X, screenPos.Y - centerScreen.Y)
                    if direction.Magnitude > 0 then
                        local edgePoint = centerScreen
                        local maxX = viewportSize.X
                        local maxY = viewportSize.Y
                        local tMin = math.huge
                        if direction.X > 0 then
                            local t = (maxX - centerScreen.X) / direction.X
                            if t > 0 and t < tMin then tMin = t; edgePoint = centerScreen + direction * t end
                        elseif direction.X < 0 then
                            local t = -centerScreen.X / direction.X
                            if t > 0 and t < tMin then tMin = t; edgePoint = centerScreen + direction * t end
                        end
                        if direction.Y > 0 then
                            local t = (maxY - centerScreen.Y) / direction.Y
                            if t > 0 and t < tMin then tMin = t; edgePoint = centerScreen + direction * t end
                        elseif direction.Y < 0 then
                            local t = -centerScreen.Y / direction.Y
                            if t > 0 and t < tMin then tMin = t; edgePoint = centerScreen + direction * t end
                        end
                        ray.From = centerScreen
                        ray.To = edgePoint
                    else
                        ray.From = centerScreen
                        ray.To = centerScreen
                    end
                end
                ray.Visible = true
            else
                ray.Visible = false
            end
        else
            ray.Visible = false
        end
    end
end

function PlayerESP:updateBoxes()
    if not self.localPlayer or not self.showBoxes then return end
    for player, boxData in pairs(self.boxes) do
        local box = boxData.drawing
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            if rootPart and head then
                local height = 5
                local width = 2
                local topPos = head.Position + Vector3.new(0, 1, 0)
                local bottomPos = rootPart.Position - Vector3.new(0, height/2, 0)
                local screenTop, topOnScreen = workspace.CurrentCamera:WorldToViewportPoint(topPos)
                local screenBottom, bottomOnScreen = workspace.CurrentCamera:WorldToViewportPoint(bottomPos)
                if topOnScreen or bottomOnScreen then
                    local centerX = screenTop.X
                    local topY = screenTop.Y
                    local bottomY = screenBottom.Y
                    local halfWidth = width * 10
                    box.top.From = Vector2.new(centerX - halfWidth, topY)
                    box.top.To = Vector2.new(centerX + halfWidth, topY)
                    box.bottom.From = Vector2.new(centerX - halfWidth, bottomY)
                    box.bottom.To = Vector2.new(centerX + halfWidth, bottomY)
                    box.left.From = Vector2.new(centerX - halfWidth, topY)
                    box.left.To = Vector2.new(centerX - halfWidth, bottomY)
                    box.right.From = Vector2.new(centerX + halfWidth, topY)
                    box.right.To = Vector2.new(centerX + halfWidth, bottomY)
                    for _, line in pairs(box) do line.Visible = true end
                else
                    for _, line in pairs(box) do line.Visible = false end
                end
            else
                for _, line in pairs(box) do line.Visible = false end
            end
        else
            for _, line in pairs(box) do line.Visible = false end
        end
    end
end

function PlayerESP:updateLabels(dt)
    if not self.localPlayer or not self.enabled then return end
    local localCharacter = self.localPlayer.Character
    if not localCharacter then return end
    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return end
    for player, labelData in pairs(self.labels) do
        local drawing = labelData.drawing
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                local headPos = head.Position + Vector3.new(0, 2, 0)
                local distance = (headPos - localHead.Position).Magnitude
                drawing.Text = string.format("%s [%.1f]", player.Name, distance)
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(headPos)
                if onScreen then
                    drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                    drawing.Visible = true
                else
                    drawing.Visible = false
                end
            else
                drawing.Visible = false
            end
        else
            drawing.Visible = false
        end
    end
end

function PlayerESP:toggleESP()
    self.enabled = not self.enabled
    for _, labelData in pairs(self.labels) do
        if labelData.drawing then labelData.drawing.Visible = self.enabled end
    end
    self.toggleButton.Text = self.enabled and "标签: 开启" or "标签: 关闭"
    self.toggleButton.BackgroundColor3 = self.enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
end

function PlayerESP:toggleRays()
    self.showRays = not self.showRays
    for _, rayData in pairs(self.rays) do
        if rayData.drawing then rayData.drawing.Visible = self.showRays end
    end
    self.rayToggleButton.Text = self.showRays and "射线: 开启" or "射线: 关闭"
    self.rayToggleButton.BackgroundColor3 = self.showRays and Color3.fromRGB(0, 150, 136) or Color3.fromRGB(244, 67, 54)
end

function PlayerESP:toggleBoxes()
    self.showBoxes = not self.showBoxes
    for _, boxData in pairs(self.boxes) do
        if boxData.drawing then
            for _, line in pairs(boxData.drawing) do
                line.Visible = self.showBoxes
            end
        end
    end
    self.boxToggleButton.Text = self.showBoxes and "方框: 开启" or "方框: 关闭"
    self.boxToggleButton.BackgroundColor3 = self.showBoxes and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(244, 67, 54)
end

function PlayerESP:toggleWallCheck()
    self.wallCheck = not self.wallCheck
    self.wallCheckButton.Text = "墙体检测: " .. (self.wallCheck and "开启" or "关闭")
    self.wallCheckButton.BackgroundColor3 = self.wallCheck and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
end

function PlayerESP:toggleTeamCheck()
    self.teamCheck = not self.teamCheck
    self.teamCheckButton.Text = "队伍区分: " .. (self.teamCheck and "开启" or "关闭")
    self.teamCheckButton.BackgroundColor3 = self.teamCheck and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(244, 67, 54)
end

function PlayerESP:toggleUI()
    self.isExpanded = not self.isExpanded
    if self.isExpanded then
        self.mainFrame.Visible = true
        self.collapsedFrame.Visible = false
    else
        self.mainFrame.Visible = false
        self.collapsedFrame.Visible = true
    end
end

function PlayerESP:createUI()
    if self.screenGui then self.screenGui:Destroy() end
    if self.inputChangedConnection then self.inputChangedConnection:Disconnect() end

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PlayerESPGui"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 250, 0, 250)
    self.mainFrame.Position = UDim2.new(0, 10, 0, 10)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.mainFrame.BorderSizePixel = 1
    self.mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ESP 控制面板"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local collapseButton = Instance.new("TextButton")
    collapseButton.Size = UDim2.new(0, 20, 0, 20)
    collapseButton.Position = UDim2.new(1, -25, 0, 2)
    collapseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    collapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    collapseButton.Text = "-"
    collapseButton.Font = Enum.Font.SourceSansBold
    collapseButton.TextSize = 14
    collapseButton.Parent = titleBar

    local mainScrollFrame = Instance.new("ScrollingFrame")
    mainScrollFrame.Size = UDim2.new(1, 0, 1, -25)
    mainScrollFrame.Position = UDim2.new(0, 0, 0, 25)
    mainScrollFrame.BackgroundTransparency = 1
    mainScrollFrame.BorderSizePixel = 0
    mainScrollFrame.ScrollBarThickness = 8
    mainScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    mainScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    mainScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mainScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    mainScrollFrame.Parent = self.mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainScrollFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = contentFrame

    self.toggleButton = Instance.new("TextButton")
    self.toggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    self.toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self.toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.toggleButton.Text = "标签: 开启"
    self.toggleButton.Font = Enum.Font.SourceSansBold
    self.toggleButton.TextSize = 14
    self.toggleButton.LayoutOrder = 1
    self.toggleButton.Parent = contentFrame

    self.rayToggleButton = Instance.new("TextButton")
    self.rayToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    self.rayToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136)
    self.rayToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.rayToggleButton.Text = "射线: 开启"
    self.rayToggleButton.Font = Enum.Font.SourceSansBold
    self.rayToggleButton.TextSize = 14
    self.rayToggleButton.LayoutOrder = 2
    self.rayToggleButton.Parent = contentFrame

    self.boxToggleButton = Instance.new("TextButton")
    self.boxToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    self.boxToggleButton.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
    self.boxToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.boxToggleButton.Text = "方框: 开启"
    self.boxToggleButton.Font = Enum.Font.SourceSansBold
    self.boxToggleButton.TextSize = 14
    self.boxToggleButton.LayoutOrder = 3
    self.boxToggleButton.Parent = contentFrame

    local aimbotLabel = Instance.new("TextLabel")
    aimbotLabel.Size = UDim2.new(0.9, 0, 0, 20)
    aimbotLabel.BackgroundTransparency = 1
    aimbotLabel.Text = "自瞄功能"
    aimbotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotLabel.TextSize = 16
    aimbotLabel.Font = Enum.Font.SourceSansBold
    aimbotLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotLabel.LayoutOrder = 4
    aimbotLabel.Parent = contentFrame

    self.aimbotToggleButton = Instance.new("TextButton")
    self.aimbotToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    self.aimbotToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    self.aimbotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.aimbotToggleButton.Text = "自瞄: 关闭"
    self.aimbotToggleButton.Font = Enum.Font.SourceSansBold
    self.aimbotToggleButton.TextSize = 14
    self.aimbotToggleButton.LayoutOrder = 5
    self.aimbotToggleButton.Parent = contentFrame

    self.triggerbotToggleButton = Instance.new("TextButton")
    self.triggerbotToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
    self.triggerbotToggleButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    self.triggerbotToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.triggerbotToggleButton.Text = "扳机: 关闭"
    self.triggerbotToggleButton.Font = Enum.Font.SourceSansBold
    self.triggerbotToggleButton.TextSize = 14
    self.triggerbotToggleButton.LayoutOrder = 6
    self.triggerbotToggleButton.Parent = contentFrame

    self.wallCheckButton = Instance.new("TextButton")
    self.wallCheckButton.Size = UDim2.new(0.9, 0, 0, 25)
    self.wallCheckButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self.wallCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.wallCheckButton.Text = "墙体检测: 开启"
    self.wallCheckButton.Font = Enum.Font.SourceSans
    self.wallCheckButton.TextSize = 12
    self.wallCheckButton.LayoutOrder = 7
    self.wallCheckButton.Parent = contentFrame

    self.teamCheckButton = Instance.new("TextButton")
    self.teamCheckButton.Size = UDim2.new(0.9, 0, 0, 25)
    self.teamCheckButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    self.teamCheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.teamCheckButton.Text = "队伍区分: 开启"
    self.teamCheckButton.Font = Enum.Font.SourceSans
    self.teamCheckButton.TextSize = 12
    self.teamCheckButton.LayoutOrder = 8
    self.teamCheckButton.Parent = contentFrame

    local aimbotSettingsLabel = Instance.new("TextLabel")
    aimbotSettingsLabel.Size = UDim2.new(0.9, 0, 0, 15)
    aimbotSettingsLabel.BackgroundTransparency = 1
    aimbotSettingsLabel.Text = "自瞄设置:"
    aimbotSettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    aimbotSettingsLabel.TextSize = 12
    aimbotSettingsLabel.Font = Enum.Font.SourceSans
    aimbotSettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotSettingsLabel.LayoutOrder = 9
    aimbotSettingsLabel.Parent = contentFrame

    local aimbotKeyFrame = Instance.new("Frame")
    aimbotKeyFrame.Size = UDim2.new(0.9, 0, 0, 25)
    aimbotKeyFrame.BackgroundTransparency = 1
    aimbotKeyFrame.LayoutOrder = 10
    aimbotKeyFrame.Parent = contentFrame
    local aimbotKeyLabel = Instance.new("TextLabel")
    aimbotKeyLabel.Size = UDim2.new(0.5, 0, 1, 0)
    aimbotKeyLabel.BackgroundTransparency = 1
    aimbotKeyLabel.Text = "自瞄按键:"
    aimbotKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotKeyLabel.TextSize = 12
    aimbotKeyLabel.Font = Enum.Font.SourceSans
    aimbotKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotKeyLabel.Parent = aimbotKeyFrame
    self.aimbotKeyBox = Instance.new("TextBox")
    self.aimbotKeyBox.Size = UDim2.new(0.4, 0, 0.7, 0)
    self.aimbotKeyBox.Position = UDim2.new(0.55, 0, 0.15, 0)
    self.aimbotKeyBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.aimbotKeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.aimbotKeyBox.Text = self.aimbotKey
    self.aimbotKeyBox.Font = Enum.Font.SourceSans
    self.aimbotKeyBox.TextSize = 12
    self.aimbotKeyBox.Parent = aimbotKeyFrame

    local aimbotRangeFrame = Instance.new("Frame")
    aimbotRangeFrame.Size = UDim2.new(0.9, 0, 0, 25)
    aimbotRangeFrame.BackgroundTransparency = 1
    aimbotRangeFrame.LayoutOrder = 11
    aimbotRangeFrame.Parent = contentFrame
    local aimbotRangeLabel = Instance.new("TextLabel")
    aimbotRangeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    aimbotRangeLabel.BackgroundTransparency = 1
    aimbotRangeLabel.Text = "自瞄范围:"
    aimbotRangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotRangeLabel.TextSize = 12
    aimbotRangeLabel.Font = Enum.Font.SourceSans
    aimbotRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotRangeLabel.Parent = aimbotRangeFrame
    self.aimbotRangeBox = Instance.new("TextBox")
    self.aimbotRangeBox.Size = UDim2.new(0.4, 0, 0.7, 0)
    self.aimbotRangeBox.Position = UDim2.new(0.55, 0, 0.15, 0)
    self.aimbotRangeBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.aimbotRangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.aimbotRangeBox.Text = tostring(self.aimbotRange)
    self.aimbotRangeBox.Font = Enum.Font.SourceSans
    self.aimbotRangeBox.TextSize = 12
    self.aimbotRangeBox.Parent = aimbotRangeFrame

    local aimbotFovFrame = Instance.new("Frame")
    aimbotFovFrame.Size = UDim2.new(0.9, 0, 0, 25)
    aimbotFovFrame.BackgroundTransparency = 1
    aimbotFovFrame.LayoutOrder = 12
    aimbotFovFrame.Parent = contentFrame
    local aimbotFovLabel = Instance.new("TextLabel")
    aimbotFovLabel.Size = UDim2.new(0.5, 0, 1, 0)
    aimbotFovLabel.BackgroundTransparency = 1
    aimbotFovLabel.Text = "自瞄视野:"
    aimbotFovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotFovLabel.TextSize = 12
    aimbotFovLabel.Font = Enum.Font.SourceSans
    aimbotFovLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotFovLabel.Parent = aimbotFovFrame
    self.aimbotFovBox = Instance.new("TextBox")
    self.aimbotFovBox.Size = UDim2.new(0.4, 0, 0.7, 0)
    self.aimbotFovBox.Position = UDim2.new(0.55, 0, 0.15, 0)
    self.aimbotFovBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.aimbotFovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.aimbotFovBox.Text = tostring(self.aimbotFov)
    self.aimbotFovBox.Font = Enum.Font.SourceSans
    self.aimbotFovBox.TextSize = 12
    self.aimbotFovBox.Parent = aimbotFovFrame

    local aimbotStrengthFrame = Instance.new("Frame")
    aimbotStrengthFrame.Size = UDim2.new(0.9, 0, 0, 25)
    aimbotStrengthFrame.BackgroundTransparency = 1
    aimbotStrengthFrame.LayoutOrder = 13
    aimbotStrengthFrame.Parent = contentFrame
    local aimbotStrengthLabel = Instance.new("TextLabel")
    aimbotStrengthLabel.Size = UDim2.new(0.5, 0, 1, 0)
    aimbotStrengthLabel.BackgroundTransparency = 1
    aimbotStrengthLabel.Text = "自瞄强度:"
    aimbotStrengthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotStrengthLabel.TextSize = 12
    aimbotStrengthLabel.Font = Enum.Font.SourceSans
    aimbotStrengthLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotStrengthLabel.Parent = aimbotStrengthFrame
    self.aimbotStrengthBox = Instance.new("TextBox")
    self.aimbotStrengthBox.Size = UDim2.new(0.4, 0, 0.7, 0)
    self.aimbotStrengthBox.Position = UDim2.new(0.55, 0, 0.15, 0)
    self.aimbotStrengthBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.aimbotStrengthBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.aimbotStrengthBox.Text = tostring(self.aimbotStrength)
    self.aimbotStrengthBox.Font = Enum.Font.SourceSans
    self.aimbotStrengthBox.TextSize = 12
    self.aimbotStrengthBox.Parent = aimbotStrengthFrame

    local aimbotInfo = Instance.new("TextLabel")
    aimbotInfo.Size = UDim2.new(0.9, 0, 0, 30)
    aimbotInfo.BackgroundTransparency = 1
    aimbotInfo.Text = "视野: 1-360 (360=全视角)\n强度: 1-20 (数值越大越强)"
    aimbotInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
    aimbotInfo.TextSize = 10
    aimbotInfo.Font = Enum.Font.SourceSans
    aimbotInfo.TextXAlignment = Enum.TextXAlignment.Left
    aimbotInfo.TextYAlignment = Enum.TextYAlignment.Top
    aimbotInfo.LayoutOrder = 14
    aimbotInfo.Parent = contentFrame

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0.9, 0, 0, 20)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "颜色设置"
    colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorLabel.TextSize = 16
    colorLabel.Font = Enum.Font.SourceSansBold
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.LayoutOrder = 15
    colorLabel.Parent = contentFrame

    local labelColorFrame = self:createColorPicker(contentFrame, UDim2.new(0, 0, 0, 0), self.colors.label, "标签", function(color)
        self.colors.label = color
        self:updateAllLabelsColor()
    end)
    labelColorFrame.LayoutOrder = 16

    local rayColorFrame = self:createColorPicker(contentFrame, UDim2.new(0, 0, 0, 0), self.colors.ray, "射线", function(color)
        self.colors.ray = color
        self:updateAllRaysColor()
    end)
    rayColorFrame.LayoutOrder = 17

    local boxColorFrame = self:createColorPicker(contentFrame, UDim2.new(0, 0, 0, 0), self.colors.box, "方框", function(color)
        self.colors.box = color
        self:updateAllBoxesColor()
    end)
    boxColorFrame.LayoutOrder = 18

    local teamToggle = Instance.new("TextButton")
    teamToggle.Size = UDim2.new(0.9, 0, 0, 25)
    teamToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    teamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    teamToggle.Text = "队伍颜色: 关闭"
    teamToggle.Font = Enum.Font.SourceSans
    teamToggle.TextSize = 12
    teamToggle.LayoutOrder = 19
    teamToggle.Parent = contentFrame
    teamToggle.MouseButton1Click:Connect(function()
        self.colors.teamBased = not self.colors.teamBased
        teamToggle.Text = "队伍颜色: " .. (self.colors.teamBased and "开启" or "关闭")
        teamToggle.BackgroundColor3 = self.colors.teamBased and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(80, 80, 80)
        self:updateAllColors()
    end)

    local sitLabel = Instance.new("TextLabel")
    sitLabel.Size = UDim2.new(0.9, 0, 0, 20)
    sitLabel.BackgroundTransparency = 1
    sitLabel.Text = "坐头功能"
    sitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sitLabel.TextSize = 16
    sitLabel.Font = Enum.Font.SourceSansBold
    sitLabel.TextXAlignment = Enum.TextXAlignment.Left
    sitLabel.LayoutOrder = 20
    sitLabel.Parent = contentFrame

    self.playerNameBox = Instance.new("TextBox")
    self.playerNameBox.Size = UDim2.new(0.9, 0, 0, 25)
    self.playerNameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.playerNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.playerNameBox.PlaceholderText = "输入玩家名或点击下方选择"
    self.playerNameBox.Text = ""
    self.playerNameBox.Font = Enum.Font.SourceSans
    self.playerNameBox.TextSize = 14
    self.playerNameBox.LayoutOrder = 21
    self.playerNameBox.Parent = contentFrame

    local playerListContainer = Instance.new("Frame")
    playerListContainer.Size = UDim2.new(0.9, 0, 0, 80)
    playerListContainer.BackgroundTransparency = 1
    playerListContainer.LayoutOrder = 22
    playerListContainer.Parent = contentFrame

    local playerListTitle = Instance.new("TextLabel")
    playerListTitle.Size = UDim2.new(1, 0, 0, 15)
    playerListTitle.BackgroundTransparency = 1
    playerListTitle.Text = "快速选择玩家:"
    playerListTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    playerListTitle.TextSize = 11
    playerListTitle.Font = Enum.Font.SourceSans
    playerListTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerListTitle.Parent = playerListContainer

    self:createPlayerList(playerListContainer)
    local playerListFrame = playerListContainer:FindFirstChild("PlayerListFrame")
    if playerListFrame then playerListFrame.Position = UDim2.new(0, 0, 0, 18) end

    self.lockButton = Instance.new("TextButton")
    self.lockButton.Size = UDim2.new(0.43, 0, 0, 25)
    self.lockButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
    self.lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.lockButton.Text = "锁定"
    self.lockButton.Font = Enum.Font.SourceSansBold
    self.lockButton.TextSize = 14
    self.lockButton.LayoutOrder = 23
    self.lockButton.Parent = contentFrame

    self.cancelButton = Instance.new("TextButton")
    self.cancelButton.Size = UDim2.new(0.43, 0, 0, 25)
    self.cancelButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    self.cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.cancelButton.Text = "取消"
    self.cancelButton.Font = Enum.Font.SourceSansBold
    self.cancelButton.TextSize = 14
    self.cancelButton.LayoutOrder = 24
    self.cancelButton.Parent = contentFrame

    self.sitStatusLabel = Instance.new("TextLabel")
    self.sitStatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
    self.sitStatusLabel.BackgroundTransparency = 1
    self.sitStatusLabel.Text = "状态: 未锁定"
    self.sitStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.sitStatusLabel.TextSize = 12
    self.sitStatusLabel.Font = Enum.Font.SourceSans
    self.sitStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.sitStatusLabel.LayoutOrder = 25
    self.sitStatusLabel.Parent = contentFrame

    self.collapsedFrame = Instance.new("TextButton")
    self.collapsedFrame.Size = UDim2.new(0, 40, 0, 40)
    self.collapsedFrame.Position = UDim2.new(0, 10, 0, 10)
    self.collapsedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.collapsedFrame.BorderSizePixel = 1
    self.collapsedFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    self.collapsedFrame.Text = "ESP"
    self.collapsedFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.collapsedFrame.TextSize = 12
    self.collapsedFrame.Font = Enum.Font.SourceSansBold
    self.collapsedFrame.Visible = false
    self.collapsedFrame.Parent = self.screenGui

    self.toggleButton.MouseButton1Click:Connect(function() self:toggleESP() end)
    self.rayToggleButton.MouseButton1Click:Connect(function() self:toggleRays() end)
    self.boxToggleButton.MouseButton1Click:Connect(function() self:toggleBoxes() end)
    self.aimbotToggleButton.MouseButton1Click:Connect(function() self:toggleAimbot() end)
    self.triggerbotToggleButton.MouseButton1Click:Connect(function() self:toggleTriggerbot() end)
    self.wallCheckButton.MouseButton1Click:Connect(function() self:toggleWallCheck() end)
    self.teamCheckButton.MouseButton1Click:Connect(function() self:toggleTeamCheck() end)
    self.lockButton.MouseButton1Click:Connect(function() self:lockToPlayer() end)
    self.cancelButton.MouseButton1Click:Connect(function() self:cancelLock() end)
    collapseButton.MouseButton1Click:Connect(function() self:toggleUI() end)
    self.collapsedFrame.MouseButton1Click:Connect(function() self:toggleUI() end)

    self.aimbotKeyBox.FocusLost:Connect(function()
        local newKey = self.aimbotKeyBox.Text:lower()
        if newKey ~= "" and #newKey == 1 then
            self.aimbotKey = newKey
            self:setupAimbotKey()
        else
            self.aimbotKeyBox.Text = self.aimbotKey
        end
    end)
    self.aimbotRangeBox.FocusLost:Connect(function()
        local newRange = tonumber(self.aimbotRangeBox.Text)
        if newRange and newRange > 0 then self.aimbotRange = newRange else self.aimbotRangeBox.Text = tostring(self.aimbotRange) end
    end)
    self.aimbotFovBox.FocusLost:Connect(function()
        local newFov = tonumber(self.aimbotFovBox.Text)
        if newFov and newFov >= 1 and newFov <= 360 then self.aimbotFov = newFov else self.aimbotFovBox.Text = tostring(self.aimbotFov) end
    end)
    self.aimbotStrengthBox.FocusLost:Connect(function()
        local newStrength = tonumber(self.aimbotStrengthBox.Text)
        if newStrength and newStrength >= 1 and newStrength <= 20 then self.aimbotStrength = newStrength else self.aimbotStrengthBox.Text = tostring(self.aimbotStrength) end
    end)

    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.isDragging = true
            self.dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            self.frameStartPos = UDim2.new(0, self.mainFrame.Position.X.Offset, 0, self.mainFrame.Position.Y.Offset)
        end
    end
    local function endDrag(input)
        if self.isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            self.isDragging = false
        end
    end
    local function updateDrag(input)
        if self.isDragging and self.isExpanded then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - self.dragStartPos
            self.mainFrame.Position = UDim2.new(
                0, self.frameStartPos.X.Offset + delta.X,
                0, self.frameStartPos.Y.Offset + delta.Y
            )
        end
    end
    titleBar.InputBegan:Connect(startDrag)
    UserInputService.InputEnded:Connect(endDrag)
    self.inputChangedConnection = UserInputService.InputChanged:Connect(updateDrag)

    self:setupAimbotKey()
    self:setupTriggerbotKey()
end

function PlayerESP:updateAllLabelsColor()
    for player, labelData in pairs(self.labels) do
        if labelData.drawing then labelData.drawing.Color = self:getPlayerColor(player, "label") end
    end
end
function PlayerESP:updateAllRaysColor()
    for player, rayData in pairs(self.rays) do
        if rayData.drawing then rayData.drawing.Color = self:getPlayerColor(player, "ray") end
    end
end
function PlayerESP:updateAllBoxesColor()
    for player, boxData in pairs(self.boxes) do
        if boxData.drawing then
            local color = self:getPlayerColor(player, "box")
            for _, line in pairs(boxData.drawing) do line.Color = color end
        end
    end
end
function PlayerESP:updateAllColors()
    self:updateAllLabelsColor()
    self:updateAllRaysColor()
    self:updateAllBoxesColor()
end

function PlayerESP:init()
    self.localPlayer = Players.LocalPlayer
    self:createUI()
    Players.PlayerAdded:Connect(function(player)
        if player ~= self.localPlayer then
            self:createLabel(player)
            self:createRay(player)
            self:createBox(player)
        end
        self:updatePlayerList()
    end)
    Players.PlayerRemoving:Connect(function(player)
        self:removeLabel(player)
        self:removeRay(player)
        self:removeBox(player)
        if player == self.sitTarget then self:cancelLock() end
        self:updatePlayerList()
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= self.localPlayer then
            self:createLabel(player)
            self:createRay(player)
            self:createBox(player)
        end
    end
    RunService.Heartbeat:Connect(function(dt)
        self:updateLabels(dt)
        self:updateCrosshairRays()
        self:updateBoxes()
    end)
end

PlayerESP:init()

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == PlayerESP.localPlayer then
        PlayerESP:cancelLock()
        if PlayerESP.aimbotConnection then PlayerESP.aimbotConnection:Disconnect() end
        if PlayerESP.triggerbotConnection then PlayerESP.triggerbotConnection:Disconnect() end
        if PlayerESP.inputChangedConnection then PlayerESP.inputChangedConnection:Disconnect() end
        if PlayerESP.aimbotKeyBeganConnection then PlayerESP.aimbotKeyBeganConnection:Disconnect() end
        if PlayerESP.aimbotKeyEndedConnection then PlayerESP.aimbotKeyEndedConnection:Disconnect() end
        if PlayerESP.triggerbotBeganConn then PlayerESP.triggerbotBeganConn:Disconnect() end
        if PlayerESP.triggerbotEndedConn then PlayerESP.triggerbotEndedConn:Disconnect() end
        PlayerESP:releaseFire()
        for _, labelData in pairs(PlayerESP.labels) do if labelData.drawing then labelData.drawing:Remove() end end
        for _, rayData in pairs(PlayerESP.rays) do if rayData.drawing then rayData.drawing:Remove() end end
        for _, boxData in pairs(PlayerESP.boxes) do
            if boxData.drawing then for _, line in pairs(boxData.drawing) do line:Remove() end end
        end
        if PlayerESP.screenGui then PlayerESP.screenGui:Destroy() end
    end
end)