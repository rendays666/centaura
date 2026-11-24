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