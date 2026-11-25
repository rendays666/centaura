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
