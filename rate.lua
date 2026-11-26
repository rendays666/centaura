-- purpose: per-player fire-rate tracking and gating for remotes
local M = {}
function M.setup(ctx)
    ctx.getRate = function(r, uid)
        local now = tick()
        local function count(t)
            local n = 0
            if not t then return n end
            for _, v in ipairs(t) do
                if now - v <= 1 then n = n + 1 end
            end
            return n
        end
        if uid ~= nil then
            local u = ctx.fireTimes[uid]
            return u and count(u[r]) or 0
        end
        local n = 0
        for _, u in pairs(ctx.fireTimes) do n = n + count(u[r]) end
        return n
    end
    ctx.recordFire = function(r, uid)
        local u = ctx.fireTimes[uid]
        if not u then u = { Bullet = {}, Damager = {} }; ctx.fireTimes[uid] = u end
        local t = u[r]
        if not t then t = {}; u[r] = t end
        table.insert(t, tick())
        local now = tick()
        local i = 1
        while i <= #t do
            if now - t[i] > 2 then table.remove(t, i) else i = i + 1 end
        end
    end
    ctx.canFire = function(uid)
        return ctx.getRate("Bullet", uid) < ctx.maxFiresPerSec and ctx.getRate("Damager", uid) < ctx.maxFiresPerSec
    end
end
return M
