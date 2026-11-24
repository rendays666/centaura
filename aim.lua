-- purpose: aim target selection and camera application
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local Cam = ctx.Cam
    local opts = ctx.opts

    ctx.getTargetPart = function(plr)
        local c = plr.Character
        if not c then return nil end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        if opts.AimPart == "Head" then return c:FindFirstChild("Head") end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    end

    ctx.getBestAimEnemy = function()
        local best, bestDist, bestHP = nil, math.huge, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and ctx.isEnemy(plr) then
                local part = ctx.getTargetPart(plr)
                if part then
                    local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                    local dist = (Cam.CFrame.Position - part.Position).Magnitude
                    if onScreen and dist <= ctx.aimEspDistance then
                        local allowed = true
                        if opts.AimFOV and ctx.fovCircle then
                            local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                            allowed = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude <= ctx.fovRadius
                        end
                        if allowed then
                            local ray = Ray.new(Cam.CFrame.Position, (part.Position - Cam.CFrame.Position).Unit * dist)
                            local hit = workspace:FindPartOnRay(ray, LP.Character, false, true)
                            if hit and hit:IsDescendantOf(plr.Character) then
                                if opts.AimPriority == "Nearest" then
                                    if dist < bestDist then bestDist = dist; best = plr end
                                else
                                    local hp = plr.Character:FindFirstChildOfClass("Humanoid")
                                    hp = hp and hp.Health or math.huge
                                    if hp < bestHP or (hp == bestHP and dist < bestDist) then
                                        bestHP = hp
                                        bestDist = dist
                                        best = plr
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    ctx.applyAimAt = function(targetPos)
        local cur = Cam.CFrame
        local tgt = CFrame.new(cur.Position, targetPos)
        if opts.AimStrength == "Strong" then
            Cam.CFrame = tgt
        elseif opts.AimStrength == "Medium" then
            Cam.CFrame = cur:Lerp(tgt, 0.5)
        else
            Cam.CFrame = cur:Lerp(tgt, ctx.aimSmoothness)
        end
    end
end
return M