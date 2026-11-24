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
            if ctx.opts.DamageArmor then modeStr = modeStr .. "+TANK" end
            local line1 = string.format("%s | %s | %s%s%s", modeStr, ctx.STATUS, tgtName,
                tgtHP ~= "-" and (" " .. tgtHP .. "HP") or "", pendHP)
            local line2 = string.format("R:%.1f/%d E:%d/%d L:%d B:%d A:%d",
                math.max(rB, rD), ctx.maxFiresPerSec, valid, valid + lob + bl, lob, bl, armorN)
            ctx.statusLbl.Text = line1 .. "\n" .. line2
        end
    end)
end
return M