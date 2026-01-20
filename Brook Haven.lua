local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Player Utilities",
    LoadingTitle = "Rayfield Interface",
    LoadingSubtitle = "by Assistant",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UtilityConfig",
        FileName = "Config"
    }
})

-- TABS
local MainTab = Window:CreateTab("Main", 4483362458)
local LocalTab = Window:CreateTab("Local Player", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local targetPlayer = nil
local orbitConnection = nil
local noclipConnection = nil

local orbitAngle = 0
local orbitRadius = 5
local orbitSpeed = 5
local noclipEnabled = false

-- Helper: Get Player List
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- === MAIN TAB ===
local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(Option)
        targetPlayer = Players:FindFirstChild(Option[1])
    end,
})

MainTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        PlayerDropdown:Set(getPlayerList())
    end,
})

MainTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        else
            Rayfield:Notify({Title = "Error", Content = "Select a valid player!", Duration = 3})
        end
    end,
})

MainTab:CreateToggle({
    Name = "Orbit Player",
    CurrentValue = false,
    Flag = "OrbitToggle",
    Callback = function(Value)
        if Value then
            if not targetPlayer then 
                Rayfield:Notify({Title = "Warning", Content = "Select a player first!", Duration = 3})
                return 
            end
            orbitConnection = RunService.Heartbeat:Connect(function(dt)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    orbitAngle = orbitAngle + (orbitSpeed * dt)
                    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                    local offset = Vector3.new(math.cos(orbitAngle) * orbitRadius, 0, math.sin(orbitAngle) * orbitRadius)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + offset, targetPos)
                end
            end)
        else
            if orbitConnection then orbitConnection:Disconnect() orbitConnection = nil end
        end
    end,
})

-- === LOCAL PLAYER TAB ===

LocalTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

LocalTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

LocalTab:CreateToggle({
    Name = "Noclip (after disabling wait a few seconds for it to disable.)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            noclipConnection = RunService.Stepped:Connect(function()
                if noclipEnabled and LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then 
                noclipConnection:Disconnect() 
                noclipConnection = nil 
            end
        end
    end,
})
