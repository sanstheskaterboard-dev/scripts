local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Nagi Hub | Build A Boat For Treasure",
   LoadingTitle = "Nagi Hub",
   LoadingSubtitle = "by Nagi",
   ConfigurationSaving = {
      Enabled = false, -- Disabled as per removal of configuration loading
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
    autorejoin = false
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

-- Calculation for Stages
local function getStageCount()
    local count = 0
    for _, v in pairs(workspace.BoatStages.NormalStages:GetChildren()) do
        if string.match(v.Name, "CaveStage") then
            count = count + 1
        end
    end
    return count
end

-- Core Farm Logic
local function collectChest()
    local h = plr.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    
    local fog = game:GetService("Lighting").FogEnd
    local count = 0
    
    repeat
        count = count + 1
        updateStatus("Collecting Chest", "Attempt: " .. count)
        h.CFrame = workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger.CFrame + Vector3.new(0, 5, 0)
        task.wait(0.5)
        if count > 30 then 
            updateStatus("Chest Error", "Too many attempts, resetting.")
            plr.Character.Humanoid.Health = 0 
            break 
        end
    until game:GetService("Lighting").FogEnd ~= fog or not nagi.goldfarm
end

local function goldFarm()
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then 
        updateStatus("Waiting", "Waiting for character...")
        plr.CharacterAdded:Wait() 
        task.wait(1)
    end
    
    local root = plr.Character.HumanoidRootPart
    local maxStages = getStageCount()
    workspace.Gravity = 0
    
    for i = 1, maxStages do
        if not nagi.goldfarm then break end
        
        root.CFrame = workspace.BoatStages.NormalStages["CaveStage" .. i].DarknessPart.CFrame
        root.AssemblyLinearVelocity = Vector3.new(0, 0, -50)
        
        -- Countdown logic
        for timer = 25, 0, -1 do
            if not nagi.goldfarm then break end
            updateStatus("Farming Gold", string.format("Stage: %d/%d\nNext stage in: %.1fs", i, maxStages, timer/10))
            task.wait(0.1)
        end
    end
    
    if nagi.goldfarm then
        workspace.Gravity = 196.2
        collectChest()
        updateStatus("Finishing", "Waiting for rewards...")
        task.wait(2)
        workspace.ClaimRiverResultsGold:FireServer()
        plr.CharacterAdded:Wait()
        task.wait(1)
    end
    workspace.Gravity = 196.2
end

-- Main Section
MainTab:CreateToggle({
   Name = "Auto Farm Gold",
   CurrentValue = false,
   Flag = "GoldFarm", 
   Callback = function(Value)
      nagi.goldfarm = Value
      if not Value then updateStatus("Farm Status", "Standby") end
      task.spawn(function()
          while nagi.goldfarm do
              pcall(goldFarm)
              task.wait()
          end
      end)
   end,
})

-- Event Section
EventTab:CreateToggle({
   Name = "Auto Farm Candy",
   CurrentValue = false,
   Flag = "CandyFarm", 
   Callback = function(Value)
      if Value then
          if not workspace:FindFirstChild("Houses") then
              nagi.candyfarm = false
              Rayfield:Notify({
                  Title = "No Candy Found",
                  Content = "There is currently no candy event active!",
                  Duration = 5,
                  Image = "alert-triangle",
              })
              task.spawn(function()
                  task.wait()
                  -- Force toggle off visually since we aren't using LoadConfiguration
                  nagi.candyfarm = false
              end)
              return
          end

          nagi.candyfarm = true
          task.spawn(function()
              while nagi.candyfarm do
                  if not workspace:FindFirstChild("Houses") then 
                      nagi.candyfarm = false 
                      updateStatus("Farm Status", "Standby")
                      break 
                  end
                  pcall(function()
                      local houses = workspace.Houses:GetChildren()
                      for i, house in pairs(houses) do
                          if not nagi.candyfarm then break end
                          updateStatus("Candy Farm", "Visiting House: " .. i .. "/" .. #houses)
                          local root = plr.Character:FindFirstChild("HumanoidRootPart")
                          if root then
                              workspace.Gravity = 0
                              root.CFrame = house.Door.DoorInnerTouch.CFrame
                              task.wait(0.5)
                              for _ = 1, 4 do
                                  root.AssemblyAngularVelocity = Vector3.new(0, 40, 0)
                                  task.wait(0.2)
                              end
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

-- Settings Section
SettingsTab:CreateToggle({
   Name = "Auto Rejoin",
   CurrentValue = false,
   Flag = "AutoRejoin",
   Callback = function(Value)
      nagi.autorejoin = Value
   end,
})

GuiService.ErrorMessageChanged:Connect(function()
    if nagi.autorejoin then
        task.wait(5)
        TeleportService:Teleport(game.PlaceId, plr)
    end
end)

-- Credits Section
CreditsTab:CreateParagraph({Title = "Nagi Hub", Content = "Enjoy the script!"})

CreditsTab:CreateButton({
   Name = "Copy Discord Link",
   Callback = function()
      setclipboard("https://discord.gg/MQAut7egGp")
      Rayfield:Notify({
         Title = "Copied!",
         Content = "Discord invite link copied to clipboard.",
         Duration = 5,
         Image = "copy",
      })
   end,
})
