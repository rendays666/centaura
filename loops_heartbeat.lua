-- purpose: heartbeat auto-kill (tank pulling runs in autopull tank.lua)
local M = {}
function M.setup(ctx)
    local Run = ctx.Run

    Run.Heartbeat:Connect(function()
        if ctx.MODULES_OK and ctx.opts.AutoKill then
            pcall(function()
                local list = ctx.getTargetList()
                if #list == 0 then
                    ctx.currentTarget = nil
                    ctx.STATUS = "No target"
                else
                    ctx.currentTarget = list[1]
                    -- per-player cooldown: sweep every eligible enemy, not one per tick
                    for _, t in ipairs(list) do
                        if ctx.doKill(t) then ctx.currentTarget = t end
                    end
                end
            end)
        else
            ctx.currentTarget = nil
            for k in pairs(ctx.pending) do ctx.pending[k] = nil end
        end

        pcall(ctx.updateMedic, tick())
    end)
end
return M
