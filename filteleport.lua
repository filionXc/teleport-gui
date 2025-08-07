loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Убираем старый GUI, если есть
if player:FindFirstChild("PlayerGui") then
    local old = player.PlayerGui:FindFirstChild("TargetTeleportGui")
    if old then old:Destroy() end
end

local SPEED_DELTA = 1
local FOLLOW_OFFSET = CFrame.new(0, 0, 5) -- 5 студий сзади

local function createGui()
    if player.PlayerGui:FindFirstChild("TargetTeleportGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TargetTeleportGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 440)
    frame.Position = UDim2.new(0, 10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(0.55, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Target Teleport"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Signature
    local sig = Instance.new("TextLabel", frame)
    sig.Size = UDim2.new(0.25, 0, 0, 30)
    sig.Position = UDim2.new(0.55, 0, 0, 0)
    sig.BackgroundTransparency = 1
    sig.Text = "by filion"
    sig.TextColor3 = Color3.fromRGB(150, 150, 150)
    sig.Font = Enum.Font.GothamItalic
    sig.TextSize = 16
    sig.TextXAlignment = Enum.TextXAlignment.Right

    -- Close button
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.1, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.8, 0, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✖️"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20

    -- Scrolling frame for targets
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, -160)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)

    -- Kill Aura
    local killAuraEnabled = false
    local killBtn = Instance.new("TextButton", frame)
    killBtn.Size = UDim2.new(1, -20, 0, 40)
    killBtn.Position = UDim2.new(0, 10, 1, -130)
    killBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    killBtn.TextColor3 = Color3.new(1, 1, 1)
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextSize = 18
    killBtn.Text = "Kill Aura: OFF"

    -- Speed buttons
    local speedUp = Instance.new("TextButton", frame)
    speedUp.Size = UDim2.new(0.45, -5, 0, 30)
    speedUp.Position = UDim2.new(0, 10, 1, -90)
    speedUp.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedUp.TextColor3 = Color3.fromRGB(0, 255, 0)
    speedUp.Font = Enum.Font.GothamBold
    speedUp.TextSize = 18
    speedUp.Text = "+Speed"

    local speedDown = Instance.new("TextButton", frame)
    speedDown.Size = UDim2.new(0.45, -5, 0, 30)
    speedDown.Position = UDim2.new(0.55, 0, 1, -90)
    speedDown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedDown.TextColor3 = Color3.fromRGB(255, 0, 0)
    speedDown.Font = Enum.Font.GothamBold
    speedDown.TextSize = 18
    speedDown.Text = "-Speed"

    -- Follow toggle
    local followEnabled = false
    local followBtn = Instance.new("TextButton", frame)
    followBtn.Size = UDim2.new(1, -20, 0, 30)
    followBtn.Position = UDim2.new(0, 10, 1, -50)
    followBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
    followBtn.TextColor3 = Color3.new(1, 1, 1)
    followBtn.Font = Enum.Font.GothamBold
    followBtn.TextSize = 18
    followBtn.Text = "Start Follow"

    -- Open button
    local openBtn = Instance.new("TextButton", screenGui)
    openBtn.Size = UDim2.new(0, 40, 0, 40)
    openBtn.Position = UDim2.new(0, 10, 0, 10)
    openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextSize = 24
    openBtn.Text = "👁️"
    openBtn.Visible = false

    -- Drag logic
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function update(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
    title.InputBegan:Connect(startDrag)
    sig.InputBegan:Connect(startDrag)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then update(input) end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false openBtn.Visible = true
    end)
    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = true openBtn.Visible = false
    end)

    -- Player teleport list
    local function updateList()
        for _, v in ipairs(scroll:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, targ in ipairs(Players:GetPlayers()) do
            if targ ~= player then
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 16
                btn.Text = targ.Name
                btn.MouseButton1Click:Connect(function()
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local tchar = targ.Character
                    local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
                    if hrp and thrp then
                        hrp.CFrame = thrp.CFrame * FOLLOW_OFFSET
                    end
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    updateList()
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)

    -- KillAura logic
    RunService.Heartbeat:Connect(function()
        if killAuraEnabled then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, targ in ipairs(Players:GetPlayers()) do
                    if targ ~= player then
                        local tch = targ.Character
                        local thrp = tch and tch:FindFirstChild("HumanoidRootPart")
                        local hum = tch and tch:FindFirstChildOfClass("Humanoid")
                        if thrp and hum and hum.Health > 0 and (hrp.Position - thrp.Position).Magnitude <= 10 then
                            hrp.CFrame = thrp.CFrame * FOLLOW_OFFSET
                            hum:TakeDamage(10)
                        end
                    end
                end
            end
        end
        if followEnabled then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local targ = chosenTarget
            if hrp and targ and targ.Character and targ.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targ.Character.HumanoidRootPart.CFrame * FOLLOW_OFFSET
            end
        end
    end)

    killBtn.MouseButton1Click:Connect(function()
        killAuraEnabled = not killAuraEnabled
        killBtn.Text = "Kill Aura: " .. (killAuraEnabled and "ON" or "OFF")
    end)

    speedUp.MouseButton1Click:Connect(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed += SPEED_DELTA end
    end)
    speedDown.MouseButton1Click:Connect(function()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = math.max(0, hum.WalkSpeed - SPEED_DELTA) end
    end)

    -- Follow toggle behavior
    local chosenTarget = nil
    followBtn.MouseButton1Click:Connect(function()
        if followEnabled then
            followEnabled = false
            followBtn.Text = "Start Follow"
            chosenTarget = nil
        else
            followEnabled = true
            followBtn.Text = "Stop Follow"
            -- брать ближайшего или последний телепорт
            chosenTarget = Players:GetPlayers():FindFirst(function(p) return p ~= player end)
        end
    end)
end

createGui()
player.CharacterAdded:Connect(function()
    wait(1)
    createGui()
end)
]])()
