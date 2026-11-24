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