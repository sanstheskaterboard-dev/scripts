-- Key System for Nagi Hub
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local CorrectKey = "NagiHubKey"
local ScriptURL = "https://raw.githubusercontent.com/sanstheskaterboard-dev/scripts/refs/heads/main/Babft.lua"
local DiscordLink = "https://discord.gg/MQAut7egGp"

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NagiHubKeySystem"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 200)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "NAGI HUB | KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- TextBox
local KeyBox = Instance.new("TextBox")
KeyBox.Name = "KeyBox"
KeyBox.Parent = MainFrame
KeyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Enter Key Here..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14

local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 8)
UICorner_2.Parent = KeyBox

-- Redeem Button
local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Name = "RedeemBtn"
RedeemBtn.Parent = MainFrame
RedeemBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
RedeemBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
RedeemBtn.Size = UDim2.new(0.38, 0, 0, 40)
RedeemBtn.Font = Enum.Font.GothamBold
RedeemBtn.Text = "Redeem Key"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.TextSize = 14

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 8)
UICorner_3.Parent = RedeemBtn

-- Get Key Button
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Name = "GetKeyBtn"
GetKeyBtn.Parent = MainFrame
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
GetKeyBtn.Position = UDim2.new(0.52, 0, 0.65, 0)
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 40)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.TextSize = 14

local UICorner_4 = Instance.new("UICorner")
UICorner_4.CornerRadius = UDim.new(0, 8)
UICorner_4.Parent = GetKeyBtn

-- Notification Function
local function notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "Nagi Hub",
        Text = msg,
        Duration = 5
    })
end

-- Button Logic
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(DiscordLink)
        notify("Discord link copied to clipboard!")
    else
        notify("Your executor doesn't support clipboard!")
    end
end)

RedeemBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == CorrectKey then
        notify("Key correct! Loading script...")
        ScreenGui:Destroy()
        loadstring(game:HttpGet(ScriptURL))()
    else
        notify("Incorrect key!")
    end
end)

-- Styling the Frame with a subtle stroke
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Parent = MainFrame
