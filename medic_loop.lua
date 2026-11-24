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