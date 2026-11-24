-- purpose: medic helper functions
local M = {}
function M.setup(ctx)
    local LP = ctx.LP

    ctx.getHP = function(plr)
        local c = plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return h.Health, (h.MaxHealth > 0 and h.MaxHealth or 100) end
        return nil, nil
    end

    ctx.getMyHRP = function()
        local c = LP.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    ctx.isBandageReady = function()
        local c = LP.Character
        if not c then return false end
        local t = c:FindFirstChild("BANDAGES")
        if not t then return false end
        if not t.Enabled then return false end
        if t:FindFirstChild("Cooldown") or t:FindFirstChild("Effect") then return false end
        return true
    end

    ctx.useBandage = function()
        local c = LP.Character
        if not c then return end
        local t = c:FindFirstChild("BANDAGES")
        if not t then return end
        local heal = t:FindFirstChild("Heal")
        if heal then
            pcall(function()
                local inRange = {}
                local myPos = c.PrimaryPart and c.PrimaryPart.Position or c:GetPivot().Position
                for _, p in pairs(LP.Team:GetPlayers()) do
                    if p.Character and p.Character.PrimaryPart and p ~= LP then
                        if (p.Character.PrimaryPart.Position - myPos).Magnitude <= 20 then
                            table.insert(inRange, p)
                        end
                    end
                end
                if #inRange > 0 then heal:FireServer(inRange) end
            end)
        end
        pcall(function() t:Activate() end)
    end

    ctx.medicSaveLocation = function()
        local hrp = ctx.getMyHRP()
        if hrp then ctx.medicSavedCFrame = hrp.CFrame; return true end
        return false
    end

    ctx.medicTeleportTo = function(patient)
        local hrp = ctx.getMyHRP()
        if not hrp then return end
        local pHRP = patient.Character and patient.Character:FindFirstChild("HumanoidRootPart")
        if not pHRP then return end
        local target
        if ctx.medicPositionMode == "Below" then
            target = pHRP.Position - Vector3.new(0, ctx.medicBelowStuds, 0)
        else
            target = pHRP.Position
        end
        if ctx.medicHumanize then
            target = target + Vector3.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
        end
        hrp.CFrame = CFrame.new(target, target + hrp.CFrame.LookVector)
    end

    ctx.medicReturn = function()
        local hrp = ctx.getMyHRP()
        if not hrp or not ctx.medicSavedCFrame then return end
        local target = ctx.medicSavedCFrame
        if ctx.medicHumanize then
            target = target * CFrame.new(math.random(-10, 10) / 10, 0, math.random(-10, 10) / 10)
        end
        hrp.CFrame = target
    end
end
return M