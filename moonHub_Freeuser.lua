---@diagnostic disable: duplicate-doc-field, lowercase-global, inject-field, deprecated

-- Declare global variables for Roblox environment
---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
---@diagnostic disable: redundant-parameter
---@diagnostic disable: missing-parameter

-- Disable parameter warnings for Rayfield UI library compatibility
-- Rayfield methods use table-based parameter passing which triggers these warnings

-- Type definitions for Roblox objects
---@class RBXScriptConnection
---@field Connected boolean
---@field Disconnect fun()

---@class Color3
---@field R number
---@field G number
---@field B number
---@field fromRGB fun(r: number, g: number, b: number): Color3
---@field fromHSV fun(h: number, s: number, v: number): Color3
---@field new fun(r: number, g: number, b: number): Color3

local game = game
local workspace = workspace
local Color3 = Color3
local Vector3 = Vector3
local Vector2 = Vector2
local UDim2 = UDim2
local UDim = UDim
local Instance = Instance
local CFrame = CFrame
local TweenInfo = TweenInfo
local NumberRange = NumberRange
local NumberSequence = NumberSequence
local ColorSequence = ColorSequence
local ColorSequenceKeypoint = ColorSequenceKeypoint
local NumberSequenceKeypoint = NumberSequenceKeypoint
local Ray = Ray
local Region3 = Region3
local Region3int16 = Region3int16
local BrickColor = BrickColor
local Enum = Enum
local math = math
local task = task
local tick = tick
---@diagnostic enable: undefined-global

-- Check if we're in Roblox environment
if not game then

    return
end

local Services = {
  TweenService = game:GetService("TweenService"),
  Players = game:GetService("Players"),
  ReplicatedStorage = game:GetService("ReplicatedStorage"),
  RunService = game:GetService("RunService"),
  VirtualInputManager = game:GetService("VirtualInputManager"),
  UserInputService = game:GetService("UserInputService"),
  HttpService = game:GetService("HttpService"),
  TeleportService = game:GetService("TeleportService"),
  VoiceChatService = game:GetService("VoiceChatService"),
  MarketplaceService = game:GetService("MarketplaceService"),
  Stats = game:GetService("Stats"),
  CoreGui = game:GetService("CoreGui"),
  Workspace = workspace,
  workspace = workspace
}

--[[ Executor/FS shim: silence analyzers while preserving runtime behavior ]]
local function __getenv()
    local _g = rawget(_G, "getgenv")
    local ok, env = pcall(function()
        if type(_g) == "function" then return _g() end
        return nil
    end)
    if ok and env then return env end
    return _G
end

local __ENV = __getenv()

listfiles = (__ENV and __ENV.listfiles) or listfiles
if not listfiles then function listfiles() return {} end end

isfolder = (__ENV and __ENV.isfolder) or isfolder
if not isfolder then function isfolder() return false end end

makefolder = (__ENV and __ENV.makefolder) or makefolder
if not makefolder then function makefolder() end end

writefile = (__ENV and __ENV.writefile) or writefile
if not writefile then function writefile() end end

readfile = (__ENV and __ENV.readfile) or readfile
if not readfile then function readfile() return "" end end

local function IsFoodTool(tool)
    if not tool then return false end

    -- Verify this is a Roblox Instance and a Tool (pcall guards editor/Lua analyzers)
    local okIsTool, isTool = pcall(function() return tool:IsA("Tool") end)
    if not okIsTool or not isTool then return false end

    -- Attribute-based
    local okAttr, isFoodAttr = pcall(function() return tool:GetAttribute("IsFood") end)
    if okAttr and (isFoodAttr == true or isFoodAttr == "true") then return true end

    -- Child value flags
    local flag = tool:FindFirstChild("IsFood") or tool:FindFirstChild("Food") or tool:FindFirstChild("Consumable")
    if flag and flag:IsA("BoolValue") and flag.Value == true then return true end
    if flag and flag:IsA("StringValue") and tostring(flag.Value):lower():find("food") then return true end

    -- Tag-based (CollectionService)
    local CollectionService = rawget(Services or {}, "CollectionService")
    if not CollectionService then
        local okCS, svc = pcall(game.GetService, game, "CollectionService")
        if okCS then CollectionService = svc end
    end
    if CollectionService then
        local okTag, tagged = pcall(CollectionService.HasTag, CollectionService, tool, "Food")
        if okTag and tagged then return true end
    end

    -- Name heuristics (fallback)
    local n = string.lower(tostring(tool.Name or ""))
    local keywords = {
        "food","eat","snack","meal","ration","drink","water","soda","juice",
        "apple","berry","bread","meat","fish","cake","cookie","soup","stew","potion"
    }
    for _, k in ipairs(keywords) do
        if string.find(n, k, 1, true) then
            return true
        end
    end

    return false
end

-- Add file system functions if they exist in the environment
local listfiles = listfiles or function(folder)
    -- Fallback implementation if listfiles doesn't exist
    return {}
end

local isfolder = isfolder or function(folder)
    -- Fallback implementation if isfolder doesn't exist
    return false
end

local makefolder = makefolder or function(folder)
    -- Fallback implementation if makefolder doesn't exist
    return false
end

local writefile = writefile or function(filename, content)
    -- Fallback implementation if writefile doesn't exist

    return false
end

local readfile = readfile or function(filename)
    -- Fallback implementation if readfile doesn't exist

    return ""
end

--[[
    RAYFIELD UI LIBRARY LOADING
]]
local Rayfield = nil
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()
end)

if not success or not Rayfield then

    -- Fallback to basic error handling
    Rayfield = {
        Notify = function(data)

        end,
        CreateWindow = function() return {
            CreateTab = function() return {
                CreateToggle = function() return {} end,
                CreateButton = function() return {} end,
                CreateSection = function() return {} end,
                CreateLabel = function() return { Set = function() end } end,
                CreateDropdown = function() return { Refresh = function() end, Select = function() end } end,
                CreateInput = function() return {} end,
                CreateSlider = function() return {} end
            } end,
            LoadConfiguration = function() end,
            SaveConfiguration = function() end
        } end
    }
end

--[[
    GLOBAL CONFIGURATIONS
]]

local Config = {
    Spam = {
    Enabled = false,
    Message = "Moon HUB is the best!",
    Interval = 1
    },

    Spectate = {
    IsSpectating = false,
    SelectedPlayer = "Ninguém",
    Camera = workspace.CurrentCamera
    },

    Admin = {
    GroupId = 497686443,
    AdminRank = 255,
    ModeratorRank = 254,
    AlertsEnabled = true
    },

    WalkSpeed = {
    CurrentSpeed = 16,
    MinSpeed = 16,
    MaxSpeed = 500,
    Debounce = false
    },

    ESP = {
    FillColor = Color3.fromRGB(175, 25, 255),
    DepthMode = "AlwaysOnTop",
    FillTransparency = 0.5,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTransparency = 0,
    Enabled = false
    },

    Teleports = {
    {Name = "🛡️ Safe Zone", Position = Vector3.new(-105.29137420654297, 642.4719848632812, 514.2374877929688)},
    {Name = "🏜️ Desert", Position = Vector3.new(-672.6334838867188, 642.568603515625, 1115.691162109375)},
    {Name = "🌋 Volcano", Position = Vector3.new(120.21180725097656, 685.631103515625, 1570.7666015625)},
    {Name = "🏖️ Beach", Position = Vector3.new(-29.751022338867188, 644.6039428710938, -70.5428695678711)},
    {Name = "🌫️ Cloud Arena", Position = Vector3.new(-1173.7010498046875, 1268.14404296875, 766.4228515625)}
    },
    
    -- Clan locations and data
    Clans = {
        Locations = {
            {Name = "Clan Base 1", Position = Vector3.new(0, 0, 0)},
            {Name = "Clan Base 2", Position = Vector3.new(100, 0, 100)},
            {Name = "Clan Base 3", Position = Vector3.new(-100, 0, -100)}
        },
        AutoJoin = {
            Enabled = false,
            TargetClan = "",
            CheckInterval = 5
        }
    },
    
    -- Skin unlock lists
    Skins = {
        Christmas = {
            "SantaHat", "ReindeerAntlers", "ChristmasTree", "Snowman", "Gingerbread", "Elf", "Nutcracker"
        },
        Pig = {
            "PIG1", "PIG2", "PIG3", "PIG4", "PIG5", "PIG6", "PIG7", "PIG8"
        },
        Easter = {
            "EasterBunny", "EasterEgg", "SpringFlowers", "PastelColors", "Basket", "Chick", "Lamb"
        },
        Secret = {
            "GoldenWeapon", "DiamondArmor", "MysticStaff", "ShadowBlade", "LightningBow", "IceSword", "FireAxe"
        },
        XM24 = {
            "XM24Fr", "XM24Bear", "XM24Eag", "XM24Br", "XM24Cr", "XM24Sq"
        }
    },
    
    -- Animal spawn data
    Animals = {
        Common = {
            "Dog", "Cat", "Bird", "Fish", "Hamster", "Rabbit", "Guinea Pig"
        },
        Rare = {
            "Lion", "Tiger", "Elephant", "Giraffe", "Zebra", "Panda", "Kangaroo"
        },
        Legendary = {
            "Dragon", "Phoenix", "Unicorn", "Griffin", "Kraken", "Yeti", "Sphinx"
        },
        Skins = {
            "Default", "Golden", "Silver", "Rainbow", "Neon", "Crystal", "Shadow", "Light"
        }
    },
    
    -- Weapon and tool data
    Weapons = {
        Melee = {
            "Sword", "Axe", "Hammer", "Dagger", "Spear", "Mace", "Katana"
        },
        Ranged = {
            "Bow", "Crossbow", "Gun", "Laser", "Plasma", "Rocket", "Sniper"
        },
        Magic = {
            "Staff", "Wand", "Orb", "Crystal", "Scroll", "Tome", "Rune"
        },
        Tools = {
            "Push", "ModdedPush", "Pull", "Grab", "Throw", "Teleport", "Clone"
        }
    },
    
    -- NPC and enemy data
    NPCs = {
        Types = {
            "Guard", "Merchant", "Trainer", "QuestGiver", "Boss", "Minion", "Elite"
        },
        Bosses = {
            "DragonBoss", "GiantBoss", "ShadowBoss", "IceBoss", "FireBoss", "LightningBoss", "EarthBoss"
        },
        Farming = {
            Enabled = false,
            TargetTypes = {"Dummy", "5k", "NPC", "Boss"},
            AttackRange = 20,
            CheckInterval = 0.1
        }
    },
    
    -- Animation and movement data
    Animations = {
        IDs = {
            Dance = "rbxassetid://507770677",
            Walk = "rbxassetid://507770714",
            Run = "rbxassetid://507770714",
            Jump = "rbxassetid://507770000",
            Idle = "rbxassetid://507766666"
        },
        Settings = {
            DefaultSpeed = 1.0,
            DefaultTime = 0,
            LoopEnabled = true
        }
    },
    
    -- UI and display settings
    UI = {
        Theme = "Default",
        Notifications = {
            Enabled = true,
            Duration = 2,
            Position = "TopRight"
        },
        Colors = {
            Primary = Color3.fromRGB(0, 170, 255),
            Secondary = Color3.fromRGB(255, 255, 255),
            Success = Color3.fromRGB(0, 255, 0),
            Warning = Color3.fromRGB(255, 255, 0),
            Error = Color3.fromRGB(255, 0, 0)
        }
    },
    
    -- Performance and optimization settings
    Performance = {
        ESP = {
            MaxDistance = 1000,
            UpdateInterval = 0.1,
            MaxPlayers = 50
        },
        Farming = {
            MaxTargets = 10,
            CheckRadius = 100,
            Pathfinding = false
        },
        Rendering = {
            Quality = "High",
            Shadows = true,
            Particles = true
        }
    },
    
    -- Game-specific constants
    Game = {
        -- Remote event names
        RemoteEvents = {
            Attack = "AttackEvent",
            Unlock = "UnlockEvent",
            Spawn = "SpawnEvent",
            Eat = "EatEvent",
            Skills = "SkillsRemoteEvent"
        },
        
        -- Game passes and items
        GamePasses = {
            Premium = "PremiumPass",
            VIP = "VIPPass",
            Admin = "AdminPass"
        },
        
        -- Achievement and reward data
        Achievements = {
            "FirstKill", "KillStreak", "BossSlayer", "Collector", "Explorer", "Socialite"
        },
        
        -- Level and experience data
        Experience = {
            MaxLevel = 100,
            BaseXP = 100,
            XPMultiplier = 1.5,
            LevelCap = 1000
        }
    },
    
    -- Script configuration
    Script = {
        Version = "1.0.0",
        Author = "Moon HUB",
        UpdateURL = "https://example.com/updates",
        Features = {
            "FireballAura", "ESP", "TagSystem", "Farming", "Combat", "Teleport", "Spectate", "NPCControl"
        }
    }
}

--[[
    GLOBAL UI ELEMENTS
]]
-- Global UI elements for cross-function access
---@type table<string, any>
local UI = {
    TargetFeedbackLabel = nil,
    TargetLocationLabel = nil,
    TargetInfoLabel = nil,
    TargetStatsLabel = nil,
    TargetActionsLabel = nil
}

--[[
    GLOBAL STATE MANAGEMENT
]]

local State = {
    -- Farming state
    isFarming = false,
    dummyFarmActive = false,
    dummyFarmConnection = nil,
    
    -- ESP state
    ESPStorage = nil,
    ESPConnections = {},

    -- Clan state
    clanName = "",
    
    -- Combat state
    attackAllNPCToggle = false,
    dummyFarm5kEnabled = false,
    killAura = false,
    huntPlayers = false,
    farmLowLevels = false,
    targetPriority = "Closest",
    isAuraActive = false,
    
    -- Godmode state
    godmodeToggle = false,
    lastClickedAnimal = nil,
    lastClickedSkin = nil,
    
    -- Weapon state
    selectedWeaponIndex = 1,
    
    -- Target state
    ViewingTarget = false,
    FocusingTarget = false,
    BenggingTarget = false,
    HeadsittingTarget = false,
    StandingTarget = false,
    BackpackingTarget = false,
    DoggyingTarget = false,
    SuckingTarget = false,
    DraggingTarget = false,
    
    -- Target loop threads
    BengLoop = nil,
    HeadsitLoop = nil,
    StandLoop = nil,
    BackpackLoop = nil,
    DoggyLoop = nil,
    SuckLoop = nil,
    DragLoop = nil,
    
    -- Target system
    -- State.TargetedPlayer moved to State table
    TargetedPlayer = nil,
    
    -- Configuration values
    FPDH = 500
}

--[[
    CONNECTIONS & CACHE MANAGEMENT
]]

-- Connections table for managing all script connections
---@type table<string, RBXScriptConnection|nil>
local Connections = {
    -- Aura connections
    fireballAura = nil,
    
    -- Thread connections
    tagScan = nil,
    clanAutoJoin = nil,
    killNPCMonitor = nil,
    locationUpdate = nil,
    npcFling = nil,
    bossFarming = nil,
}
local function __ensureESPStorage()
    State.ESPStorage = State.ESPStorage or Instance.new("Folder")
    State.ESPStorage.Name = "ESP_Storage"
    State.ESPStorage.Parent = workspace
end

pcall(__ensureESPStorage)

-- State table for boolean flags and thread references
do
    local _extra = {
    -- NPC state
    killNPCToggle = false,
    killNPCMonitorThread = nil,
    
    -- NPC Flinging state
    npcFlingActive = false,
    npcFlingThread = nil
}
    if State == nil then State = {} end
    for k,v in pairs(_extra) do State[k] = v end
end

---@class CacheTable
---@field velocityAsset any?
---@field clanDropdown any?
---@field teleportDropdown any?
---@field spectateDropdown any?
---@field npcPlayerDropdown any?
---@field npcTargetDropdown any?
---@field themeDropdown any?
---@field configDropdown any?
---@field tagStatusLabel any?
---@field killNPCHealthThreads table
---@field bossHealthThreads table
---@field tagOwnerInfo {label: string, color: Color3}
---@field tagDevInfo {label: string, color: Color3}
---@field tagRankInfo table<number, {label: string, color: Color3}>

local Cache = {
    -- Reusable assets
    velocityAsset = nil,
    
    -- UI elements
    clanDropdown = nil,
    teleportDropdown = nil,
    spectateDropdown = nil,
    npcPlayerDropdown = nil,
    npcTargetDropdown = nil,
    themeDropdown = nil,
    configDropdown = nil,
    tagStatusLabel = nil,
    
    -- Thread collections
    killNPCHealthThreads = {},
    bossHealthThreads = {},
    
    -- Tag system info
    tagOwnerInfo = {label = "OWNER", color = Color3.fromRGB(255, 255, 0)},
    tagDevInfo = {label = "DEVELOPER", color = Color3.fromRGB(255, 0, 0)},
    tagRankInfo = {
        [2] = {label = "PREMIUM", color = Color3.fromRGB(0, 170, 255)},
        [1] = {label = "FREE USER", color = Color3.fromRGB(255, 150, 150)}
    }
} ---@type CacheTable

--[[
    TAG SYSTEM STORAGE
]]
-- Tag system storage - moved here to be accessible by Util functions
---@type table<string, any>
local TagData = {
    guiByPlayer = {},
    renderConnByPlayer = {},
    charAddedConn = {},
    charRemovingConn = {},
    infoByPlayer = {},
    lastRankByPlayer = {},
}

--[[
    UTILITY FUNCTIONS
]]

---@diagnostic disable: deprecated
local Util = {}

-- Core utility functions

-- Utility: find a Tool by (case-insensitive) name in Character or Backpack
-- Targeting helper: returns valid enemy players sorted by priority ("Closest" or "Lowest Health")
function Util.getValidTargetsSorted(priority)local lp = Services.Players.LocalPlayer
    local char = lp and lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end

    local myPos = root.Position
    local targets = {}
    local maxDist = tonumber(State and State.detectionRadius) or 70
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
            local shield = p.Character:FindFirstChild("SafeZoneShield")
            if hum and rootPart and hum.Health > 0 and not shield then
                local dist = (myPos - rootPart.Position).Magnitude
                if dist <= maxDist then
                table.insert(targets, {
                    player = p,
                    character = p.Character,
                    humanoid = hum,
                    distance = dist,
                    health = hum.Health,
                                })
            end
            end
        end
    end

    local method = string.lower(tostring(priority or State.targetPriority or "Closest"))
    -- normalize aliases
    if method == "lowest health" or method == "low health" or method == "lowest" or method == "health" then
        table.sort(targets, function(a,b) return a.health < b.health end)
    else
        table.sort(targets, function(a,b) return a.distance < b.distance end)
    end
    return targets
end

function Util.findToolByName(name)
    if not name or name == "" then return nil end
    local lp = Services.Players and Services.Players.LocalPlayer
    if not lp or not lp.Character then return nil end
    local lower = string.lower
    local target = lower(tostring(name))

    local function matchTool(container)
        if not container then return nil end
        for _, inst in ipairs(container:GetChildren()) do
            if inst:IsA("Tool") then
                local n = inst.Name or ""
                if lower(n) == target or string.find(lower(n), target, 1, true) then
                    return inst
                end
            end
        end
        return nil
    end

    local char = lp.Character
    local back = lp:FindFirstChildOfClass("Backpack")
    return matchTool(char) or matchTool(back)
end

-- Utility: equip a tool by name ("food"), returning the equipped Tool or nil
function Util.equipToolByName(name)
    local lp = Services.Players and Services.Players.LocalPlayer
    if not lp or not lp.Character then return nil end
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local tool = Util.findToolByName(name)
    if tool then
        pcall(function() hum:EquipTool(tool) end)
        return tool
    end
    return nil
end

function Util.GetPing()
    local ping = 0
    pcall(function()
        ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return ping or 0.2
end

function Util.GetPush()
    local player = Services.Players.LocalPlayer
    if not player then return nil end

    local function findIn(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool.Name == "Push" or tool.Name == "ModdedPush" then
                return tool
            end
        end
        return nil
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    local found = findIn(backpack)
    if found then return found end

    local char = player.Character
    if char then
        found = findIn(char)
        if found then return found end
    end

    return nil
end

function Util.GetCharacter(Player)
    return Player and Player.Character or nil
end

function Util.GetRoot(Player)
    local char = Util.GetCharacter(Player)
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- More utility functions

function Util.isNPC(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.MaxHealth > 1000
end

function Util.armNPC(npc)
    -- Accept either a Model or a table with .Character
    local model = npc
    if type(npc) == "table" and npc.Character then model = npc.Character end
    if not model or type(model) ~= "userdata" then return end
    local humanoid = model:FindFirstChild("Humanoid") or model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = 50
    humanoid.JumpPower = 100
end

function Util.getSpectatePlayers()
    local players = {}
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer and player.Character and 
               player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                table.insert(players, player.Name)
            end
        end
    end
    return players
end

function Util.enhancedStartSpectating()
    if Config.Spectate.IsSpectating then
        Util.enhancedStopSpectating()
    end
    
    local targetPlayer = Services.Players:FindFirstChild(Config.Spectate.SelectedPlayer)
    if not targetPlayer or not targetPlayer.Character then
---@diagnostic disable-next-line: redundant-parameter
        Rayfield:Notify({
            Title = "Spectate Error",
            Content = "Target player not found or has no character.",
            Duration = 2
        })
        return
    end

-- Function to get spawn arguments for the selected animal
function Util.getSpawnArgs(animalName, skinName)
    -- Ensure we have valid string inputs
    if not animalName then
        return nil, "animalName is nil"
    end
    
    -- Convert to string if it's not already
    animalName = tostring(animalName)
    skinName = skinName and tostring(skinName) or animalName
    
    if not Config.AnimalMap then
        return nil, "animalMap table is nil"
    end
    
    local animalConfig = Config.AnimalMap[animalName]
    
    if not animalConfig then
        for key, value in pairs(Config.AnimalMap) do
            if string.lower(key) == string.lower(animalName) then
                animalConfig = value
                break
            end
        end
    end
    
    if not animalConfig then
        return nil, "Animal not found in configuration"
    end
    
    local skinId = skinName
    local anim = animalConfig.anim
    
    if animalConfig.skinIdOverrides and animalConfig.skinIdOverrides[skinName] then
        skinId = animalConfig.skinIdOverrides[skinName]
    end
    
    if animalConfig.animOverrides and animalConfig.animOverrides[skinName] then
        anim = animalConfig.animOverrides[skinName]
    end
    
    return {animalConfig.id, skinId, anim}, nil
end

    Config.Spectate.IsSpectating = true
    local camera = Config.Spectate.Camera
    camera.CameraSubject = targetPlayer.Character:FindFirstChild("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    
    if Rayfield and Rayfield.Notify then
        Rayfield:Notify({
            Title = "Spectate",
            Content = "Now spectating " .. targetPlayer.Name,
            Duration = 2
        })
    end
end

function Util.enhancedStopSpectating()
    if not Config.Spectate.IsSpectating then return end
    
    Config.Spectate.IsSpectating = false
    local camera = Config.Spectate.Camera
    camera.CameraSubject = Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    
    if Rayfield and Rayfield.Notify then
        Rayfield:Notify({
            Title = "Spectate",
            Content = "Stopped spectating",
            Duration = 2
        })
    end
end

function Util.updateTargetFeedback(text)
    if UI.TargetFeedbackLabel then
        UI.TargetFeedbackLabel:Set(text)
    end
end

function Util.updateTargetLocation(text)
    if UI.TargetLocationLabel then
        UI.TargetLocationLabel:Set(text)
    end
end

function Util.updateLocationDisplay()
    local playerRoot = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if playerRoot then
        local position = playerRoot.Position
        Util.updateTargetLocation("📍 **LOCATION:** X: " .. math.floor(position.X) .. " | Y: " .. math.floor(position.Y) .. " | Z: " .. math.floor(position.Z))
    end
end

-- More utility functions continued

function Util.NPCSkidFling(targetPlayer, controlledNPC)
    if not controlledNPC or not targetPlayer then return end
    
    local npcRoot = Util.GetRoot(controlledNPC)
    local targetRoot = Util.GetRoot(targetPlayer)
    if not npcRoot or not targetRoot then return end
    
    -- Create fling effect
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 1000, 0)
    bodyVelocity.Parent = npcRoot
    
    -- Position NPC for fling
    npcRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
    
    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
end

function Util.walkfling(targetPlayer, controlledNPC)
    if not controlledNPC or not targetPlayer then return end
    
    local npcRoot = Util.GetRoot(controlledNPC)
    local targetRoot = Util.GetRoot(targetPlayer)
    if not npcRoot or not targetRoot then return end
    
    -- Create walking fling effect
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 500, 0)
    bodyVelocity.Parent = npcRoot
    
    -- Position NPC for fling
    npcRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1)
    
    game:GetService("Debris"):AddItem(bodyVelocity, 0.2)
end

function Util.refreshNPCPlayerList()
    local players = {}
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
    end
    return players
end

function Util.refreshNPCTargetList()
    local targets = {}
    for _, npc in pairs(workspace:GetChildren()) do
        if Util.isNPC(npc) then
            table.insert(targets, npc.Name)
        end
    end
    return targets
end

function Util.findBosses()
    local bosses = {}
    for _, npc in pairs(workspace:GetChildren()) do
        if Util.isNPC(npc) and npc.Name:match("Boss") then
            table.insert(bosses, npc)
        end
    end
    return bosses
end

function Util.farmBosses()
    ---@diagnostic disable: undefined-field
    if Connections.bossFarming then
        Connections.bossFarming:Disconnect()
        Connections.bossFarming = nil
    end
    
    Connections.bossFarming = Services.RunService.Heartbeat:Connect(function()
        local bosses = Util.findBosses()
        for _, boss in pairs(bosses) do
            if State.bossFarmingEnabled then
                local humanoid = boss:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Attack boss logic here
                    local args = {[1] = boss}
                    Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                end
            end
        end
    end)
end
    

-- Duplicate Util.getSpawnArgs removed

-- Tag system utility functions
---@diagnostic disable: undefined-field
function Util.Tag_destroyFor(player)
    if TagData.renderConnByPlayer[player] then
        TagData.renderConnByPlayer[player]:Disconnect()
        TagData.renderConnByPlayer[player] = nil
    end
    local gui = TagData.guiByPlayer[player]
    if gui and gui.Parent then gui:Destroy() end
    TagData.guiByPlayer[player] = nil
    TagData.infoByPlayer[player] = nil
    TagData.lastRankByPlayer[player] = nil
end

function Util.Tag_getInfo(player)
    local ok, rank = pcall(function()
        return player:GetRankInGroup(Config.Admin.GroupId)
    end)
    if not ok then return nil, nil end
    if rank and rank >= 255 then
        return Cache.tagOwnerInfo, rank
    elseif rank and rank >= 254 then
        return Cache.tagDevInfo, rank
    end
    return Cache.tagRankInfo[rank], rank
end

function Util.Tag_attach(player, char, info)
    if not info then return end
    local head = char:WaitForChild("Head", 10)
    if not head then return end

    Util.Tag_destroyFor(player)

    local b = Instance.new("BillboardGui")
    b.Name = "RoleTag"
    b.AlwaysOnTop = true
    b.Size = UDim2.new(2.8, 0, 0.5, 0)
    b.StudsOffset = Vector3.new(0, 4.0, 0)
    b.Adornee = head
    b.Parent = head
    TagData.guiByPlayer[player] = b
    TagData.infoByPlayer[player] = info

    -- Main dark container frame
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 0.3
    f.BorderSizePixel = 0
    f.Parent = b

    -- Glowing border using rank color
    local border = Instance.new("Frame")
    border.AnchorPoint = Vector2.new(0, 0)
    border.Position = UDim2.new(0, 0, 0, 0)
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundColor3 = info.color
    border.BackgroundTransparency = 0.8
    border.BorderSizePixel = 0
    border.Parent = f

    -- Text label
    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, 0, 0.5, 0)
    label.Size = UDim2.new(0.9, 0, 0.8, 0)
    label.BackgroundTransparency = 1
    label.Text = info.label
    label.TextColor3 = info.color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = f

    -- Render connection for updates
    TagData.renderConnByPlayer[player] = Services.RunService.RenderStepped:Connect(function()
        if not char or not char:FindFirstChild("Head") or not b.Parent then
            Util.Tag_destroyFor(player)
            return
        end
    end)
end

function Util.Tag_clearAllNow()
    if TagData.guiByPlayer and type(TagData.guiByPlayer) == "table" then
        for player, _ in pairs(TagData.guiByPlayer) do
            Util.Tag_destroyFor(player)
        end
    end
end

function Util.Tag_scanOnce()
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer then
                local char = player.Character
                if char then
                    local info, rank = Util.Tag_getInfo(player)
                    if info and rank ~= TagData.lastRankByPlayer[player] then
                        Util.Tag_attach(player, char, info)
                        TagData.lastRankByPlayer[player] = rank
                    end
                end
            end
        end
    end
end

function Util.Tag_startScanner()
    if Connections.tagScan then
        Connections.tagScan:Disconnect()
        Connections.tagScan = nil
    end
    
    Connections.tagScan = Services.RunService.Heartbeat:Connect(function()
        Util.Tag_scanOnce()
    end)
end

function Util.Tag_stopScanner()
    if Connections.tagScan then
        Connections.tagScan:Disconnect()
        Connections.tagScan = nil
    end
end

function Util.setupEnhancedTagSystem()
    -- Setup character added/removing connections for all players
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer then
                if player.Character then
                    local info, rank = Util.Tag_getInfo(player)
                    if info then
                        Util.Tag_attach(player, player.Character, info)
                        TagData.lastRankByPlayer[player] = rank
                    end
                end
                
                TagData.charAddedConn[player] = player.CharacterAdded:Connect(function(char)
                    local info, rank = Util.Tag_getInfo(player)
                    if info then
                        Util.Tag_attach(player, char, info)
                        TagData.lastRankByPlayer[player] = rank
                    end
                end)
                
                TagData.charRemovingConn[player] = player.CharacterRemoving:Connect(function()
                    Util.Tag_destroyFor(player)
                end)
            end
        end
    end
    
    -- Setup for new players
    Services.Players.PlayerAdded:Connect(function(player)
        TagData.charAddedConn[player] = player.CharacterAdded:Connect(function(char)
            local info, rank = Util.Tag_getInfo(player)
            if info then
                Util.Tag_attach(player, char, info)
                TagData.lastRankByPlayer[player] = rank
            end
        end)
        
        TagData.charRemovingConn[player] = player.CharacterRemoving:Connect(function()
            Util.Tag_destroyFor(player)
        end)
    end)
    
    -- Setup for players leaving
    Services.Players.PlayerRemoving:Connect(function(player)
        Util.Tag_destroyFor(player)
        if TagData.charAddedConn[player] then
            TagData.charAddedConn[player]:Disconnect()
            TagData.charAddedConn[player] = nil
        end
        if TagData.charRemovingConn[player] then
            TagData.charRemovingConn[player]:Disconnect()
            TagData.charRemovingConn[player] = nil
        end
    end)
    
    -- Start the scanner
    Util.Tag_startScanner()
end

-- Farming and ESP utility functions
function Util.coinFarmLoop()
    while State.isFarming and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local coins = workspace:GetChildren()
            
            for _, coin in pairs(coins) do
                if coin.Name:match("Coin") and coin:FindFirstChild("Position") then
                    local distance = (rootPart.Position - coin.Position.Position).Magnitude
                    if distance < 50 then
                        rootPart.CFrame = CFrame.new(coin.Position.Position)
                        task.wait(0.1)
                    end
                end
            end
        end)
    end
end

function Util.attackAllNPCsLoop()
    while State.attackAllNPCToggle and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local npcs = workspace:GetChildren()
            
            for _, npc in pairs(npcs) do
                if Util.isNPC(npc) then
                    local humanoid = npc:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local distance = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                        if distance < 20 then
                            local args = {[1] = npc}
                            Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                        end
                    end
                end
            end
        end)
    end
end

function Util.dummyFarmFunction()
    while State.dummyFarmActive and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local dummies = workspace:GetChildren()
            
            for _, dummy in pairs(dummies) do
                if dummy.Name:match("Dummy") and dummy:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - dummy.HumanoidRootPart.Position).Magnitude
                    if distance < 10 then
                        local args = {[1] = dummy}
                        Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                    end
                end
            end
        end)
    end
end

function Util.dummy5kFarmLoop()
    while State.dummyFarm5kEnabled and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local dummies = workspace:GetChildren()
            
            for _, dummy in pairs(dummies) do
                if dummy.Name:match("5k") and dummy:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - dummy.HumanoidRootPart.Position).Magnitude
                    if distance < 10 then
                        local args = {[1] = dummy}
                        Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                    end
                end
            end
        end)
    end
end

-- Auto eat functionality moved to PVP tab implementation

function Util.killAuraLoop()
    while State.killAura and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local players = Services.Players:GetPlayers()
            
            for _, targetPlayer in pairs(players) do
                if targetPlayer ~= player and targetPlayer.Character and 
                   targetPlayer.Character:FindFirstChild("Humanoid") and 
                   targetPlayer.Character.Humanoid.Health > 0 then
                    
                    local distance = (rootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 10 then
                        local args = {[1] = targetPlayer.Character}
                        Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                    end
                end
            end
        end)
    end
end

function Util.loopKillAllPlayers()
    while State.huntPlayers and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local players = Services.Players:GetPlayers()
            
            for _, targetPlayer in pairs(players) do
                if targetPlayer ~= player and targetPlayer.Character and 
                   targetPlayer.Character:FindFirstChild("Humanoid") and 
                   targetPlayer.Character.Humanoid.Health > 0 then
                    
                    local distance = (rootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then
                        rootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position)
                        task.wait(0.1)
                        
                        local args = {[1] = targetPlayer.Character}
                        Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                    end
                end
            end
        end)
    end
end

function Util.autoKillLowLevels()
    while State.farmLowLevels and task.wait(0.1) do
        pcall(function()
            local player = Services.Players.LocalPlayer
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = player.Character.HumanoidRootPart
            local players = Services.Players:GetPlayers()
            
            for _, targetPlayer in pairs(players) do
                if targetPlayer ~= player and targetPlayer.Character and 
                   targetPlayer.Character:FindFirstChild("Humanoid") and 
                   targetPlayer.Character.Humanoid.Health > 0 then
                    
                    -- Check if player is low level (you can customize this logic)
                    local level = targetPlayer.Level and targetPlayer.Level.Value or 1
                    if level < 10 then
                        local distance = (rootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance < 30 then
                            rootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position)
                            task.wait(0.1)
                            
                            local args = {[1] = targetPlayer.Character}
                            Services.ReplicatedStorage.RemoteEvents.AttackEvent:FireServer(unpack(args))
                        end
                    end
                end
            end
        end)
    end
end

function Util.InitializeESPStorage()
    State.ESPStorage = Instance.new("Folder")
    State.ESPStorage.Name = "ESPStorage"
    State.ESPStorage.Parent = workspace
end

function Util.CreateESP(player)
    if not player or player == Services.Players.LocalPlayer then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP_" .. player.Name
    esp.Size = UDim2.new(0, 100, 0, 100)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    esp.Adornee = player.Character and player.Character:FindFirstChild("Head")
    esp.Parent = State.ESPStorage
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Config.ESP.FillColor
    frame.BackgroundTransparency = Config.ESP.FillTransparency
    frame.BorderSizePixel = 0
    frame.Parent = esp
    
    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.Position = UDim2.new(0, 0, 0, 0)
    outline.BackgroundColor3 = Config.ESP.OutlineColor
    outline.BackgroundTransparency = Config.ESP.OutlineTransparency
    outline.BorderSizePixel = 0
    outline.Parent = esp
    
    State.ESPConnections[player] = player.CharacterAdded:Connect(function(char)
        esp.Adornee = char:WaitForChild("Head", 10)
    end)
end

function Util.RemoveESP(player)
    if State.ESPConnections[player] then
        State.ESPConnections[player]:Disconnect()
        State.ESPConnections[player] = nil
    end
    
    local esp = State.ESPStorage:FindFirstChild("ESP_" .. player.Name)
    if esp then
        esp:Destroy()
    end
end

function Util.findClosestTarget()
    local targets = Util.getValidTargetsSorted(State.targetPriority or "Closest")
    if #targets > 0 then
        return targets[1].player, targets[1].distance
    end
    return nil, nil
end

function Util.predictPosition(target, distance)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local targetRoot = target.Character.HumanoidRootPart
    local velocity = targetRoot.Velocity
    local ping = Util.GetPing()
    
    -- Simple prediction based on velocity and ping
    local totalTimeToPredict = ping * 2
    local averageVelocity = velocity
    
    local futurePosition = targetRoot.Position + (averageVelocity * totalTimeToPredict)
    
    return futurePosition
end

    
    
-- Clan and teleport utility functions
function Util.refreshClanTeamList()
    local clans = {}
    local players = Services.Players:GetPlayers()
    if players and type(players) == "table" then
        for _, player in pairs(players) do
            if player ~= Services.Players.LocalPlayer then
                local clan = player:FindFirstChild("Clan")
                if clan and clan.Value and clan.Value ~= "" then
                    if not table.find(clans, clan.Value) then
                        table.insert(clans, clan.Value)
                    end
                end
            end
        end
    end
    
    return clans
end

function Util.getTeleportPlayers()
    local players = {}
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
    end
    return players
end

function Util.cleanTeleportPlayerList()
    local players = Util.getTeleportPlayers()
    local cleanedPlayers = {}
    
    for _, playerName in pairs(players) do
        if playerName and playerName ~= "" then
            table.insert(cleanedPlayers, playerName)
        end
    end
    
    return cleanedPlayers
end

function Util.teleportTo(location)
    local success, result = pcall(function()
        local player = Services.Players.LocalPlayer
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = player.Character.HumanoidRootPart
        
        if type(location) == "table" and location.Position then
            -- Teleport to specific position
            rootPart.CFrame = CFrame.new(location.Position)
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. location.Name,
                Duration = 2
            })
        elseif type(location) == "string" then
            -- Teleport to player
            local targetPlayer = Services.Players:FindFirstChild(location)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                rootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. targetPlayer.Name,
                    Duration = 2
                })
            else
                Rayfield:Notify({
                    Title = "Teleport Error",
                    Content = "Player " .. location .. " not found",
                    Duration = 2
                })
            end
        end
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Teleport Error",
            Content = "Teleport failed: " .. tostring(result),
            Duration = 3
        })
    end
end

function Util.getPlayers()
    local players = {}
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, player in pairs(playerList) do
            if player ~= Services.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
    end
    return players
end

function Util.handleTargetPlayerLeaving(player)
    if player == State.TargetedPlayer then
        State.TargetedPlayer = nil
        Util.updateTargetFeedback("🎯 **TARGET:** None | ❌ **NO TARGET**")
        Rayfield:Notify({
            Title = "Target Lost",
            Content = "Target player has left the game.",
            Duration = 2
        })
    end
end

--[[
    FEATURE MODULES
]]
-- Fireball Aura Module
local FireballAura = {}
FireballAura.isActive = false
FireballAura.lastFireTime = 0
FireballAura.fireInterval = 0.5

function FireballAura.start()
    if FireballAura.isActive then return end
    
    FireballAura.isActive = true
    if Connections.fireballAura then
        Connections.fireballAura:Disconnect()
        Connections.fireballAura = nil
    end
    
    Connections.fireballAura = Services.RunService.RenderStepped:Connect(function()
        if not FireballAura.isActive or (tick() - FireballAura.lastFireTime < FireballAura.fireInterval) then return end

        local target, distance = Util.findClosestTarget()

        if target and distance then
            local predictedPosition = Util.predictPosition(target, distance)
            
            local args = {
                [1] = predictedPosition,
                [2] = "NewFireball",
            }

            -- Get the SkillsInRS remote event
            local SkillsInRS = Services.ReplicatedStorage:FindFirstChild("SkillsInRS")
            if SkillsInRS and SkillsInRS:FindFirstChild("RemoteEvent") then
                SkillsInRS.RemoteEvent:FireServer(unpack(args))
                FireballAura.lastFireTime = tick()
            end
        end
    end)
    
    Rayfield:Notify({
        Title = "Fireball Aura",
        Content = "Fireball Aura activated!",
        Duration = 2
    })
end

function FireballAura.stop()
    if not FireballAura.isActive then return end
    
    FireballAura.isActive = false
    if Connections.fireballAura then
        Connections.fireballAura:Disconnect()
        Connections.fireballAura = nil
    end
    
    Rayfield:Notify({
        Title = "Fireball Aura",
        Content = "Fireball Aura deactivated!",
        Duration = 2
    })
end

function FireballAura.setInterval(interval)
    FireballAura.fireInterval = interval or 0.5
end

-- ESP Module
local ESP = {}
ESP.isActive = false

function ESP.start()
    if ESP.isActive then return end
    
    ESP.isActive = true
    Config.ESP.Enabled = true
    Util.InitializeESPStorage()
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer then
            Util.CreateESP(player)
        end
    end
    
    Rayfield:Notify({
        Title = "ESP",
        Content = "ESP activated!",
        Duration = 2
    })
end

function ESP.stop()
    if not ESP.isActive then return end
    
    ESP.isActive = false
    Config.ESP.Enabled = false
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        Util.RemoveESP(player)
    end
    
    if State.ESPStorage then
        State.ESPStorage:Destroy()
        State.ESPStorage = nil
    end
    
    Rayfield:Notify({
        Title = "ESP",
        Content = "ESP deactivated!",
        Duration = 2
    })
end

function ESP.updateColors(fillColor, outlineColor)
    Config.ESP.FillColor = fillColor or Config.ESP.FillColor
    Config.ESP.OutlineColor = outlineColor or Config.ESP.OutlineColor
end

-- Tag System Module
local TagSystem = {}
TagSystem.isActive = false

function TagSystem.start()
    if TagSystem.isActive then return end
    
    TagSystem.isActive = true
    Util.setupEnhancedTagSystem()
    
    Rayfield:Notify({
        Title = "Tag System",
        Content = "Tag system activated!",
        Duration = 2
    })
end

function TagSystem.stop()
    if not TagSystem.isActive then return end
    
    TagSystem.isActive = false
    Util.Tag_stopScanner()
    Util.Tag_clearAllNow()
    
    Rayfield:Notify({
        Title = "Tag System",
        Content = "Tag system deactivated!",
        Duration = 2
    })
end

function TagSystem.refresh()
    if TagSystem.isActive then
        Util.Tag_scanOnce()
    end
end

-- Farming Module
local Farming = {}
Farming.isActive = false
Farming.currentMode = nil

function Farming.start(mode)
    if Farming.isActive then
        Farming.stop()
    end
    
    Farming.isActive = true
    Farming.currentMode = mode
    
    if mode == "coins" then
        State.isFarming = true
        task.spawn(Util.coinFarmLoop)
    elseif mode == "npcs" then
        State.attackAllNPCToggle = true
        task.spawn(Util.attackAllNPCsLoop)
    elseif mode == "dummies" then
        State.dummyFarmActive = true
        task.spawn(Util.dummyFarmFunction)
    elseif mode == "5k" then
        State.dummyFarm5kEnabled = true
        task.spawn(Util.dummy5kFarmLoop)
    elseif mode == "bosses" then
        State.bossFarmingEnabled = true
        Util.farmBosses()
    end
    
    Rayfield:Notify({
        Title = "Farming",
        Content = mode:upper() .. " farming started!",
        Duration = 2
    })
end

function Farming.stop()
    if not Farming.isActive then return end
    
    Farming.isActive = false
    local mode = Farming.currentMode
    Farming.currentMode = nil
    
    if mode == "coins" then
        State.isFarming = false
    elseif mode == "npcs" then
        State.attackAllNPCToggle = false
    elseif mode == "dummies" then
        State.dummyFarmActive = false
    elseif mode == "5k" then
        State.dummyFarm5kEnabled = false
    elseif mode == "bosses" then
        State.bossFarmingEnabled = false
        if Connections.bossFarming then
            Connections.bossFarming:Disconnect()
            Connections.bossFarming = nil
        end
    end
    
    Rayfield:Notify({
        Title = "Farming",
        Content = mode:upper() .. " farming stopped!",
        Duration = 2
    })
end

function Farming.getStatus()
    return {
        isActive = Farming.isActive,
        currentMode = Farming.currentMode
    }
end

-- Combat Module
local Combat = {}
Combat.isActive = false
Combat.currentMode = nil

function Combat.start(mode)
    if Combat.isActive then
        Combat.stop()
    end
    
    Combat.isActive = true
    Combat.currentMode = mode
    
    if mode == "killAura" then
        State.killAura = true
        task.spawn(Util.killAuraLoop)
    elseif mode == "huntPlayers" then
        State.huntPlayers = true
        task.spawn(Util.loopKillAllPlayers)
    elseif mode == "farmLowLevels" then
        State.farmLowLevels = true
        task.spawn(Util.autoKillLowLevels)
    end
    
    Rayfield:Notify({
        Title = "Combat",
        Content = mode:upper() .. " combat activated!",
        Duration = 2
    })
end

function Combat.stop()
    if not Combat.isActive then return end
    
    Combat.isActive = false
    local mode = Combat.currentMode
    Combat.currentMode = nil
    
    if mode == "killAura" then
        State.killAura = false
    elseif mode == "huntPlayers" then
        State.huntPlayers = false
    elseif mode == "farmLowLevels" then
        State.farmLowLevels = false
    end
    
    Rayfield:Notify({
        Title = "Combat",
        Content = mode:upper() .. " combat deactivated!",
        Duration = 2
    })
end

function Combat.getStatus()
    return {
        isActive = Combat.isActive,
        currentMode = Combat.currentMode
    }
end

-- Teleport Module
local Teleport = {}
Teleport.isActive = false

function Teleport.toLocation(location)
    if Teleport.isActive then return end
    
    Teleport.isActive = true
    Util.teleportTo(location)
    
    task.wait(0.5)
    Teleport.isActive = false
end

function Teleport.toPlayer(playerName)
    if Teleport.isActive then return end
    
    Teleport.isActive = true
    Util.teleportTo(playerName)
    
    task.wait(0.5)
    Teleport.isActive = false
end

function Teleport.getLocations()
    return Config.Teleports
end

function Teleport.addLocation(name, position)
    table.insert(Config.Teleports, {
        Name = name,
        Position = position
    })
end

-- Spectate Module
local Spectate = {}
Spectate.isActive = false

function Spectate.start(playerName)
    if Spectate.isActive then
        Spectate.stop()
    end
    
    Config.Spectate.SelectedPlayer = playerName
    Spectate.isActive = true
    Util.enhancedStartSpectating()
end

function Spectate.stop()
    if not Spectate.isActive then return end
    
    Spectate.isActive = false
    Util.enhancedStopSpectating()
end

function Spectate.getPlayers()
    return Util.getSpectatePlayers()
end

function Spectate.getStatus()
    return {
        isActive = Spectate.isActive,
        currentTarget = Config.Spectate.SelectedPlayer
    }
end

-- NPC Control Module
local NPCControl = {}
NPCControl.isActive = false
NPCControl.controlledNPCs = {}

function NPCControl.arm(npc)
    if not npc then return end
    
    Util.armNPC(npc)
    NPCControl.controlledNPCs[npc] = true
    
    Rayfield:Notify({
        Title = "NPC Control",
        Content = "NPC armed successfully!",
        Duration = 2
    })
end

function NPCControl.disarm(npc)
    if not npc then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    
    NPCControl.controlledNPCs[npc] = nil
    
    Rayfield:Notify({
        Title = "NPC Control",
        Content = "NPC disarmed successfully!",
        Duration = 2
    })
end

function NPCControl.disarmAll()
    if NPCControl.controlledNPCs and type(NPCControl.controlledNPCs) == "table" then
        for npc, _ in pairs(NPCControl.controlledNPCs) do
            NPCControl.disarm(npc)
        end
        NPCControl.controlledNPCs = {}
    end
end

function NPCControl.fling(targetPlayer, controlledNPC, method)
    if method == "skid" then
        Util.NPCSkidFling(targetPlayer, controlledNPC)
    elseif method == "walk" then
        Util.walkfling(targetPlayer, controlledNPC)
    end
end

function NPCControl.getControlledNPCs()
    local npcs = {}
    if NPCControl.controlledNPCs and type(NPCControl.controlledNPCs) == "table" then
        for npc, _ in pairs(NPCControl.controlledNPCs) do
            table.insert(npcs, npc.Name)
        end
    end
    return npcs
end

-- Target System Module
local TargetSystem = {}
TargetSystem.isActive = false
TargetSystem.currentTarget = nil

function TargetSystem.select(player)
    if not player then return end
    
    TargetSystem.currentTarget = player
    State.TargetedPlayer = player
    Util.updateTargetFeedback("🎯 **TARGET:** " .. player.Name .. " | ✅ **READY**")
    
    Rayfield:Notify({
        Title = "Target Selected",
        Content = "Target: " .. player.Name,
        Duration = 2
    })
end

function TargetSystem.clear()
    TargetSystem.currentTarget = nil
    State.TargetedPlayer = nil
    Util.updateTargetFeedback("🎯 **TARGET:** None | ❌ **NO TARGET**")
    
    Rayfield:Notify({
        Title = "Target Cleared",
        Content = "Target has been cleared.",
        Duration = 2
    })
end

function TargetSystem.getStatus()
    return {
        isActive = TargetSystem.isActive,
        currentTarget = TargetSystem.currentTarget and TargetSystem.currentTarget.Name or "None"
    }
end

function TargetSystem.startAction(action)
    if not TargetSystem.currentTarget then
        Rayfield:Notify({
            Title = "Target Error",
            Content = "No target selected.",
            Duration = 2
        })
        return
    end
    
    TargetSystem.isActive = true
    
    if action == "view" then
        State.ViewingTarget = true
        task.spawn(Util.ViewLoop)
    elseif action == "focus" then
        State.FocusingTarget = true
        task.spawn(Util.FocusLoop)
    elseif action == "beng" then
        State.BenggingTarget = true
        task.spawn(Util.BengLoop)
    elseif action == "headsit" then
        State.HeadsittingTarget = true
        task.spawn(Util.HeadsitLoop)
    elseif action == "stand" then
        State.StandingTarget = true
        task.spawn(Util.StandLoop)
    elseif action == "backpack" then
        State.BackpackingTarget = true
        task.spawn(Util.BackpackLoop)
    elseif action == "doggy" then
        State.DoggyingTarget = true
        task.spawn(Util.DoggyLoop)
    elseif action == "suck" then
        State.SuckingTarget = true
        task.spawn(Util.SuckLoop)
    elseif action == "drag" then
        State.DraggingTarget = true
        task.spawn(Util.DragLoop)
    end
    
    Rayfield:Notify({
        Title = "Target Action",
        Content = action:upper() .. " action started on " .. TargetSystem.currentTarget.Name,
        Duration = 2
    })
end

function TargetSystem.stopAction()
    if not TargetSystem.isActive then return end
    
    TargetSystem.isActive = false
    
    -- Stop all target actions
    State.ViewingTarget = false
    State.FocusingTarget = false
    State.BenggingTarget = false
    State.HeadsittingTarget = false
    State.StandingTarget = false
    State.BackpackingTarget = false
    State.DoggyingTarget = false
    State.SuckingTarget = false
    State.DraggingTarget = false
    
    -- Cancel all loops
    if State.ViewLoop then task.cancel(State.ViewLoop) end
    if State.FocusLoop then task.cancel(State.FocusLoop) end
    if State.BengLoop then task.cancel(State.BengLoop) end
    if State.HeadsitLoop then task.cancel(State.HeadsitLoop) end
    if State.StandLoop then task.cancel(State.StandLoop) end
    if State.BackpackLoop then task.cancel(State.BackpackLoop) end
    if State.DoggyLoop then task.cancel(State.DoggyLoop) end
    if State.SuckLoop then task.cancel(State.SuckLoop) end
    if State.DragLoop then task.cancel(State.DragLoop) end
    
    Rayfield:Notify({
        Title = "Target Action",
        Content = "All target actions stopped.",
        Duration = 2
    })
end

-- Auto Features Module
local AutoFeatures = {}
AutoFeatures.isActive = false

function AutoFeatures.start()
    if AutoFeatures.isActive then return end
    
    AutoFeatures.isActive = true
    State.autoEat = true
    -- Auto eat will be handled by the PVP tab toggle
    
    Rayfield:Notify({
        Title = "Auto Features",
        Content = "Auto features activated!",
        Duration = 2
    })
end

function AutoFeatures.stop()
    if not AutoFeatures.isActive then return end
    
    AutoFeatures.isActive = false
    State.autoEat = false
    
    Rayfield:Notify({
        Title = "Auto Features",
        Content = "Auto features deactivated!",
        Duration = 2
    })
end

function AutoFeatures.getStatus()
    return {
        isActive = AutoFeatures.isActive,
        autoEat = State.autoEat
    }
end

-- Settings Module
local Settings = {}
Settings.isActive = false

function Settings.loadConfig(configName)
    local success, result = pcall(function()
        Rayfield:LoadConfiguration(configName)
        Rayfield:Notify({
            Title = "Settings",
            Content = "Configuration '" .. configName .. "' loaded successfully!",
            Duration = 2
        })
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Settings Error",
            Content = "Failed to load configuration: " .. tostring(result),
            Duration = 3
        })
    end
end

function Settings.saveConfig(configName)
    local success, result = pcall(function()
        Rayfield:SaveConfiguration(configName)
        Rayfield:Notify({
            Title = "Settings",
            Content = "Configuration '" .. configName .. "' saved successfully!",
            Duration = 2
        })
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Settings Error",
            Content = "Failed to save configuration: " .. tostring(result),
            Duration = 3
        })
    end
end

function Settings.updateTheme(themeName)
    local success, result = pcall(function()
        -- Theme update logic here
        Rayfield:Notify({
            Title = "Settings",
            Content = "Theme updated to: " .. themeName,
            Duration = 2
        })
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Settings Error",
            Content = "Failed to update theme: " .. tostring(result),
            Duration = 3
        })
    end
end

-- Tag_GroupId now uses Config.Admin.GroupId
-- Tag info moved to Cache.tagRankInfo, Cache.tagOwnerInfo, Cache.tagDevInfo

-- Tag system storage (moved to top of file for Util function access)

--[[
    TAG SYSTEM FUNCTIONS
]]
local function Tag_destroyFor(player)
    if TagData.renderConnByPlayer[player] then
        TagData.renderConnByPlayer[player]:Disconnect()
        TagData.renderConnByPlayer[player] = nil
    end
    local gui = TagData.guiByPlayer[player]
    if gui and gui.Parent then gui:Destroy() end
    TagData.guiByPlayer[player] = nil
    TagData.infoByPlayer[player] = nil
    TagData.lastRankByPlayer[player] = nil
end

local function Tag_getInfo(player)
    local ok, rank = pcall(function()
        return player:GetRankInGroup(Config.Admin.GroupId)
    end)
    if not ok then return nil, nil end
    if rank and rank >= 255 then
        return Cache.tagOwnerInfo, rank
    elseif rank and rank >= 254 then
        return Cache.tagDevInfo, rank
    end
    return Cache.tagRankInfo[rank], rank
end

local function Tag_attach(player, char, info)
    if not info then return end
    local head = char:WaitForChild("Head", 10)
    if not head then return end

    Tag_destroyFor(player)

    local b = Instance.new("BillboardGui")
    b.Name = "RoleTag"
    b.AlwaysOnTop = true
    b.Size = UDim2.new(2.8, 0, 0.5, 0) -- Wider but slimmer height like the reference
    b.StudsOffset = Vector3.new(0, 4.0, 0)
    b.Adornee = head
    b.Parent = head
    TagData.guiByPlayer[player] = b
    TagData.infoByPlayer[player] = info

    -- Main dark container frame
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Darker, more solid background
    f.BackgroundTransparency = 0.05
    f.Parent = b

    -- Rounded corners
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 25) -- Simple rounded corners like reference
    c.Parent = f

    -- Glowing border using rank color
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Thickness = 3 -- Thicker border like reference image
    s.Color = info.color -- Use the rank color (blue for Premium, grey for Free, etc.)
    s.Transparency = 0.1 -- Less transparent for more prominent border
    s.Parent = f

    -- Inner glow effect using rank color with slight variation
    local innerGlow = Instance.new("UIStroke")
    innerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerGlow.Thickness = 1
    innerGlow.Color = info.color -- Same rank color
    innerGlow.Transparency = 0.4
    innerGlow.Parent = f

    -- Icon container (left side) - smaller and closer to text
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0.12, 0, 0.8, 0) -- Smaller icon container
    iconContainer.Position = UDim2.new(0.20, 0, 0.5, 0) -- Move star even closer to text
    iconContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = f

    -- Star icon (bright pink/magenta like reference) - now bigger and directly on normal background
    local starIcon = Instance.new("TextLabel")
    starIcon.Size = UDim2.new(1.0, 0, 1.0, 0) -- Perfectly sized to fit container
    starIcon.Position = UDim2.new(0.5, 0, 0.5, 0) -- Perfectly centered
    starIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    starIcon.BackgroundTransparency = 1
    starIcon.Font = Enum.Font.GothamBold
    starIcon.Text = "★"
    starIcon.TextScaled = true
    starIcon.TextColor3 = Color3.fromRGB(236, 72, 153) -- Bright magenta/pink like reference
    starIcon.TextStrokeTransparency = 0.3
    starIcon.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    starIcon.ZIndex = 10 -- Ensure star is always on top
    starIcon.Parent = iconContainer

    -- Add small sparkle dots around the star (like reference)
    for i = 1, 4 do
        local sparkle = Instance.new("TextLabel")
        sparkle.Size = UDim2.new(0.12, 0, 0.12, 0)
        sparkle.Position = UDim2.new(0.2 + (i * 0.15), 0, 0.2 + (i * 0.15), 0)
        sparkle.AnchorPoint = Vector2.new(0.5, 0.5)
        sparkle.BackgroundTransparency = 1
        sparkle.Font = Enum.Font.Gotham
        sparkle.Text = "•"
        sparkle.TextScaled = true
        sparkle.TextColor3 = Color3.fromRGB(255, 255, 255) -- White sparkles
        sparkle.TextTransparency = 0.2
        sparkle.Parent = iconContainer
    end

    -- Text container (right side) - keep text position, make pill smaller
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(0.35, 0, 0.8, 0) -- Smaller text container to make pill shorter
    textContainer.Position = UDim2.new(0.60, 0, 0.5, 0) -- Move text closer to star
    textContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = f

    -- Main role text using rank color - improved readability
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0.6, 0)
    t.Position = UDim2.new(0.5, 0, 0.3, 0)
    t.AnchorPoint = Vector2.new(0.5, 0.5)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.Text = info.label
    t.TextScaled = true
    t.TextColor3 = info.color -- Use rank color for role text
    t.TextStrokeTransparency = 0.2 -- Reduced for better readability
    t.TextStrokeColor3 = Color3.new(0, 0, 0)
    t.Parent = textContainer

    -- Player name text (smaller, faded) - improved readability
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, 0, 0.4, 0)
    playerName.Position = UDim2.new(0.5, 0, 0.8, 0)
    playerName.AnchorPoint = Vector2.new(0.5, 0.5)
    playerName.BackgroundTransparency = 1
    playerName.Font = Enum.Font.GothamBold -- Changed to bold for better readability
    playerName.Text = "@" .. player.Name
    playerName.TextScaled = true
    playerName.TextColor3 = Color3.fromRGB(147, 51, 234) -- Purple/magenta like reference
    playerName.TextTransparency = 0.4 -- Reduced transparency for better readability
    playerName.TextStrokeTransparency = 0.5 -- Added stroke for contrast
    playerName.TextStrokeColor3 = Color3.new(0, 0, 0)
    playerName.Parent = textContainer

    -- Floating animation
    Services.TweenService:Create(b, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {StudsOffset = Vector3.new(0, 4.2, 0)}):Play()

    -- Distance-based transparency
    local currentTween
            TagData.renderConnByPlayer[player] = Services.RunService.RenderStepped:Connect(function()
        if not head.Parent or not b.Parent then Tag_destroyFor(player) return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local dist = (cam.CFrame.Position - head.Position).Magnitude
        local tr = dist < 25 and 0 or dist < 45 and (dist - 25) / 20 or 1
        local bg = 0.1 + tr
        
        if math.abs(f.BackgroundTransparency - bg) > 0.05 then
            if currentTween then currentTween:Cancel() end
            currentTween = Services.TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = bg})
            currentTween:Play()
            Services.TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = tr}):Play()
            Services.TweenService:Create(playerName, TweenInfo.new(0.3), {TextTransparency = 0.6 + tr * 0.4}):Play()
            Services.TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 0.2 + tr * 0.8}):Play()
            Services.TweenService:Create(innerGlow, TweenInfo.new(0.3), {Transparency = 0.4 + tr * 0.6}):Play()
        end
    end)
end

-- Tag scanner system
    State.tagScanEnabled = true
    State.tagScanThread = nil

local function Tag_clearAllNow()
    if TagData.guiByPlayer and type(TagData.guiByPlayer) == "table" then
        for player, _ in pairs(TagData.guiByPlayer) do
        Tag_destroyFor(player)
        end
    end
end

local function Tag_scanOnce()
    
    -- Attach/update/detach per current state
    local playerList = Services.Players:GetPlayers()
    if playerList and type(playerList) == "table" then
        for _, p in ipairs(playerList) do
        local info, rank = Tag_getInfo(p)
        if info and p.Character and p.Character:FindFirstChild("Head") then
                local existing = TagData.guiByPlayer[p]
                local cached = TagData.infoByPlayer[p]
                local lastRank = TagData.lastRankByPlayer and TagData.lastRankByPlayer[p]
            if (not existing) or (not cached) or cached.label ~= info.label or cached.color ~= info.color or lastRank ~= rank then
                Tag_attach(p, p.Character, info)
                    TagData.lastRankByPlayer[p] = rank
            end
        else
                if TagData.guiByPlayer[p] then
                Tag_destroyFor(p)
                end
            end
        end
    end

    -- Clean up players that left
    if TagData.guiByPlayer and type(TagData.guiByPlayer) == "table" then
        for tracked, _ in pairs(TagData.guiByPlayer) do
            if tracked.Parent ~= Services.Players then
                Tag_destroyFor(tracked)
            end
        end
    end
end

local function Tag_startScanner()
            if State.tagScanThread then return end
            State.tagScanEnabled = true
            State.tagScanThread = task.spawn(function()
        task.wait(1) -- Reduced initial wait time
        while State.tagScanEnabled do
            Tag_scanOnce()
            task.wait(2)
        end
        State.tagScanThread = nil
    end)
end

local function Tag_stopScanner()
    State.tagScanEnabled = false
end

-- Start tag scanner
Tag_startScanner()

-- Enhanced tag system with rolling checks and teleport protection
local function setupEnhancedTagSystem()
    -- Track all players that should have tags
    local playersWithTags = {}
    
    -- Function to ensure a player has their tag
    local function ensurePlayerTag(player)
        if not player or player == Services.Players.LocalPlayer then return end
        
        local info, rank = Tag_getInfo(player)
        if not info then return end
        
        -- Check if player already has a valid tag
        local existingTag = TagData.guiByPlayer[player]
        local currentChar = player.Character
        
        if currentChar and currentChar:FindFirstChild("Head") then
            -- If no tag exists or tag is invalid, create it
            if not existingTag or not existingTag.Parent or existingTag.Parent ~= currentChar.Head then
                Tag_attach(player, currentChar, info)
                playersWithTags[player] = true
            end
        end
    end
    
    -- Function to remove invalid tags
    local function cleanupInvalidTags()
        if TagData.guiByPlayer and type(TagData.guiByPlayer) == "table" then
            for player, _ in pairs(TagData.guiByPlayer) do
            if not player or not player.Parent or not player.Character or 
               not player.Character:FindFirstChild("Head") or 
                   not TagData.guiByPlayer[player] or 
                   not TagData.guiByPlayer[player].Parent then
                Tag_destroyFor(player)
                playersWithTags[player] = nil
                end
            end
        end
    end
    
    -- Function to perform rolling check on all players
    local function performRollingCheck()
        -- Clean up any invalid tags first
        cleanupInvalidTags()
        
        -- Check all current players
        local playerList = Services.Players:GetPlayers()
        if playerList and type(playerList) == "table" then
            for _, player in ipairs(playerList) do
                if player ~= Services.Players.LocalPlayer then
                ensurePlayerTag(player)
                end
            end
        end
        
        -- Remove tags for players who left
        if TagData.guiByPlayer and type(TagData.guiByPlayer) == "table" then
            for player, _ in pairs(TagData.guiByPlayer) do
            if not player or not player.Parent then
                Tag_destroyFor(player)
                playersWithTags[player] = nil
                end
            end
        end
    end
    
    -- Enhanced character event handling
    local function setupCharacterEvents()
        -- Handle existing players
        local playerList = Services.Players:GetPlayers()
        if playerList and type(playerList) == "table" then
            for _, player in ipairs(playerList) do
                if player ~= Services.Players.LocalPlayer then
                -- Connect to character added
                    TagData.charAddedConn[player] = player.CharacterAdded:Connect(function(character)
                    task.wait(1.5) -- Wait longer for character to fully load
                    ensurePlayerTag(player)
                end)
                
                -- Connect to character removing
                    TagData.charRemovingConn[player] = player.CharacterRemoving:Connect(function()
                    -- Don't destroy tag immediately, let rolling check handle it
                    task.wait(0.1)
                end)
                
                -- Handle current character if exists
                if player.Character then
                    task.wait(0.5)
                    ensurePlayerTag(player)
                    end
                end
            end
        end
        
        -- Handle new players joining
        Services.Players.PlayerAdded:Connect(function(player)
            if player ~= Services.Players.LocalPlayer then
                -- Connect to character added
                TagData.charAddedConn[player] = player.CharacterAdded:Connect(function(character)
                    task.wait(1.5) -- Wait longer for character to fully load
                    ensurePlayerTag(player)
                end)
                
                -- Connect to character removing
                TagData.charRemovingConn[player] = player.CharacterRemoving:Connect(function()
                    -- Don't destroy tag immediately, let rolling check handle it
                    task.wait(0.1)
                end)
                
                -- Handle current character if exists
                if player.Character then
                    task.wait(0.5)
                    ensurePlayerTag(player)
                end
            end
        end)
        
        -- Handle players leaving
        Services.Players.PlayerRemoving:Connect(function(player)
            Tag_destroyFor(player)
            playersWithTags[player] = nil
            if TagData.charAddedConn[player] then
                TagData.charAddedConn[player]:Disconnect()
                TagData.charAddedConn[player] = nil
            end
            if TagData.charRemovingConn[player] then
                TagData.charRemovingConn[player]:Disconnect()
                TagData.charRemovingConn[player] = nil
            end
        end)
    end
    
    -- Start the rolling check system
    local function startRollingChecks()
        -- Perform initial check
        performRollingCheck()
        
        -- Continuous rolling check every 1 second
        task.spawn(function()
            while true do
                performRollingCheck()
                task.wait(1) -- Check every second
            end
        end)
        
        -- Teleport protection check every 0.5 seconds
        task.spawn(function()
            while State.tagScanEnabled do
                -- Quick check for missing tags on existing players
                for _, player in ipairs(Services.Players:GetPlayers()) do
                    if player ~= Services.Players.LocalPlayer and player.Character and 
                       player.Character:FindFirstChild("Head") then
                        local existingTag = TagData.guiByPlayer[player]
                        if not existingTag or not existingTag.Parent or 
                           existingTag.Parent ~= player.Character.Head then
                            -- Tag is missing or invalid, recreate it
                            local info, rank = Tag_getInfo(player)
                            if info then
                                Tag_attach(player, player.Character, info)
                            end
                        end
                    end
                end
                task.wait(0.5) -- Check every 0.5 seconds for teleport protection
            end
        end)
    end
    
    -- Setup the enhanced system
    setupCharacterEvents()
    startRollingChecks()
    
    return performRollingCheck -- Return function for manual calls
end

-- Setup enhanced tag system
local performRollingCheck = setupEnhancedTagSystem()

--[[
    MAIN WINDOW CREATION
]]
-- Ensure Rayfield is loaded before creating UI
if not Rayfield then
    error("Rayfield UI library failed to load!")
end

local Window = Rayfield:CreateWindow({
   Name = "Moon Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Moon Hub Interface Suite",
   LoadingSubtitle = "by Moon Hub Team",
   ShowText = "Moon Hub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Moon Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

local Window = Rayfield:CreateWindow({
  Name = "Moon Hub",
  KeySystem = true,
  KeySettings = {
    Title = "Moon Hub",
    Subtitle = "Key System",
    FileName = "MoonHub-Key",
    SaveKey = true,               -- cache the key locally
    GrabKeyFromSite = true,       -- fetch from URL
    Key = {"https://raw.githubusercontent.com/deathier545/antitesting/refs/heads/main/MoonHub-Key"}
  }
})

--[[
    TAB CREATION
]]

local FarmTab = Window:CreateTab("Farm", "package")
local PvPTab = Window:CreateTab("PvP", "sword")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local MiscTab = Window:CreateTab("Misc", "box")
local TargetTab = Window:CreateTab("Target", "circle-user-round")
local ScriptsTab = Window:CreateTab("Scripts", "code")
local SkinsTab = Window:CreateTab("Skins", "sword")
local NPCTab = Window:CreateTab("NPC", "skull")
-- Check if player has premium rank or above
-- removed premium-scoped function

-- Enhanced premium access check with additional security
-- removed premium-scoped function

-- Create Premium tab only if player has access
-- removed premium if-block

local function hasPremiumAccess()
    local lp = Services and Services.Players and Services.Players.LocalPlayer
    local groupId = Config and Config.Admin and Config.Admin.GroupId
    if lp and groupId then
        local ok, rank = pcall(function()
            return lp:GetRankInGroup(groupId)
        end)
        if ok and type(rank) == 'number' and rank > 1 then
            return true
        end
    end
    -- Fallback: no group or rank; treat as non-premium
    return false
end

-- Notify premium users about their access
if hasPremiumAccess() then
    task.wait(1) -- Wait a moment for UI to load
    local success, rank = pcall(function()
        return Services.Players.LocalPlayer:GetRankInGroup(Config.Admin.GroupId)
    end)
    if success and rank then
        local rankName = "Premium"
        if rank >= 254 then
            rankName = "Moderator+"
        elseif rank > 1 then
            rankName = "Rank " .. tostring(rank)
        end
        
        Rayfield:Notify({
            Title = "✨ Premium Access Granted",
            Content = "Welcome! You have " .. rankName .. " access to premium features.",
            Duration = 3
        })
    end
end

local SettingsTab = Window:CreateTab("Settings", "settings")

--[[
    FARM TAB UI
]]

--[[
    FARM TAB FUNCTIONS
]]

local function coinFarmLoop()
    while State.isFarming and task.wait(0.1) do
        pcall(function()
            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
            if Events and Events:FindFirstChild("CoinEvent") then
                Events.CoinEvent:FireServer()
            end
        end)
    end
end

local function attackAllNPCsLoop()
    while State.attackAllNPCToggle and task.wait(0.01) do
        pcall(function()
            local npcsWithHealth = {}
            local NPCFolder = workspace:FindFirstChild("NPC")
            
            if NPCFolder then
                for _, npc in ipairs(NPCFolder:GetDescendants()) do
                    if npc:IsA("Humanoid") and npc.Health > 0 then
                        table.insert(npcsWithHealth, {
                            humanoid = npc,
                            health = npc.Health
                        })
                    end
                end
                
                table.sort(npcsWithHealth, function(a, b)
                    return a.health < b.health
                end)
                
                for _, npcData in ipairs(npcsWithHealth) do
                    if State.attackAllNPCToggle then
                        local args = {
                            [1] = npcData.humanoid,
                            [2] = 1
                        }
                        if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                            Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(unpack(args))
                        end
                    end
                end
            end
        end)
    end
end

local function dummyFarmFunction()
            if State.dummyFarmConnection then
            State.dummyFarmConnection:Disconnect()
            State.dummyFarmConnection = nil
        end
    
    if State.dummyFarmActive then
        State.dummyFarmConnection = Services.RunService.Heartbeat:Connect(function()
            pcall(function()
                local MAP = workspace:FindFirstChild("MAP")
                if MAP and MAP:FindFirstChild("dummies") then
                    local targetDummy = MAP.dummies:GetChildren()[1]
                    local player = Services.Players.LocalPlayer
                    
                    if targetDummy and player.Character then
                        local humanoid = targetDummy:FindFirstChild("Humanoid")
                        local rootPart = targetDummy:FindFirstChild("HumanoidRootPart")
                        local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and rootPart and playerRoot then
                            playerRoot.CFrame = rootPart.CFrame * CFrame.new(0, 8, 0)
                                                    if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                            Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(humanoid, 1)
                            end
                        end
                    end
                end
            end)
        end)
    end
end

local function dummy5kFarmLoop()
    while State.dummyFarm5kEnabled and task.wait() do
        pcall(function()
            local MAP = workspace:FindFirstChild("MAP")
            if MAP and MAP:FindFirstChild("5k_dummies") then
                local dummies = MAP["5k_dummies"]:GetChildren()
                local targetDummy = nil
                local shortestDistance = math.huge
                local player = Services.Players.LocalPlayer
                
                for _, dummy in pairs(dummies) do
                    if dummy.Name == "Dummy2" then
                        if dummy:FindFirstChild("Humanoid") and dummy:FindFirstChild("HumanoidRootPart") then
                            local isOccupied = false
                            local dummyRoot = dummy.HumanoidRootPart
                            
                            for _, otherPlayer in ipairs(Services.Players:GetPlayers()) do
                                if otherPlayer.Character and otherPlayer ~= player then
                                    local otherPlayerRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if otherPlayerRoot and (otherPlayerRoot.Position - dummyRoot.Position).Magnitude < 10 then
                                        isOccupied = true
                                        break
                                    end
                                end
                            end
                            
                            if not isOccupied then
                                local distance = (player.Character.HumanoidRootPart.Position - dummyRoot.Position).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    targetDummy = dummy
                                end
                            end
                        end
                    end
                end
                
                if targetDummy and player.Character then
                    local humanoid = targetDummy:FindFirstChild("Humanoid")
                    local rootPart = targetDummy:FindFirstChild("HumanoidRootPart")
                    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart and playerRoot then
                        playerRoot.CFrame = rootPart.CFrame * CFrame.new(0, 8, 0)
                        if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                            Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(humanoid, 1)
                        end
                    end
                end
            end
        end)
    end
end

--[[
    FARM TAB UI
]]
FarmTab:CreateToggle({
    Name = "💰 Coin Farm",
    CurrentValue = false,
    Callback = function(state)
        State.isFarming = state
        
        if State.isFarming then
            task.spawn(coinFarmLoop)
            Rayfield:Notify({
                Title = "💰 Coin Farm Activated",
                Content = "Coin Farm has been activated.",
                Duration = 1
            })
        else
            Rayfield:Notify({
                Title = "💰 Coin Farm Deactivated",
                Content = "Coin Farm has been deactivated.",
                Duration = 1
            })
        end
    end
})

FarmTab:CreateToggle({
    Name = "👹 Attack All Bosses",
    CurrentValue = false,
    Callback = function(state)
        State.attackAllNPCToggle = state
        
        if state then
            task.spawn(attackAllNPCsLoop)
        end
        
        Rayfield:Notify({
            Title = "👹 Attack All Bosses",
            Content = state and "Auto attack on all bosses has been activated!" or "Auto attack on all bosses has been deactivated!",
            Duration = 1
        })
    end
})

FarmTab:CreateToggle({
    Name = "🧍🏻 Dummy Farm",
    CurrentValue = false,
    Callback = function(state)
        State.dummyFarmActive = state
        dummyFarmFunction()
        
        Rayfield:Notify({
            Title = "🧍🏻 Dummy Farm " .. (state and "Activated" or "Deactivated"),
            Content = state and "Dummy Farm has been activated!" or "Dummy Farm has been deactivated!",
            Duration = 1
        })
    end
})

FarmTab:CreateToggle({
    Name = "🧍🏻 Dummy 5k Farm",
    CurrentValue = false,
    Callback = function(state)
        State.dummyFarm5kEnabled = state
        
        if state then
            task.spawn(dummy5kFarmLoop)
        end
        
        Rayfield:Notify({
            Title = "🧍🏻 Dummy 5k Farm " .. (state and "Activated" or "Deactivated"),
            Content = state and "Dummy 5k Farm has been activated!" or "Dummy 5k Farm has been deactivated!",
            Duration = 1
        })
    end
})

FarmTab:CreateToggle({
    Name = "📻 Free Radio",
    CurrentValue = false,
    Callback = function(state)
        pcall(function()
            local player = Services.Players.LocalPlayer
            local gui = player:FindFirstChild("PlayerGui")
            if gui and gui:FindFirstChild("DRadio_Gui") then
                gui.DRadio_Gui.Enabled = state
            end
        end)
        
        Rayfield:Notify({
            Title = "📻 Free Radio",
            Content = state and "Free Radio has been activated!" or "Free Radio has been deactivated!",
            Duration = 1
        })
    end
})

FarmTab:CreateToggle({
    Name = "🔍 Visual 13x Exp",
    CurrentValue = false,
    Callback = function(state)
        pcall(function()
            local player = Services.Players.LocalPlayer
            local gui = player:FindFirstChild("PlayerGui")
            if gui and gui:FindFirstChild("LevelBar") and gui.LevelBar:FindFirstChild("gamepassText") then
                gui.LevelBar.gamepassText.Visible = state
                if state then
                    gui.LevelBar.gamepassText.Text = "13x exp"
                end
            end
        end)
        
        Rayfield:Notify({
            Title = "🔍 Visual 13x Exp",
            Content = state and "13x Exp has been activated!" or "13x Exp has been deactivated!",
            Duration = 1
        })
    end
})

--[[
    PVP TAB FUNCTIONS
]]

-- Fireball Aura System (from XW0dHKI.txt)
        local SkillsInRS = Services.ReplicatedStorage:WaitForChild("SkillsInRS", 10)
        if not SkillsInRS then return end
        local SkillsRemoteEvent = SkillsInRS:WaitForChild("RemoteEvent", 10)
        if not SkillsRemoteEvent then return end

local function autoEatLoop()
    while State.autoEat and task.wait(1) do
        pcall(function()
            -- Exact name first:
            local tool = Util.equipToolByName("Food")

            -- Fallback: any tool that qualifies as food
            if not tool then
                local lp = Services.Players.LocalPlayer
                local hum = lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                local backpack = lp and lp:FindFirstChildOfClass("Backpack")
                if hum and backpack then
                    for _, t in ipairs(backpack:GetChildren()) do
                        if IsFoodTool(t) then
                            pcall(function() hum:EquipTool(t) end)
                            tool = t
                            break
                        end
                    end
                end
            end

            if tool then
                pcall(function() tool:Activate() end)
                task.wait(0.2)
            end
        end)
    end
end

local function loopKillAllPlayers()
    local localPlayer = Services.Players.LocalPlayer

    while State.huntPlayers and task.wait() do
        pcall(function()
            for _, target in ipairs(Services.Players:GetPlayers()) do
                if target ~= localPlayer and target.Character and target.Character:FindFirstChild("Humanoid") and 
                   target.Character.Humanoid.Health > 1 and not target.Character:FindFirstChild("SafeZoneShield") then

                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

                    if targetRoot and localRoot then
                        if (localRoot.Position - targetRoot.Position).Magnitude > 10 then
                            localRoot.CFrame = targetRoot.CFrame
                        end

                        local startTime = tick()

                        while target.Character and target.Character:FindFirstChild("Humanoid") and 
                              target.Character.Humanoid.Health > 1 and State.huntPlayers do

                            if tick() - startTime > 8 then
                                break
                            end

                            local carryArgs = {
                                [1] = target,
                                [2] = "request_accepted"
                            }
                            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
                            if Events and Events:FindFirstChild("CarryEvent") then
                                Events.CarryEvent:FireServer(unpack(carryArgs))
                            end

                            local attackArgs = {
                                [1] = target.Character.Humanoid,
                                [2] = 24
                            }
                            if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                                Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(unpack(attackArgs))
                            end

                            task.wait()
                        end
                    end
                end
            end
        end)
    end
end

local function autoKillLowLevels()
    local lp = Services.Players.LocalPlayer

    while State.farmLowLevels and task.wait() do
        pcall(function()
            local best = nil
            for _, p in ipairs(Services.Players:GetPlayers()) do
                if p ~= lp and p.Character and p:FindFirstChild("leaderstats") and 
                   p.leaderstats.Level.Value < lp.leaderstats.Level.Value and 
                   p.Character:FindFirstChild("HumanoidRootPart") and 
                   p.Character:FindFirstChild("Humanoid") and 
                   p.Character.Humanoid.Health > 1 and 
                   not p.Character:FindFirstChild("SafeZoneShield") and 
                   (not best or p.leaderstats.Level.Value < best.leaderstats.Level.Value) then 
                    best = p 
                end
            end

            if best and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local lr, tr = lp.Character.HumanoidRootPart, best.Character.HumanoidRootPart
                if (lr.Position - tr.Position).Magnitude > 10 then 
                    lr.CFrame = tr.CFrame 
                end
                
                local Events = Services.ReplicatedStorage:FindFirstChild("Events")
                if Events and Events:FindFirstChild("CarryEvent") then
                    Events.CarryEvent:FireServer(best, "request_accepted")
                end
                
                if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                    Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(best.Character.Humanoid, 24)
                end
            end
        end)
    end
end

-- ESP System Functions
local function InitializeESPStorage()
    if not State.ESPStorage then
        State.ESPStorage = Instance.new("Folder")
        State.ESPStorage.Name = "ESP_Storage"
        State.ESPStorage.Parent = Services.CoreGui
    end
end

local function CreateESP(player)
    if not State.ESPStorage or not Config.ESP.Enabled then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name
    highlight.FillColor = Config.ESP.FillColor
    highlight.DepthMode = Config.ESP.DepthMode
    highlight.FillTransparency = Config.ESP.FillTransparency
    highlight.OutlineColor = Config.ESP.OutlineColor
    highlight.OutlineTransparency = Config.ESP.OutlineTransparency
    highlight.Parent = State.ESPStorage

    if player.Character then
        highlight.Adornee = player.Character
    end

    State.ESPConnections[player] = player.CharacterAdded:Connect(function(character)
        highlight.Adornee = character
    end)
end

local function RemoveESP(player)
    if State.ESPStorage then
        local esp = State.ESPStorage:FindFirstChild(player.Name)
        if esp then
            esp:Destroy()
        end
    end
    
    if State.ESPConnections[player] then
        State.ESPConnections[player]:Disconnect()
        State.ESPConnections[player] = nil
    end
end

local function ToggleESP(state)
    Config.ESP.Enabled = state
    
    if state then
        InitializeESPStorage()
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Services.Players.LocalPlayer then
                CreateESP(player)
            end
        end
    else
        if State.ESPConnections and type(State.ESPConnections) == "table" then
            for player, _ in pairs(State.ESPConnections) do
            RemoveESP(player)
            end
        end
        
        if State.ESPStorage then
            State.ESPStorage:Destroy()
            State.ESPStorage = nil
        end
    end
    
    Rayfield:Notify({
        Title = "👁️ ESP Players",
        Content = state and "ESP Activated!" or "ESP Deactivated!",
        Duration = 1
    })
end

-- Walk Speed Functions
local function updateWalkSpeed(speed)
    local character = Services.Players.LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character.Humanoid.WalkSpeed = speed
    end
end

-- Fireball Aura Functions (from XW0dHKI.txt)
local detectionRadius = 70
local fireInterval = 0.5
local lastFireTime = 0
local previousTargets = {}

local function findClosestTarget()
    local character = Services.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil, nil end

    local myPosition = character.HumanoidRootPart.Position
    local targets = {}

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPosition = player.Character.HumanoidRootPart.Position
            local distance = (myPosition - targetPosition).Magnitude

            if distance <= detectionRadius then
                table.insert(targets, {
                    character = player.Character,
                    distance = distance,
                    health = player.Character.Humanoid.Health
                })
            end
        end
    end

    if #targets == 0 then return nil, nil end

    if State.targetPriority == "Lowest Health" then
        table.sort(targets, function(a, b) return a.health < b.health end)
    else
        table.sort(targets, function(a, b) return a.distance < b.distance end)
    end

    return targets[1].character, targets[1].distance
end

local function predictPosition(target, distance)
    local rootPart = target.HumanoidRootPart
    
    if not previousTargets[target] then
        previousTargets[target] = {Velocities = {}, Index = 1}
    end
    local data = previousTargets[target]
    data.Velocities[data.Index] = rootPart.AssemblyLinearVelocity
    data.Index = (data.Index % 3) + 1

    local averageVelocity = Vector3.new(0, 0, 0)
    if data.Velocities and type(data.Velocities) == "table" then
    for _, vel in pairs(data.Velocities) do
        averageVelocity = averageVelocity + vel
    end
    averageVelocity = averageVelocity / #data.Velocities
    end

    local flightTime = distance / State.projectileSpeed
            local ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    local totalTimeToPredict = flightTime + ping

    local futurePosition = rootPart.Position + (averageVelocity * totalTimeToPredict)
    
    return futurePosition
end

-- Fireball Aura Loop using RenderStepped (working method from XW0dHKI.txt)
-- fireballAuraConnection moved to Connections.fireballAura

local function startFireballAura()
    if Connections.fireballAura then
        Connections.fireballAura:Disconnect()
        Connections.fireballAura = nil
    end
    
    Connections.fireballAura = Services.RunService.RenderStepped:Connect(function()
        if not State.isAuraActive or (tick() - lastFireTime < fireInterval) then return end

        local target, distance = findClosestTarget()

        if target and distance then
            local predictedPosition = predictPosition(target, distance)
            
            local args = {
                [1] = predictedPosition,
                [2] = "NewFireball",
            }

            -- Get the SkillsInRS remote event
            local SkillsInRS = Services.ReplicatedStorage:FindFirstChild("SkillsInRS")
            if SkillsInRS and SkillsInRS:FindFirstChild("RemoteEvent") then
                SkillsInRS.RemoteEvent:FireServer(unpack(args))
                lastFireTime = tick()
            end
        end
    end)
end

local function stopFireballAura()
    if Connections.fireballAura then
        Connections.fireballAura:Disconnect()
        Connections.fireballAura = nil
    end
end

local function delayedNotification()
            if Config.WalkSpeed.Debounce then return end
        Config.WalkSpeed.Debounce = true
    
    task.wait(1) -- Wait 1 second after last slider movement
    
    Rayfield:Notify({
        Title = "🚀 Speed Adjustment",
                    Content = "Your walk speed has been set to " .. Config.WalkSpeed.CurrentSpeed .. "!",
        Duration = 1
    })
    
            Config.WalkSpeed.Debounce = false
end

--[[
    PVP TAB UI
]]

-- ⚔️ Aura Section
PvPTab:CreateSection("⚔️ Aura")

PvPTab:CreateToggle({
    Name = "🐟 Auto Eat (PC & Mobile)",
    CurrentValue = false,
    Callback = function(state)
        State.autoEat = state
        if State.autoEat then
            task.spawn(autoEatLoop)
        end
        
        Rayfield:Notify({
            Title = "🐟 Auto Eat",
            Content = state and "Auto Eat has been activated for your device." or "Auto Eat has been deactivated.",
            Duration = 1
        })
    end
})

PvPTab:CreateToggle({
    Name = "⚔️ Kill Aura",
    CurrentValue = false,
    Callback = function(state)
        State.killAura = state
        if state then
            task.spawn(Util.killAuraLoop)
        end
        
        Rayfield:Notify({
            Title = "⚔️ Kill Aura " .. (state and "Activated" or "Deactivated"),
            Content = state and "Kill Aura is now active." or "Kill Aura is now inactive.",
            Duration = 1
        })
    end
})

-- Target Priority Dropdown (Shared with Kill Aura)
PvPTab:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest", "Lowest Health"},
    CurrentOption = "Closest",
    Flag = "SharedTargetPriority",
    Callback = function(Option)
        -- Handle both string and table inputs
        local selectedOption = ""
        if type(Option) == "table" then
            selectedOption = Option[1] or "Closest"
        else
            selectedOption = tostring(Option) or "Closest"
        end
        
        State.targetPriority = selectedOption
        Rayfield:Notify({
            Title = "Target Priority",
            Content = "Target priority set to: " .. selectedOption .. " (Affects both Kill Aura and Fireball Aura)",
            Duration = 2
        })
    end,
})

-- Fireball Aura Toggle
PvPTab:CreateToggle({
    Name = "🔥 Fireball Aura",
    CurrentValue = false,
    Callback = function(state)
        if state then
            FireballAura.start()
        else
            FireballAura.stop()
        end
        
        Rayfield:Notify({
            Title = "🔥 Fireball Aura " .. (state and "Activated" or "Deactivated"),
            Content = state and "Fireball Aura is now active." or "Fireball Aura is now inactive.",
            Duration = 1
        })
    end
})

-- Detection Range Slider
PvPTab:CreateSlider({
    Name = "Detection Range",
    Range = {10, 300},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 70,
    Flag = "FireballRangeSlider",
    Callback = function(Value)
        State.detectionRadius = Value
        Rayfield:Notify({
            Title = "Detection Range",
            Content = "Detection range set to: " .. Value .. " studs.",
            Duration = 1
        })
    end,
})

-- Fire Interval Slider
PvPTab:CreateSlider({
    Name = "Fire Interval",
    Range = {0.1, 1.0},
    Increment = 0.1,
    Suffix = " s",
    CurrentValue = 0.5,
    Flag = "FireballIntervalSlider",
    Callback = function(Value)
        State.fireInterval = Value; FireballAura.setInterval(Value)
        Rayfield:Notify({
            Title = "Fire Interval",
            Content = "Fire interval set to: " .. string.format("%.1f", Value) .. "s.",
            Duration = 1
        })
    end,
})

PvPTab:CreateToggle({
    Name = "🤯 Loop Kill All Players",
    CurrentValue = false,
    Callback = function(state)
        State.huntPlayers = state
        if state then
            task.spawn(loopKillAllPlayers)
        end
        
        Rayfield:Notify({
            Title = state and "🤯 Loop Kill Activated" or "🛑 Loop Kill Stopped",
            Content = state and "Now hunting all players!" or "Stopped hunting players.",
            Duration = 1
        })
    end
})

PvPTab:CreateToggle({
    Name = "😎 Auto Kill Low Levels",
    CurrentValue = false,
    Callback = function(state)
        State.farmLowLevels = state
        if state then
            task.spawn(autoKillLowLevels)
        end
        
        Rayfield:Notify({
            Title = state and "😎 Auto Kill Low Levels Activated" or "🛑 Auto Kill Low Levels Stopped",
            Content = state and "Hunting lower-level players!" or "Stopped hunting low-level players.",
            Duration = 1
        })
    end
})

-- 🔧 Other Section
PvPTab:CreateSection("🔧 Other")

PvPTab:CreateButton({
    Name = "🔥 Free Fireball",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "Fireball"
        tool.RequiresHandle = false

        tool.Activated:Connect(function()
            local mouse = Services.Players.LocalPlayer:GetMouse()
            local args = {
                [1] = mouse.Hit.p,
                [2] = "NewFireball"
            }
            local SkillsInRS = Services.ReplicatedStorage:FindFirstChild("SkillsInRS")
            if SkillsInRS and SkillsInRS:FindFirstChild("RemoteEvent") then
                SkillsInRS.RemoteEvent:FireServer(unpack(args))
            end
        end)

        tool.Parent = Services.Players.LocalPlayer.Backpack
        
        Rayfield:Notify({
            Title = "🔥 Fireball Created",
            Content = "The Fireball has been added to your backpack!",
            Duration = 1
        })
    end
})

PvPTab:CreateButton({
    Name = "⚡ Free Lightningball",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "Lightning Ball"
        tool.RequiresHandle = false

        tool.Activated:Connect(function()
            local mouse = Services.Players.LocalPlayer:GetMouse()
            for i = 1, 3 do
                local args = {
                    [1] = mouse.Hit.p,
                    [2] = "NewLightningball"
                }
                local SkillsInRS = Services.ReplicatedStorage:FindFirstChild("SkillsInRS")
                if SkillsInRS and SkillsInRS:FindFirstChild("RemoteEvent") then
                    SkillsInRS.RemoteEvent:FireServer(unpack(args))
                end
                task.wait(0.1)
            end
        end)

        tool.Parent = Services.Players.LocalPlayer.Backpack
        
        Rayfield:Notify({
            Title = "⚡ Lightningball Created",
            Content = "The Lightningball has been added to your backpack!",
            Duration = 1
        })
    end
})

PvPTab:CreateToggle({
    Name = "👁️ ESP Players",
    CurrentValue = false,
    Callback = function(state)
        ToggleESP(state)
    end
})

PvPTab:CreateSlider({
    Name = "🚀 Walk Speed",
    Range = {Config.WalkSpeed.MinSpeed, Config.WalkSpeed.MaxSpeed},
    Increment = 1,
    CurrentValue = Config.WalkSpeed.CurrentSpeed,
    Callback = function(value)
        Config.WalkSpeed.CurrentSpeed = value
        updateWalkSpeed(value)
        task.spawn(delayedNotification)
    end
})

-- Character connection to maintain speed on respawn
Services.Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if Config.WalkSpeed.CurrentSpeed > Config.WalkSpeed.MinSpeed then
        character:WaitForChild("Humanoid")
            updateWalkSpeed(Config.WalkSpeed.CurrentSpeed)
    end
end)

-- Cleanup fireball aura when players leave
Services.Players.PlayerRemoving:Connect(function(player)
    if player.Character and previousTargets[player.Character] then
        previousTargets[player.Character] = nil
    end
end)

--[[
    CLAN JOIN SYSTEM
]]

-- Clan Join variables
local invitationEvent = Services.ReplicatedStorage:WaitForChild("invitationEvent", 9e9)
local ClanTeamsFolder = workspace:FindFirstChild("Teams")
local clanTeamList = {}
local selectedClan = ""
local clanAutoJoin = false
local clanAutoJoinThread = nil
local lastJoinedClan = nil

-- Function to refresh clan team list
local function refreshClanTeamList()
    clanTeamList = {}
    
    -- Check multiple possible clan locations
    local clanLocations = {
        workspace:FindFirstChild("Teams"),
        workspace:FindFirstChild("Clans"),
        workspace:FindFirstChild("ClanTeams"),
        workspace:FindFirstChild("TeamSystem")
    }
    
    for _, location in ipairs(clanLocations) do
        if location then
            for _, team in ipairs(location:GetChildren()) do
                -- Check if it's actually a clan/team (has leader or members)
                if team:FindFirstChild("leader") or team:FindFirstChild("members") or team:FindFirstChild("Members") then
                    table.insert(clanTeamList, team.Name)
                end
            end
        end
    end
    
    -- Also check for clans in workspace directly
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("leader") or obj:FindFirstChild("members") or obj:FindFirstChild("Members") then
            -- Check if it's likely a clan (not a player character)
            if not Services.Players:FindFirstChild(obj.Name) and obj.Name ~= Services.Players.LocalPlayer.Name then
                table.insert(clanTeamList, obj.Name)
            end
        end
    end
    
    -- Remove duplicates
    local uniqueClans = {}
    for _, clan in ipairs(clanTeamList) do
        if not table.find(uniqueClans, clan) then
            table.insert(uniqueClans, clan)
        end
    end
    clanTeamList = uniqueClans
    
    if #clanTeamList > 0 then
        selectedClan = clanTeamList[1]
    end
    
    return clanTeamList
end

-- Initialize clan list
refreshClanTeamList()

-- Clan Join Section
PvPTab:CreateSection("🏛️ Clan Join")

-- Clan Selection Dropdown
local ClanDropdown = PvPTab:CreateDropdown({
    Name = "Select Clan",
    Options = clanTeamList,
    CurrentOption = selectedClan,
    Flag = "ClanSelection",
    Callback = function(choice)
        -- Handle both string and table inputs
        if type(choice) == "table" then
            selectedClan = choice[1] or ""
        else
            selectedClan = tostring(choice) or ""
        end
    end
})

-- Join Selected Clan Button
PvPTab:CreateButton({
    Name = "Join Selected Clan",
    Callback = function()
        if not selectedClan or selectedClan == "" then
            return
        end

        local clanIcon = ""
        local clanLeader = nil
        
        -- Try to find clan in multiple locations
        local clanLocations = {
            workspace:FindFirstChild("Teams"),
            workspace:FindFirstChild("Clans"),
            workspace:FindFirstChild("ClanTeams"),
            workspace:FindFirstChild("TeamSystem")
        }
        
        for _, location in ipairs(clanLocations) do
            if location then
                local teamFolder = location:FindFirstChild(selectedClan)
                if teamFolder then
                    -- Try different leader property names
                    local leaderProp = teamFolder:FindFirstChild("leader") or teamFolder:FindFirstChild("Leader") or teamFolder:FindFirstChild("owner")
                    if leaderProp then
                        clanLeader = leaderProp.Value
                            break
                        end
                    end
                end
            end

        -- Also check workspace directly
        if not clanLeader then
            local clanObj = workspace:FindFirstChild(selectedClan)
            if clanObj then
                local leaderProp = clanObj:FindFirstChild("leader") or clanObj:FindFirstChild("Leader") or clanObj:FindFirstChild("owner")
                if leaderProp then
                    clanLeader = leaderProp.Value
                end
            end
        end
        
        -- Get clan icon if leader found
        if clanLeader then
                                    local leaderPlayer = Services.Players:FindFirstChild(clanLeader)
            if leaderPlayer then
                local iconProp = leaderPlayer:FindFirstChild("ClanIcon") or leaderPlayer:FindFirstChild("clanIcon") or leaderPlayer:FindFirstChild("TeamIcon")
                if iconProp and iconProp.Value and iconProp.Value ~= "" then
                    clanIcon = iconProp.Value
                end
            end
        end

        local currentClan = Services.Players.LocalPlayer:FindFirstChild("Clan") and Services.Players.LocalPlayer.Clan.Value or nil
        if currentClan and currentClan ~= selectedClan then
            pcall(function()
                Services.ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("ClanEvent", 9e9):FireServer({{ action = "leave_clan" }})
            end)
            task.wait(0.5)
        end

        local success = false
        pcall(function()
            local args = { { teamIcon = clanIcon, action = "accepted", teamName = selectedClan } }
            invitationEvent:FireServer(unpack(args))
            success = true
        end)

        if not success then
            pcall(function()
                local args = { { teamIcon = clanIcon, action = "accepted", teamName = selectedClan }, selectedClan }
                invitationEvent:FireServer(unpack(args))
                success = true
            end)
        end

        if not success then
            pcall(function()
                invitationEvent:FireServer(selectedClan)
                success = true
            end)
        end

        if success then
            lastJoinedClan = selectedClan
        end
    end
})

-- Auto-refresh clan list every 30 seconds to keep it updated
task.spawn(function()
    while task.wait(30) do
        local clans = refreshClanTeamList()
        if ClanDropdown then
            ClanDropdown:Refresh(clans)
        end
    end
end)

-- Also refresh when the game starts
task.spawn(function()
    task.wait(5) -- Wait for game to fully load
    local clans = refreshClanTeamList()
    if ClanDropdown then
        ClanDropdown:Refresh(clans)
    end
end)

-- Auto Join Selected Clan Toggle
PvPTab:CreateToggle({
    Name = "Auto Join Selected Clan",
    CurrentValue = false,
    Callback = function(state)
        clanAutoJoin = state
        if clanAutoJoin then
            if clanAutoJoinThread then return end
            clanAutoJoinThread = task.spawn(function()
                while clanAutoJoin do
                    if selectedClan and selectedClan ~= "" then
                        local clanIcon = ""
                        pcall(function()
                            local tf = workspace:FindFirstChild("Teams")
                            if tf then
                                local teamFolder = tf:FindFirstChild(selectedClan)
                                if teamFolder and teamFolder:FindFirstChild("leader") then
                                    local leaderName = teamFolder.leader.Value
                                    local leaderPlayer = Services.Players:FindFirstChild(leaderName)
                                    if leaderPlayer and leaderPlayer:FindFirstChild("ClanIcon") and leaderPlayer.ClanIcon.Value and leaderPlayer.ClanIcon.Value ~= "" then
                                        clanIcon = leaderPlayer.ClanIcon.Value
                                    end
                                end
                            end
                        end)

                        if lastJoinedClan and lastJoinedClan ~= selectedClan then
                            pcall(function()
                                Services.ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("ClanEvent", 9e9):FireServer({{ action = "leave_clan" }})
                            end)
                        end

                        pcall(function()
                            local args = { { teamIcon = clanIcon, action = "accepted", teamName = selectedClan } }
                            invitationEvent:FireServer(unpack(args))
                            lastJoinedClan = selectedClan
                        end)
                    end
                    task.wait(1)
                end
            end)
        else
            clanAutoJoinThread = nil
        end
    end
})

-- Refresh Clan List Button
PvPTab:CreateButton({
    Name = "Refresh Clan List",
    Callback = function()
        local clans = refreshClanTeamList()
        if ClanDropdown then
            ClanDropdown:Refresh(clans)
        end

    end
})

--[[
    PLAYER TELEPORT SYSTEM
]]

-- Player Teleport variables (using Config.Spectate.SelectedPlayer)

-- Function to get players for teleport
local function getTeleportPlayers()
    local players = {"Ninguém"}
    local currentPlayers = {}
    
    -- Get current players and track them
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer then
            table.insert(players, player.Name)
            currentPlayers[player.Name] = true
        end
    end
    
    -- Return clean list
    return players
end

-- Player Teleport Section
PvPTab:CreateSection("🙋🏻 Teleport to Player")

-- Teleport Dropdown
local TeleportDropdown = PvPTab:CreateDropdown({
    Name = "Select Player to Teleport to",
    Options = getTeleportPlayers(), -- Use function to get initial players
    CurrentOption = "Ninguém",
    Flag = "PlayerTeleport",
    Callback = function(selectedPlayer)
        -- Ensure selectedPlayer is a string
        if type(selectedPlayer) == "table" then
            selectedPlayer = selectedPlayer[1] or "Ninguém"
        elseif type(selectedPlayer) ~= "string" then
            selectedPlayer = tostring(selectedPlayer) or "Ninguém"
        end
        
        Config.Spectate.SelectedPlayer = selectedPlayer
        
        if selectedPlayer == "Ninguém" then 
            Rayfield:Notify({
                Title = "Teleport",
                Content = "No player selected",
                Duration = 1
            })
            return 
        end
        
        local localPlayer = Services.Players.LocalPlayer
        local targetPlayer = Services.Players:FindFirstChild(selectedPlayer)

        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                localPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                
                Rayfield:Notify({
                    Title = "🙋🏻 Teleport Successful",
                    Content = "You have successfully teleported to " .. targetPlayer.Name .. "!",
                    Duration = 1
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Player not found or invalid target!",
                Duration = 1
            })
        end
    end
})

-- Function to clean player list (remove offline players)
local function cleanTeleportPlayerList()
    local players = getTeleportPlayers()
    if TeleportDropdown then
        -- Force refresh with clean list
        TeleportDropdown:Refresh(players, true)
        -- Reset selection if current selection is no longer valid
        if Config.Spectate.SelectedPlayer ~= "Ninguém" then
            local playerExists = false
            for _, playerName in ipairs(players) do
                if playerName == Config.Spectate.SelectedPlayer then
                    playerExists = true
                    break
                end
            end
            if not playerExists then
                Config.Spectate.SelectedPlayer = "Ninguém"
                TeleportDropdown:Set("Ninguém")
            end
        end
    end
    return players
end

-- Function to update teleport dropdown
local function updateTeleportDropdown()
    local players = getTeleportPlayers()
    if TeleportDropdown then
        TeleportDropdown:Refresh(players, true)
    end
end

-- Function to refresh teleport dropdown with proper initialization
local function refreshTeleportDropdown()
    local players = cleanTeleportPlayerList()
    return players
end

-- Refresh Teleport List Button
PvPTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        local players = refreshTeleportDropdown()
        local playerCount = #players - 1 -- Subtract 1 for "Ninguém" option
        Rayfield:Notify({
            Title = "Player List",
            Content = "Player list refreshed! Found " .. playerCount .. " players.",
            Duration = 2
        })
    end
})

-- Initialize teleport dropdown after a short delay to ensure everything is loaded
task.spawn(function()
    task.wait(2) -- Increased wait time for better initialization
    refreshTeleportDropdown()
end)

-- Periodic cleanup to ensure list stays clean
task.spawn(function()
    while task.wait(15) do -- Clean every 15 seconds
        cleanTeleportPlayerList()
    end
end)

-- Also refresh when players join/leave
Services.Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    local players = refreshTeleportDropdown()
    Rayfield:Notify({
        Title = "Player Joined",
        Content = player.Name .. " joined. Player list updated.",
        Duration = 2
    })
end)

Services.Players.PlayerRemoving:Connect(function(player)
    task.wait(0.5)
    local players = refreshTeleportDropdown()
    Rayfield:Notify({
        Title = "Player Left",
        Content = player.Name .. " left. Player list updated.",
        Duration = 2
    })
end)

--[[
    TELEPORT TAB UI
]]

--[[
    TELEPORT TAB FUNCTIONS
]]

local function teleportTo(location)
    local character = Services.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(location.Position)
        
        Rayfield:Notify({
            Title = location.Name,
            Content = "You have been teleported successfully!",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Character not found or invalid!",
            Duration = 3
        })
    end
end

--[[
    TELEPORT TAB UI
]]
-- Create teleport buttons for each location
for _, location in ipairs(Config.Teleports) do
    TeleportTab:CreateButton({
        Name = location.Name,
        Callback = function()
            teleportTo(location)
        end
    })
end

--[[
    MISC TAB UI
]]

--[[
    MISC TAB FUNCTIONS
]]

-- Name animation system
local isAnimating = false

local function animateName()
    -- Table with names for the animation
    local nameParts = {
        "M",
        "Mo",
        "Moo",
        "Moon",
        "Moon ",
        "Moon H",
        "Moon Hu",
        "Moon Hub"
    }

    -- Loop that continues while animation is active
    while isAnimating do
        -- Iterate over each part of the name to create the "typing" effect
        for _, text in ipairs(nameParts) do
            -- If toggle is deactivated mid-animation, stop the loop immediately
            if not isAnimating then break end

            -- Arguments for the name change event
            local args = {
                text,
                "player"
            }
            -- Fire the event to the server
            local success, err = pcall(function()
                local Events = Services.ReplicatedStorage:WaitForChild("Events", 1)
                if Events then
                    local nameEvent = Events:WaitForChild("nameEvent", 1)
                    if nameEvent then
                        nameEvent:FireServer(unpack(args))
                    end
                end
            end)
            
            -- Small pause so the animation is visible
            task.wait(0.2) 
        end
        -- Pause before restarting the animation
        task.wait(0.5)
    end
end

-- Admin status checking
local function checkAdminStatus(player)
    if not player then return false end
    
    local success, rank = pcall(function()
        return player:GetRankInGroup(Config.Admin.GroupId)
    end)
    
    if success and rank and rank >= 254 then
        return true
    end
    
    return false
end

-- Moon Hub Animation Toggle
MiscTab:CreateToggle({
    Name = "Moon Hub Animation",
    CurrentValue = false,
    Callback = function(state)
        isAnimating = state
        
        if isAnimating then
            -- If toggle is activated, start animation in new thread
            task.spawn(animateName)
        end
        -- If deactivated, animation stops naturally
    end
})

-- Spectate system functions
local function getPlayers()
    local playerList = {}
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Services.Players.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    table.insert(playerList, "Ninguém")
    return playerList
end

--[[
    TARGET TAB UI
]]

--[[
    TARGET TAB FUNCTIONS
]]

local ForceWhitelist = {}
local ScriptWhitelist = {}

-- Connect to player leaving event using the Util function
Services.Players.PlayerRemoving:Connect(Util.handleTargetPlayerLeaving)

-- Additional variables for the Target system
-- Velocity_Asset moved to Cache.velocityAsset
-- Initialize velocityAsset with proper error handling
local success = pcall(function()
    -- Create a BodyVelocity object to control movement in actions
    local velocityAsset = Instance.new("BodyVelocity")
    velocityAsset.Name = "BreakVelocity"
    velocityAsset.MaxForce = Vector3.new(100000, 100000, 100000)
    velocityAsset.Velocity = Vector3.new(0, 0, 0)
    Cache.velocityAsset = velocityAsset
end)

-- Ensure velocityAsset is always initialized
if not success or not Cache.velocityAsset then
    local velocityAsset = Instance.new("BodyVelocity")
    velocityAsset.Name = "BreakVelocity"
    velocityAsset.MaxForce = Vector3.new(100000, 100000, 100000)
    velocityAsset.Velocity = Vector3.new(0, 0, 0)
    Cache.velocityAsset = velocityAsset
end

-- Function to animate the character
local function PlayAnim(id, time, speed)
    pcall(function()
        local player = Services.Players.LocalPlayer
        if not player.Character or not player.Character:FindFirstChild("Humanoid") then
            return
        end
        
        player.Character.Animate.Disabled = false
        local hum = player.Character.Humanoid
        local animtrack = hum:GetPlayingAnimationTracks()
        for i, track in pairs(animtrack) do
            track:Stop()
        end
        player.Character.Animate.Disabled = true
        
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://"..id
        local loadanim = hum:LoadAnimation(Anim)
        loadanim:Play()
        if time then 
            loadanim.TimePosition = time
        end
        if speed then
            loadanim:AdjustSpeed(speed)
        end
        
        loadanim.Stopped:Connect(function()
            player.Character.Animate.Disabled = false
            for i, track in pairs(animtrack) do
                track:Stop()
            end
        end)
        
        State.CurrentAnimation = loadanim
    end)
end

-- Function to stop the current animation
local function StopAnim()
    pcall(function()
        local player = Services.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Animate.Disabled = false
            local animtrack = player.Character.Humanoid:GetPlayingAnimationTracks()
            for i, track in pairs(animtrack) do
                track:Stop()
            end
        end
        
        State.CurrentAnimation = nil
    end)
end

-- Function to get player ping
local function GetPing()
    local ping = 0
    pcall(function()
        ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return ping or 0.2
end

-- Function to get the Push tool
local function GetPush()
    local player = Services.Players.LocalPlayer
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool.Name == "Push" or tool.Name == "ModdedPush" then
            return tool
        end
    end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool.Name == "Push" or tool.Name == "ModdedPush" then
            return tool
        end
    end
    return nil
end

-- Function to get player by name/display
local function GetPlayer(UserDisplay)
    if UserDisplay and UserDisplay ~= "" then
        for i,v in pairs(Services.Players:GetPlayers()) do
            if v.Name:lower():match(UserDisplay:lower()) or v.DisplayName:lower():match(UserDisplay:lower()) then
                return v
            end
        end
    end
    return nil
end

-- Helper Target functions
local function GetCharacter(Player)
    return Player and Player.Character or nil
end

local function GetRoot(Player)
    local char = GetCharacter(Player)
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

local function TeleportTO(posX,posY,posZ,targetPlayer,method)
    pcall(function()
        local player = Services.Players.LocalPlayer
        local localRoot = GetRoot(player)
        if not localRoot then return end

        if method == "safe" then
            task.spawn(function()
                for i = 1,30 do
                    task.wait()
                    if localRoot then
                        localRoot.Velocity = Vector3.new(0,0,0)
                        if targetPlayer == "pos" then
                            localRoot.CFrame = CFrame.new(posX,posY,posZ)
                        else
                            local targetRoot = GetRoot(targetPlayer)
                            if targetRoot then
                                localRoot.CFrame = CFrame.new(targetRoot.Position) + Vector3.new(0,2,0)
                            end
                        end
                    end
                end
            end)
        else
            if localRoot then
                localRoot.Velocity = Vector3.new(0,0,0)
                if targetPlayer == "pos" then
                    localRoot.CFrame = CFrame.new(posX,posY,posZ)
                else
                    local targetRoot = GetRoot(targetPlayer)
                    if targetRoot then
                        localRoot.CFrame = CFrame.new(targetRoot.Position) + Vector3.new(0,2,0)
                    end
                end
            end
        end
    end)
end

local function PredictionTP(targetPlayer,method)
    pcall(function()
        local player = Services.Players.LocalPlayer
        local localRoot = GetRoot(player)
        local targetRoot = GetRoot(targetPlayer)
        if not localRoot or not targetRoot then return end

        local pos = targetRoot.Position
        local vel = targetRoot.Velocity
        local ping = GetPing()

        localRoot.CFrame = CFrame.new(
            (pos.X) + (vel.X) * (ping * 3.5),
            (pos.Y) + (vel.Y) * (ping * 2),
            (pos.Z) + (vel.Z) * (ping * 3.5)
        )

        if method == "safe" then
            task.wait()
            localRoot.CFrame = CFrame.new(pos)
            task.wait()
            localRoot.CFrame = CFrame.new(
                (pos.X) + (vel.X) * (ping * 3.5),
                (pos.Y) + (vel.Y) * (ping * 2),
                (pos.Z) + (vel.Z) * (ping * 3.5)
            )
        end
    end)
end

local function Push(Target)
    pcall(function()
        local Push = GetPush()
        if Push and Push:FindFirstChild("PushTool") then
            local args = {[1] = Target.Character}
            Push.PushTool:FireServer(unpack(args))
            Rayfield:Notify({
                Title = "Push",
                Content = "Pushing " .. Target.Name,
                Duration = 1
            })
        else
            -- Alternative if specific Push tool not found
            local targetRoot = GetRoot(Target)
            local player = Services.Players.LocalPlayer
            local localRoot = GetRoot(player)
            if targetRoot and localRoot then
                local direction = (targetRoot.Position - localRoot.Position).Unit
                local force = Instance.new("BodyVelocity")
                force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                force.Velocity = direction * 50
                force.Parent = targetRoot
                game:GetService("Debris"):AddItem(force, 0.2)
                Rayfield:Notify({
                    Title = "Push",
                    Content = "Pushing " .. Target.Name,
                    Duration = 1
                })
            end
        end
        
        -- Re-equip necessary tools
        local player = Services.Players.LocalPlayer
        for _, toolName in ipairs({"Push", "ModdedPush", "ClickTarget", "potion"}) do
            if player.Character:FindFirstChild(toolName) then
                local tool = player.Character:FindFirstChild(toolName)
                tool.Parent = player.Backpack
                tool.Parent = player.Character
            end
        end
    end)
end

-- Function to validate target is still valid
local function isTargetValid()
    return State.TargetedPlayer and State.TargetedPlayer.Parent and State.TargetedPlayer.Character and 
           State.TargetedPlayer.Character:FindFirstChild("Humanoid") and 
           State.TargetedPlayer.Character.Humanoid.Health > 0
end

-- Function moved to after helper functions to fix nil value error

--[[
    SCRIPTS TAB UI
]]

--[[
    SCRIPTS TAB FUNCTIONS
]]

-- Function to execute scripts safely
local function executeScript(scriptName, scriptUrl)
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl, true))()
    end)
    
    if success then
        Rayfield:Notify({
            Title = "📄 " .. scriptName,
            Content = "The " .. scriptName .. " script has been executed successfully!",
            Duration = 2
        })
    else
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Failed to execute " .. scriptName .. ": " .. tostring(err),
            Duration = 3
        })
    end
end

-- Function to execute scripts with custom URLs
local function executeCustomScript(scriptName, scriptUrl)
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    
    if success then
        Rayfield:Notify({
            Title = "📄 " .. scriptName,
            Content = "The " .. scriptName .. " script has been executed successfully!",
            Duration = 2
        })
    else
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Failed to execute " .. scriptName .. ": " .. tostring(err),
            Duration = 3
        })
    end
end

--[[
    SKINS TAB UI
]]

--[[
    SKINS TAB FUNCTIONS
]]

-- Function to unlock Christmas skins
local function unlockChristmasSkins()
    local skins = {"XM24Fr", "XM24Fr", "XM24Bear", "XM24Eag", "XM24Br", "XM24Cr", "XM24Sq"}
    
    for _, skin in pairs(skins) do
        pcall(function()
            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
            if Events and Events:FindFirstChild("SkinClickEvent") then
                Events.SkinClickEvent:FireServer(skin, "v2")
            end
        end)
        task.wait(0.1)
    end
    
    Rayfield:Notify({
        Title = "🎅🏻 Christmas Skins Unlocked",
        Content = "All Christmas skins have been successfully unlocked!",
        Duration = 3
    })
end

-- Function to unlock Pig skins
local function unlockPigSkins()
    local skins = {"PIG1", "PIG2", "PIG3", "PIG4", "PIG5", "PIG6", "PIG7", "PIG8"}
    
    for _, skin in pairs(skins) do
        pcall(function()
            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
            if Events and Events:FindFirstChild("SkinClickEvent") then
                Events.SkinClickEvent:FireServer(skin, "v2")
            end
        end)
        task.wait(0.1)
    end
    
    Rayfield:Notify({
        Title = "🐷 Pig Skins Unlocked",
        Content = "All Pig skins have been successfully unlocked!",
        Duration = 3
    })
end

-- Function to unlock secret weapons
local function unlockSecretWeapon(weaponCode)
    local args = {
        [1] = weaponCode
    }
    
    local success, err = pcall(function()
        local Events = Services.ReplicatedStorage:WaitForChild("Events", 10)
        if not Events then return end
        local WeaponEvent = Events:WaitForChild("WeaponEvent", 10)
        if not WeaponEvent then return end
        WeaponEvent:FireServer(unpack(args))
    end)
    
    if success then
        Rayfield:Notify({
            Title = "⚔️ Secret Weapon Unlocked",
            Content = "Secret sword skin has been successfully unlocked!",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "❌ Error",
            Content = "Failed to unlock weapon: " .. tostring(err),
            Duration = 3
        })
    end
end

-- Function to unlock Easter event skins
local function unlockEasterEventSkins()
    -- Easter event locations
    local localizacaoA = Vector3.new(-127.946053, 642.647949, 429.429596)
    local localizacaoB = Vector3.new(-137.940262, 642.648254, 434.050598)
    
    local function teleportToLocation(position)
        local player = Services.Players.LocalPlayer
        if not player or not player.Character then return end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        

        task.wait(2)
        

        humanoidRootPart.CFrame = CFrame.new(position)
        task.wait(0.1)
    end
    
    local function firePuzzleEvent(puzzleNumber)
        local easterEventFolder = Services.ReplicatedStorage:WaitForChild("Easter2025", 9e9)
        if not easterEventFolder then

            return
        end
        
        local remoteEvent = easterEventFolder:WaitForChild("RemoteEvent", 9e9)
        if not remoteEvent then

            return
        end
        
        local args = {
            [1] = {
                ["action"] = "pick_up",
                ["puzzle_name"] = "PUZ" .. tostring(puzzleNumber)
            }
        }
        

        remoteEvent:FireServer(unpack(args))
        task.wait(0.1)
    end
    

    -- Loop from 1 to 25
    for i = 1, 25 do

        -- 1. Teleport to Location A
        teleportToLocation(localizacaoA)
        
        -- 2. Fire Remote Event PUZi
        firePuzzleEvent(i)
        
        -- 3. Teleport to Location B
        teleportToLocation(localizacaoB)
        
        -- 4. Teleport back to Location A
        teleportToLocation(localizacaoA)
        

    end
    

end

--[[
    NPC TAB UI
]]

-- NPC Auto-kill system variables
State.killNPCToggle = false
local killNPCHealthThreads = {}
    State.killNPCMonitorThread = nil

-- Function to check if a character is an NPC
local function isNPC(char)
    local player = Services.Players.LocalPlayer
    return char and char:FindFirstChildOfClass("Humanoid") and char.Name ~= player.Name and char:IsDescendantOf(workspace.NPC)
end

-- Function to arm an NPC for auto-kill
local function armNPC(npc)
    if killNPCHealthThreads[npc] then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local lastHealth = hum.Health
    killNPCHealthThreads[npc] = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health < lastHealth then
            task.wait(0.05)
            hum.Health = 0
            if npc:FindFirstChild("HumanoidRootPart") then
                npc.HumanoidRootPart:BreakJoints()
            end
            Rayfield:Notify({
                Title = "NPC", 
                Content = "Auto-killed NPC '"..npc.Name.."' after you damaged it!", 
                Duration = 2
            })
        end
        lastHealth = hum.Health
    end)
end

-- Function to disarm all NPCs
local function disarmAll()
    if Cache.killNPCHealthThreads and type(Cache.killNPCHealthThreads) == "table" then
        for npc, conn in pairs(Cache.killNPCHealthThreads) do
        if conn then conn:Disconnect() end
    end
        Cache.killNPCHealthThreads = {}
    end
end

-- Function to start NPC auto-kill monitoring
local function startNPCMonitoring()
    local player = Services.Players.LocalPlayer
    local radius = 15
    
    State.killNPCMonitorThread = task.spawn(function()
        while State.killNPCToggle do
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, npc in ipairs(workspace.NPC:GetChildren()) do
                    if isNPC(npc) and not Cache.killNPCHealthThreads[npc] then
                        local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                        if npcHRP and (npcHRP.Position - myHRP.Position).Magnitude <= radius then
                            armNPC(npc)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Function to stop NPC auto-kill monitoring
local function stopNPCMonitoring()
                if State.killNPCMonitorThread then
                State.killNPCMonitorThread = nil
    end
    disarmAll()
end

-- Enhanced Admin Alerts System
-- Function to handle player added for admin alerts
local function enhancedPlayerAdded(player)
    if not Config.Admin.AlertsEnabled then return end
    
    local isAdmin, isModerator = checkAdminStatus(player)
    
    if isAdmin or isModerator then
        local role = isAdmin and "Administrator" or "Moderator"
        
        Rayfield:Notify({
            Title = "⚠️ Staff Join Alert",
            Content = player.Name .. " (" .. role .. ") has joined the game",
            Duration = 3
        })
    end
end

-- Staff Join Alerts Toggle
MiscTab:CreateToggle({
    Name = "⚠️ Staff Join Alerts",
    CurrentValue = true,
    Callback = function(state)
        Config.Admin.AlertsEnabled = state
        Rayfield:Notify({
            Title = "Staff Alerts",
            Content = state and "Staff join alerts enabled" or "Staff join alerts disabled",
            Duration = 1
        })
    end
})

-- Connect player added event for admin alerts
    Services.Players.PlayerAdded:Connect(enhancedPlayerAdded)

-- Enhanced Spectate System
-- Function to get players for spectate (using consolidated getPlayers function)
local function getSpectatePlayers()
    return getPlayers()
end

-- Spectate Player Dropdown
local SpectateDropdown = MiscTab:CreateDropdown({
    Name = "🧿 Spectate Player",
    Options = getSpectatePlayers(),
    CurrentOption = "Ninguém",
    Flag = "SpectatePlayer",
    Callback = function(selected)
        -- Ensure selected is a string and handle potential table values
        local selectedPlayer = ""
        if type(selected) == "string" then
            selectedPlayer = selected
        elseif type(selected) == "table" then
            selectedPlayer = selected[1] or "Ninguém"
        else
            selectedPlayer = tostring(selected) or "Ninguém"
        end
        
        Config.Spectate.SelectedPlayer = selectedPlayer
        if selectedPlayer ~= "Ninguém" then
            Rayfield:Notify({
                Title = "Player Selected",
                Content = "Ready to spectate: " .. selectedPlayer,
                Duration = 2
            })
        end
    end
})

-- Enhanced spectate functions
local function enhancedStartSpectating()
            if not Config.Spectate.SelectedPlayer or Config.Spectate.SelectedPlayer == "Ninguém" then
        Rayfield:Notify({
            Title = "Error",
            Content = "No player selected to spectate!",
            Duration = 3
        })
        return
    end

            local target = Services.Players:FindFirstChild(Config.Spectate.SelectedPlayer)
    if target and target.Character then
        local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
                    Config.Spectate.IsSpectating = true
        Config.Spectate.Camera.CameraSubject = humanoidRootPart
            
            Rayfield:Notify({
                Title = "🧿 Spectating",
                Content = "Now spectating " .. target.Name,
                Duration = 3
            })

            -- Handle character respawns
            target.CharacterAdded:Connect(function(character)
                if Config.Spectate.IsSpectating then
                    character:WaitForChild("HumanoidRootPart")
                    Config.Spectate.Camera.CameraSubject = character.HumanoidRootPart
                end
            end)
        end
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Player not found or invalid target!",
            Duration = 3
        })
    end
end

local function enhancedStopSpectating()
    Config.Spectate.IsSpectating = false
    local character = Services.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Config.Spectate.Camera.CameraSubject = humanoid
        end
    end
    
    Rayfield:Notify({
        Title = "🧿 Spectating Stopped",
        Content = "No longer spectating",
        Duration = 3
    })
    
    if SpectateDropdown then
        SpectateDropdown:Refresh(getSpectatePlayers(), true)
        SpectateDropdown:Set("Ninguém")
        Config.Spectate.SelectedPlayer = "Ninguém"
    end
end

-- Auto-refresh spectate list
task.spawn(function()
    while task.wait(5) do
        if SpectateDropdown then
            local players = getSpectatePlayers()
            SpectateDropdown:Refresh(players)
        end
    end
end)

-- Spectate Control Buttons
MiscTab:CreateButton({
    Name = "▶️ Start Spectating",
    Callback = enhancedStartSpectating
})

MiscTab:CreateButton({
    Name = "⏹️ Stop Spectating",
    Callback = enhancedStopSpectating
})

MiscTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        if SpectateDropdown then
            local players = getSpectatePlayers()
            SpectateDropdown:Refresh(players)
        end
        Rayfield:Notify({
            Title = "Player List Updated",
            Content = "Spectate dropdown has been refreshed!",
            Duration = 2
        })
    end
})

-- Unban Voice Chat Button
MiscTab:CreateButton({
    Name = "🗣️ Unban Voice Chat",
    Callback = function()
        local success, err = pcall(function()
            Services.VoiceChatService:JoinVoiceChat()
        end)
        
        if success then
            Rayfield:Notify({
                Title = "🗣️ Voice Chat Unbanned",
                Content = "Your voice chat has been unbanned!",
                Duration = 1
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to unban voice chat: " .. tostring(err),
                Duration = 1
            })
        end
    end
})

-- Fling Button
MiscTab:CreateButton({
    Name = "☠️ Fling",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/nick0022/walkflinng/refs/heads/main/README.md", true))()
        end)
        
        if success then
            Rayfield:Notify({
                Title = "☠️ Fling Activated",
                Content = "The fling script has been executed successfully!",
                Duration = 1
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Failed to load fling script: " .. tostring(err),
                Duration = 1
            })
        end
    end
})

-- Void Player Button
MiscTab:CreateButton({
    Name = "🕳️ Void Player",
    Callback = function()
        local player = Services.Players.LocalPlayer
        local character = player.Character
        
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({
                Title = "Error",
                Content = "Character not found or invalid!",
                Duration = 1
            })
            return
        end

        local originalPosition = character.HumanoidRootPart.Position
        local voidPosition = originalPosition - Vector3.new(0, 500, 0)

        Rayfield:Notify({
            Title = "🕳️ Void Player",
            Content = "Preparing void teleport...",
            Duration = 1
        })

        character.HumanoidRootPart.CFrame = CFrame.new(voidPosition)

        Rayfield:Notify({
            Title = "🕳️ Void Player",
            Content = "Player sent to void! Releasing in 3 seconds...",
            Duration = 3
        })

        task.wait(3)
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
            Rayfield:Notify({
                Title = "🕳️ Void Player",
                Content = "Player returned from void!",
                Duration = 1
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Character became invalid during process!",
                Duration = 1
            })
        end
    end
})

--[[
    TARGET TAB UI
]]
-- Target Status Section
TargetTab:CreateSection("Target Status")

-- Target Status Display
local targetFeedback = TargetTab:CreateLabel("No target selected")
UI.TargetFeedbackLabel = targetFeedback

-- Player Information Display
local targetInfo = TargetTab:CreateLabel("Select a target to view information")
UI.TargetInfoLabel = targetInfo

-- Target Statistics Display
local targetStats = TargetTab:CreateLabel("No target selected")
UI.TargetStatsLabel = targetStats

-- Target Location Display
local targetLocation = TargetTab:CreateLabel("No target selected")
UI.TargetLocationLabel = targetLocation

-- Target Actions Display
local targetActions = TargetTab:CreateLabel("No target selected")
UI.TargetActionsLabel = targetActions

-- Function to update target feedback (Rayfield compatible)
local function updateTargetFeedback(text)
    if targetFeedback then
        targetFeedback:Set(text)
    end
end

-- Function to update target info (Rayfield compatible)
local function updateTargetInfo(text)
    if targetInfo then
        targetInfo:Set(text)
    end
end

-- Function to update target statistics (Rayfield compatible)
local function updateTargetStats(text)
    if targetStats then
        targetStats:Set(text)
    end
end

-- Function to update target location (Rayfield compatible)
local function updateTargetLocation(text)
    if targetLocation then
        targetLocation:Set(text)
    end
end

-- Function to update target actions (Rayfield compatible)
local function updateTargetActions(text)
    if targetActions then
        targetActions:Set(text)
    end
end

-- Function to update location display in real-time
local function updateLocationDisplay()
    if State.TargetedPlayer and State.TargetedPlayer.Character then
        local rootPart = State.TargetedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local playerRoot = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = math.floor((rootPart.Position - playerRoot.Position).Magnitude)
                updateTargetLocation("Distance: " .. distance .. " studs")
            end
        end
    end
end

-- Start real-time location updates when target is selected
local locationUpdateThread = nil
local function startLocationUpdates()
    if locationUpdateThread then
        task.cancel(locationUpdateThread)
    end
    
    locationUpdateThread = task.spawn(function()
        while State.TargetedPlayer and State.TargetedPlayer.Parent do
            updateLocationDisplay()
            task.wait(1) -- Update every second
        end
    end)
end

local function stopLocationUpdates()
    if locationUpdateThread then
        task.cancel(locationUpdateThread)
        locationUpdateThread = nil
    end
end

-- Function to create target selection tool
local function CreateTargetTool()
    local player = Services.Players.LocalPlayer
    -- Remove old tool if exists
    if player.Backpack:FindFirstChild("ClickTarget") then
        player.Backpack:FindFirstChild("ClickTarget"):Destroy()
    end
    if player.Character and player.Character:FindFirstChild("ClickTarget") then
        player.Character:FindFirstChild("ClickTarget"):Destroy()
    end

    local GetTargetTool = Instance.new("Tool")
    GetTargetTool.Name = "ClickTarget"
    GetTargetTool.RequiresHandle = false
    GetTargetTool.TextureId = "rbxassetid://6043845934"
    GetTargetTool.ToolTip = "Select Target"
    GetTargetTool.CanBeDropped = false

    GetTargetTool.Activated:Connect(function()
        local mouse = player:GetMouse()
        local hit = mouse.Target
        local person = nil
        
        if hit and hit.Parent then
            if hit.Parent:IsA("Model") then
                person = Services.Players:GetPlayerFromCharacter(hit.Parent)
            elseif hit.Parent:IsA("Accessory") and hit.Parent.Parent then
                person = Services.Players:GetPlayerFromCharacter(hit.Parent.Parent)
            end
            
            if person and person ~= player then
                Rayfield:Notify({
                    Title = "Target Selected",
                    Content = "Current target: " .. person.Name,
                    Duration = 2
                })
                
                -- Update State.TargetedPlayer variable directly
                State.TargetedPlayer = person
                
                -- Update feedback
                updateTargetFeedback("Target: " .. person.Name)
                
                -- Update player information display
                updateTargetInfo(person.Name)
                
                -- Update target statistics display
                if person.Character then
                    local humanoid = person.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        updateTargetStats("Health: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth))
                    else
                        updateTargetStats("No character")
                    end
                else
                    updateTargetStats("No character")
                end
                
                -- Update target location display
                if person.Character then
                    local rootPart = person.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local playerRoot = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if playerRoot then
                            local distance = math.floor((rootPart.Position - playerRoot.Position).Magnitude)
                            updateTargetLocation("Distance: " .. distance .. " studs")
                        else
                            updateTargetLocation("No player root")
                        end
                    else
                        updateTargetLocation("No target root")
                    end
                else
                    updateTargetLocation("No character")
                end
                
                -- Update target actions display
                updateTargetActions("Selected at " .. os.date("%H:%M:%S"))
                
                -- Start real-time location updates
                startLocationUpdates()
                
                -- Update global state
                State.TargetedUserId = person.UserId
            elseif person == player then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "You cannot select yourself.",
                    Duration = 2
                })
            else
                -- Stop location updates
                stopLocationUpdates()
                
                -- Clear target
                State.TargetedPlayer = nil
                State.TargetedUserId = nil
                
                updateTargetFeedback("No target selected")
                updateTargetInfo("Select a target to view information")
                updateTargetStats("No target selected")
                updateTargetLocation("No target selected")
                updateTargetActions("No target selected")
                
                Rayfield:Notify({
                    Title = "Target Removed",
                    Content = "No player selected.",
                    Duration = 2
                })
            end
        end
    end)
    
    GetTargetTool.Parent = player.Backpack
    GetTargetTool.Parent = player.Character -- Auto-equip the tool
    
    Rayfield:Notify({
        Title = "Tool Created",
        Content = "Use the tool to select a target by clicking on it.",
        Duration = 3
    })
end

-- Grab Selection Tool Button
TargetTab:CreateButton({
    Name = "🎯 Grab Selection Tool",
    Callback = function()
        CreateTargetTool()
    end
})

-- Target Actions Section
TargetTab:CreateSection("Target Actions")

-- View Target Toggle
TargetTab:CreateToggle({
    Name = "👁️ View Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            local target = State.TargetedPlayer -- Local reference to avoid nil warnings
            local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                workspace.CurrentCamera.CameraSubject = humanoid
                
                Rayfield:Notify({
                    Title = "Camera",
                    Content = "Viewing " .. target.Name,
                    Duration = 2
                })
                
                updateTargetFeedback("👁️ **VIEWING:** " .. target.Name .. " | 📹 **CAMERA ACTIVE**")
                
                -- Create loop to maintain view
                    State.ViewLoop = task.spawn(function()
        while State.ViewingTarget and target and task.wait(0.5) do
                        pcall(function()
                            if target.Character and target.Character:FindFirstChild("Humanoid") then
                                workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
                            end
                        end)
                    end
                end)
                
                State.ViewingTarget = true
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Could not find target character.",
                    Duration = 2
                })
            end
        else
                    State.ViewingTarget = false
        
        if State.ViewLoop then
            task.cancel(State.ViewLoop)
            State.ViewLoop = nil
            end
            
            pcall(function()
                local player = Services.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                end
            end)
            
            Rayfield:Notify({
                Title = "Camera",
                Content = "Returning to normal view.",
                Duration = 2
            })
            
            updateTargetFeedback("🎯 **TARGET:** " .. State.TargetedPlayer.Name .. " | ✅ **READY**")
        end
    end
})

-- Focus on Target Toggle
TargetTab:CreateToggle({
    Name = "🎯 Focus on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            local target = State.TargetedPlayer -- Local reference to avoid nil warnings
            Rayfield:Notify({
                Title = "Focus",
                Content = "Following " .. target.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🎯 **FOCUSING:** " .. target.Name .. " | 🔄 **FOLLOWING**")
            
            -- Create loop to follow target
                State.FocusLoop = task.spawn(function()
        State.FocusingTarget = true
        while State.FocusingTarget and target and task.wait(0.2) do
                    pcall(function()
                        TeleportTO(0, 0, 0, target)
                    end)
                end
            end)
        else
                    State.FocusingTarget = false
        
        if State.FocusLoop then
            task.cancel(State.FocusLoop)
            State.FocusLoop = nil
            end
            
            Rayfield:Notify({
                Title = "Focus",
                Content = "Stopped following the target.",
                Duration = 2
            })
            
            updateTargetFeedback("🎯 **TARGET:** " .. State.TargetedPlayer.Name .. " | ✅ **READY**")
        end
    end
})

-- Teleport to Target Button
TargetTab:CreateButton({
    Name = "🚀 Teleport to Target",
    Callback = function()
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        local target = State.TargetedPlayer -- Local reference to avoid nil warnings
        TeleportTO(0, 0, 0, target)
        
        Rayfield:Notify({
            Title = "Teleport",
            Content = "Teleported to " .. target.Name,
            Duration = 2
        })
    end
})

-- Prediction Teleport Button
TargetTab:CreateButton({
    Name = "🎯 Prediction Teleport",
    Callback = function()
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        local target = State.TargetedPlayer -- Local reference to avoid nil warnings
        PredictionTP(target)
        
        Rayfield:Notify({
            Title = "Prediction Teleport",
            Content = "Prediction teleport to " .. target.Name,
            Duration = 2
        })
    end
})

-- Clear Target Button
TargetTab:CreateButton({
    Name = "❌ Clear Target",
    Callback = function()
        -- Stop location updates
        stopLocationUpdates()
        
        State.TargetedPlayer = nil
        State.TargetedUserId = nil
        
        updateTargetFeedback("No target selected")
        updateTargetInfo("Select a target to view information")
        updateTargetStats("No target selected")
        updateTargetLocation("No target selected")
        updateTargetActions("No target selected")
        
        Rayfield:Notify({
            Title = "Target Cleared",
            Content = "Target has been cleared.",
            Duration = 2
        })
    end
})

-- Additional Target Features Section
TargetTab:CreateSection("Additional Target Features")

-- Beng on Target Toggle
TargetTab:CreateToggle({
    Name = "Beng on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            local target = State.TargetedPlayer -- Local reference to avoid nil warnings
            -- Start animation
            PlayAnim(5918726674, 0, 1)
            
            Rayfield:Notify({
                Title = "Beng on Target",
                Content = "Beng animation activated on " .. target.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🍑 **BENG:** " .. target.Name .. " | 🔥 **ACTIVE**")
            
            -- Create loop to maintain Beng position
                State.BengLoop = task.spawn(function()
        State.BenggingTarget = true
        while State.BenggingTarget and target and task.wait(0.1) do
                    pcall(function()
                        local targetRoot = GetRoot(target)
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if targetRoot and localRoot then
                            -- Position player in "Beng" stance relative to target
                            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.1)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                StopAnim()
                pcall(function()
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.BenggingTarget = false
        
        if State.BengLoop then
            task.cancel(State.BengLoop)
            State.BengLoop = nil
            end
            
            -- Stop animation
            StopAnim()
            pcall(function()
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Beng on Target",
                Content = "Beng animation stopped.",
                Duration = 2
            })
            
            updateTargetFeedback("🎯 **TARGET:** " .. State.TargetedPlayer.Name .. " | ✅ **READY**")
        end
    end
})

-- Headsit on Target Toggle
TargetTab:CreateToggle({
    Name = "Headsit on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            Rayfield:Notify({
                Title = "Headsit on Target",
                Content = "Headsit activated on " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🪑 **HEADSIT:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Create loop to maintain headsit position
                State.HeadsitLoop = task.spawn(function()
        State.HeadsittingTarget = true
        while State.HeadsittingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetRoot = GetRoot(State.TargetedPlayer)
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if targetRoot and localRoot and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.Sit = true
                            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 0)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                pcall(function()
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.HeadsittingTarget = false
        
        if State.HeadsitLoop then
            task.cancel(State.HeadsitLoop)
            State.HeadsitLoop = nil
            end
            
            pcall(function()
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Headsit on Target",
                Content = "Headsit stopped.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

-- Stand Next to Target Toggle
TargetTab:CreateToggle({
    Name = "Stand Next to Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            -- Start stand animation
            PlayAnim(13823324057, 4, 0)
            
            Rayfield:Notify({
                Title = "Stand Next to Target",
                Content = "Standing next to " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🚶 **STAND:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Create loop to maintain stand position
                State.StandLoop = task.spawn(function()
        State.StandingTarget = true
        while State.StandingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetRoot = GetRoot(State.TargetedPlayer)
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if targetRoot and localRoot then
                            -- Position player standing next to target
                            localRoot.CFrame = targetRoot.CFrame * CFrame.new(-3, 1, 0)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                StopAnim()
                pcall(function()
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.StandingTarget = false
        
        if State.StandLoop then
            task.cancel(State.StandLoop)
            State.StandLoop = nil
            end
            
            -- Stop animation
            StopAnim()
            pcall(function()
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Stand Next to Target",
                Content = "Stopped standing next to target.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

-- Backpack on Target Toggle
TargetTab:CreateToggle({
    Name = "Backpack on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            Rayfield:Notify({
                Title = "Backpack on Target",
                Content = "Backpack position on " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🎒 **BACKPACK:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Create loop to maintain backpack position
                State.BackpackLoop = task.spawn(function()
        State.BackpackingTarget = true
        while State.BackpackingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetRoot = GetRoot(State.TargetedPlayer)
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        local TempV
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if targetRoot and localRoot and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.Sit = true
                            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, math.rad(-3), 0)
                            if TempV then
                                TempV.Parent = localRoot
                            end
                        end
                    end)
                end
                
                -- Clean up when finished
                pcall(function()
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.BackpackingTarget = false
        
        if State.BackpackLoop then
            task.cancel(State.BackpackLoop)
            State.BackpackLoop = nil
            end
            
            pcall(function()
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Backpack on Target",
                Content = "Stopped backpack position on target.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

-- Doggy on Target Toggle
TargetTab:CreateToggle({
    Name = "Doggy on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            -- Start doggy animation
            PlayAnim(13694096724, 3.4, 0)
            
            Rayfield:Notify({
                Title = "Doggy on Target",
                Content = "Doggy position on " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🐕 **DOGGY:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Create loop to maintain doggy position
                State.DoggyLoop = task.spawn(function()
        State.DoggyingTarget = true
        while State.DoggyingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetRoot = GetRoot(State.TargetedPlayer)
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if targetRoot and localRoot then
                            -- Position player in doggy position relative to target
                            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0.23, 0)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                StopAnim()
                pcall(function()
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.DoggyingTarget = false
        
        if State.DoggyLoop then
            task.cancel(State.DoggyLoop)
            State.DoggyLoop = nil
            end
            
            -- Stop animation
            StopAnim()
            pcall(function()
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Doggy on Target",
                Content = "Stopped doggy position on target.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

-- Suck on Target Toggle
TargetTab:CreateToggle({
    Name = "Suck on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            -- Use idle animation to keep character straight
            pcall(function()
                if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    -- Idle/stand animation
                    PlayAnim(507766666, 0, 0)
                    
                    -- Ensure character doesn't lean
                    if Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Suck on Target",
                Content = "Suck position on " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("💋 **SUCK:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Variables for movement
            local moveDirection = 1
            local moveTimer = 0
            
            -- Create loop to maintain suck position
                State.SuckLoop = task.spawn(function()
        State.SuckingTarget = true
        while State.SuckingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetHead = State.TargetedPlayer.Character and State.TargetedPlayer.Character:FindFirstChild("Head")
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if not targetHead then
                            targetHead = GetRoot(State.TargetedPlayer)
                        end
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if localRoot and targetHead then
                            -- Calculate movement offset
                            moveTimer = moveTimer + 0.1
                            if moveTimer > 1 then
                                moveDirection = -moveDirection
                                moveTimer = 0
                            end
                            
                            local offset = 0.3 * moveDirection
                            
                            -- Position player in front of target's face with movement
                            localRoot.CFrame = targetHead.CFrame * CFrame.new(0, 0.7, -(1.5 + offset)) * CFrame.Angles(0, math.rad(180), 0)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                StopAnim()
                pcall(function()
                    if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                    end
                    
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.SuckingTarget = false
        
        if State.SuckLoop then
            task.cancel(State.SuckLoop)
            State.SuckLoop = nil
            end
            
            -- Stop animation and restore normal character state
            StopAnim()
            pcall(function()
                if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                end
                
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Suck on Target",
                Content = "Stopped suck position on target.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

-- Drag on Target Toggle
TargetTab:CreateToggle({
    Name = "Drag on Target",
    CurrentValue = false,
    Callback = function(state)
        if not isTargetValid() then
            Rayfield:Notify({
                Title = "Error",
                Content = "No valid target selected.",
                Duration = 2
            })
            return
        end
        
        if state then
            -- Use drag animation
            pcall(function()
                if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    -- Drag animation (extended hand)
                    PlayAnim(10714360343, 0.5, 0)
                    
                    -- Ensure character doesn't lean
                    if Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Drag on Target",
                Content = "Drag position on " .. State.TargetedPlayer.Name,
                Duration = 2
            })
            
            updateTargetFeedback("🖐️ **DRAG:** " .. State.TargetedPlayer.Name .. " | 🎯 **ACTIVE**")
            
            -- Create loop to maintain drag position
                State.DragLoop = task.spawn(function()
        State.DraggingTarget = true
        while State.DraggingTarget and State.TargetedPlayer and task.wait(0.1) do
                    pcall(function()
                        local targetRightHand = State.TargetedPlayer.Character and State.TargetedPlayer.Character:FindFirstChild("RightHand")
                        local player = Services.Players.LocalPlayer
                        local localRoot = GetRoot(player)
                        
                        if not targetRightHand then
                            targetRightHand = GetRoot(State.TargetedPlayer)
                        end
                        
                        if localRoot and not localRoot:FindFirstChild("BreakVelocity") then
                            local TempV = Cache.velocityAsset:Clone()
                            TempV.Parent = localRoot
                        end
                        
                        if localRoot and targetRightHand then
                            -- Position player in drag position
                            localRoot.CFrame = targetRightHand.CFrame * CFrame.new(0, -2.5, 1) * CFrame.Angles(math.rad(-2), math.rad(-3), 0)
                            localRoot.Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
                
                -- Clean up when finished
                StopAnim()
                pcall(function()
                    if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                    end
                    
                    if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                        GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                    end
                end)
            end)
        else
                    State.DraggingTarget = false
        
        if State.DragLoop then
            task.cancel(State.DragLoop)
            State.DragLoop = nil
            end
            
            -- Stop animation and restore normal character state
            StopAnim()
            pcall(function()
                if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Services.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                end
                
                if GetRoot(Services.Players.LocalPlayer):FindFirstChild("BreakVelocity") then
                    GetRoot(Services.Players.LocalPlayer).BreakVelocity:Destroy()
                end
            end)
            
            Rayfield:Notify({
                Title = "Drag on Target",
                Content = "Stopped drag position on target.",
                Duration = 2
            })
            
            if State.TargetedPlayer then
                updateTargetFeedback("Target: " .. State.TargetedPlayer.Name)
            else
                updateTargetFeedback("Target: None")
            end
        end
    end
})

--[[
    SCRIPTS TAB UI
]]
-- Infinity Yield Button
ScriptsTab:CreateButton({
    Name = "📄 Infinity Yield",
    Callback = function()
        executeScript("Infinity Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end
})

-- Moon AntiAfk Button
ScriptsTab:CreateButton({
    Name = "📄 Moon AntiAfk",
    Callback = function()
        executeScript("Moon AntiAfk", "https://raw.githubusercontent.com/rodri0022/afkmoon/refs/heads/main/README.md")
    end
})

-- Moon AntiLag Button
ScriptsTab:CreateButton({
    Name = "📄 Moon AntiLag",
    Callback = function()
        executeScript("Moon AntiLag", "https://raw.githubusercontent.com/nick0022/antilag/refs/heads/main/README.md")
    end
})

-- FE R15 Emotes and Animation Button
ScriptsTab:CreateButton({
    Name = "📄 FE R15 Emotes and Animation",
    Callback = function()
        executeScript("FE R15 Emotes and Animation", "https://raw.githubusercontent.com/BeemTZy/Motiona/refs/heads/main/source.lua")
    end
})

-- Moon FE Emotes Button
ScriptsTab:CreateButton({
    Name = "📄 Moon FE Emotes",
    Callback = function()
        executeScript("Moon FE Emotes", "https://raw.githubusercontent.com/rodri0022/freeanimmoon/refs/heads/main/README.md")
    end
})

-- Moon Troll Button
ScriptsTab:CreateButton({
    Name = "📄 Moon Troll",
    Callback = function()
        executeScript("Moon Troll", "https://raw.githubusercontent.com/nick0022/trollscript/refs/heads/main/README.md")
    end
})

-- Sirius Button
ScriptsTab:CreateButton({
    Name = "📄 Sirius",
    Callback = function()
        executeScript("Sirius", "https://sirius.menu/sirius")
    end
})

-- Keyboard Button
ScriptsTab:CreateButton({
    Name = "📄 Keyboard",
    Callback = function()
        executeScript("Keyboard", "https://raw.githubusercontent.com/GGH52lan/GGH52lan/main/keyboard.txt")
    end
})

-- Shader Button
ScriptsTab:CreateButton({
    Name = "📄 Shader",
    Callback = function()
        executeScript("Shader", "https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua")
    end
})

--[[
    SKINS TAB UI
]]
-- Christmas Skins Button
SkinsTab:CreateButton({
    Name = "🎅🏻 Christmas Skins",
    Callback = function()
        unlockChristmasSkins()
    end
})

-- Pig Skins Button
SkinsTab:CreateButton({
    Name = "🐷 Pig Skins",
    Callback = function()
        unlockPigSkins()
    end
})

-- Secret Weapon Buttons
SkinsTab:CreateButton({
    Name = "⚔️ Secret Weapon",
    Callback = function()
        unlockSecretWeapon("SSSSSSS2")
    end
})

SkinsTab:CreateButton({
    Name = "⚔️ Secret Weapon2",
    Callback = function()
        unlockSecretWeapon("SSSSSSS4")
    end
})

SkinsTab:CreateButton({
    Name = "⚔️ Secret Weapon3",
    Callback = function()
        unlockSecretWeapon("SSSS2")
    end
})

SkinsTab:CreateButton({
    Name = "⚔️ Secret Weapon4",
    Callback = function()
        unlockSecretWeapon("SSSS1")
    end
})

-- Easter Event Skins Button
SkinsTab:CreateButton({
    Name = "🥚 Easter Event Skins",
    Callback = function()
        unlockEasterEventSkins()
    end
})

--[[
    NPC TAB UI
]]
-- 🎯 NPC Control Section
NPCTab:CreateSection("🎯 NPC Control")

-- Auto Kill Nearby NPCs After Damage toggle (from original animal2.txt)
NPCTab:CreateToggle({
    Name = "Auto Kill Nearby NPCs After Damage",
    CurrentValue = false,
    Callback = function(state)
        State.killNPCToggle = state
        local player = Services.Players.LocalPlayer
        local radius = 15
        
        local function isNPC(char)
            return char and char:FindFirstChildOfClass("Humanoid") and char.Name ~= player.Name and char:IsDescendantOf(workspace.NPC)
        end
        
        local function armNPC(npc)
            if Cache.killNPCHealthThreads[npc] then return end
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local lastHealth = hum.Health
            Cache.killNPCHealthThreads[npc] = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health < lastHealth then
                    task.wait(0.05)
                    hum.Health = 0
                    if npc:FindFirstChild("HumanoidRootPart") then
                        npc.HumanoidRootPart:BreakJoints()
                    end
                    Rayfield:Notify({
                        Title = "NPC", 
                        Content = "Auto-killed NPC '"..npc.Name.."' after you damaged it!", 
                        Duration = 2
                    })
                end
                lastHealth = hum.Health
            end)
        end
        
        local function disarmAll()
            for npc, conn in pairs(Cache.killNPCHealthThreads) do
                if conn then conn:Disconnect() end
            end
            Cache.killNPCHealthThreads = {}
        end
        
        if State.killNPCToggle then
            Rayfield:Notify({
                Title = "NPC", 
                Content = "Auto-kill armed: Will kill any nearby NPCs after you damage them!", 
                Duration = 3
            })
            State.killNPCMonitorThread = task.spawn(function()
                while State.killNPCToggle do
                    local myChar = player.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        for _, npc in ipairs(workspace.NPC:GetChildren()) do
                            if isNPC(npc) and not Cache.killNPCHealthThreads[npc] then
                                local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                                if npcHRP and (npcHRP.Position - myHRP.Position).Magnitude <= radius then
                                    armNPC(npc)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            disarmAll()
            if State.killNPCMonitorThread then State.killNPCMonitorThread = nil end
            Rayfield:Notify({
                Title = "NPC", 
                Content = "Auto-kill stopped.", 
                Duration = 2
            })
        end
    end
})

-- NPC Control Section
NPCTab:CreateSection("🎮 NPC Control")

-- NPC Control Toggle
NPCTab:CreateToggle({
    Name = "🎮 NPC Control System",
    CurrentValue = false,
    Callback = function(state)
        if state then
            Rayfield:Notify({
                Title = "NPC Control", 
                Content = "NPC Control system activated! Use the controls below.", 
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "NPC Control", 
                Content = "NPC Control system disabled.", 
                Duration = 2
            })
        end
    end
})

-- NPC Fling Toggle
NPCTab:CreateToggle({
    Name = "🚀 NPC Fling",
    CurrentValue = false,
    Callback = function(state)
        if state then
            Rayfield:Notify({
                Title = "NPC Fling", 
                Content = "NPC Fling activated! NPCs will fling players.", 
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "NPC Fling", 
                Content = "NPC Fling disabled.", 
                Duration = 2
            })
        end
    end
})

-- NPC Walk Fling Toggle
NPCTab:CreateToggle({
    Name = "🚶 NPC Walk Fling",
    CurrentValue = false,
    Callback = function(state)
        if state then
            Rayfield:Notify({
                Title = "NPC Walk Fling", 
                Content = "NPC Walk Fling activated! NPCs will walk and fling players.", 
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "NPC Walk Fling", 
                Content = "NPC Walk Fling disabled.", 
                Duration = 2
            })
        end
    end
})

--[[
    ANIMAL CONFIGURATION
]]
-- Animal configuration map for Premium features
Config.AnimalMap = {
    Axolotl = {id = "axolotl", anim = "axolotl_Anim"},
    BTrex = {id = "babydino", anim = "btrexAnim"},
    BabyCat = {id = "babycats", anim = "babycatAnim"},
    BabyElephant = {
        id = "baby_elephant", anim = "babyelephantAnim", gamepassPassId = 89053083,
        skinIdOverrides = {
            elephant1 = "elephant1", elephant2 = "elephant2", elephant3 = "elephant3",
            elephant4 = "elephant4", elephant5 = "elephant5", elephant6 = "elephant6",
            elephant7 = "elephant7", elephant8 = "elephant8", elephant9 = "elephant9",
            elephant10 = "elephant10", elephant11 = "elephant11", elephant12 = "elephant12",
            elephant13 = "elephant13", elephant14 = "elephant14", elephant15 = "elephant15",
            elephant16 = "elephant16", elephant17 = "elephant17", elephant18 = "elephant18",
            elephant19 = "elephant19", elephant20 = "elephant20", elephant21 = "elephant21",
            elephant22 = "elephant22", elephant23 = "elephant23", elephant24 = "gamepass24",
            elephant27 = "gamepass27", elephant28 = "gamepass28", elephant29 = "gamepass29",
            elephant30 = "gamepass30", elephant31 = "gamepass31"
        },
        animOverrides = {
            elephant24 = "babytankelephantAnim", elephant27 = "babytankelephantAnim",
            elephant28 = "babytankelephantAnim", elephant29 = "babytankelephantAnim",
            elephant30 = "babytankelephantAnim", elephant31 = "babytankelephantAnim"
        }
    },
    BabyKangaroo = {id = "baby_kangaroos", anim = "baby_kangarooAnim"},
    BabyLionRework = {
        id = "babylion_rework", anim = "babylionR_Anim", gamepassPassId = 121800750,
        skinIdOverrides = {
            lion1 = "babylion1", lion2 = "babylion2", lion3 = "babylion3", lion4 = "babylion4",
            lion5 = "babylion5", lion6 = "babylion6", lion7 = "babylion7", lion8 = "babylion8",
            lion9 = "babylion9", lion10 = "babylion10", lion11 = "babylion11", lion12 = "babylion12",
            lion13 = "babylion13", lion14 = "babylion14", lion15 = "babylion15", lion16 = "babylion16"
        },
        animOverrides = {
            gamepass17 = "babylionRWing_Anim", gamepass18 = "babylionRWing_Anim",
            gamepass21 = "babygriffin_Anim", gamepass22 = "babygriffin_Anim",
            gamepass23 = "babygriffin_Anim", gamepass24 = "babygriffin_Anim",
            gamepass25 = "babygriffin_Anim", gamepass26 = "babygriffin_Anim"
        }
    },
    BabyPenguin = {id = "baby_penguin", anim = "babypenguinAnim"},
    BabyWolf = {
        id = "baby_wolf", anim = "babywolf1Anim", gamepassPassId = 38950138,
        skinIdOverrides = {
            babywolf1 = "baby_wolf1", babywolf2 = "baby_wolf2", babywolf3 = "baby_wolf3",
            babywolf4 = "baby_wolf4", babywolf5 = "baby_wolf5", babywolf6 = "baby_wolf6",
            babywolf7 = "baby_wolf7", babywolf8 = "baby_wolf8", babywolf9 = "baby_wolf9",
            babywolf10 = "baby_wolf10", babywolf11 = "baby_wolf11", babywolf12 = "baby_wolf12",
            babywolf13 = "baby_wolf13", babywolf14 = "baby_wolf14", babywolf15 = "baby_wolf15",
            babywolf16 = "baby_wolf16", babywolf17 = "baby_wolf17", babywolf18 = "gamepass18",
            babywolf19 = "gamepass19", babywolf20 = "gamepass20", babywolf21 = "gamepass21",
            babywolf22 = "gamepass22", babywolf23 = "gamepass23", babywolf24 = "gamepass24"
        },
        animOverrides = {
            babywolf1 = "babywolf1Anim", babywolf2 = "babywolf1Anim", babywolf3 = "babywolf1Anim",
            babywolf4 = "babywolf1Anim", babywolf5 = "babywolf1Anim", babywolf6 = "babywolf1Anim",
            babywolf7 = "babywolf1Anim", babywolf8 = "babywolf1Anim", babywolf9 = "babywolf1Anim",
            babywolf10 = "babywolf1Anim", babywolf11 = "babywolf1Anim", babywolf12 = "babywolf1Anim",
            babywolf13 = "babywolf1Anim", babywolf14 = "babywolf1Anim", babywolf15 = "babywolf2Anim",
            babywolf16 = "babywolf2Anim", babywolf17 = "babywolf2Anim", babywolf18 = "babywolf3Anim",
            babywolf19 = "babywolf3Anim", babywolf20 = "babywolf3Anim", babywolf21 = "babywolf3Anim",
            babywolf22 = "babywolf3Anim", babywolf23 = "babywolf3Anim", babywolf24 = "babywolf3Anim"
        }
    },
    Bear = {id = "bears", anim = "bearAnim"},
    Capybara = {id = "capybara", anim = "capybaraAnim"},
    Cat = {id = "cats", anim = "catAnim"},
    Centaur = {id = "centaur", anim = "centaurAnim"},
    Chicken = {id = "chicken", anim = "chickenAnim"},
    Christmas2023 = {
        id = "christmas2023", anim = "newhorseAnim", gamepassPassId = 670590394,
        skinIdOverrides = {
            capybara = "capybara1", snake = "snake1", crocodile = "crocodile1", horse = "horse1",
            giraffe = "giraffe1", gamepass_horse = "gamepass_horse", gamepass_giraffe1 = "gamepass_giraffe1",
            gamepass_giraffe2 = "gamepass_giraffe2", gamepass_babywolf = "gamepass_babywolf",
            gamepass_wolf = "gamepass_wolf"
        },
        animOverrides = {
            capybara = "capybaraAnim", snake = "snakeAnim", crocodile = "crocodileAnim",
            horse = "newhorseAnim", giraffe = "giraffeAnim", gamepass_horse = "newhorseAnim",
            gamepass_giraffe1 = "christmasgiraffeAnim", gamepass_giraffe2 = "christmasgiraffeAnim",
            gamepass_babywolf = "babywolf1Anim", gamepass_wolf = "wolf1Anim"
        },
        tokenOverrides = {
            capybara = "XM23CP", snake = "XM23SN", crocodile = "XM23CR", horse = "XM23HR", giraffe = "XM23GR"
        }
    },
    Christmas2024 = {id = "christmas2024", anim = "newbear2Anim"},
    Cow = {id = "cows", anim = "cowAnim"},
    Crab = {id = "crab", anim = "crabAnim"},
    Crocodile = {id = "crocodile", anim = "crocodileAnim"},
    Dragon = {id = "dragons", anim = "dragonAnim"},
    Eagle = {id = "eagle", anim = "eagleAnim"},
    Elephant = {id = "elephant", anim = "elephantAnim"},
    Fox = {id = "fox", anim = "foxAnim"},
    Frog = {id = "frog", anim = "frogAnim"},
    Giraffe = {id = "giraffe", anim = "giraffeAnim"},
    Gorilla = {id = "gorilla", anim = "gorillaAnim"},
    Halloween2023 = {
        id = "halloween2023", anim = "newhorseAnim", gamepassPassId = 270811024,
        animOverrides = {
            horse = "newhorseAnim", capybara = "capybaraAnim", crocodile = "crocodileAnim",
            monkey = "halloweenmonkeyAnim", dragon = "dragonAnim", snake = "snakeAnim",
            gamepass_lion = "reworklion_Anim", gamepass_lioness = "reworklion_Anim",
            gamepass_babylion = "babylionR_Anim", gamepass_dragon = "dragonAnim",
            gamepass_monkey = "halloweenmonkeyAnim", gamepass_horse = "newhorseAnim"
        },
        tokenOverrides = {
            horse = "H23HR", capybara = "H23CP", crocodile = "H23CR", monkey = "H23MK",
            dragon = "H23DR", snake = "H23SN"
        }
    },
    Horse = {id = "horse", anim = "horseAnim"},
    Husky = {id = "husky", anim = "huskyAnim"},
    Hyena = {id = "hyena", anim = "hyenaAnim"},
    Kangaroo = {id = "kangaroos", anim = "kangarooAnim"},
    Komodo = {id = "komodo", anim = "komodoAnim"},
    LionRework = {id = "lion_rework", anim = "reworklion_Anim"},
    LionessRework = {id = "lioness_rework", anim = "reworklion_Anim"},
    Mantis = {id = "mantis", anim = "mantisAnim"},
    Monkey = {id = "monkey", anim = "monkeyAnim"},
    NewBear = {id = "newbears", anim = "newbearAnim"},
    NewDeer = {id = "newdeer", anim = "newdeerAnim"},
    NewHorse = {id = "newhorse", anim = "newhorseAnim"},
    Old = {
        id = "old", anim = "lionAnim",
        animOverrides = {
            mysticpanther = "lionessAnim", greywolf = "wolfAnim", brownlion = "lionAnim",
            brownlioness = "lionessAnim", baby_brownlion = "babylionAnim", brown_cerberus = "cerberusAnim",
            jaguar = "lionessAnim", mysticlion = "lionAnim", mysticwolf = "wolfAnim", blackpanther = "lionessAnim"
        }
    },
    Penguin = {
        id = "penguin", anim = "penguinAnim",
        skinIdOverrides = {
            police2 = "police1_penguin", police1 = "police2_penguin",
            yellow_samuraipenguin = "gamepass1", red_samuraipenguin = "gamepass2", blue_samuraipenguin = "gamepass3"
        },
        animOverrides = {
            gamepass1 = "premPenguinAnim", gamepass2 = "premPenguinAnim", gamepass3 = "premPenguinAnim"
        }
    },
    Pig = {
        id = "pigs", anim = "pigAnim",
        animOverrides = {
            babypig1 = "babypigAnim", babypig2 = "babypigAnim", babypig3 = "babypigAnim",
            gamepass1 = "pig2Anim", gamepass2 = "pig2Anim", gamepass3 = "pig2Anim", gamepass4 = "pig2Anim"
        }
    },
    Rabbit = {
        id = "rabbit", anim = "rabbitAnim",
        skinIdOverrides = {
            anime_rabbit = "gamepass1", police_rabbit = "gamepass2", white_rabbit = "gamepass3"
        },
        animOverrides = {
            gamepass1 = "premRabbitAnim", gamepass2 = "premRabbitAnim", gamepass3 = "premRabbitAnim"
        }
    },
    Rhino = {id = "rhino", anim = "rhinoAnim"},
    Skeleton = {
        id = "skeletons", anim = "skeleton_deerAnim",
        animOverrides = {
            deer_1 = "skeleton_deerAnim", rhino_1 = "skeleton_rhinoAnim", trex_1 = "skeleton_trexAnim",
            wolf_1 = "skeleton_wolfAnim", gamepass_deer2 = "skeleton_deerAnim", gamepass_deer3 = "skeleton_deerAnim",
            gamepass_rhino2 = "skeleton_rhinoAnim", gamepass_rhino3 = "skeleton_rhinoAnim",
            gamepass_trex2 = "skeleton_trexAnim", gamepass_trex3 = "skeleton_trexAnim",
            gamepass_wolf2 = "skeleton_wolfAnim", gamepass_wolf3 = "skeleton_wolfAnim"
        }
    },
    Snake = {
        id = "snakes", anim = "snakeAnim",
        animOverrides = {
            gamepass1 = "snakeAnim2", gamepass2 = "snakeAnim2", gamepass3 = "snakeAnim2",
            gamepass4 = "snakeAnim2", gamepass5 = "snakeAnim2"
        }
    },
    Spider = {id = "spider", anim = "spiderAnim"},
    Squirrel = {
        id = "squirrel", anim = "squirrelAnim",
        animOverrides = {
            gamepass1 = "squirrel2Anim", gamepass2 = "squirrel2Anim", gamepass3 = "squirrel2Anim",
            gamepass4 = "squirrel2Anim", gamepass5 = "squirrel2Anim"
        }
    },
    Tiger = {
        id = "tiger", anim = "tigerAnim",
        animOverrides = {
            circle_grey = "babytigerAnim", orange_babytiger = "babytigerAnim",
            white_babytiger = "babytigerAnim", stripe_grey = "babytigerAnim",
            gamepass1 = "premTigerAnim", gamepass2 = "premTigerAnim", gamepass3 = "premTigerAnim"
        }
    },
    Valentines2024 = {
        id = "valentines2024", anim = "pegasusAnim",
        animOverrides = {
            capybara1 = "capybaraAnim", eagle1 = "eagleAnim", eagle2 = "eagleAnim",
            giraffe1 = "giraffeAnim", giraffe2 = "giraffeAnim", horse1 = "pegasusAnim",
            horse2 = "pegasusAnim", snake1 = "snakeAnim"
        }
    },
    WolfRework = {
        id = "wolf_rework", anim = "wolf1Anim",
        skinIdOverrides = {
            wolf18 = "gamepass18", wolf19 = "gamepass19", wolf20 = "gamepass20",
            wolf21 = "gamepass21", wolf22 = "gamepass22", wolf23 = "gamepass23", wolf24 = "gamepass24"
        },
        animOverrides = {
            wolf15 = "wolf2Anim", wolf16 = "wolf2Anim", wolf18 = "wolf3Anim", wolf19 = "wolf3Anim",
            wolf20 = "wolf3Anim", wolf21 = "wolf3Anim", wolf22 = "wolf3Anim", wolf23 = "wolf3Anim",
            wolf24 = "wolf3Anim"
        }
    }
}

--[[
    PREMIUM TAB FUNCTIONS
]]
-- Premium tab variables
-- Godmode variables (now in State table)

local function controlNPC(npc, targetPlayer)
    if not npc or not targetPlayer then return false end
    
    local npcRootPart = npc:FindFirstChild("HumanoidRootPart")
    local PlayerCharacter = Services.Players.LocalPlayer.Character
    local PlayerRootPart = PlayerCharacter and PlayerCharacter:FindFirstChild("HumanoidRootPart")
    
    if not (npcRootPart and PlayerRootPart) then
        return false
    end
    

    for _, v in pairs(npc:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
    

    local A0 = Instance.new("Attachment")
    local AP = Instance.new("AlignPosition")
    local AO = Instance.new("AlignOrientation")
    local A1 = Instance.new("Attachment")
    

    A0.Parent = npcRootPart
    A1.Parent = PlayerRootPart
    AP.Parent = npcRootPart
    AO.Parent = npcRootPart
    

    AP.Responsiveness = 200
    AP.MaxForce = math.huge
    AO.MaxTorque = math.huge
    AO.Responsiveness = 200
    

    AP.Attachment0 = A0
    AP.Attachment1 = A1
    AO.Attachment0 = A0
    AO.Attachment1 = A1
    

    task.wait(0.1)
    if not (AP.Attachment0 and AP.Attachment1 and AO.Attachment0 and AO.Attachment1) then
        return false
    end
    
    return true
end

local function NPCSkidFling(targetPlayer, controlledNPC)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not controlledNPC then return false end
    
    local TCharacter = targetPlayer.Character
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = TCharacter:FindFirstChild("HumanoidRootPart")
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    local npcHRP = controlledNPC:FindFirstChild("HumanoidRootPart")
    local npcHumanoid = controlledNPC:FindFirstChildOfClass("Humanoid")
    
    if not npcHRP or not npcHumanoid then return false end
    

    local originalNPCPos = npcHRP.CFrame
    

    local camera = workspace.CurrentCamera
    if THead then
        camera.CameraSubject = THead
    elseif not THead and Handle then
        camera.CameraSubject = Handle
    elseif THumanoid and TRootPart then
        camera.CameraSubject = THumanoid
    end
    

    workspace.FallenPartsDestroyHeight = 0/0
    
    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = npcHRP
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
    
    npcHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    

    local NPCFPos = function(BasePart, Pos, Ang)
        npcHRP.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        controlledNPC:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        npcHRP.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        npcHRP.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    

    local NPCSFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        local flingStarted = false
        
        repeat
            if npcHRP and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    
                    NPCFPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else

                    flingStarted = true
                    NPCFPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                    task.wait()
                    
                    NPCFPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    

                    if flingStarted then
                        npcHRP.CFrame = originalNPCPos
                        controlledNPC:SetPrimaryPartCFrame(originalNPCPos)
                        break
                    end
                end
            else
                break
            end
        until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= Services.Players or not targetPlayer.Character == TCharacter or THumanoid.Sit or npcHumanoid.Health <= 0 or tick() > Time + TimeToWait or flingStarted
    end
    

    if TRootPart and THead then
        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
            NPCSFBasePart(THead)
        else
            NPCSFBasePart(TRootPart)
        end
    elseif TRootPart and not THead then
        NPCSFBasePart(TRootPart)
    elseif not TRootPart and THead then
        NPCSFBasePart(THead)
    elseif not TRootPart and not THead and Accessory and Handle then
        NPCSFBasePart(Handle)
    end
    

    if npcHRP then
        npcHRP.CFrame = originalNPCPos
        controlledNPC:SetPrimaryPartCFrame(originalNPCPos)

        npcHRP.Velocity = Vector3.new(0, 0, 0)
        npcHRP.RotVelocity = Vector3.new(0, 0, 0)
    end
    

    BV:Destroy()
    npcHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    

    camera.CameraSubject = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    

    repeat
        npcHRP.CFrame = originalNPCPos * CFrame.new(0, .5, 0)
        controlledNPC:SetPrimaryPartCFrame(originalNPCPos * CFrame.new(0, .5, 0))
        npcHumanoid:ChangeState("GettingUp")
        for _, x in pairs(controlledNPC:GetChildren()) do
            if x:IsA("BasePart") then
                x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
            end
        end
        task.wait()
    until (npcHRP.Position - originalNPCPos.p).Magnitude < 25
    
    workspace.FallenPartsDestroyHeight = State.FPDH or 500
    

    if controlledNPC then
        local npcHumanoid = controlledNPC:FindFirstChildOfClass("Humanoid")
        if npcHumanoid then

            for _, part in pairs(controlledNPC:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:BreakJoints()
                end
            end
            

            npcHumanoid.Health = 0
        end
    end
    
    return true
end

local function walkfling(targetPlayer, controlledNPC)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not controlledNPC then return false end
    

    return NPCSkidFling(targetPlayer, controlledNPC)
end

-- Robux Weapons System
-- Weapon variables (now in State table)
local weaponIndexToCode = {
    [1] = "SS4",
    [2] = "SS5", 
    [3] = "SS6",
    [4] = "SS9",
    [5] = "SSS1",
    [6] = "SSS2",
    [7] = "SSS3",
    [8] = "SSSSSS2",
    [9] = "SSSSSS9",
    [10] = "SSSSSSS1",
    [11] = "SSSSSSS3",
    [12] = "SSSSSSS5",
    [13] = "SSSSSSS6",
    [14] = "SSSSSSSS6",
    [15] = "SSSSSSSS7"
}

--[[
    PREMIUM TAB UI - PREMIUM ACCESS REQUIRED
    This entire section is protected by rank verification.
    Only players with Premium rank (1) or above can see this content.
]]
-- Only create content if player has premium access

-- removed premium if-block
 -- Close the hasPremiumAccess() check for Premium tab content

--[[
    BOSS FARMING SYSTEM
]]
State.bossFarmingEnabled = false
    State.bossFarmingThread = nil
local bossHealthThreads = {}

-- Function to find all bosses
local function findBosses()
    local bosses = {}
    local NPCFolder = workspace:FindFirstChild("NPC")
    
    if NPCFolder then
        for _, npc in ipairs(NPCFolder:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                local humanoid = npc.Humanoid
                if humanoid.Health > 0 then
                    table.insert(bosses, npc)
                end
            end
        end
    end
    
    return bosses
end

-- Function to arm a boss for auto-kill (same as NPC system)
local function armBoss(boss)
    if bossHealthThreads[boss] then return end
    local hum = boss:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local lastHealth = hum.Health
    bossHealthThreads[boss] = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health < lastHealth then
            task.wait(0.05)
            hum.Health = 0
            if boss:FindFirstChild("HumanoidRootPart") then
                boss.HumanoidRootPart:BreakJoints()
            end

        end
        lastHealth = hum.Health
    end)
end

-- Function to disarm all bosses
local function disarmAllBosses()
    if Cache.bossHealthThreads and type(Cache.bossHealthThreads) == "table" then
        for boss, conn in pairs(Cache.bossHealthThreads) do
        if conn then conn:Disconnect() end
    end
        Cache.bossHealthThreads = {}
    end
end

-- Function to farm bosses
local function farmBosses()
    while State.bossFarmingEnabled do
        local bosses = findBosses()
        
        for _, boss in ipairs(bosses) do
            if not State.bossFarmingEnabled then break end
            
            local humanoid = boss:FindFirstChild("Humanoid")
            local rootPart = boss:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and humanoid.Health > 0 then
                local player = Services.Players.LocalPlayer
                local character = player.Character
                
                if character and character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport above boss
                    character.HumanoidRootPart.CFrame = rootPart.CFrame * CFrame.new(0, 8, 0)
                    
                    -- Arm the boss for auto-kill BEFORE freezing player
                    armBoss(boss)
                    
                    -- Attack boss once to trigger the auto-kill system
                    local args = {
                        humanoid,
                        1
                    }
                    
                    if Services.ReplicatedStorage:FindFirstChild("jdskhfsIIIllliiIIIdchgdIiIIIlIlIli") then
                        Services.ReplicatedStorage.jdskhfsIIIllliiIIIdchgdIiIIIlIlIli:FireServer(unpack(args))
                    end
                    
                    -- Wait a moment for the attack to register
                    task.wait(0.3)
                    
                    -- Now freeze player in place using multiple methods
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = character.HumanoidRootPart
                    
                    -- Also anchor the character to prevent movement
                    character.HumanoidRootPart.Anchored = true
                    
                    -- Disable humanoid movement
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.WalkSpeed = 0
                        character.Humanoid.JumpPower = 0
                    end
                    
                    -- Wait for the auto-kill system to handle the boss
                    task.wait(1.5)
                    
                    -- Restore player movement
                    character.HumanoidRootPart.Anchored = false
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.WalkSpeed = 16
                        character.Humanoid.JumpPower = 50
                    end
                    
                    -- Remove BodyVelocity
                    if bodyVelocity and bodyVelocity.Parent then
                        bodyVelocity:Destroy()
                    end
                    
                    -- Wait before moving to next boss
                    task.wait(1)
                end
            end
        end
        
        -- Wait before checking for new bosses
        task.wait(2)
    end
end

-- Boss Farming Section

-- Boss Farming Toggle

-- removed premium widget block


--[[
    SETTINGS TAB FUNCTIONS
]]
-- Settings tab variables and functions
local FallenPartsDestroyHeight = 500

-- Function to update FallenPartsDestroyHeight
local function updateFPDH(value)
    FallenPartsDestroyHeight = value
    workspace.FallenPartsDestroyHeight = value
    Rayfield:Notify({
        Title = "Settings",
        Content = "FallenPartsDestroyHeight set to: " .. value,
        Duration = 2
    })
end

--[[
    SETTINGS TAB UI
]]
-- Update Lists Button
local function manualUpdateAllDropdowns()
    refreshTeleportDropdown()
    if SpectateDropdown then
        local players = getSpectatePlayers()
        SpectateDropdown:Refresh(players)
    end
    
    Rayfield:Notify({
        Title = "🔄 Lists Updated",
        Content = "All player lists have been updated!",
        Duration = 1
    })
end

SettingsTab:CreateButton({
    Name = "🔄 Update Player Lists",
    Callback = manualUpdateAllDropdowns
})

SettingsTab:CreateButton({
    Name = "🔃 Rejoin Game",
    Callback = function()
        Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        Rayfield:Notify({
            Title = "Rejoining Game",
            Content = "Attempting to rejoin the current session...",
            Duration = 1
        })
    end
})

SettingsTab:CreateSection("Window Configuration")

-- Rayfield theme options (using available themes)
local themeValues = {"Default", "Dark", "Light", "Midnight", "Sentinel", "Crimson", "Ocean", "Pine", "Lotus", "Cherry", "Sunset", "Magenta", "Aurora", "Candy"}

local themeDropdown = SettingsTab:CreateDropdown({
    Name = "Select Theme",
    Options = themeValues,
    CurrentOption = "Default",
    Flag = "ThemeSelection",
    Callback = function(theme)
        -- Handle both string and table inputs
        local selectedTheme = ""
        if type(theme) == "table" then
            selectedTheme = theme[1] or "Default"
        else
            selectedTheme = tostring(theme) or "Default"
        end
        
        -- Note: Theme changing is not available in current Rayfield version
        Rayfield:Notify({
            Title = "Theme",
            Content = "Theme changing not available in current Rayfield version",
            Duration = 2
        })
    end
})

local transparencyToggle = SettingsTab:CreateToggle({
    Name = "Window Transparency",
    CurrentValue = false,
    Callback = function(state)
        -- Note: Rayfield doesn't have direct transparency toggle like WindUI
        -- This is a placeholder for compatibility
        Rayfield:Notify({
            Title = "Transparency",
            Content = "Transparency toggle not available in Rayfield",
            Duration = 2
        })
    end
})

SettingsTab:CreateSection("Save/Load Configuration")

local configName = ""

SettingsTab:CreateInput({
    Name = "Configuration Name",
    PlaceholderText = "MyConfig",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        configName = text
    end
})

local configFiles = listfiles("MoonHUB") or {}
local configDropdown = SettingsTab:CreateDropdown({
    Name = "Saved Configurations",
    Options = configFiles,
    CurrentOption = "",
    Flag = "SavedConfigs",
    Callback = function(selected)
        -- Handle both string and table inputs
        if type(selected) == "table" then
            configName = selected[1] or ""
        else
            configName = tostring(selected) or ""
        end
    end
})

SettingsTab:CreateButton({
    Name = "💾 Save Configuration",
    Callback = function()
        if configName ~= "" then
            -- Create the MoonHUB folder if it doesn't exist
            if not isfolder("MoonHUB") then
                makefolder("MoonHUB")
            end
            
            local configData = {
                Theme = "Default", -- Placeholder since GetCurrentTheme() is not available
                Transparency = false, -- Placeholder for compatibility
                WalkSpeed = Config.WalkSpeed.CurrentSpeed,
                ESPEnabled = Config.ESP.Enabled,
                Keybind = "RightShift" -- Default keybind since currentKeybind doesn't exist
            }
            
            local success, err = pcall(function()
                writefile("MoonHUB/"..configName..".json", Services.HttpService:JSONEncode(configData))
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "Configuration Saved",
                    Content = "Settings saved as: "..configName,
                    Duration = 3
                })
                -- Update the configuration list
                configFiles = listfiles("MoonHUB") or {}
                configDropdown:Refresh(configFiles)
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to save config: "..tostring(err),
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a configuration name!",
                Duration = 2
            })
        end
    end
})

SettingsTab:CreateButton({
    Name = "📂 Load Configuration",
    Callback = function()
        if configName ~= "" and pcall(function() readfile("MoonHUB/"..configName..".json") end) then
            local success, configData = pcall(function()
                return Services.HttpService:JSONDecode(readfile("MoonHUB/"..configName..".json"))
            end)
            
            if success and configData then
                -- Apply loaded configurations
                if configData.Theme then
                    -- Note: Theme changing is not available in current Rayfield version
                    -- themeDropdown:Refresh() is not needed for Rayfield
                end
                
                if configData.Transparency ~= nil then
                    -- Placeholder for transparency compatibility
                    transparencyToggle:SetValue(configData.Transparency)
                end
                
                if configData.WalkSpeed then
                    Config.WalkSpeed.CurrentSpeed = configData.WalkSpeed
                    updateWalkSpeed(configData.WalkSpeed)
                end
                
                if configData.ESPEnabled ~= nil then
                    ToggleESP(configData.ESPEnabled)
                end
                
                if configData.Keybind then
                    -- Note: Rayfield keybind setting would go here
                    -- currentKeybind variable doesn't exist in this version
                end
                
                Rayfield:Notify({
                    Title = "Configuration Loaded",
                    Content = "Settings loaded from: "..configName,
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to load config!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Config file not found!",
                Duration = 2
            })
        end
    end
})

SettingsTab:CreateButton({
    Name = "🔄 Refresh Config List",
    Callback = function()
        configFiles = listfiles("MoonHUB") or {}
        configDropdown:Refresh(configFiles)
        Rayfield:Notify({
            Title = "Config List Updated",
            Content = "Configuration list has been refreshed",
            Duration = 1
        })
    end
})

-- Settings: Tag system configuration
SettingsTab:CreateSection("Role Tag System")

SettingsTab:CreateToggle({
    Name = "Overhead Role Tags",
    CurrentValue = true,
    Callback = function(state)
        if state then
            Tag_startScanner()
            Rayfield:Notify({ Title = "Tags", Content = "Role tags enabled", Duration = 2 })
        else
            Tag_stopScanner()
            Tag_clearAllNow()
            Rayfield:Notify({ Title = "Tags", Content = "Role tags disabled", Duration = 2 })
        end
    end
})

SettingsTab:CreateButton({
    Name = "🔄 Refresh All Tags",
    Callback = function()
        Tag_clearAllNow()
        task.wait(0.5)
        if performRollingCheck then
            performRollingCheck()
        end
        Rayfield:Notify({ Title = "Tags", Content = "All tags refreshed with rolling check", Duration = 2 })
    end
})

SettingsTab:CreateButton({
    Name = "🧹 Clear All Tags",
    Callback = function()
        Tag_clearAllNow()
        Rayfield:Notify({ Title = "Tags", Content = "All tags cleared", Duration = 2 })
    end
})

SettingsTab:CreateButton({
    Name = "🛡️ Force Tag Recovery",
    Callback = function()
        if performRollingCheck then
            performRollingCheck()
            Rayfield:Notify({ Title = "Tags", Content = "Forced tag recovery - checking all players", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Tags", Content = "Tag system not available", Duration = 2 })
        end
    end
})

-- Tag status display
local tagStatusLabel = SettingsTab:CreateLabel("Tag Status: Active - Rolling check every 1s, Teleport protection every 0.5s")

-- Function to update tag status
local function updateTagStatus()
            if State.tagScanEnabled then
        local playerCount = 0
        local validTags = 0
        
        for player, tag in pairs(TagData.guiByPlayer) do
            if player and player.Parent and player.Character and 
               player.Character:FindFirstChild("Head") and tag and tag.Parent then
                validTags = validTags + 1
            end
            playerCount = playerCount + 1
        end
        
        tagStatusLabel:Set("Tag Status: Active - " .. validTags .. " valid tags, " .. playerCount .. " total tracked")
    else
        tagStatusLabel:Set("Tag Status: Inactive - Tags disabled")
    end
end

-- Update status every 3 seconds
task.spawn(function()
    while task.wait(3) do
        updateTagStatus()
    end
end)

-- Function to handle regular animal spawning
local function spawnAnimal(animalName, skinName)
    -- Ensure we have valid string inputs
    if not animalName then return end
    
    animalName = tostring(animalName)
    skinName = skinName and tostring(skinName) or animalName
    
    local animalConfig = Config.AnimalMap[animalName]
    if not animalConfig then
        Rayfield:Notify({
            Title = "Error",
            Content = "Animal not found in configuration",
            Duration = 2
        })
        return
    end
    
    local skinId = skinName
    local anim = animalConfig.anim
    local token = nil
    
    if animalConfig.skinIdOverrides and animalConfig.skinIdOverrides[skinName] then
        skinId = animalConfig.skinIdOverrides[skinName]
    end
    
    if animalConfig.animOverrides and animalConfig.animOverrides[skinName] then
        anim = animalConfig.animOverrides[skinName]
    end
    
    if animalConfig.tokenOverrides and animalConfig.tokenOverrides[skinName] then
        token = animalConfig.tokenOverrides[skinName]
    end
    
    local isGamepass = (animalConfig.gamepassPassId ~= nil) and ((skinId and skinId:match("^gamepass%d+$")) ~= nil)
    
    if isGamepass then
        Rayfield:Notify({
            Title = "Gamepass Skin",
            Content = "Gamepass skin detected: " .. skinId .. " - Use godmode for this skin",
            Duration = 3
        })
        return
    elseif token then
        local Events = Services.ReplicatedStorage:FindFirstChild("Events")
        if Events and Events:FindFirstChild("SpawnEvent") then
            Events.SpawnEvent:FireServer(animalConfig.id, skinId, anim, token)
        end
        Rayfield:Notify({
            Title = "Animal Spawned",
            Content = "Spawned " .. animalName .. " successfully with token: " .. token,
            Duration = 2
        })
    else
        local Events = Services.ReplicatedStorage:FindFirstChild("Events")
        if Events and Events:FindFirstChild("SpawnEvent") then
            Events.SpawnEvent:FireServer(animalConfig.id, skinId, anim)
        end
        Rayfield:Notify({
            Title = "Animal Spawned",
            Content = "Spawned " .. animalName .. " successfully",
            Duration = 2
        })
    end
end

-- Function to handle animal clicks and store the selection
local function handleAnimalClick(animalName, skinName)
    if not animalName then return end
    
    -- Ensure we have valid string inputs
    animalName = tostring(animalName)
    skinName = skinName and tostring(skinName) or animalName
    
    State.lastClickedAnimal = animalName
    State.lastClickedSkin = skinName
    
    if State.godmodeToggle then
        Rayfield:Notify({
            Title = "Starting Godmode",
            Content = "Auto-starting godmode with: " .. animalName .. (skinName and " (" .. skinName .. ")" or ""),
            Duration = 2
        })
        
        local spawnArgs, error = Util.getSpawnArgs(animalName, skinName)
        
        if spawnArgs then
            local savedPos = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Services.Players.LocalPlayer.Character.HumanoidRootPart.Position or nil
            local plotArgs = {"buyPlot", "2"}
            local targetPos = Vector3.new(146, 643, 427)
            
            Rayfield:Notify({
                Title = "Godmode",
                Content = "Target: " .. animalName .. " | Args: " .. table.concat(spawnArgs, ", "),
                Duration = 2
            })
            
            Rayfield:Notify({
                Title = "Godmode",
                Content = "Started",
                Duration = 2
            })
            
            if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
                Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 
            end
            
            local active = true
            task.spawn(function()
                local hrp = nil
                if animalName == "Player" then
                    while active do
                        local char = Services.Players.LocalPlayer.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        pcall(function() 
                            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
                            if Events and Events:FindFirstChild("SpawnEvent") then
                                Events.SpawnEvent:FireServer(unpack(spawnArgs))
                            end
                            local PlotSystemRE = Services.ReplicatedStorage:FindFirstChild("PlotSystemRE")
                            if PlotSystemRE then
                                PlotSystemRE:FireServer(unpack(plotArgs))
                            end
                        end)
                        if hrp and targetPos and (hrp.Position - targetPos).Magnitude < 1 then break end
                        task.wait()
                    end
                    if active and hrp and savedPos then 
                        task.wait(1) 
                        hrp.CFrame = CFrame.new(savedPos) 
                        Rayfield:Notify({
                            Title = "Godmode",
                            Content = "Returned",
                            Duration = 2
                        }) 
                    end
                else
                    local function fireBoth() 
                        pcall(function() 
                            local Events = Services.ReplicatedStorage:FindFirstChild("Events")
                            if Events and Events:FindFirstChild("SpawnEvent") then
                                Events.SpawnEvent:FireServer(unpack(spawnArgs))
                            end
                            local PlotSystemRE = Services.ReplicatedStorage:FindFirstChild("PlotSystemRE")
                            if PlotSystemRE then
                                PlotSystemRE:FireServer(unpack(plotArgs))
                            end
                        end) 
                    end
                    if Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
                        Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 
                    end

                    local tPos = Vector3.new(146, 643, 427) 
                    local close = false 
                    local phase1 = false
                    
                    while active and not phase1 do
                        local char = Services.Players.LocalPlayer.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then 
                            local d = (hrp.Position - tPos).Magnitude 
                            if d < 5 then 
                                close = true 
                                phase1 = true 
                            else 
                                fireBoth() 
                            end 
                        end
                        task.wait(0.05)
                    end
                    
                    if active and close then
                        local s = tick()
                        while active and (tick() - s) < 2 do 
                            pcall(function() 
                                local PlotSystemRE = Services.ReplicatedStorage:FindFirstChild("PlotSystemRE")
                                if PlotSystemRE then
                                    PlotSystemRE:FireServer(unpack(plotArgs)) 
                                end
                            end)
                            task.wait(0.1) 
                        end
                    end
                    
                    if active and close then
                        hrp = Services.Players.LocalPlayer.Character and Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then 
                            local fd = (hrp.Position - tPos).Magnitude 
                            if fd < 10 and savedPos then 
                                task.wait(1) 
                                hrp.CFrame = CFrame.new(savedPos) 
                            else 
                                Rayfield:Notify({
                                    Title = "Godmode",
                                    Content = "Failed: " .. math.floor(fd),
                                    Duration = 2
                                }) 
                            end 
                        end
                    end
                end
                active = false
                Rayfield:Notify({
                    Title = "Godmode",
                    Content = "Stopped",
                    Duration = 2
                })
            end)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Could not get spawn args for: " .. animalName .. " - " .. (error or "Unknown error"),
                Duration = 2
            })
        end
    else
        -- Regular spawning mode
        spawnAnimal(animalName, skinName)
    end
end

--[[
    ANIMAL DETECTION SYSTEM
]]
-- Hook into the game's animal selection system
local function setupAnimalDetection()
    -- Function to wire each animal species (non-blocking)
    local function wireSpecies(folder)
        task.spawn(function()
            for _, skin in ipairs(folder:GetChildren()) do
                local frame = skin:FindFirstChild("Frame")
                if frame then
                    local button = frame:FindFirstChild("Button")
                    if button then
                        -- Disconnect any existing connections to avoid duplicates
                        pcall(function()
                            -- Store the connection reference for later disconnection
                            if button.MouseButton1Click then
                                -- Disconnect if there's an existing connection
                                if button.MouseButton1Click.Connected then
                                    button.MouseButton1Click:Disconnect()
                                end
                            end
                        end)
                        
                        -- Add our custom handler
                        button.MouseButton1Click:Connect(function()
                            -- Handle based on toggle state
                            if State.godmodeToggle then
                                -- Store selection for godmode
                                handleAnimalClick(folder.Name, skin.Name)
                            else
                                -- Spawn animal immediately
                                spawnAnimal(folder.Name, skin.Name)
                            end
                        end)
                    end
                end
                task.wait(0.01) -- Small delay between each button to prevent lag
            end
        end)
        
        -- Handle new animals added
        folder.ChildAdded:Connect(function(child)
            task.spawn(function()
                task.wait(0.2) -- Wait for child to fully load
                local frame = child:FindFirstChild("Frame")
                if frame then
                    local button = frame:FindFirstChild("Button")
                    if button then
                        button.MouseButton1Click:Connect(function()
                            -- Handle based on toggle state
                            if State.godmodeToggle then
                                -- Store selection for godmode
                                handleAnimalClick(folder.Name, child.Name)
                            else
                                -- Spawn animal immediately
                                spawnAnimal(folder.Name, child.Name)
                            end
                        end)
                    end
                end
            end)
        end)
    end
    
    -- Completely non-blocking setup
    local function asyncSetup()
        local success, gui = pcall(function()
            -- Use very short timeouts and async approach
            local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui", 1)
            if not playerGui then return nil end
            
            local animalsGui = playerGui:WaitForChild("AnimalsGUI", 1)
            if not animalsGui then return nil end
            
            local windowFrame = animalsGui:WaitForChild("windowFrame", 1)
            if not windowFrame then return nil end
            
            local bodyFrame = windowFrame:WaitForChild("bodyFrame", 1)
            if not bodyFrame then return nil end
            
            local body2Frame = bodyFrame:WaitForChild("body2Frame", 1)
            if not body2Frame then return nil end
            
            local animals = body2Frame:WaitForChild("Animals", 1)
            if not animals then return nil end
            
            return animals
        end)
        
        if success and gui then
            -- Wire existing species in background
            task.spawn(function()
                for _, spec in ipairs(gui:GetChildren()) do
                    wireSpecies(spec)
                    task.wait(0.05) -- Small delay between species
                end
                
                -- Handle new species
                gui.ChildAdded:Connect(wireSpecies)
                
                -- Success notification removed to prevent startup spam
            end)
            
            return true
        else
            return false
        end
    end
    
    -- Non-blocking retry
    local attempts = 0
    local maxAttempts = 2
    
    local function tryNext()
        if attempts >= maxAttempts then
            -- Silent fail - no warning notification
            return
        end
        
        attempts = attempts + 1
        if asyncSetup() then
            return
        else
            task.wait(1) -- Wait 1 second before retrying
            tryNext()
        end
    end
    
    tryNext()
end

-- Call this when the script loads with a proper delay to avoid lag
task.spawn(function()
    -- Wait for the game to fully load before attempting to hook into GUI
    task.wait(8)
    setupAnimalDetection()
end)

--[[
    LOAD CONFIGURATION
]]

-- Load configuration with error handling
local success, err = pcall(function()
    if Rayfield and Rayfield.LoadConfiguration then
        Rayfield:LoadConfiguration()
    end
end)

-- End of script

function Util.StartAutoEat()
    State.autoEat = true
    if not State._autoEatRunning then
        State._autoEatRunning = true
        task.spawn(function() autoEatLoop() State._autoEatRunning = false end)
    end
end
function Util.StopAutoEat()
    State.autoEat = false
end

