local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Speed setting
local SpeedValue = 16
local followTarget = nil
local isFollowing = false

-- Teleport behind a player
local function teleportBehind(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetRoot = target.Character.HumanoidRootPart
    local backPos = targetRoot.CFrame * CFrame.new(0, 0, 5)
    root.CFrame = backPos
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 500)
Frame.Position = UDim2.new(0.5, -150, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "✖"
CloseButton.Parent = Frame

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 30, 0, 30)
OpenButton.Position = UDim2.new(0, 5, 0, 5)
OpenButton.Text = "👁️"
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    OpenButton.Visible = false
end)

-- Speed Controls
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 100, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 1, -40)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Text = "Speed: "..SpeedValue
SpeedLabel.Parent = Frame

local SpeedUpButton = Instance.new("TextButton")
SpeedUpButton.Size = UDim2.new(0, 50, 0, 30)
SpeedUpButton.Position = UDim2.new(0, 120, 1, -40)
SpeedUpButton.Text = "+Speed"
SpeedUpButton.Parent = Frame

local SpeedDownButton = Instance.new("TextButton")
SpeedDownButton.Size = UDim2.new(0, 50, 0, 30)
SpeedDownButton.Position = UDim2.new(0, 180, 1, -40)
SpeedDownButton.Text = "-Speed"
SpeedDownButton.Parent = Frame

SpeedUpButton.MouseButton1Click:Connect(function()
    SpeedValue += 1
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
    end
    SpeedLabel.Text = "Speed: "..SpeedValue
end)

SpeedDownButton.MouseButton1Click:Connect(function()
    SpeedValue -= 1
    if SpeedValue < 1 then SpeedValue = 1 end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
    end
    SpeedLabel.Text = "Speed: "..SpeedValue
end)

-- Auto reset speed and GUI
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = SpeedValue
    end
    ScreenGui.Enabled = true
end)

-- Scrolling Frame for player list
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(0, 280, 0, 300)
PlayerListFrame.Position = UDim2.new(0, 10, 0, 40)
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.ScrollBarThickness = 8
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Parent = Frame

local function updatePlayerList()
    PlayerListFrame:ClearAllChildren()
    local yPos = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 30)
            Button.Position = UDim2.new(0, 5, 0, yPos)
            Button.Text = "Follow: " .. player.Name
            Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Button.TextColor3 = Color3.new(1,1,1)
            Button.Parent = PlayerListFrame
            yPos += 35

            Button.MouseButton1Click:Connect(function()
                followTarget = player
                isFollowing = true
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Stop following button
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0, 280, 0, 30)
StopButton.Position = UDim2.new(0, 10, 1, -80)
StopButton.Text = "Stop Following"
StopButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
StopButton.TextColor3 = Color3.new(1,1,1)
StopButton.Parent = Frame

StopButton.MouseButton1Click:Connect(function()
    isFollowing = false
    followTarget = nil
end)

-- Continuous teleport loop
RunService.RenderStepped:Connect(function()
    if isFollowing and followTarget then
        teleportBehind(followTarget)
    end
end)
