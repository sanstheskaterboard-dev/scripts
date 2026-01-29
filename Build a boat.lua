local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nagi Hub | Build A Boat For Treasure",
   LoadingTitle = "Nagi Hub",
   LoadingSubtitle = "by Nagi",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "NagiHub",
      FileName = "BABFT_Config"
   },
   Discord = {
      Enabled = true,
      Invite = "MQAut7egGp",
      RememberJoins = true
   },
   KeySystem = false
})

-- Variables
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local nagi = {
    goldfarm = false,
    candyfarm = false,
    autorejoin = false,
    walkspeed = 16,
    jumppower = 50
}

-- Anti-AFK
local GC = getconnections or get_signal_cons
if GC then
    for i,v in pairs(GC(plr.Idled)) do
        if v["Disable"] then v["Disable"](v)
        elseif v["Disconnect"] then v["Disconnect"](v) end
    end
else
    plr.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Update Character Stats
plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = nagi.walkspeed
    hum.UseJumpPower = true
    hum.JumpPower = nagi.jumppower
end)

-- Tabs
local MainTab = Window:CreateTab("Main", "home")
local EventTab = Window:CreateTab("Event", "star")
local SettingsTab = Window:CreateTab("Settings", "settings")
local CreditsTab = Window:CreateTab("Credits", "info")

-- Status Paragraph
local StatusPara = MainTab:CreateParagraph({Title = "Farm Status", Content = "Standby"})

local function updateStatus(title, content)
    StatusPara:Set({Title = title, Content = content or ""})
end

-- Stuck Detection (Conditional: Far from Stage 9)
local lastPos = Vector3.new(0,0,0)
local stuckTimer = 0

task.spawn(function()
    while task.wait(1) do
        if nagi.goldfarm and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            local stage9 = workspace.BoatStages.NormalStages:FindFirstChild("CaveStage9")
            
            if stage9 and hum.Health > 0 then
                local distToStage9 = (root.Position - stage9.DarknessPart.Position).Magnitude
                
                -- Only check for stuck if more than 300 studs away from Stage 9
                if distToStage9 > 300 then
                    local moveDist = (root.Position - lastPos).Magnitude
                    if moveDist < 1 then
                        stuckTimer = stuckTimer + 1
                    else
                        stuckTimer = 0
                    end
                    
                    if stuckTimer >= 3 then
                        updateStatus("Anti-Stuck", "Stuck detected far from end! Resetting...")
                        hum.Health = 0
                        stuckTimer = 0
                    end
                else
                    stuckTimer = 0 -- Reset timer if we are near the end
                end
            end
            lastPos = root.Position
        else
            stuckTimer = 0
        end
    end
end)

-- Server Runtime Display
local RuntimeLabel = SettingsTab:CreateParagraph({Title = "Server Stats", Content = "Calculating runtime..."})

task.spawn(function()
    while task.wait(1) do
        local seconds = math.floor(workspace.DistributedGameTime)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60
        RuntimeLabel:Set({
            Title = "Server Stats",
            Content = string.format("Server Runtime: %02d:%02d:%02d", hours, mins, secs)
        })
    end
end)

-- Core Gold Farm Logic
local function goldFarm()
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then 
        updateStatus("Status", "Waiting for Character...")
        plr.CharacterAdded:Wait() 
        task.wait(1)
    end
    
    local root = plr.Character.HumanoidRootPart
    local folder = workspace.BoatStages.NormalStages
    workspace.Gravity = 0
    
    -- Stage Loop (2.0s per stage)
    for i = 1, 10 do
        if not nagi.goldfarm or plr.Character.Humanoid.Health <= 0 then break end
        local stage = folder:FindFirstChild("CaveStage" .. i)
        if stage then
            root.CFrame = stage.DarknessPart.CFrame
            root.AssemblyLinearVelocity = Vector3.new(0, 0, -50)
            
            -- Wait exactly 2.0s per stage
            for timer = 20, 0, -1 do
                if not nagi.goldfarm or plr.Character.Humanoid.Health <= 0 then break end
                updateStatus("Farming Gold", string.format("Stage: %d/10\nNext stage in: %.1fs", i, timer/10))
                task.wait(0.1)
            end
        end
    end
    
    if nagi.goldfarm and plr.Character.Humanoid.Health > 0 then
        updateStatus("Status", "Collecting Gold Chest...")
        root.CFrame = folder.TheEnd.GoldenChest.Trigger.CFrame + Vector3.new(0, 5, 0)
        task.wait(1)
        workspace.Gravity = 196.2
        workspace.ClaimRiverResultsGold:FireServer()
        task.wait(1.5)
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.Health = 0
        end
    end
    workspace.Gravity = 196.2
end

-- Toggles
MainTab:CreateToggle({
   Name = "Auto Farm Gold",
   CurrentValue = false,
   Flag = "GoldFarm", 
   Callback = function(Value)
      nagi.goldfarm = Value
      if not Value then 
          updateStatus("Farm Status", "Standby") 
          workspace.Gravity = 196.2 
      else
          task.spawn(function()
              while nagi.goldfarm do
                  pcall(goldFarm)
                  task.wait()
              end
          end)
      end
   end,
})

EventTab:CreateToggle({
   Name = "Auto Farm Candy",
   CurrentValue = false,
   Flag = "CandyFarm", 
   Callback = function(Value)
      if Value then
          if not workspace:FindFirstChild("Houses") then
              Rayfield:Notify({Title = "Error", Content = "Candy Event not active.", Duration = 5})
              return
          end
          nagi.candyfarm = true
          task.spawn(function()
              while nagi.candyfarm do
                  if not workspace:FindFirstChild("Houses") then nagi.candyfarm = false break end
                  pcall(function()
                      for i, house in pairs(workspace.Houses:GetChildren()) do
                          if not nagi.candyfarm then break end
                          updateStatus("Event", "Visiting House: " .. i)
                          local root = plr.Character:FindFirstChild("HumanoidRootPart")
                          if root then
                              workspace.Gravity = 0
                              root.CFrame = house.Door.DoorInnerTouch.CFrame
                              task.wait(0.5)
                              for _ = 1, 4 do root.AssemblyAngularVelocity = Vector3.new(0, 40, 0) task.wait(0.2) end
                              workspace.Gravity = 196.2
                          end
                      end
                  end)
                  task.wait(1)
              end
          end)
      else
          nagi.candyfarm = false
          updateStatus("Farm Status", "Standby")
      end
   end,
})

-- Settings
SettingsTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) nagi.walkspeed = v if plr.Character then plr.Character.Humanoid.WalkSpeed = v end end,
})

SettingsTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 250},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) nagi.jumppower = v if plr.Character then plr.Character.Humanoid.JumpPower = v end end,
})

SettingsTab:CreateToggle({
   Name = "Auto Rejoin",
   CurrentValue = false,
   Callback = function(v) nagi.autorejoin = v end,
})

GuiService.ErrorMessageChanged:Connect(function()
    if nagi.autorejoin then task.wait(5) TeleportService:Teleport(game.PlaceId, plr) end
end)

CreditsTab:CreateButton({
   Name = "Copy Discord Link",
   Callback = function() setclipboard("https://discord.gg/MQAut7egGp") end,
})
