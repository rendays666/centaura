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

    ctx.pingCache = { value = 0, at = 0 }
    ctx.getPing = function()
        local now = tick()
        if now - ctx.pingCache.at < 0.5 then return ctx.pingCache.value end
        local ok, value = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        value = (ok and type(value) == "number") and value or 0
        ctx.pingCache = { value = value, at = now }
        return value
    end

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