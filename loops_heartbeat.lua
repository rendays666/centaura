-- purpose: heartbeat auto-kill (vehicle damage runs in armor_damage.lua)
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