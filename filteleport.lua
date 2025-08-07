local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Переменная скорости
local SpeedValue = 16

-- Функция телепорта сзади цели
local function teleportBehind(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetRoot = target.Character.HumanoidRootPart
    local backPos = targetRoot.CFrame * CFrame.new(0, 0, 5)
    root.CFrame = backPos
end

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
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

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 100, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 0, 350)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Text = "Speed: "..SpeedValue
SpeedLabel.Parent = Frame

local SpeedUpButton = Instance.new("TextButton")
SpeedUpButton.Size = UDim2.new(0, 50, 0, 30)
SpeedUpButton.Position = UDim2.new(0, 120, 0, 350)
SpeedUpButton.Text = "+Speed"
SpeedUpButton.Parent = Frame

local SpeedDownButton = Instance.new("TextButton")
SpeedDownButton.Size = UDim2.new(0, 50, 0, 30)
SpeedDownButton.Position = UDim2.new(0, 180, 0, 350)
SpeedDownButton.Text = "-Speed"
SpeedDownButton.Parent = Frame

SpeedUpButton.MouseButton1Click:Connect(function()
    SpeedValue = SpeedValue + 1
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
    end
    SpeedLabel.Text = "Speed: "..SpeedValue
end)

SpeedDownButton.MouseButton1Click:Connect(function()
    SpeedValue = SpeedValue - 1
    if SpeedValue < 1 then SpeedValue = 1 end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
    end
    SpeedLabel.Text = "Speed: "..SpeedValue
end)

-- Автовосстановление скорости и GUI после смерти
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = SpeedValue
    end
    ScreenGui.Enabled = true
end)

-- Кнопка телепорта к первому игроку сзади него
local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0, 180, 0, 40)
TeleportButton.Position = UDim2.new(0, 10, 0, 300)
TeleportButton.Text = "Телепорт к первому игроку"
TeleportButton.Parent = Frame

TeleportButton.MouseButton1Click:Connect(function()
    local players = Players:GetPlayers()
    if #players > 1 then
        teleportBehind(players[2])
    end
end)
