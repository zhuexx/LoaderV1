-- Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "AllInOneESP",
   LoadingTitle = "AllInOneESP",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AllInOneESP",
      FileName = "Configuration"
   },
   KeySystem = true, -- Set to false if you want to use your own key system
   KeySettings = {
      Title = "AllInOneESP - Key System",
      Subtitle = "Enter your key below",
      Note = "Join the Discord for a key (discord.gg/example)",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"YOUR_KEY_HERE"} -- Input your key here or set GrabKeyFromSite to true
   }
})

-- Modules
local SeedPackController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SeedPackController"))
local SeedPackData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedPackData"))
local CalculatePlantValue = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CalculatePlantValue"))
local Comma = require(ReplicatedStorage:WaitForChild("Comma_Module"))

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Key System Variables
local isActivated = false
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

-- Create Tabs
local MainTab = Window:CreateTab("Main", 4483362458) -- Main Tab
local SeedTab = Window:CreateTab("Seed Spinner", 4483362458) -- Seed Tab
local PlantTab = Window:CreateTab("Plant ESP", 4483362458) -- Plant Tab
local EggTab = Window:CreateTab("Egg ESP", 4483362458) -- Egg Tab
local DupeTab = Window:CreateTab("Pet Duplicator", 4483362458) -- Dupe Tab

-- Main Tab (Key System)
local KeySection = MainTab:CreateSection("Activation")

local KeyInput = MainTab:CreateInput({
   Name = "License Key",
   PlaceholderText = "Enter your key here",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text) end,
})

local ActivateButton = MainTab:CreateButton({
   Name = "Activate",
   Callback = function()
      local key = KeyInput:GetText()
      if validateKey(key) then
         isActivated = true
         Rayfield:Notify({
            Title = "Activation Successful",
            Content = "Thank you for using AllInOneESP",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
      else
         Rayfield:Notify({
            Title = "Invalid Key",
            Content = "Please check your key and try again",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
      end
   end,
})

local HWIDLabel = MainTab:CreateLabel("HWID: "..HWID:sub(1, 8).."..."..HWID:sub(-4))

function validateKey(key)
   -- Replace with your actual key validation logic
   local validKeys = {
      ["ABC123-XYZ456"] = true,
      ["TEST-KEY-2023"] = true,
   }
   return validKeys[key] or false
end

-- Seed Spinner Tab
local SeedSection = SeedTab:CreateSection("Seed Spinner")

local selectedPack = ""
local selectedSeed = ""

local PackDropdown = SeedTab:CreateDropdown({
   Name = "Select Pack",
   Options = {},
   CurrentOption = "SELECT PACK",
   Flag = "PackDropdown",
   Callback = function(Option)
      selectedPack = Option
   end,
})

local SeedDropdown = SeedTab:CreateDropdown({
   Name = "Select Seed",
   Options = {},
   CurrentOption = "SELECT SEED",
   Flag = "SeedDropdown",
   Callback = function(Option)
      selectedSeed = Option
   end,
})

-- Populate pack dropdown
for packName, _ in pairs(SeedPackData.Packs) do
   table.insert(PackDropdown.Options, packName)
end
table.sort(PackDropdown.Options)

-- Update seeds when pack is selected
PackDropdown.Callback = function(Option)
   selectedPack = Option
   SeedDropdown:Refresh({}, true)
   
   if SeedPackData.Packs[selectedPack] then
      local seedOptions = {}
      for _, seedData in ipairs(SeedPackData.Packs[selectedPack].Items) do
         local seedName = seedData.Name or seedData.RewardId or "Unknown"
         table.insert(seedOptions, seedName)
      end
      SeedDropdown:Refresh(seedOptions)
   end
end

local SpinButton = SeedTab:CreateButton({
   Name = "Spin Seed",
   Callback = function()
      if not isActivated then 
         Rayfield:Notify({
            Title = "Not Activated",
            Content = "Please activate first",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return 
      end
      
      if selectedPack == "" or selectedSeed == "" then
         Rayfield:Notify({
            Title = "Selection Error",
            Content = "Please select both pack and seed",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return
      end
      
      if not SeedPackData.Packs[selectedPack] then
         Rayfield:Notify({
            Title = "Invalid Pack",
            Content = "Selected pack is invalid",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return
      end
      
      local items = SeedPackData.Packs[selectedPack].Items
      local index = 1
      local seedData = nil
      
      for i, item in ipairs(items) do
         if (item.Name and item.Name == selectedSeed) or (item.RewardId and item.RewardId == selectedSeed) then
            index = i
            seedData = item
            break
         end
      end
      
      if not seedData then
         Rayfield:Notify({
            Title = "Seed Not Found",
            Content = "Seed not found in selected pack",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return
      end
      
      local success, err = pcall(function()
         SeedPackController:Spin({
            seedPackType = selectedPack,
            resultIndex = index
         })
         
         Rayfield:Notify({
            Title = "Success",
            Content = "Obtained: "..selectedSeed,
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
      end)
      
      if not success then
         Rayfield:Notify({
            Title = "Error",
            Content = "Error: "..tostring(err),
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
      end
   end,
})

-- Plant ESP Tab
local PlantSection = PlantTab:CreateSection("Plant ESP")

local plantESPEnabled = false
local PLANT_RANGE = 50
local PlantESPs = {}
local PlantUpdateQueue = {}

local PlantToggle = PlantTab:CreateToggle({
   Name = "Plant ESP",
   CurrentValue = false,
   Flag = "PlantESP",
   Callback = function(Value)
      if not isActivated then 
         Value = false
         PlantToggle:Set(false)
         Rayfield:Notify({
            Title = "Not Activated",
            Content = "Please activate first",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return 
      end
      
      plantESPEnabled = Value
      if plantESPEnabled then
         scanPlants()
      else
         clearAllPlantESP()
      end
   end,
})

local RangeSlider = PlantTab:CreateSlider({
   Name = "ESP Range",
   Range = {10, 200},
   Increment = 10,
   Suffix = "studs",
   CurrentValue = 50,
   Flag = "PlantRange",
   Callback = function(Value)
      PLANT_RANGE = Value
      if plantESPEnabled then
         clearAllPlantESP()
         scanPlants()
      end
   end,
})

local function createPlantBillboard(model)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "esp"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.ResetOnSpawn = false
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Name = "money"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "..."
    label.Parent = billboard

    return billboard
end

local function updatePlantESP(model)
    if not plantESPEnabled then return end
    local esp = PlantESPs[model]
    if not esp or not model:IsDescendantOf(workspace) then return end
    local label = esp:FindFirstChild("money")
    if label then
        local success, value = pcall(CalculatePlantValue, model)
        if success and typeof(value) == "number" then
            label.Text = Comma.Comma(value) .. "Â¢"
        end
    end
end

local function trackPlant(model)
    if PlantESPs[model] then return end
    PlantUpdateQueue[model] = tick() + math.random()
end

local function untrackPlant(model)
    if PlantESPs[model] then
        PlantESPs[model]:Destroy()
        PlantESPs[model] = nil
    end
    PlantUpdateQueue[model] = nil
end

local function createPlantESP(model)
    if not plantESPEnabled then return end
    if PlantESPs[model] then return end
    if not model:IsDescendantOf(workspace) then return end
    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    if (part.Position - RootPart.Position).Magnitude <= PLANT_RANGE then
        local esp = createPlantBillboard(model)
        PlantESPs[model] = esp
        updatePlantESP(model)
    end
end

local function removePlantESP(model)
    local esp = PlantESPs[model]
    if esp and model:IsDescendantOf(workspace) then
        local part = model:FindFirstChildWhichIsA("BasePart")
        if part and (part.Position - RootPart.Position).Magnitude > PLANT_RANGE + 10 then
            esp:Destroy()
            PlantESPs[model] = nil
        end
    end
end

local function clearAllPlantESP()
    for model, esp in pairs(PlantESPs) do
        esp:Destroy()
        PlantESPs[model] = nil
    end
    PlantUpdateQueue = {}
end

local function scanPlants()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and CollectionService:HasTag(obj, "Harvestable") then
            trackPlant(obj)
        end
    end
end

-- Egg ESP Tab
local EggSection = EggTab:CreateSection("Egg ESP")

local eggESPEnabled = false
local ESPCache = {}
local ActiveEggs = {}
local EggPets = {}

local EggToggle = EggTab:CreateToggle({
   Name = "Egg ESP",
   CurrentValue = false,
   Flag = "EggESP",
   Callback = function(Value)
      if not isActivated then 
         Value = false
         EggToggle:Set(false)
         Rayfield:Notify({
            Title = "Not Activated",
            Content = "Please activate first",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return 
      end
      
      eggESPEnabled = Value
      if eggESPEnabled then
         if setupEggData() then
            scanEggs()
         else
            eggESPEnabled = false
            EggToggle:Set(false)
            Rayfield:Notify({
               Title = "Error",
               Content = "Failed to load pet data",
               Duration = 6.5,
               Image = 4483362458,
               Actions = {
                  Ignore = {
                     Name = "Okay",
                     Callback = function() end
                  },
               },
            })
         end
      else
         clearAllEggESP()
      end
   end,
})

local function GetPetName(Egg)
    if not Egg then return "?" end
    local EggID = Egg:GetAttribute("OBJECT_UUID") or Egg:GetAttribute("Id")
    return EggPets[EggID] or "?"
end

local function AddESP(Egg)
    if not eggESPEnabled or not Egg then return end
    if Egg:GetAttribute("OWNER") and Egg:GetAttribute("OWNER") ~= LocalPlayer.Name then return end

    local EggID = Egg:GetAttribute("OBJECT_UUID") or Egg:GetAttribute("Id")
    if not EggID then return end

    if not ESPCache[EggID] then
        local Label = Drawing.new("Text")
        Label.Text = GetPetName(Egg)
        Label.Size = 18
        Label.Color = Color3.new(1, 1, 1)
        Label.Outline = true
        Label.OutlineColor = Color3.new(0, 0, 0)
        Label.Center = true
        Label.Visible = false
        
        ESPCache[EggID] = Label
    end
    ActiveEggs[EggID] = Egg
end

local function RemoveESP(Egg)
    if not Egg then return end
    local EggID = Egg:GetAttribute("OBJECT_UUID") or Egg:GetAttribute("Id")
    if ESPCache[EggID] then
        ESPCache[EggID]:Remove()
        ESPCache[EggID] = nil
    end
    ActiveEggs[EggID] = nil
end

local function UpdateESP()
    if not eggESPEnabled then return end
    for EggID, Egg in pairs(ActiveEggs) do
        if not Egg or not Egg:IsDescendantOf(workspace) then
            RemoveESP(Egg)
        else
            local Label = ESPCache[EggID]
            if Label then
                Label.Text = GetPetName(Egg)
                local Position, OnScreen = Camera:WorldToViewportPoint(Egg:GetPivot().Position)
                Label.Visible = OnScreen
                if OnScreen then
                    Label.Position = Vector2.new(Position.X, Position.Y)
                end
            end
        end
    end
end

local function clearAllEggESP()
    for EggID, Label in pairs(ESPCache) do
        Label:Remove()
    end
    ESPCache = {}
    ActiveEggs = {}
end

local function scanEggs()
    for _, Egg in pairs(CollectionService:GetTagged("PetEggServer")) do
        AddESP(Egg)
    end
end

local function setupEggData()
    local success, result = pcall(function()
        -- Method 1: Check modules for egg data
        for _, module in pairs(ReplicatedStorage:GetDescendants()) do
            if module:IsA("ModuleScript") and module.Name:lower():find("egg") then
                local req = require(module)
                if type(req) == "table" and req.Eggs then
                    EggPets = req.Eggs
                    break
                end
            end
        end
        
        -- Method 2: Check event connections
        if not next(EggPets) then
            local event = ReplicatedStorage:FindFirstChild("EggReadyToHatch_RE") or ReplicatedStorage:FindFirstChild("PetEggService")
            if event then
                local conn = getconnections(event.OnClientEvent)[1]
                if conn then
                    local func = conn.Function
                    if func then
                        local _, petData = debug.getupvalue(func, 2)
                        if petData then
                            EggPets = petData
                        end
                    end
                end
            end
        end
        
        -- Method 3: Hardcoded fallback (add your game's specific pet names if known)
        if not next(EggPets) then
            EggPets = {
                ["Egg1"] = "Common Pet",
                ["Egg2"] = "Rare Pet",
            }
        end
    end)
    
    return success and next(EggPets) ~= nil
end

-- Dupe Tab
local DupeSection = DupeTab:CreateSection("Pet Duplicator")

local DupeButton = DupeTab:CreateButton({
   Name = "Duplicate Pet",
   Callback = function()
      if not isActivated then 
         Rayfield:Notify({
            Title = "Not Activated",
            Content = "Please activate first",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
         return 
      end
      
      local success = duplicatePet()
      if success then
         Rayfield:Notify({
            Title = "Success",
            Content = "Pet duplicated successfully",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
         })
      end
   end,
})

local function getTool()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    return nil
end

local function duplicatePet()
    local tool = getTool()
    if not tool then 
        Rayfield:Notify({
            Title = "Error",
            Content = "No pet tool found",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {
               Ignore = {
                  Name = "Okay",
                  Callback = function() end
               },
            },
        })
        return false 
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local visual = tool:Clone()
        visual.Parent = workspace
        
        if visual:IsA("Tool") and visual:FindFirstChild("Handle") then
            visual.Handle.CFrame = root.CFrame * CFrame.new(3, 0, 0)
        elseif visual:IsA("Model") then
            local part = visual:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CFrame = root.CFrame * CFrame.new(3, 0, 0)
            end
        end
        
        game:GetService("Debris"):AddItem(visual, 2)
    end

    local clone = tool:Clone()
    clone.Parent = backpack
    
    return true
end

-- CollectionService events
CollectionService:GetInstanceAddedSignal("Harvestable"):Connect(function(obj)
    if obj:IsA("Model") and plantESPEnabled then
        trackPlant(obj)
    end
end)

CollectionService:GetInstanceRemovedSignal("Harvestable"):Connect(function(obj)
    if obj:IsA("Model") then
        untrackPlant(obj)
    end
end)

CollectionService:GetInstanceAddedSignal("PetEggServer"):Connect(function(Egg)
    if eggESPEnabled then
        AddESP(Egg)
    end
end)

CollectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(function(Egg)
    RemoveESP(Egg)
end)

-- Character handling
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Plant ESP update loop
task.spawn(function()
    while true do
        if plantESPEnabled then
            local now = tick()
            for model, _ in pairs(PlantUpdateQueue) do
                if not model:IsDescendantOf(workspace) then
                    untrackPlant(model)
                else
                    createPlantESP(model)
                    removePlantESP(model)
                    if PlantESPs[model] and now >= PlantUpdateQueue[model] then
                        updatePlantESP(model)
                        PlantUpdateQueue[model] = now + 3 + math.random()
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Egg ESP update loop
RunService.PreRender:Connect(UpdateESP)

-- Initialize
Rayfield:LoadConfiguration()