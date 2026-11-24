-- purpose: heartbeat auto-kill and armor damage
local M = {}
function M.setup(ctx)
    local Run = ctx.Run
    local LP = ctx.LP

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

        if ctx.MODULES_OK and (ctx.opts.DamageArmor or ctx.opts.ArmorESP) then
            pcall(function()
                local now = tick()
                if now - ctx.armorLastScan >= ctx.CONFIG.ArmorScanInterval then
                    ctx.armorLastScan = now
                    ctx.armorCache = ctx.scanEnemyArmor()
                end
                if ctx.opts.DamageArmor and #ctx.armorCache > 0 and now - ctx.armorLastShot >= ctx.CONFIG.ArmorFireInterval then
                    local myHRP = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
                    local best, bestD = nil, math.huge
                    for _, m in ipairs(ctx.armorCache) do
                        if m.Parent then
                            local ref = m:FindFirstChild("Head") or m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
                            if ref then
                                local d = myHRP and (ref.Position - myHRP.Position).Magnitude or 0
                                if d < bestD and d <= ctx.CONFIG.MaxArmorDistance then
                                    bestD = d
                                    best = m
                                end
                            end
                        end
                    end
                    if best and ctx.doArmorKill(best) then
                        ctx.armorLastShot = now
                    end
                end
            end)
        end

        pcall(ctx.updateMedic, tick())
    end)
end
return M