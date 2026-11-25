-- Centaura single-file bundle (generated)
local __modules = {}
local __oldRequire = require
local function __require(name)
    if type(name) == 'string' and __modules[name] ~= nil then
        return __modules[name]
    end
    return __oldRequire(name)
end
require = __require

__modules['log'] = (function()
-- purpose: logging buffer, clipboard export, fatal reporting
local M = {}
function M.setup(ctx)
    ctx.LOG_BUF = {}
    ctx.COPY_FN = setclipboard or toclipboard or writeclipboard or nil
    ctx.L = function(m)
        m = tostring(m)
        table.insert(ctx.LOG_BUF, m)
        if #ctx.LOG_BUF > 500 then table.remove(ctx.LOG_BUF, 1) end
        pcall(function() print("[TREK] " .. m) end)
    end
    ctx.saveLogToClipboard = function()
        if ctx.COPY_FN then
            return pcall(ctx.COPY_FN, "[TREK LOG]\n" .. table.concat(ctx.LOG_BUF, "\n"))
        end
        return false
    end
    ctx.FATAL = function(e)
        ctx.L("FATAL: " .. tostring(e))
        ctx.L(debug.traceback())
        ctx.saveLogToClipboard()
    end
end
return M
end)()

__modules['services'] = (function()
-- purpose: Roblox services, local player, module/remotes discovery, shared player helpers
local M = {}
function M.setup(ctx)
    ctx.Players = game:GetService("Players")
    ctx.RS = game:GetService("ReplicatedStorage")
    ctx.UIS = game:GetService("UserInputService")
    ctx.Run = game:GetService("RunService")
    ctx.TeamsSvc = game:GetService("Teams")
    ctx.workspace = workspace
    ctx.Cam = workspace.CurrentCamera

    ctx.LP = ctx.Players.LocalPlayer
    if not ctx.LP then error("LocalPlayer nil") end
    ctx.PG = ctx.LP:FindFirstChild("PlayerGui") or ctx.LP:WaitForChild("PlayerGui", 10)
    if not ctx.PG then error("PlayerGui nil") end
    ctx.L("Player: " .. ctx.LP.Name)

    ctx.deepFind = function(parent, name, depth)
        depth = depth or 0
        if depth > 3 then return nil end
        local f = parent:FindFirstChild(name)
        if f then return f end
        for _, c in ipairs(parent:GetChildren()) do
            if c:IsA("Folder") or c:IsA("Model") or c:IsA("Configuration") then
                local r = ctx.deepFind(c, name, depth + 1)
                if r then return r end
            end
        end
        return nil
    end

    ctx.TM = ctx.RS:FindFirstChild("TREKModules") or ctx.deepFind(ctx.RS, "TREKModules")
    ctx.GS = ctx.TM and ctx.TM:FindFirstChild("GunSettings")
    ctx.TR = ctx.RS:FindFirstChild("TREKRemotes") or ctx.deepFind(ctx.RS, "TREKRemotes")
    ctx.BR = ctx.TR and ctx.TR:FindFirstChild("BulletRemote")
    ctx.DR = ctx.TR and ctx.TR:FindFirstChild("DamagerRemote")
    ctx.MODULES_OK = (ctx.BR and ctx.DR) and true or false

    ctx.isEnemy = function(plr)
        if plr == ctx.LP then return false end
        if plr.Team and ctx.LP.Team and plr.Team == ctx.LP.Team then return false end
        return true
    end
    ctx.isTeammate = function(plr)
        return plr ~= ctx.LP and ctx.LP.Team and plr.Team == ctx.LP.Team
    end
end
return M
end)()

__modules['config'] = (function()
-- purpose: user config table and derived options/state scalars
local M = {}
function M.setup(ctx)
    ctx.CONFIG = {
        Title = "RENRENHUB CENTAURA",
        Tabs  = { "Combat", "AutoKill", "Aim", "ESP", "Medic", "Display" },

        NoRecoil   = true,
        NoSpread   = true,
        NoCooldown = false,
        NoReload   = false,
        OneHit     = false,

        AutoKill         = false,
        SekaratMode      = false,
        TargetMode       = "Nearest",
        AutoKillCooldown = 1.0,
        AutoKillDamage   = 100,
        SekaratMinHP     = 20,
        MaxFiresPerSec   = 8,

        AutoAim       = true,
        AimFOV        = true,
        AimStrength   = "Smooth",
        AimPriority   = "Nearest",
        AimPart       = "Head",
        AimSmoothness = 0.20,
        FOVRadius     = 30,
        AimEspDistance= 250,

        PlayerESP    = true,
        ESPShowNames = true,
        ESPShowHP    = true,
        ESPShowDist  = true,

        MedicEnabled     = false,
        MedicHPThreshold = 50,
        MedicBelowStuds  = 8,
        MedicTeleportWait= 0.5,
        MedicPositionMode= "Below",
        MedicHumanize    = true,

        PullTanks          = false,
        PullDistance       = 15,
        ArmorESP           = true,
        ArmorESPShowDist   = true,
        MaxArmorDistance   = 400,
    }

    ctx.opts = {
        NoRecoil     = ctx.CONFIG.NoRecoil,
        NoSpread     = ctx.CONFIG.NoSpread,
        NoCooldown   = ctx.CONFIG.NoCooldown,
        NoReload     = ctx.CONFIG.NoReload,
        OneHit       = ctx.CONFIG.OneHit,
        AutoKill     = ctx.CONFIG.AutoKill,
        SekaratMode  = ctx.CONFIG.SekaratMode,
        AutoAim      = ctx.CONFIG.AutoAim,
        AimFOV       = ctx.CONFIG.AimFOV,
        AimStrength  = ctx.CONFIG.AimStrength,
        AimPriority  = ctx.CONFIG.AimPriority,
        AimPart      = ctx.CONFIG.AimPart,
        PlayerESP    = ctx.CONFIG.PlayerESP,
        ESPShowNames = ctx.CONFIG.ESPShowNames,
        ESPShowHP    = ctx.CONFIG.ESPShowHP,
        ESPShowDist  = ctx.CONFIG.ESPShowDist,
        MedicEnabled = ctx.CONFIG.MedicEnabled,
        PullTanks    = ctx.CONFIG.PullTanks,
        ArmorESP     = ctx.CONFIG.ArmorESP,
        ArmorESPShowDist = ctx.CONFIG.ArmorESPShowDist,
    }

    ctx.autoKillCooldown  = ctx.CONFIG.AutoKillCooldown
    ctx.autoKillDamage    = ctx.CONFIG.AutoKillDamage
    ctx.minHP             = ctx.CONFIG.SekaratMinHP
    ctx.maxFiresPerSec    = ctx.CONFIG.MaxFiresPerSec
    ctx.aimEspDistance    = ctx.CONFIG.AimEspDistance
    ctx.fovRadius         = ctx.CONFIG.FOVRadius
    ctx.aimSmoothness     = ctx.CONFIG.AimSmoothness
    ctx.medicHPThreshold  = ctx.CONFIG.MedicHPThreshold
    ctx.medicBelowStuds   = ctx.CONFIG.MedicBelowStuds
    ctx.medicTeleportWait = ctx.CONFIG.MedicTeleportWait
    ctx.medicPositionMode = ctx.CONFIG.MedicPositionMode
    ctx.medicHumanize     = ctx.CONFIG.MedicHumanize
    ctx.targetMode        = ctx.CONFIG.TargetMode
    ctx.pullDistance      = ctx.CONFIG.PullDistance

    ctx.T_COMBAT   = ctx.CONFIG.Tabs[1] or "Combat"
    ctx.T_AUTOKILL = ctx.CONFIG.Tabs[2] or "AutoKill"
    ctx.T_AIM      = ctx.CONFIG.Tabs[3] or "Aim"
    ctx.T_ESP      = ctx.CONFIG.Tabs[4] or "ESP"
    ctx.T_MEDIC    = ctx.CONFIG.Tabs[5] or "Medic"
    ctx.T_DISPLAY  = ctx.CONFIG.Tabs[6] or "Display"
    ctx.tabNames   = { ctx.T_COMBAT, ctx.T_AUTOKILL, ctx.T_AIM, ctx.T_ESP, ctx.T_MEDIC, ctx.T_DISPLAY }
end
return M
end)()

__modules['state'] = (function()
-- purpose: mutable runtime state shared across modules
local M = {}
function M.setup(ctx)
    ctx.lastTargeted = nil
    ctx.lockedTarget = nil
    ctx.currentTarget = nil
    ctx.lastKill = 0
    ctx.originals = {}
    ctx.pending = {}
    ctx.failCounts = {}
    ctx.blacklist = {}
    ctx.INSTANT_FIRERATE = 100000
    ctx.PENDING_TIMEOUT = 4.0
    ctx.FAIL_THRESHOLD = 3
    ctx.BLACKLIST_DURATION = 30
    ctx.STATUS = "Idle"

    ctx.fireTimes = { Bullet = {}, Damager = {} }

    ctx.armorCache = {}
    ctx.armorLastScan = 0
    ctx.armorLastShot = 0

    ctx.playerESPObjects = {}

    ctx.fovCircle = nil

    ctx.medicState = "IDLE"
    ctx.medicQueue = {}
    ctx.medicCurrentPatient = nil
    ctx.medicSavedCFrame = nil
    ctx.medicStateStart = 0
    ctx.medicLastScan = 0
    ctx.medicInitialPatientHP = 0
end
return M
end)()

__modules['autosave'] = (function()
-- purpose: persist user settings to executor file and auto-load them on execute
local M = {}
function M.setup(ctx)
    local PATH = "centaura_config.json"
    local HttpService = game:GetService("HttpService")
    local canFS = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
    ctx.CONFIG_PATH = PATH

    local SCALARS = {
        "autoKillCooldown", "autoKillDamage", "minHP", "maxFiresPerSec",
        "aimEspDistance", "fovRadius", "aimSmoothness",
        "medicHPThreshold", "medicBelowStuds", "medicTeleportWait",
        "medicPositionMode", "medicHumanize", "targetMode", "pullDistance",
    }
    local MIRROR = {
        autoKillCooldown = "AutoKillCooldown",
        autoKillDamage = "AutoKillDamage",
        minHP = "SekaratMinHP",
        maxFiresPerSec = "MaxFiresPerSec",
        aimEspDistance = "AimEspDistance",
        fovRadius = "FOVRadius",
        aimSmoothness = "AimSmoothness",
        medicHPThreshold = "MedicHPThreshold",
        medicBelowStuds = "MedicBelowStuds",
        medicTeleportWait = "MedicTeleportWait",
        medicPositionMode = "MedicPositionMode",
        medicHumanize = "MedicHumanize",
        targetMode = "TargetMode",
        pullDistance = "PullDistance",
    }

    local dirty = false

    local function syncOpts()
        for k, v in pairs(ctx.opts) do
            if ctx.CONFIG[k] ~= nil then ctx.opts[k] = ctx.CONFIG[k] end
        end
    end

    ctx.saveConfig = function()
        if not canFS then return false end
        local data = { CONFIG = ctx.CONFIG, opts = ctx.opts, scalars = {} }
        for _, k in ipairs(SCALARS) do data.scalars[k] = ctx[k] end
        local ok, raw = pcall(function() return HttpService:JSONEncode(data) end)
        if not ok then return false end
        return pcall(writefile, PATH, raw)
    end

    ctx.loadConfig = function()
        if not canFS then return false end
        local okFile, exists = pcall(isfile, PATH)
        if not okFile or not exists then return false end
        local okRead, raw = pcall(readfile, PATH)
        if not okRead or type(raw) ~= "string" or raw == "" then return false end
        local okDec, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not okDec or type(data) ~= "table" then return false end

        if type(data.CONFIG) == "table" then
            for k, v in pairs(data.CONFIG) do
                if ctx.CONFIG[k] ~= nil then ctx.CONFIG[k] = v end
            end
        end
        if type(data.opts) == "table" then
            for k, v in pairs(data.opts) do
                if ctx.opts[k] ~= nil then
                    ctx.opts[k] = v
                    if ctx.CONFIG[k] ~= nil then ctx.CONFIG[k] = v end
                end
            end
        end
        if type(data.scalars) == "table" then
            for _, k in ipairs(SCALARS) do
                local v = data.scalars[k]
                if v ~= nil then
                    ctx[k] = v
                    local ck = MIRROR[k]
                    if ck and ctx.CONFIG[ck] ~= nil then ctx.CONFIG[ck] = v end
                end
            end
        end
        syncOpts()
        return true
    end

    ctx.requestSave = function()
        dirty = true
    end

    pcall(ctx.loadConfig)

    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(1)
            if dirty then
                dirty = false
                pcall(ctx.saveConfig)
            end
        end
    end)
end
return M
end)()

__modules['rate'] = (function()
-- purpose: fire-rate tracking and gating for remotes
local M = {}
function M.setup(ctx)
    ctx.getRate = function(r)
        local t = ctx.fireTimes[r]
        if not t then return 0 end
        local n = 0
        local now = tick()
        for _, v in ipairs(t) do
            if now - v <= 1 then n = n + 1 end
        end
        return n
    end
    ctx.recordFire = function(r)
        local t = ctx.fireTimes[r]
        if not t then t = {}; ctx.fireTimes[r] = t end
        table.insert(t, tick())
        local now = tick()
        local i = 1
        while i <= #t do
            if now - t[i] > 2 then table.remove(t, i) else i = i + 1 end
        end
    end
    ctx.canFire = function()
        return ctx.getRate("Bullet") < ctx.maxFiresPerSec and ctx.getRate("Damager") < ctx.maxFiresPerSec
    end
end
return M
end)()

__modules['armor_detect'] = (function()
-- purpose: enemy armor/vehicle model detection (humans and tank-like machines)
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local TeamsSvc = ctx.TeamsSvc
    local workspace = ctx.workspace

    ctx.matchTeamByPrefix = function(nameLower)
        for _, team in ipairs(TeamsSvc:GetTeams()) do
            local full = team.Name:lower()
            local p3 = full:sub(1, math.min(3, #full))
            if #full >= 3 and nameLower:sub(1, #full) == full then return team end
            if #p3 == 3 and nameLower:sub(1, 3) == p3 then return team end
        end
        return nil
    end

    ctx.looksLikeVehicle = function(name)
        local n = name:lower()
        for _, kw in ipairs({ "gun", "turret", "tank", "vehicle", "machinegun", "mg",
            "artillery", "cannon", "apc", "halftrack", "jeep", "truck", "plane",
            "fighter", "bomber", "walker", "mech", "brownie", "destroyer" }) do
            if n:find(kw) then return true end
        end
        return false
    end

    ctx.isEnemyOwner = function(model)
        local tv = model:FindFirstChild("Team")
        if tv and tv:IsA("ObjectValue") and tv.Value then
            return tv.Value ~= LP.Team
        end
        local cr = model:FindFirstChild("Creator")
        if cr and cr:IsA("ObjectValue") then
            local pl = cr.Value
            if pl and pl:IsA("Player") then
                if pl.Team then return pl.Team ~= LP.Team end
                return false
            end
        end
        for _, team in ipairs(TeamsSvc:GetTeams()) do
            local bv = model:FindFirstChild(team.Name)
            if bv and bv:IsA("BoolValue") then
                return (team ~= LP.Team) == bv.Value
            end
        end
        local n = model.Name:lower()
        local matched = ctx.matchTeamByPrefix(n)
        if matched then return matched ~= LP.Team end
        local p = model.Parent
        local depth = 0
        while p and p ~= workspace and depth < 3 do
            local pm = ctx.matchTeamByPrefix(p.Name:lower())
            if pm then return pm ~= LP.Team end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end

    ctx.isEnemyEntity = function(model)
        if not model or not LP.Team then return false end
        if model:FindFirstAncestorOfClass("Player") then return false end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health <= 0 then return false end
            if hum.Team then return hum.Team ~= LP.Team end
        end
        return ctx.isEnemyOwner(model)
    end

    ctx.isEnemyModel = ctx.isEnemyEntity

    ctx.scanEnemyArmor = function()
        local list, seen = {}, {}
        local playerChars = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then playerChars[p.Character] = true end
        end

        local function add(model)
            if not model or seen[model] or playerChars[model] then return end
            seen[model] = true
            if ctx.isEnemyEntity(model) then list[#list + 1] = model end
        end

        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Humanoid") and d.Health > 0 then
                local model = d.Parent
                if model and model:IsA("Model") then
                    local hasArmor = model:FindFirstChild("BrowPlate") ~= nil
                    if not hasArmor then
                        for _, p in ipairs(model:GetDescendants()) do
                            if p:IsA("BasePart") and p:GetAttribute("Armored") then
                                hasArmor = true
                                break
                            end
                        end
                    end
                    if hasArmor or ctx.looksLikeVehicle(model.Name) then add(model) end
                end
            elseif d:IsA("BasePart") then
                if d:GetAttribute("Armored") or d.Name == "Plate" then
                    add(d:FindFirstAncestorOfClass("Model"))
                end
            elseif d:IsA("Model") and ctx.looksLikeVehicle(d.Name) then
                add(d)
            end
        end
        return list
    end
end
return M
end)()

__modules['autopull tank'] = (function()
-- purpose: client-side tank pulling + wreck cleanup (replaces auto damage tank)
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local workspace = ctx.workspace

    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    -- vehicle reference used by vehicle ESP
    local function vehicleRef(veh)
        local hull = veh and veh:FindFirstChild("HullModel")
        if hull then
            return hull.PrimaryPart or hull:FindFirstChildOfClass("BasePart")
        end
        return veh and (veh.PrimaryPart or veh:FindFirstChildOfClass("BasePart"))
    end
    ctx.vehicleRef = vehicleRef

    ctx.scanEnemyArmor = function()
        local list = {}
        local root = vehiclesRoot()
        if not root then return list end
        for _, child in ipairs(root:GetChildren()) do
            local veh = child:FindFirstChild("Vehicle")
            if veh then list[#list + 1] = veh end
        end
        return list
    end
    ctx.scanVehicles = ctx.scanEnemyArmor

    local function isTankDestroyed(vehicleModel, vehicle)
        local hpVal = vehicle:FindFirstChild("Health") or vehicle:FindFirstChild("HP") or vehicleModel:FindFirstChild("Health")
        if hpVal and hpVal:IsA("ValueBase") and hpVal.Value <= 0 then return true end

        local hpAttr = vehicle:GetAttribute("Health")
        if hpAttr and hpAttr <= 0 then return true end
        if vehicle:GetAttribute("Destroyed") or vehicleModel:GetAttribute("Destroyed") then return true end

        local hum = vehicle:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health <= 0 then return true end

        local n = string.lower(vehicleModel.Name)
        if string.find(n, "wreck") or string.find(n, "destroyed") then return true end

        local fire = vehicle:FindFirstChildWhichIsA("Fire", true) or vehicle:FindFirstChildWhichIsA("Smoke", true)
        if fire then return true end

        return false
    end

    local function isFriendlyVehicle(vehicleModel, vehicle)
        local myTeam = LP.Team
        if not myTeam then return false end
        if string.find(string.lower(vehicleModel.Name), string.lower(myTeam.Name)) then return true end

        local seat = vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        if seat and seat.Occupant then
            local driver = ctx.Players:GetPlayerFromCharacter(seat.Occupant.Parent)
            if driver and driver.Team == myTeam then return true end
        end
        return false
    end

    -- Pulls enemy tanks to the player; destroyed tanks are dropped far below.
    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.2)
            ctx.armorCache = ctx.scanEnemyArmor()
            if ctx.opts.PullTanks then
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local root = vehiclesRoot()
                if hrp and root then
                    local pullDist = ctx.pullDistance or 15
                    for _, vehicleModel in ipairs(root:GetChildren()) do
                        local vehicle = vehicleModel:FindFirstChild("Vehicle")
                        if vehicle and not isFriendlyVehicle(vehicleModel, vehicle) then
                            if isTankDestroyed(vehicleModel, vehicle) then
                                pcall(function()
                                    local pos = vehicle:GetPivot()
                                    if pos.Y > -500 then
                                        vehicle:PivotTo(pos * CFrame.new(0, -500, 0))
                                        for _, part in ipairs(vehicle:GetDescendants()) do
                                            if part:IsA("BasePart") then part.Anchored = true end
                                        end
                                    end
                                end)
                            else
                                local dist = (hrp.Position - vehicle:GetPivot().Position).Magnitude
                                if dist > 20 then
                                    local targetPos = hrp.CFrame * CFrame.new(0, 0, -pullDist)
                                    pcall(function()
                                        vehicle:PivotTo(targetPos)
                                        for _, part in ipairs(vehicle:GetDescendants()) do
                                            if part:IsA("BasePart") then part.Anchored = true end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
return M
end)()

__modules['esp'] = (function()
-- purpose: player ESP drawings and FOV circle
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local Cam = ctx.Cam
    local opts = ctx.opts

    ctx.playerESPObjects = ctx.playerESPObjects or {}
    local playerESPObjects = ctx.playerESPObjects

    ctx.clearPlayerESP = function()
        for _, obj in pairs(playerESPObjects) do
            for _, d in pairs(obj) do pcall(function() d:Remove() end) end
        end
        for k in pairs(playerESPObjects) do playerESPObjects[k] = nil end
    end

    ctx.vehicleESPObjects = ctx.vehicleESPObjects or {}
    local vehicleESPObjects = ctx.vehicleESPObjects

    ctx.clearVehicleESP = function()
        for _, obj in pairs(vehicleESPObjects) do
            for _, d in pairs(obj) do pcall(function() d:Remove() end) end
        end
        for k in pairs(vehicleESPObjects) do vehicleESPObjects[k] = nil end
    end

    ctx.updateVehicleESP = function()
        if not opts.ArmorESP then ctx.clearVehicleESP(); return end
        local seen = {}
        for _, m in ipairs(ctx.armorCache or {}) do
            if m.Parent then
                local ref = m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
                if ref then
                    local pos, onScreen = Cam:WorldToViewportPoint(ref.Position)
                    local dist = (Cam.CFrame.Position - ref.Position).Magnitude
                    if onScreen and dist <= ctx.CONFIG.MaxArmorDistance then
                        seen[m] = true
                        if not vehicleESPObjects[m] then
                            local ok, txt, dtxt = pcall(function()
                                local a = Drawing.new("Text"); a.Size = 14; a.Color = Color3.fromRGB(255, 170, 60); a.Center = true; a.Outline = true
                                local b = Drawing.new("Text"); b.Size = 12; b.Color = Color3.fromRGB(255, 220, 120); b.Center = true; b.Outline = true
                                return a, b
                            end)
                            if ok then vehicleESPObjects[m] = { name = txt, dist = dtxt } end
                        end
                        local obj = vehicleESPObjects[m]
                        if obj then
                            obj.name.Text = "[ARMOR] " .. m.Name
                            obj.name.Position = Vector2.new(pos.X, pos.Y - 14)
                            obj.name.Visible = true
                            if opts.ArmorESPShowDist then
                                obj.dist.Text = math.floor(dist) .. "m"
                                obj.dist.Position = Vector2.new(pos.X, pos.Y)
                                obj.dist.Visible = true
                            else obj.dist.Visible = false end
                        end
                    end
                end
            end
        end
        for m, obj in pairs(vehicleESPObjects) do
            if not seen[m] then
                for _, d in pairs(obj) do pcall(function() d:Remove() end) end
                vehicleESPObjects[m] = nil
            end
        end
    end

    ctx.updatePlayerESP = function()
        if not opts.PlayerESP then ctx.clearPlayerESP(); return end
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and ctx.isEnemy(plr) then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local headPos, onScreen = Cam:WorldToViewportPoint(head.Position)
                    local dist = (Cam.CFrame.Position - head.Position).Magnitude
                    if onScreen and dist <= ctx.aimEspDistance then
                        seen[plr] = true
                        if not playerESPObjects[plr] then
                            local okD, n, h, d = pcall(function()
                                local a = Drawing.new("Text"); a.Size = 16; a.Color = Color3.fromRGB(255, 255, 0); a.Center = true; a.Outline = true
                                local b = Drawing.new("Text"); b.Size = 14; b.Color = Color3.fromRGB(0, 255, 0); b.Center = true; b.Outline = true
                                local c = Drawing.new("Text"); c.Size = 14; c.Color = Color3.fromRGB(0, 180, 255); c.Center = true; c.Outline = true
                                return a, b, c
                            end)
                            if okD then playerESPObjects[plr] = { name = n, hp = h, dist = d } end
                        end
                        local obj = playerESPObjects[plr]
                        if obj then
                            if opts.ESPShowNames then
                                obj.name.Text = plr.Name
                                obj.name.Position = Vector2.new(headPos.X, headPos.Y - 32)
                                obj.name.Visible = true
                            else obj.name.Visible = false end
                            if opts.ESPShowHP then
                                obj.hp.Text = "HP: " .. math.floor(hum.Health)
                                obj.hp.Position = Vector2.new(headPos.X, headPos.Y - 14)
                                obj.hp.Visible = true
                            else obj.hp.Visible = false end
                            if opts.ESPShowDist then
                                obj.dist.Text = math.floor(dist) .. "m"
                                obj.dist.Position = Vector2.new(headPos.X, headPos.Y + 5)
                                obj.dist.Visible = true
                            else obj.dist.Visible = false end
                        end
                    end
                end
            end
        end
        for plr, obj in pairs(playerESPObjects) do
            if not seen[plr] then
                for _, d in pairs(obj) do pcall(function() d:Remove() end) end
                playerESPObjects[plr] = nil
            end
        end
    end

    ctx.fovCircle = nil
    pcall(function()
        ctx.fovCircle = Drawing.new("Circle")
        ctx.fovCircle.Visible = true
        ctx.fovCircle.Radius = ctx.fovRadius
        ctx.fovCircle.Color = Color3.fromRGB(255, 255, 255)
        ctx.fovCircle.Thickness = 1
        ctx.fovCircle.Transparency = 1
        ctx.fovCircle.Filled = false
    end)
end
return M
end)()

__modules['esp_vehicle'] = (function()
-- purpose: vehicle ESP (BillboardGui name + distance, Highlight) for workspace.Map.Map.Vehicles
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local workspace = ctx.workspace

    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    ctx.vehicleESP = {}

    ctx.clearVehicleESP = function()
        for veh, obj in pairs(ctx.vehicleESP) do
            if obj.hl then pcall(function() obj.hl:Destroy() end) end
            if obj.gui then pcall(function() obj.gui:Destroy() end) end
            ctx.vehicleESP[veh] = nil
        end
    end

    -- Replaces the old Drawing-based vehicle ESP from esp.lua.
    ctx.updateVehicleESP = function()
        if not ctx.opts.ArmorESP then ctx.clearVehicleESP(); return end
        local root = vehiclesRoot()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local my = hrp and hrp.Position
        local seen = {}

        if root and my then
            for _, child in ipairs(root:GetChildren()) do
                local veh = child:FindFirstChild("Vehicle")
                local ref = veh and ctx.vehicleRef and ctx.vehicleRef(veh)
                if ref and ref.Parent then
                    local dist = (ref.Position - my).Magnitude
                    if dist <= ctx.CONFIG.MaxArmorDistance then
                        seen[veh] = true
                        local obj = ctx.vehicleESP[veh]
                        if not obj then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = veh:IsA("Model") and veh or ref
                            hl.FillColor = Color3.fromRGB(255, 170, 60)
                            hl.FillTransparency = 0.75
                            hl.OutlineColor = Color3.fromRGB(255, 220, 120)
                            hl.Parent = ref

                            local gui = Instance.new("BillboardGui")
                            gui.Adornee = ref
                            gui.Size = UDim2.new(0, 220, 0, 36)
                            gui.StudsOffset = Vector3.new(0, 3, 0)
                            gui.AlwaysOnTop = true
                            gui.Parent = ref

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 220, 120)
                            label.TextSize = 14
                            label.Font = Enum.Font.GothamBold
                            label.TextStrokeTransparency = 0.2
                            label.Parent = gui

                            obj = { hl = hl, gui = gui, label = label }
                            ctx.vehicleESP[veh] = obj
                        end
                        local name = (veh.Parent and veh.Parent.Name) or veh.Name
                        if ctx.opts.ArmorESPShowDist then
                            obj.label.Text = string.format("%s  [%dm]", name, math.floor(dist))
                        else
                            obj.label.Text = name
                        end
                    end
                end
            end
        end

        for veh, obj in pairs(ctx.vehicleESP) do
            if not seen[veh] or not veh.Parent then
                if obj.hl then pcall(function() obj.hl:Destroy() end) end
                if obj.gui then pcall(function() obj.gui:Destroy() end) end
                ctx.vehicleESP[veh] = nil
            end
        end
    end

    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.2)
            pcall(ctx.updateVehicleESP)
        end
    end)
end
return M
end)()

__modules['aim'] = (function()
-- purpose: aim target selection and camera application
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local Cam = ctx.Cam
    local opts = ctx.opts

    ctx.getTargetPart = function(plr)
        local c = plr.Character
        if not c then return nil end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        if opts.AimPart == "Head" then return c:FindFirstChild("Head") end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    end

    ctx.getBestAimEnemy = function()
        local best, bestDist, bestHP = nil, math.huge, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and ctx.isEnemy(plr) then
                local part = ctx.getTargetPart(plr)
                if part then
                    local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                    local dist = (Cam.CFrame.Position - part.Position).Magnitude
                    if onScreen and dist <= ctx.aimEspDistance then
                        local allowed = true
                        if opts.AimFOV and ctx.fovCircle then
                            local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                            allowed = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude <= ctx.fovRadius
                        end
                        if allowed then
                            local ray = Ray.new(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * dist)
                            local hit = workspace:FindPartOnRay(ray, LP.Character, false, true)
                            if hit and hit:IsDescendantOf(plr.Character) then
                                if opts.AimPriority == "Nearest" then
                                    if dist < bestDist then bestDist = dist; best = plr end
                                else
                                    local hp = plr.Character:FindFirstChildOfClass("Humanoid")
                                    hp = hp and hp.Health or math.huge
                                    if hp < bestHP or (hp == bestHP and dist < bestDist) then
                                        bestHP = hp
                                        bestDist = dist
                                        best = plr
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    ctx.applyAimAt = function(targetPos)
        local cur = Cam.CFrame
        local tgt = CFrame.new(cur.Position, targetPos)
        if opts.AimStrength == "Strong" then
            Cam.CFrame = tgt
        elseif opts.AimStrength == "Medium" then
            Cam.CFrame = cur:Lerp(tgt, 0.5)
        else
            Cam.CFrame = cur:Lerp(tgt, ctx.aimSmoothness)
        end
    end
end
return M
end)()

__modules['medic_core'] = (function()
-- purpose: medic helper functions
local M = {}
function M.setup(ctx)
    local LP = ctx.LP

    ctx.getHP = function(plr)
        local c = plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return h.Health, (h.MaxHealth > 0 and h.MaxHealth or 100) end
        return nil, nil
    end

    ctx.getMyHRP = function()
        local c = LP.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    ctx.isBandageReady = function()
        local c = LP.Character
        if not c then return false end
        local t = c:FindFirstChild("BANDAGES")
        if not t then return false end
        if not t.Enabled then return false end
        if t:FindFirstChild("Cooldown") or t:FindFirstChild("Effect") then return false end
        return true
    end

    ctx.useBandage = function()
        local c = LP.Character
        if not c then return end
        local t = c:FindFirstChild("BANDAGES")
        if not t then return end
        local heal = t:FindFirstChild("Heal")
        if heal then
            pcall(function()
                local inRange = {}
                local myPos = c.PrimaryPart and c.PrimaryPart.Position or c:GetPivot().Position
                for _, p in pairs(LP.Team:GetPlayers()) do
                    if p.Character and p.Character.PrimaryPart and p ~= LP then
                        if (p.Character.PrimaryPart.Position - myPos).Magnitude <= 20 then
                            table.insert(inRange, p)
                        end
                    end
                end
                if #inRange > 0 then heal:FireServer(inRange) end
            end)
        end
        pcall(function() t:Activate() end)
    end

    ctx.medicSaveLocation = function()
        local hrp = ctx.getMyHRP()
        if hrp then ctx.medicSavedCFrame = hrp.CFrame; return true end
        return false
    end

    ctx.medicTeleportTo = function(patient)
        local hrp = ctx.getMyHRP()
        if not hrp then return end
        local pHRP = patient.Character and patient.Character:FindFirstChild("HumanoidRootPart")
        if not pHRP then return end
        local target
        if ctx.medicPositionMode == "Below" then
            target = pHRP.Position - Vector3.new(0, ctx.medicBelowStuds, 0)
        else
            target = pHRP.Position
        end
        if ctx.medicHumanize then
            target = target + Vector3.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
        end
        hrp.CFrame = CFrame.new(target, target + hrp.CFrame.LookVector)
    end

    ctx.medicReturn = function()
        local hrp = ctx.getMyHRP()
        if not hrp or not ctx.medicSavedCFrame then return end
        local target = ctx.medicSavedCFrame
        if ctx.medicHumanize then
            target = target * CFrame.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
        end
        hrp.CFrame = target
    end
end
return M
end)()

__modules['medic_loop'] = (function()
-- purpose: medic state machine update
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP

    ctx.updateMedic = function(now)
        if not ctx.opts.MedicEnabled then ctx.medicState = "IDLE"; return end
        if now - ctx.medicLastScan > 0.2 then
            ctx.medicLastScan = now
            for i = #ctx.medicQueue, 1, -1 do
                local hp, max = ctx.getHP(ctx.medicQueue[i])
                if not ctx.medicQueue[i].Parent or not hp or (hp / max) >= ctx.medicHPThreshold / 100 then
                    table.remove(ctx.medicQueue, i)
                end
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if ctx.isTeammate(p) then
                    local hp, max = ctx.getHP(p)
                    if hp and (hp / max) < ctx.medicHPThreshold / 100 and not table.find(ctx.medicQueue, p) then
                        table.insert(ctx.medicQueue, p)
                    end
                end
            end
        end
        if ctx.medicState == "IDLE" then
            if #ctx.medicQueue > 0 and ctx.medicSavedCFrame then
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local tool = char and char:FindFirstChild("BANDAGES")
                if not tool and hum then
                    local bpTool = LP.Backpack:FindFirstChild("BANDAGES")
                    if bpTool then pcall(function() hum:EquipTool(bpTool) end) end
                end
                if ctx.isBandageReady() then
                    ctx.medicCurrentPatient = ctx.medicQueue[1]
                    ctx.medicState = "PRE_TELEPORT"
                    ctx.medicStateStart = now
                end
            end
        elseif ctx.medicState == "PRE_TELEPORT" then
            if not ctx.medicCurrentPatient.Parent or not ctx.medicCurrentPatient.Character then
                ctx.medicState = "RETURN"
                return
            end
            if now - ctx.medicStateStart >= 0.2 then
                ctx.medicTeleportTo(ctx.medicCurrentPatient)
                ctx.medicState = "WAIT_PATIENT"
                ctx.medicStateStart = now
            end
        elseif ctx.medicState == "WAIT_PATIENT" then
            local hp, max = ctx.getHP(ctx.medicCurrentPatient)
            if not ctx.medicCurrentPatient.Parent or not hp then
                ctx.medicState = "RETURN"
                return
            end
            ctx.medicTeleportTo(ctx.medicCurrentPatient)
            if now - ctx.medicStateStart >= ctx.medicTeleportWait then
                ctx.medicInitialPatientHP = hp
                ctx.useBandage()
                ctx.medicState = "WAIT_HEAL"
                ctx.medicStateStart = now
            end
        elseif ctx.medicState == "WAIT_HEAL" then
            local hp, max = ctx.getHP(ctx.medicCurrentPatient)
            if not ctx.medicCurrentPatient.Parent or not hp then
                ctx.medicState = "RETURN"
                return
            end
            ctx.medicTeleportTo(ctx.medicCurrentPatient)
            if hp > ctx.medicInitialPatientHP or now - ctx.medicStateStart > 3 then
                ctx.medicState = "RETURN"
            end
        elseif ctx.medicState == "RETURN" then
            ctx.medicReturn()
            ctx.medicCurrentPatient = nil
            ctx.medicState = "IDLE"
        end
    end
end
return M
end)()

__modules['combat'] = (function()
-- purpose: weapon module stat apply/reapply and reequip
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local GS = ctx.GS
    local opts = ctx.opts
    local originals = ctx.originals

    ctx.apply = function()
        if not GS then return 0 end
        local hit = 0
        for _, inst in ipairs(GS:GetDescendants()) do
            if inst:IsA("ModuleScript") then
                local okR, s = pcall(require, inst)
                if okR and type(s) == "table" then
                    if not originals[inst] then
                        originals[inst] = {
                            Recoil = s.Recoil, MinDamage = s.MinDamage, MaxDamage = s.MaxDamage,
                            HeadshotMultiplier = s.HeadshotMultiplier, LimbMultiplier = s.LimbMultiplier,
                            AmmoCount = s.AmmoCount, ChargeSpeed = s.ChargeSpeed, ReloadSpeed = s.ReloadSpeed,
                            spread = s.spread, minimumSpread = s.minimumSpread, firerate = s.firerate,
                        }
                    end
                    local o = originals[inst]
                    local function ss(k, v)
                        if rawget(s, k) ~= nil then pcall(function() s[k] = v end) end
                    end
                    ss("Recoil", opts.NoRecoil and 0 or o.Recoil)
                    ss("MinDamage", opts.OneHit and 999999 or o.MinDamage)
                    ss("MaxDamage", opts.OneHit and 999999 or o.MaxDamage)
                    ss("HeadshotMultiplier", opts.OneHit and 1 or o.HeadshotMultiplier)
                    ss("LimbMultiplier", opts.OneHit and 1 or o.LimbMultiplier)
                    ss("spread", opts.NoSpread and 0 or o.spread)
                    ss("minimumSpread", opts.NoSpread and 0 or o.minimumSpread)
                    ss("firerate", opts.NoCooldown and ctx.INSTANT_FIRERATE or o.firerate)
                    ss("ChargeSpeed", opts.NoReload and 0.001 or o.ChargeSpeed)
                    ss("ReloadSpeed", opts.NoReload and 0.001 or o.ReloadSpeed)
                    ss("AmmoCount", opts.NoReload and 9999 or o.AmmoCount)
                    hit = hit + 1
                end
            end
        end
        return hit
    end

    ctx.reequip = function()
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        local t = c:FindFirstChildOfClass("Tool")
        if h and t then
            task.spawn(function()
                pcall(function() h:UnequipTools() end)
                task.wait(0.12)
                pcall(function() h:EquipTool(t) end)
            end)
        end
    end
end
return M
end)()

__modules['targeting_scan'] = (function()
-- purpose: enemy scanning and target selection
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP

    ctx.inLobby = function(plr)
        local c = plr.Character
        if not c then return true, "nochar" end
        if not c:IsDescendantOf(ctx.workspace) then return true, "notws" end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return true, "noHRP" end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return true, "dead" end
        if c:FindFirstChildOfClass("ForceField") then return true, "ff" end
        return false, nil
    end

    ctx.isBL = function(uid)
        local b = ctx.blacklist[uid]
        if b and tick() < b then return true end
        if b then ctx.blacklist[uid] = nil end
        return false
    end

    ctx.recordFail = function(uid)
        ctx.failCounts[uid] = (ctx.failCounts[uid] or 0) + 1
        if ctx.failCounts[uid] >= ctx.FAIL_THRESHOLD then
            ctx.blacklist[uid] = tick() + ctx.BLACKLIST_DURATION
            ctx.failCounts[uid] = 0
        end
    end

    ctx.scanEnemies = function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if ctx.isEnemy(p) and not ctx.isBL(p.UserId) then
                if not ctx.inLobby(p) then
                    local c = p.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        if not (ctx.opts.SekaratMode and h.Health <= ctx.minHP) then
                            list[#list + 1] = p
                        end
                    end
                end
            end
        end
        return list
    end

    ctx.nearestTarget = function()
        local hrp = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
        if not hrp then return nil end
        local my = hrp.Position
        local best, bd = nil, math.huge
        for _, p in ipairs(ctx.scanEnemies()) do
            local e = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if e then
                local d = (e.Position - my).Magnitude
                if d < bd then best, bd = p, d end
            end
        end
        return best
    end

    ctx.queueTarget = function()
        local es = ctx.scanEnemies()
        if #es == 0 then return nil end
        table.sort(es, function(a, b) return a.UserId < b.UserId end)
        if ctx.lastTargeted then
            for _, p in ipairs(es) do
                if p.UserId > ctx.lastTargeted.UserId then return p end
            end
        end
        return es[1]
    end

    ctx.getTarget = function()
        if ctx.targetMode == "Nearest" then return ctx.nearestTarget() end
        if ctx.lockedTarget then
            local c = ctx.lockedTarget.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and not ctx.isBL(ctx.lockedTarget.UserId)
               and not (ctx.opts.SekaratMode and h.Health <= ctx.minHP)
               and not ctx.inLobby(ctx.lockedTarget) then
                return ctx.lockedTarget
            end
            ctx.lastTargeted = ctx.lockedTarget
            ctx.lockedTarget = nil
        end
        local nx = ctx.queueTarget()
        ctx.lockedTarget = nx
        return nx
    end
end
return M
end)()

__modules['targeting_kill'] = (function()
-- purpose: gun info, pending checks, kill execution
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local GS = ctx.GS

    ctx.gunInfo = function()
        local c = LP.Character
        if not c then return nil end
        local t = c:FindFirstChildOfClass("Tool")
        if not t then return nil end
        local gs = t:FindFirstChild("Gun")
        if not gs then return nil end
        local br = t:FindFirstChild("Barrel")
        if not br then return nil end
        local gsT
        pcall(function() if GS then gsT = require(GS[t.Name]) end end)
        local color = Color3.new(1, 0, 0)
        if gsT then
            if gsT.useTeam and LP.Team then color = LP.TeamColor.Color
            elseif gsT.customColor then color = gsT.customColor end
        end
        return { gunScript = gs, barrel = br, settings = gsT, color = color }
    end

    ctx.checkPending = function(uid, hp, tc)
        local p = ctx.pending[uid]
        if not p then return "send" end
        if p.char ~= tc then ctx.pending[uid] = nil; return "send" end
        local expected = p.startHP - p.totalSent
        local elapsed = tick() - p.sentAt
        if hp <= expected + 0.5 then
            ctx.pending[uid] = nil
            ctx.failCounts[uid] = 0
            return "send"
        end
        if elapsed > ctx.PENDING_TIMEOUT then
            ctx.pending[uid] = nil
            if hp < p.startHP - 0.5 then ctx.failCounts[uid] = 0 else ctx.recordFail(uid) end
            return "send"
        end
        return "wait"
    end

    ctx.doKill = function(target)
        if not target then return false end
        local tc = target.Character
        if not tc then return false end
        local th = tc:FindFirstChildOfClass("Humanoid")
        if not th or th.Health <= 0 then return false end
        local hp = th.Health
        local uid = target.UserId
        if not ctx.canFire() then
            ctx.STATUS = string.format("Rate %.1f/%d", ctx.getRate("Damager"), ctx.maxFiresPerSec)
            return false
        end
        if ctx.checkPending(uid, hp, tc) == "wait" then
            ctx.STATUS = "Wait " .. target.Name
            return false
        end
        local dmg = ctx.autoKillDamage
        if ctx.opts.SekaratMode then
            if hp <= ctx.minHP then return false end
            dmg = math.min(dmg, hp - ctx.minHP)
            if dmg <= 0 then return false end
        end
        dmg = math.floor(dmg)
        if dmg < 1 then dmg = 1 end
        local tgt = tc:FindFirstChild("Head") or tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso")
        if not tgt then return false end
        local info = ctx.gunInfo()
        if not info then return false end
        local p = ctx.pending[uid]
        if p and p.char == tc then
            p.totalSent = p.totalSent + dmg
            p.sentAt = tick()
        else
            ctx.pending[uid] = { startHP = hp, totalSent = dmg, sentAt = tick(), char = tc }
        end
        pcall(function() ctx.BR:FireServer(info.barrel.Position, tgt.Position, info.color, tgt, false) end)
        ctx.recordFire("Bullet")
        pcall(function() ctx.DR:FireServer(info.gunScript, info.barrel.Position, tc, dmg, tgt, "Bullet") end)
        ctx.recordFire("Damager")
        ctx.STATUS = string.format("%.0f→%s", dmg, target.Name)
        return true
    end
end
return M
end)()

__modules['leaderboard_ui'] = (function()
-- purpose: leaderboard window creation
local M = {}
function M.setup(ctx)
    local PG = ctx.PG

    ctx.lbGui = Instance.new("ScreenGui")
    ctx.lbGui.Name = "TREK_LB"
    ctx.lbGui.ResetOnSpawn = false
    ctx.lbGui.IgnoreGuiInset = true
    ctx.lbGui.DisplayOrder = 998
    ctx.lbGui.Parent = PG
    ctx.lbGui.Enabled = false

    ctx.lbMain = Instance.new("Frame")
    ctx.lbMain.Size = UDim2.new(0, 240, 0, 280)
    ctx.lbMain.Position = UDim2.new(0, 10, 0, 70)
    ctx.lbMain.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ctx.lbMain.BorderSizePixel = 0
    ctx.lbMain.Active = true
    ctx.lbMain.Parent = ctx.lbGui
    Instance.new("UICorner", ctx.lbMain).CornerRadius = UDim.new(0, 7)
    local lbStroke = Instance.new("UIStroke")
    lbStroke.Color = Color3.fromRGB(255, 200, 60)
    lbStroke.Thickness = 1.5
    lbStroke.Parent = ctx.lbMain
    ctx.lbTitleBar = Instance.new("Frame")
    ctx.lbTitleBar.Size = UDim2.new(1, 0, 0, 22)
    ctx.lbTitleBar.BackgroundTransparency = 1
    ctx.lbTitleBar.Parent = ctx.lbMain
    local lbTitle = Instance.new("TextLabel")
    lbTitle.Size = UDim2.new(1, -24, 1, 0)
    lbTitle.Position = UDim2.new(0, 6, 0, 0)
    lbTitle.BackgroundTransparency = 1
    lbTitle.Text = "Leaderboard"
    lbTitle.TextColor3 = Color3.fromRGB(255, 200, 60)
    lbTitle.TextSize = 11
    lbTitle.Font = Enum.Font.GothamBold
    lbTitle.TextXAlignment = Enum.TextXAlignment.Left
    lbTitle.Parent = ctx.lbTitleBar
    local lbX = Instance.new("TextButton")
    lbX.Size = UDim2.new(0, 18, 0, 18)
    lbX.Position = UDim2.new(1, -21, 0, 2)
    lbX.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
    lbX.Text = "X"
    lbX.TextColor3 = Color3.new(1, 1, 1)
    lbX.TextSize = 10
    lbX.Font = Enum.Font.GothamBold
    lbX.BorderSizePixel = 0
    lbX.Parent = ctx.lbTitleBar
    Instance.new("UICorner", lbX).CornerRadius = UDim.new(0, 3)
    lbX.Activated:Connect(function() ctx.lbGui.Enabled = false end)
    ctx.lbScroll = Instance.new("ScrollingFrame")
    ctx.lbScroll.Size = UDim2.new(1, -6, 1, -28)
    ctx.lbScroll.Position = UDim2.new(0, 3, 0, 24)
    ctx.lbScroll.BackgroundTransparency = 1
    ctx.lbScroll.BorderSizePixel = 0
    ctx.lbScroll.ScrollBarThickness = 4
    ctx.lbScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 60)
    ctx.lbScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ctx.lbScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ctx.lbScroll.Parent = ctx.lbMain
    local lbList = Instance.new("UIListLayout")
    lbList.Padding = UDim.new(0, 2)
    lbList.SortOrder = Enum.SortOrder.LayoutOrder
    lbList.Parent = ctx.lbScroll
end
return M
end)()

__modules['leaderboard_logic'] = (function()
-- purpose: leaderboard rebuild, drag, periodic refresh
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local UIS = ctx.UIS

    ctx.buildLB = function()
        for _, c in ipairs(ctx.lbScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local cols, colOrder = {}, {}
        for _, p in ipairs(Players:GetPlayers()) do
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("ValueBase") and not cols[v.Name] then
                        cols[v.Name] = true
                        colOrder[#colOrder + 1] = v.Name
                    end
                end
            end
        end
        if #colOrder == 0 then colOrder = { "Kills", "Deaths", "Score" } end
        local data = {}
        for _, p in ipairs(Players:GetPlayers()) do
            local s = {}
            local ls = p:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetChildren()) do
                    if v:IsA("ValueBase") then s[v.Name] = v.Value end
                end
            end
            data[#data + 1] = { plr = p, stats = s }
        end
        table.sort(data, function(a, b)
            local sa = a.stats.Score or a.stats.Kills or 0
            local sb = b.stats.Score or b.stats.Kills or 0
            if type(sa) == "number" and type(sb) == "number" and sa ~= sb then return sa > sb end
            return a.plr.Name < b.plr.Name
        end)
        local hdr = string.format("%-3s %-12s", "#", "Player")
        for _, c in ipairs(colOrder) do
            hdr = hdr .. string.format(" %4s", string.upper(string.sub(c, 1, 3)))
        end
        local hr = Instance.new("Frame")
        hr.Size = UDim2.new(1, 0, 0, 16)
        hr.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        hr.BorderSizePixel = 0
        hr.LayoutOrder = 0
        hr.Parent = ctx.lbScroll
        Instance.new("UICorner", hr).CornerRadius = UDim.new(0, 2)
        local hl = Instance.new("TextLabel")
        hl.Size = UDim2.new(1, -6, 1, 0)
        hl.Position = UDim2.new(0, 3, 0, 0)
        hl.BackgroundTransparency = 1
        hl.Text = hdr
        hl.TextColor3 = Color3.fromRGB(180, 180, 200)
        hl.TextSize = 9
        hl.Font = Enum.Font.Code
        hl.TextXAlignment = Enum.TextXAlignment.Left
        hl.Parent = hr
        for rank, e in ipairs(data) do
            if rank > 25 then break end
            local p = e.plr
            local isSelf = (p == LP)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 16)
            row.BorderSizePixel = 0
            row.LayoutOrder = rank
            row.BackgroundColor3 = isSelf and Color3.fromRGB(60, 50, 15) or (rank % 2 == 0 and Color3.fromRGB(25, 25, 38) or Color3.fromRGB(20, 20, 32))
            row.Parent = ctx.lbScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 2)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 5, 0, 5)
            dot.Position = UDim2.new(0, 3, 0.5, -2.5)
            dot.BorderSizePixel = 0
            dot.Parent = row
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            dot.BackgroundColor3 = p.Team and p.TeamColor.Color or Color3.fromRGB(120, 120, 140)
            local nm = p.Name
            if #nm > 12 then nm = nm:sub(1, 11) .. "…" end
            local txt = string.format("%-3d %-12s", rank, nm)
            for _, c in ipairs(colOrder) do
                local v = e.stats[c] or 0
                local sv
                if type(v) == "number" then
                    if v >= 1e6 then sv = string.format("%.1fM", v / 1e6)
                    elseif v >= 1e3 then sv = string.format("%.1fK", v / 1e3)
                    else sv = tostring(math.floor(v)) end
                else
                    sv = tostring(v):sub(1, 4)
                end
                txt = txt .. string.format(" %4s", sv)
            end
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = isSelf and Color3.fromRGB(255, 230, 100) or Color3.fromRGB(210, 210, 225)
            lbl.TextSize = 9
            lbl.Font = Enum.Font.Code
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row
        end
    end

    task.spawn(function()
        while ctx.lbGui.Parent do
            task.wait(1.5)
            if ctx.lbGui.Enabled then pcall(ctx.buildLB) end
        end
    end)

    do
        local d, s, sp = false, nil, nil
        ctx.lbTitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = true
                s = i.Position
                sp = ctx.lbMain.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                ctx.lbMain.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = false
            end
        end)
    end
end
return M
end)()

__modules['ui_window'] = (function()
-- purpose: main window, title bar, status bar, drag, floating toggle logo
local M = {}
function M.setup(ctx)
    local UIS = ctx.UIS
    local Cam = ctx.Cam
    local CONFIG = ctx.CONFIG

    local screenH = Cam.ViewportSize.Y
    local FRAME_W = 240
    local FRAME_H = math.clamp(screenH * 0.72, 400, 600)
    local TITLE_H, TABROW_H, STATUS_H = 24, 44, 40

    ctx.FRAME_W = FRAME_W
    ctx.FRAME_H = FRAME_H
    ctx.TITLE_H = TITLE_H
    ctx.TABROW_H = TABROW_H
    ctx.STATUS_H = STATUS_H

    ctx.gui = Instance.new("ScreenGui")
    ctx.gui.Name = "TREK_Combined"
    ctx.gui.ResetOnSpawn = false
    ctx.gui.IgnoreGuiInset = true
    ctx.gui.DisplayOrder = 999
    ctx.gui.Parent = ctx.PG

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
    main.Position = UDim2.new(1, -FRAME_W - 5, 0, 60)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = ctx.gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 160)
    stroke.Thickness = 1.5
    stroke.Parent = main
    ctx.main = main

    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, 0, 0, TITLE_H)
    tb.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    tb.BorderSizePixel = 0
    tb.Active = true
    tb.Parent = main
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 7)
    ctx.tb = tb

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -28, 1, 0)
    tl.Position = UDim2.new(0, 8, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = CONFIG.Title
    tl.TextColor3 = Color3.fromRGB(0, 220, 160)
    tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tb

    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0, 20, 0, 20)
    mBtn.Position = UDim2.new(1, -24, 0, 2)
    mBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mBtn.Text = "-"
    mBtn.TextColor3 = Color3.new(1, 1, 1)
    mBtn.TextSize = 14
    mBtn.Font = Enum.Font.GothamBold
    mBtn.BorderSizePixel = 0
    mBtn.AutoButtonColor = false
    mBtn.Parent = tb
    Instance.new("UICorner", mBtn).CornerRadius = UDim.new(0, 3)
    ctx.mBtn = mBtn

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -6, 0, STATUS_H)
    statusBar.Position = UDim2.new(0, 3, 1, -STATUS_H - 2)
    statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = main
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 4)
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -8, 1, -4)
    statusLbl.Position = UDim2.new(0, 4, 0, 2)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Booting..."
    statusLbl.TextColor3 = Color3.fromRGB(140, 220, 190)
    statusLbl.TextSize = 9
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.TextYAlignment = Enum.TextYAlignment.Top
    statusLbl.TextWrapped = true
    statusLbl.Parent = statusBar
    ctx.statusBar = statusBar
    ctx.statusLbl = statusLbl

    local minimized = false
    mBtn.Activated:Connect(function()
        minimized = not minimized
        main.Size = UDim2.new(0, FRAME_W, 0, minimized and TITLE_H or FRAME_H)
        if ctx.tabBar then ctx.tabBar.Visible = not minimized end
        if ctx.content then ctx.content.Visible = not minimized end
        statusBar.Visible = not minimized
        mBtn.Text = minimized and "+" or "-"
    end)

    do -- title bar drag
        local d, s, sp = false, nil, nil
        tb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = true
                s = i.Position
                sp = main.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d = false
            end
        end)
    end

    do -- floating logo at right-middle: drag to move, tap to show/hide the GUI
        local tog = Instance.new("TextButton")
        tog.Size = UDim2.new(0, 34, 0, 34)
        tog.Position = UDim2.new(1, -46, 0.5, -17)
        tog.BackgroundColor3 = Color3.fromRGB(0, 170, 130)
        tog.Text = "T"
        tog.TextColor3 = Color3.new(1, 1, 1)
        tog.TextSize = 16
        tog.Font = Enum.Font.GothamBlack
        tog.BorderSizePixel = 0
        tog.AutoButtonColor = false
        tog.Parent = ctx.gui
        Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)
        local tstroke = Instance.new("UIStroke")
        tstroke.Color = Color3.fromRGB(0, 255, 200)
        tstroke.Thickness = 1.5
        tstroke.Parent = tog
        ctx.togBtn = tog

        local d, s, sp, moved = false, nil, nil, false
        tog.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                d, moved = true, false
                s = i.Position
                sp = tog.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not d then return end
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
                local dd = i.Position - s
                if math.abs(dd.X) > 6 or math.abs(dd.Y) > 6 then moved = true end
                if moved then
                    tog.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dd.X, sp.Y.Scale, sp.Y.Offset + dd.Y)
                end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                if d and not moved then
                    main.Visible = not main.Visible
                    tog.BackgroundColor3 = main.Visible and Color3.fromRGB(0, 170, 130) or Color3.fromRGB(120, 120, 130)
                end
                d = false
            end
        end)
    end
end
return M
end)()

__modules['ui_tabs'] = (function()
-- purpose: tab bar and tab frames
local M = {}
function M.setup(ctx)
    local main = ctx.main
    local TITLE_H = ctx.TITLE_H
    local TABROW_H = ctx.TABROW_H
    local FRAME_H = ctx.FRAME_H
    local STATUS_H = ctx.STATUS_H

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -6, 0, TABROW_H)
    tabBar.Position = UDim2.new(0, 3, 0, TITLE_H)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = main
    ctx.tabBar = tabBar

    ctx.tabsFrame = {}
    ctx.tabButtons = {}
    local positions = {
        UDim2.new(0, 0, 0, 0), UDim2.new(1 / 3, 0, 0, 0), UDim2.new(2 / 3, 0, 0, 0),
        UDim2.new(0, 0, 0, 22), UDim2.new(1 / 3, 0, 0, 22), UDim2.new(2 / 3, 0, 0, 22),
    }
    for i, name in ipairs(ctx.tabNames) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / 3, -2, 0, 20)
        b.Position = positions[i]
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        b.Text = name
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = tabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
        ctx.tabButtons[name] = b
    end

    local CONTENT_Y = TITLE_H + TABROW_H + 2
    local CONTENT_H = FRAME_H - CONTENT_Y - STATUS_H - 2
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -6, 0, CONTENT_H)
    content.Position = UDim2.new(0, 3, 0, CONTENT_Y)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    ctx.content = content

    for _, name in ipairs(ctx.tabNames) do
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 4
        sf.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 140)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.ScrollingDirection = Enum.ScrollingDirection.Y
        sf.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        sf.Visible = false
        sf.Parent = content
        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0, 3)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Parent = sf
        Instance.new("UIPadding", sf).PaddingBottom = UDim.new(0, 6)
        Instance.new("UIPadding", sf).PaddingTop = UDim.new(0, 2)
        ctx.tabsFrame[name] = sf
    end

    ctx.switchTab = function(name)
        for n, frame in pairs(ctx.tabsFrame) do frame.Visible = (n == name) end
        for n, btn in pairs(ctx.tabButtons) do
            btn.BackgroundColor3 = (n == name) and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        end
    end
    for name, btn in pairs(ctx.tabButtons) do
        btn.Activated:Connect(function() ctx.switchTab(name) end)
    end
    ctx.switchTab(ctx.T_COMBAT)
end
return M
end)()

__modules['ui_widgets'] = (function()
-- purpose: basic reusable UI widgets
local M = {}
function M.setup(ctx)
    local opts = ctx.opts

    ctx.orderCounter = {}
    ctx.nextOrder = function(parent)
        ctx.orderCounter[parent] = (ctx.orderCounter[parent] or 0) + 1
        return ctx.orderCounter[parent]
    end

    ctx.newSection = function(parent, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(0, 200, 150)
        l.TextSize = 10
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = ctx.nextOrder(parent)
        l.Parent = parent
    end

    local NEEDS_RELOAD = { NoSpread = true, NoReload = true }
    ctx.newToggle = function(parent, text, key, onChange)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextSize = 11
        b.Font = Enum.Font.GothamSemibold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = ctx.nextOrder(parent)
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.Activated:Connect(function()
            local was = opts[key]
            opts[key] = not opts[key]
            b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
            b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
            if NEEDS_RELOAD[key] and not was and opts[key] then ctx.reequip() end
            if ctx.MODULES_OK and (key == "NoRecoil" or key == "NoSpread" or key == "NoCooldown" or key == "NoReload" or key == "OneHit") then ctx.apply() end
            if key == "AutoKill" or key == "SekaratMode" then
                for k in pairs(ctx.pending) do ctx.pending[k] = nil end
            end
            if onChange then onChange(opts[key]) end
            if ctx.requestSave then ctx.requestSave() end
        end)
    end
end
return M
end)()

__modules['ui_number'] = (function()
-- purpose: numeric stepper widget
local M = {}
function M.setup(ctx)
    ctx.newNumber = function(parent, label, initial, minV, maxV, stepV, decimals, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 88, 0, 28)
        lbl.Position = UDim2.new(0, 0, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 30, 0, 28)
        minus.Position = UDim2.new(0, 90, 0, 2)
        minus.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
        minus.Text = "−"
        minus.TextColor3 = Color3.new(1, 1, 1)
        minus.TextSize = 20
        minus.Font = Enum.Font.GothamBold
        minus.BorderSizePixel = 0
        minus.AutoButtonColor = false
        minus.Parent = row
        Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 74, 0, 28)
        valLabel.Position = UDim2.new(0, 122, 0, 2)
        valLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        valLabel.Text = ""
        valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valLabel.TextSize = 13
        valLabel.Font = Enum.Font.GothamBold
        valLabel.BorderSizePixel = 0
        valLabel.Parent = row
        Instance.new("UICorner", valLabel).CornerRadius = UDim.new(0, 4)
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 30, 0, 28)
        plus.Position = UDim2.new(0, 198, 0, 2)
        plus.BackgroundColor3 = Color3.fromRGB(30, 140, 50)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(1, 1, 1)
        plus.TextSize = 18
        plus.Font = Enum.Font.GothamBold
        plus.BorderSizePixel = 0
        plus.AutoButtonColor = false
        plus.Parent = row
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
        local currentVal = initial
        local function fmt(v)
            if decimals > 0 then return string.format("%." .. decimals .. "f", v) end
            return tostring(math.floor(v + 0.5))
        end
        local function setVal(newVal)
            newVal = math.clamp(newVal, minV, maxV)
            newVal = math.floor(newVal / stepV + 0.5) * stepV
            if decimals == 0 then newVal = math.floor(newVal + 0.5) end
            currentVal = newVal
            valLabel.Text = fmt(currentVal)
            callback(currentVal)
            if ctx.requestSave then ctx.requestSave() end
        end
        valLabel.Text = fmt(currentVal)
        callback(currentVal)
        local holdActive = false
        local function startHold(dir)
            if holdActive then return end
            holdActive = true
            task.spawn(function()
                task.wait(0.4)
                while holdActive do
                    setVal(currentVal + dir * stepV)
                    task.wait(0.06)
                end
            end)
        end
        local function stopHold() holdActive = false end
        minus.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setVal(currentVal - stepV)
                startHold(-1)
            end
        end)
        minus.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopHold()
            end
        end)
        plus.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setVal(currentVal + stepV)
                startHold(1)
            end
        end)
        plus.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopHold()
            end
        end)
    end
end
return M
end)()

__modules['ui_widgets_extra'] = (function()
-- purpose: dropdown and action row widgets
local M = {}
function M.setup(ctx)
    ctx.newDropdown = function(parent, label, options, initialVal, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.42, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.56, 0, 0, 26)
        btn.Position = UDim2.new(0.44, 0, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
        btn.Text = initialVal
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local idx = 1
        for i, v in ipairs(options) do
            if v == initialVal then idx = i; break end
        end
        btn.Activated:Connect(function()
            idx = idx % #options + 1
            btn.Text = options[idx]
            callback(options[idx])
            if ctx.requestSave then ctx.requestSave() end
        end)
    end

    ctx.newActionRow = function(parent, btn1Text, btn1Fn, btn2Text, btn2Fn)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local b1 = Instance.new("TextButton")
        b1.Size = UDim2.new(0.5, -2, 1, 0)
        b1.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        b1.Text = btn1Text
        b1.TextColor3 = Color3.fromRGB(220, 220, 255)
        b1.TextSize = 11
        b1.Font = Enum.Font.GothamSemibold
        b1.BorderSizePixel = 0
        b1.Parent = row
        Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 4)
        b1.Activated:Connect(btn1Fn)
        local b2 = Instance.new("TextButton")
        b2.Size = UDim2.new(0.5, -2, 1, 0)
        b2.Position = UDim2.new(0.5, 2, 0, 0)
        b2.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
        b2.Text = btn2Text
        b2.TextColor3 = Color3.fromRGB(220, 220, 255)
        b2.TextSize = 11
        b2.Font = Enum.Font.GothamSemibold
        b2.BorderSizePixel = 0
        b2.Parent = row
        Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 4)
        b2.Activated:Connect(btn2Fn)
    end
end
return M
end)()

__modules['tabs_combat'] = (function()
-- purpose: Combat tab UI (weapon mods, armor damage, actions)
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_COMBAT]
    ctx.newSection(p, "WEAPON MODS")
    ctx.newToggle(p, "No Recoil", "NoRecoil")
    ctx.newToggle(p, "No Spread", "NoSpread")
    ctx.newToggle(p, "No Cooldown", "NoCooldown")
    ctx.newToggle(p, "No Reload", "NoReload")
    ctx.newToggle(p, "One Hit Kill", "OneHit")
    ctx.newSection(p, "TANK / VEHICLE")
    ctx.newToggle(p, "Auto Pull Tank", "PullTanks")
    ctx.newNumber(p, "Pull Distance", ctx.pullDistance, 5, 50, 1, 0, function(v)
        ctx.pullDistance = v
        ctx.CONFIG.PullDistance = v
    end)
    ctx.newNumber(p, "Armor ESP Dist (m)", ctx.CONFIG.MaxArmorDistance, 50, 2000, 50, 0, function(v)
        ctx.CONFIG.MaxArmorDistance = v
    end)
    ctx.newSection(p, "ACTIONS")
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
    b.Text = "Reapply Mods"
    b.TextColor3 = Color3.fromRGB(220, 220, 255)
    b.TextSize = 11
    b.Font = Enum.Font.GothamSemibold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.LayoutOrder = ctx.nextOrder(p)
    b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.Activated:Connect(function()
        if ctx.MODULES_OK then ctx.apply(); ctx.reequip() end
    end)
end
return M
end)()

__modules['tabs_autokill'] = (function()
-- purpose: AutoKill tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_AUTOKILL]
    ctx.newSection(p, "AUTO KILL")
    ctx.newToggle(p, "Auto Kill", "AutoKill")
    ctx.newToggle(p, "Sekarat Mode", "SekaratMode")
    ctx.newSection(p, "TARGET MODE")
    local modeRow = Instance.new("Frame")
    modeRow.Size = UDim2.new(1, 0, 0, 28)
    modeRow.BackgroundTransparency = 1
    modeRow.LayoutOrder = ctx.nextOrder(p)
    modeRow.Parent = p
    local nBtn = Instance.new("TextButton")
    nBtn.Size = UDim2.new(0.5, -2, 1, 0)
    nBtn.BackgroundColor3 = ctx.targetMode == "Nearest" and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    nBtn.Text = "Nearest"
    nBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    nBtn.TextSize = 11
    nBtn.Font = Enum.Font.GothamSemibold
    nBtn.BorderSizePixel = 0
    nBtn.AutoButtonColor = false
    nBtn.Parent = modeRow
    Instance.new("UICorner", nBtn).CornerRadius = UDim.new(0, 4)
    local qBtn = Instance.new("TextButton")
    qBtn.Size = UDim2.new(0.5, -2, 1, 0)
    qBtn.Position = UDim2.new(0.5, 2, 0, 0)
    qBtn.BackgroundColor3 = ctx.targetMode == "Queue" and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    qBtn.Text = "Queue"
    qBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    qBtn.TextSize = 11
    qBtn.Font = Enum.Font.GothamSemibold
    qBtn.BorderSizePixel = 0
    qBtn.AutoButtonColor = false
    qBtn.Parent = modeRow
    Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0, 4)
    nBtn.Activated:Connect(function()
        ctx.targetMode = "Nearest"
        ctx.lockedTarget = nil
        ctx.lastTargeted = nil
        nBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        qBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        if ctx.requestSave then ctx.requestSave() end
    end)
    qBtn.Activated:Connect(function()
        ctx.targetMode = "Queue"
        ctx.lockedTarget = nil
        ctx.lastTargeted = nil
        nBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        qBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        if ctx.requestSave then ctx.requestSave() end
    end)
    ctx.newSection(p, "KILL VALUES")
    ctx.newNumber(p, "Cooldown (s)", ctx.autoKillCooldown, 0.15, 60, 0.1, 1, function(v) ctx.autoKillCooldown = v end)
    ctx.newNumber(p, "Damage", ctx.autoKillDamage, 1, 999999, 10, 0, function(v) ctx.autoKillDamage = v end)
    ctx.newNumber(p, "Sekarat HP", ctx.minHP, 1, 99999, 5, 0, function(v) ctx.minHP = v end)
    ctx.newNumber(p, "Max fires/s", ctx.maxFiresPerSec, 1, 15, 1, 0, function(v) ctx.maxFiresPerSec = v end)
    ctx.newSection(p, "ACTIONS")
    ctx.newActionRow(p, "Reset Queue", function()
        ctx.lastTargeted = nil
        ctx.lockedTarget = nil
        for k in pairs(ctx.pending) do ctx.pending[k] = nil end
    end, "Clear Blacklist", function()
        for k in pairs(ctx.failCounts) do ctx.failCounts[k] = nil end
        for k in pairs(ctx.blacklist) do ctx.blacklist[k] = nil end
    end)
end
return M
end)()

__modules['tabs_aim'] = (function()
-- purpose: Aim tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_AIM]
    ctx.newSection(p, "AUTO AIM")
    ctx.newToggle(p, "Auto Aim", "AutoAim")
    ctx.newToggle(p, "FOV Circle", "AimFOV")
    ctx.newDropdown(p, "Strength", { "Smooth", "Medium", "Strong" }, ctx.opts.AimStrength, function(v) ctx.opts.AimStrength = v end)
    ctx.newDropdown(p, "Priority", { "Nearest", "Lowest HP" }, ctx.opts.AimPriority, function(v) ctx.opts.AimPriority = v end)
    ctx.newDropdown(p, "Aim Part", { "Head", "Body" }, ctx.opts.AimPart, function(v) ctx.opts.AimPart = v end)
    ctx.newSection(p, "VALUES")
    ctx.newNumber(p, "Smoothness", ctx.aimSmoothness, 0.02, 1, 0.02, 2, function(v) ctx.aimSmoothness = v end)
    ctx.newNumber(p, "FOV Radius", ctx.fovRadius, 20, 1000, 10, 0, function(v) ctx.fovRadius = v end)
    ctx.newNumber(p, "ESP Distance", ctx.aimEspDistance, 50, 5000, 50, 0, function(v) ctx.aimEspDistance = v end)
end
return M
end)()

__modules['tabs_esp'] = (function()
-- purpose: ESP tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_ESP]
    ctx.newSection(p, "PLAYER ESP")
    ctx.newToggle(p, "Player ESP", "PlayerESP")
    ctx.newToggle(p, "Show Names", "ESPShowNames")
    ctx.newToggle(p, "Show HP", "ESPShowHP")
    ctx.newToggle(p, "Show Distance", "ESPShowDist")
    ctx.newSection(p, "ARMOR / VEHICLE ESP")
    ctx.newToggle(p, "Tank/Armor ESP", "ArmorESP")
    ctx.newToggle(p, "Armor Distance", "ArmorESPShowDist")
end
return M
end)()

__modules['tabs_medic'] = (function()
-- purpose: Medic tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_MEDIC]
    ctx.newSection(p, "STATUS")
    local medicStatus = Instance.new("TextLabel")
    medicStatus.Size = UDim2.new(1, 0, 0, 44)
    medicStatus.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    medicStatus.Text = "Medic: OFF"
    medicStatus.TextColor3 = Color3.fromRGB(140, 220, 180)
    medicStatus.TextSize = 10
    medicStatus.Font = Enum.Font.Code
    medicStatus.TextXAlignment = Enum.TextXAlignment.Left
    medicStatus.TextYAlignment = Enum.TextYAlignment.Top
    medicStatus.TextWrapped = true
    medicStatus.LayoutOrder = ctx.nextOrder(p)
    medicStatus.Parent = p
    Instance.new("UICorner", medicStatus).CornerRadius = UDim.new(0, 4)
    task.spawn(function()
        while ctx.gui.Parent do
            task.wait(0.3)
            if ctx.opts.MedicEnabled then
                local bandage = ctx.isBandageReady() and "READY" or "CD"
                medicStatus.Text = string.format("State: %s\nQueue: %d | %s | %s",
                    ctx.medicState, #ctx.medicQueue, bandage,
                    ctx.medicCurrentPatient and ctx.medicCurrentPatient.Name or "-")
            else
                medicStatus.Text = "Medic: OFF"
            end
        end
    end)
    ctx.newSection(p, "MEDIC MODE")
    ctx.newToggle(p, "Medic Enabled", "MedicEnabled", function(v)
        if v then ctx.medicSaveLocation() end
        ctx.medicState = "IDLE"
        ctx.medicQueue = {}
    end)
    ctx.newSection(p, "SETTINGS")
    ctx.newNumber(p, "HP Threshold %", ctx.medicHPThreshold, 5, 95, 5, 0, function(v) ctx.medicHPThreshold = v end)
    ctx.newNumber(p, "Below Studs", ctx.medicBelowStuds, 2, 50, 1, 0, function(v) ctx.medicBelowStuds = v end)
    ctx.newNumber(p, "Teleport Wait", ctx.medicTeleportWait, 0.1, 5, 0.1, 1, function(v) ctx.medicTeleportWait = v end)
    ctx.newDropdown(p, "Position", { "Below", "Front" }, ctx.medicPositionMode, function(v) ctx.medicPositionMode = v end)
    local humBtn = Instance.new("TextButton")
    humBtn.Size = UDim2.new(1, 0, 0, 28)
    humBtn.BackgroundColor3 = ctx.medicHumanize and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
    humBtn.Text = "Humanize  [" .. (ctx.medicHumanize and "ON" or "OFF") .. "]"
    humBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    humBtn.TextSize = 11
    humBtn.Font = Enum.Font.GothamSemibold
    humBtn.BorderSizePixel = 0
    humBtn.AutoButtonColor = false
    humBtn.LayoutOrder = ctx.nextOrder(p)
    humBtn.Parent = p
    Instance.new("UICorner", humBtn).CornerRadius = UDim.new(0, 4)
    humBtn.Activated:Connect(function()
        ctx.medicHumanize = not ctx.medicHumanize
        humBtn.BackgroundColor3 = ctx.medicHumanize and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        humBtn.Text = "Humanize  [" .. (ctx.medicHumanize and "ON" or "OFF") .. "]"
        if ctx.requestSave then ctx.requestSave() end
    end)
end
return M
end)()

__modules['tabs_display'] = (function()
-- purpose: Display tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_DISPLAY]
    ctx.newSection(p, "PANELS")
    local lbBtn = Instance.new("TextButton")
    lbBtn.Size = UDim2.new(1, 0, 0, 28)
    lbBtn.BackgroundColor3 = ctx.lbGui.Enabled and Color3.fromRGB(180, 140, 20) or Color3.fromRGB(40, 40, 58)
    lbBtn.Text = "Leaderboard  [" .. (ctx.lbGui.Enabled and "ON" or "OFF") .. "]"
    lbBtn.TextColor3 = Color3.fromRGB(255, 220, 120)
    lbBtn.TextSize = 11
    lbBtn.Font = Enum.Font.GothamSemibold
    lbBtn.BorderSizePixel = 0
    lbBtn.AutoButtonColor = false
    lbBtn.LayoutOrder = ctx.nextOrder(p)
    lbBtn.Parent = p
    Instance.new("UICorner", lbBtn).CornerRadius = UDim.new(0, 4)
    lbBtn.Activated:Connect(function()
        ctx.lbGui.Enabled = not ctx.lbGui.Enabled
        lbBtn.BackgroundColor3 = ctx.lbGui.Enabled and Color3.fromRGB(180, 140, 20) or Color3.fromRGB(40, 40, 58)
        lbBtn.Text = "Leaderboard  [" .. (ctx.lbGui.Enabled and "ON" or "OFF") .. "]"
        if ctx.lbGui.Enabled then pcall(ctx.buildLB) end
    end)
    ctx.newSection(p, "TOOLS")
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, 0, 0, 28)
    copyBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
    copyBtn.Text = "Copy Error Log"
    copyBtn.TextColor3 = Color3.fromRGB(255, 230, 150)
    copyBtn.TextSize = 11
    copyBtn.Font = Enum.Font.GothamSemibold
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.LayoutOrder = ctx.nextOrder(p)
    copyBtn.Parent = p
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
    copyBtn.Activated:Connect(function()
        local o = ctx.saveLogToClipboard()
        copyBtn.Text = o and "Copied!" or "Copy Failed"
        task.wait(1.5)
        copyBtn.Text = "Copy Error Log"
    end)
    ctx.newSection(p, "MODULE STATUS")
    local modInfo = Instance.new("TextLabel")
    modInfo.Size = UDim2.new(1, 0, 0, 50)
    modInfo.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    modInfo.Text = "Checking..."
    modInfo.TextColor3 = Color3.fromRGB(140, 220, 180)
    modInfo.TextSize = 10
    modInfo.Font = Enum.Font.Code
    modInfo.TextXAlignment = Enum.TextXAlignment.Left
    modInfo.TextYAlignment = Enum.TextYAlignment.Top
    modInfo.TextWrapped = true
    modInfo.LayoutOrder = ctx.nextOrder(p)
    modInfo.Parent = p
    Instance.new("UICorner", modInfo).CornerRadius = UDim.new(0, 4)
    task.spawn(function()
        task.wait(0.5)
        local gunCount = 0
        if ctx.GS then
            for _, inst in ipairs(ctx.GS:GetDescendants()) do
                if inst:IsA("ModuleScript") then gunCount = gunCount + 1 end
            end
        end
        while ctx.gui.Parent do
            modInfo.Text = string.format("Modules: %s\nGuns: %d\nRemotes: %s",
                ctx.MODULES_OK and "OK" or "MISSING", gunCount,
                (ctx.BR and "OK" or "NO") .. " / " .. (ctx.DR and "OK" or "NO"))
            task.wait(3)
        end
    end)
end
return M
end)()

__modules['loops_render'] = (function()
-- purpose: render-stepped UI updates
local M = {}
function M.setup(ctx)
    local Run = ctx.Run
    Run.RenderStepped:Connect(function()
        if ctx.fovCircle then
            pcall(function()
                ctx.fovCircle.Position = Vector2.new(ctx.Cam.ViewportSize.X / 2, ctx.Cam.ViewportSize.Y / 2)
                ctx.fovCircle.Radius = ctx.fovRadius
                ctx.fovCircle.Visible = ctx.opts.AutoAim and ctx.opts.AimFOV
            end)
        end
        if ctx.opts.AutoAim then
            local t = ctx.getBestAimEnemy()
            if t then
                local part = ctx.getTargetPart(t)
                if part then ctx.applyAimAt(part.Position) end
            end
        end
        pcall(ctx.updatePlayerESP)
    end)
end
return M
end)()

__modules['loops_heartbeat'] = (function()
-- purpose: heartbeat auto-kill (tank pulling runs in autopull tank.lua)
local M = {}
function M.setup(ctx)
    local Run = ctx.Run

    Run.Heartbeat:Connect(function()
        if ctx.MODULES_OK then
            pcall(function()
                if ctx.opts.AutoKill then ctx.currentTarget = ctx.getTarget() else ctx.currentTarget = nil end
            end)
        end
        if ctx.MODULES_OK and ctx.opts.AutoKill then
            local rem = ctx.autoKillCooldown - (tick() - ctx.lastKill)
            if rem <= 0 then
                pcall(function()
                    if ctx.doKill(ctx.currentTarget) then ctx.lastKill = tick()
                    elseif not ctx.currentTarget then ctx.STATUS = "No target" end
                end)
            else
                ctx.STATUS = string.format("CD %.2fs", rem)
            end
        else
            for k in pairs(ctx.pending) do ctx.pending[k] = nil end
        end

        pcall(ctx.updateMedic, tick())
    end)
end
return M
end)()

__modules['loops_tasks'] = (function()
-- purpose: periodic tasks, events, status updates
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local Run = ctx.Run
    local GS = ctx.GS

    task.spawn(function()
        while ctx.gui.Parent do
            task.wait(2)
            local now = tick()
            for id, p in pairs(ctx.pending) do
                local plr = Players:GetPlayerByUserId(id)
                if not plr or not plr.Character or plr.Character ~= p.char or (now - p.sentAt > 10) then
                    ctx.pending[id] = nil
                end
            end
            for id, t in pairs(ctx.blacklist) do
                if now >= t then ctx.blacklist[id] = nil end
            end
        end
    end)

    if GS then
        pcall(function()
            GS.DescendantAdded:Connect(function(c)
                if c:IsA("ModuleScript") then task.defer(ctx.apply) end
            end)
        end)
        local acc = 0
        Run.Heartbeat:Connect(function(dt)
            if not (ctx.opts.NoRecoil or ctx.opts.NoSpread or ctx.opts.NoCooldown or ctx.opts.NoReload or ctx.opts.OneHit) then return end
            acc = acc + dt
            if acc >= 2 then
                acc = 0
                ctx.apply()
            end
        end)
    end

    Players.PlayerRemoving:Connect(function(plr)
        if ctx.playerESPObjects[plr] then
            for _, d in pairs(ctx.playerESPObjects[plr]) do pcall(function() d:Remove() end) end
            ctx.playerESPObjects[plr] = nil
        end
        for i = #ctx.medicQueue, 1, -1 do
            if ctx.medicQueue[i] == plr then table.remove(ctx.medicQueue, i) end
        end
        if ctx.medicCurrentPatient == plr then ctx.medicCurrentPatient = nil end
    end)

    task.spawn(function()
        while ctx.gui.Parent do
            task.wait(0.4)
            local valid, lob, bl = 0, 0, 0
            for _, p in ipairs(Players:GetPlayers()) do
                if ctx.isEnemy(p) then
                    local c = p.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h and h.Health > 0 then
                            if ctx.inLobby(p) then lob = lob + 1
                            elseif ctx.isBL(p.UserId) then bl = bl + 1
                            else valid = valid + 1 end
                        end
                    end
                end
            end
            local rB, rD = ctx.getRate("Bullet"), ctx.getRate("Damager")
            local tgtName, tgtHP, pendHP = "-", "-", ""
            if ctx.currentTarget and ctx.currentTarget.Character then
                tgtName = ctx.currentTarget.Name
                local h = ctx.currentTarget.Character:FindFirstChildOfClass("Humanoid")
                if h then tgtHP = math.floor(h.Health) end
                local p = ctx.pending[ctx.currentTarget.UserId]
                if p then pendHP = string.format(" ⏳%.0f", p.startHP - p.totalSent) end
            end
            local armorN = 0
            for _, m in ipairs(ctx.armorCache) do
                if m.Parent then armorN = armorN + 1 end
            end
            local modeStr = ctx.opts.MedicEnabled and "MED" or (ctx.opts.AutoKill and "KILL" or "IDLE")
            if ctx.opts.PullTanks then modeStr = modeStr .. "+PULL" end
            local line1 = string.format("%s | %s | %s%s%s", modeStr, ctx.STATUS, tgtName,
                tgtHP ~= "-" and (" " .. tgtHP .. "HP") or "", pendHP)
            local line2 = string.format("R:%.1f/%d E:%d/%d L:%d B:%d A:%d",
                math.max(rB, rD), ctx.maxFiresPerSec, valid, valid + lob + bl, lob, bl, armorN)
            ctx.statusLbl.Text = line1 .. "\n" .. line2
        end
    end)
end
return M
end)()

-- main entry point
-- purpose: entry point wiring all modules
local function req(name)
    if script and script.Parent then
        return require(script.Parent:WaitForChild(name))
    end
    return require(name)
end

local ctx
local function fatal(e)
    if ctx and ctx.FATAL then ctx.FATAL(e) else print("[TREK] FATAL: " .. tostring(e)) end
    pcall(function()
        local pg = (ctx and ctx.PG) or (ctx and ctx.LP and ctx.LP:FindFirstChild("PlayerGui")) or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("TREK_Combined")
        if old then old:Destroy() end
        local g = Instance.new("ScreenGui")
        g.Name = "TREK_Combined"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.DisplayOrder = 999
        g.Parent = pg
        local m = Instance.new("Frame")
        m.Size = UDim2.new(0, 240, 0, 120)
        m.Position = UDim2.new(0, 10, 0, 60)
        m.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        m.BorderSizePixel = 0
        m.Parent = g
        Instance.new("UICorner", m).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 1, -10)
        lbl.Position = UDim2.new(0, 5, 0, 5)
        lbl.BackgroundTransparency = 1
        lbl.Text = "TREK Crash\n" .. tostring(e)
        lbl.TextColor3 = Color3.new(1, 0.7, 0.7)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = true
        lbl.Parent = m
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(1, -10, 0, 20)
        cb.Position = UDim2.new(0, 5, 1, -25)
        cb.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
        cb.Text = "Copy log"
        cb.TextColor3 = Color3.fromRGB(255, 230, 150)
        cb.TextSize = 10
        cb.Font = Enum.Font.GothamBold
        cb.BorderSizePixel = 0
        cb.Parent = m
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 3)
        cb.Activated:Connect(function()
            if ctx and ctx.saveLogToClipboard then ctx.saveLogToClipboard() end
        end)
    end)
    if ctx and ctx.saveLogToClipboard then ctx.saveLogToClipboard() end
end

local ok, err = xpcall(function()
    ctx = {}
    req("log").setup(ctx)
    ctx.L("=== START ===")
    req("services").setup(ctx)
    req("config").setup(ctx)
    req("state").setup(ctx)
    req("autosave").setup(ctx)
    req("rate").setup(ctx)
    req("armor_detect").setup(ctx)
    req("autopull tank").setup(ctx)
    req("esp").setup(ctx)
    req("esp_vehicle").setup(ctx)
    req("aim").setup(ctx)
    req("medic_core").setup(ctx)
    req("medic_loop").setup(ctx)
    req("combat").setup(ctx)
    req("targeting_scan").setup(ctx)
    req("targeting_kill").setup(ctx)
    req("leaderboard_ui").setup(ctx)
    req("leaderboard_logic").setup(ctx)
    req("ui_window").setup(ctx)
    req("ui_tabs").setup(ctx)
    req("ui_widgets").setup(ctx)
    req("ui_number").setup(ctx)
    req("ui_widgets_extra").setup(ctx)
    req("tabs_combat").setup(ctx)
    req("tabs_autokill").setup(ctx)
    req("tabs_aim").setup(ctx)
    req("tabs_esp").setup(ctx)
    req("tabs_medic").setup(ctx)
    req("tabs_display").setup(ctx)
    req("loops_render").setup(ctx)
    req("loops_heartbeat").setup(ctx)
    req("loops_tasks").setup(ctx)

    local n = 0
    if ctx.MODULES_OK then
        local okA, res = pcall(ctx.apply)
        n = okA and res or 0
    end
    ctx.STATUS = ctx.MODULES_OK and ("Ready " .. n .. "g") or "No modules"
    ctx.L("=== READY === modules=" .. tostring(ctx.MODULES_OK) .. " guns=" .. n)
end, fatal)

if not ok then
    print("[TREK] Crash: " .. tostring(err))
end