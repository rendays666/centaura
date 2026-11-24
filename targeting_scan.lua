-- purpose: enemy scanning and target selection
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP

    ctx.inLobby = function(plr)
        local c = plr.Character
        if not c then return true, "nochar" end
        if not c:IsDescendantOf(ctx.workspace) then return true, "notws" end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return true, "noHRP" end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return true, "dead" end
        if c:FindFirstChildOfClass("ForceField") then return true, "ff" end
        return false, nil
    end

    ctx.isBL = function(uid)
        local b = ctx.blacklist[uid]
        if b and tick() < b then return true end
        if b then ctx.blacklist[uid] = nil end
        return false
    end

    ctx.recordFail = function(uid)
        ctx.failCounts[uid] = (ctx.failCounts[uid] or 0) + 1
        if ctx.failCounts[uid] >= ctx.FAIL_THRESHOLD then
            ctx.blacklist[uid] = tick() + ctx.BLACKLIST_DURATION
            ctx.failCounts[uid] = 0
        end
    end

    ctx.scanEnemies = function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if ctx.isEnemy(p) and not ctx.isBL(p.UserId) then
                if not ctx.inLobby(p) then
                    local c = p.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        if not (ctx.opts.SekaratMode and h.Health <= ctx.minHP) then
                            list[#list + 1] = p
                        end
                    end
                end
            end
        end
        return list
    end

    ctx.nearestTarget = function()
        local hrp = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
        if not hrp then return nil end
        local my = hrp.Position
        local best, bd = nil, math.huge
        for _, p in ipairs(ctx.scanEnemies()) do
            local e = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if e then
                local d = (e.Position - my).Magnitude
                if d < bd then best, bd = p, d end
            end
        end
        return best
    end

    ctx.queueTarget = function()
        local es = ctx.scanEnemies()
        if #es == 0 then return nil end
        table.sort(es, function(a, b) return a.UserId < b.UserId end)
        if ctx.lastTargeted then
            for _, p in ipairs(es) do
                if p.UserId > ctx.lastTargeted.UserId then return p end
            end
        end
        return es[1]
    end

    ctx.getTarget = function()
        if ctx.targetMode == "Nearest" then return ctx.nearestTarget() end
        if ctx.lockedTarget then
            local c = ctx.lockedTarget.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and not ctx.isBL(ctx.lockedTarget.UserId)
               and not (ctx.opts.SekaratMode and h.Health <= ctx.minHP)
               and not ctx.inLobby(ctx.lockedTarget) then
                return ctx.lockedTarget
            end
            ctx.lastTargeted = ctx.lockedTarget
            ctx.lockedTarget = nil
        end
        local nx = ctx.queueTarget()
        ctx.lockedTarget = nx
        return nx
    end
end
return M