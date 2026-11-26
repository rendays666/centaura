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

    -- skip enemies whose HP went up so active healers are not damage-focused
    ctx.sampleHP = function(plr)
        local c = plr.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local uid = plr.UserId
        local s = ctx.hpSamples[uid]
        if s and s.char == c and h.Health > s.hp + 0.1 then
            ctx.healUntil[uid] = tick() + ctx.HEAL_SKIP
            ctx.pending[uid] = nil
        end
        ctx.hpSamples[uid] = { char = c, hp = h.Health }
    end

    ctx.isHealing = function(uid)
        local t = ctx.healUntil[uid]
        if t and tick() < t then return true end
        if t then ctx.healUntil[uid] = nil end
        return false
    end

    ctx.scanEnemies = function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if ctx.isEnemy(p) then
                ctx.sampleHP(p)
                if not ctx.isHealing(p.UserId) and not ctx.isBL(p.UserId) then
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

    -- ordered list of all eligible enemies, used to sweep every target
    ctx.getTargetList = function()
        local es = ctx.scanEnemies()
        if ctx.targetMode == "Queue" then
            table.sort(es, function(a, b) return a.UserId < b.UserId end)
        else
            local hrp = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
            if hrp then
                local my = hrp.Position
                local function dist(p)
                    local e = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    return e and (e.Position - my).Magnitude or math.huge
                end
                table.sort(es, function(a, b) return dist(a) < dist(b) end)
            end
        end
        return es
    end

    ctx.getTarget = function()
        if ctx.targetMode == "Nearest" then return ctx.nearestTarget() end
        if ctx.lockedTarget then
            local c = ctx.lockedTarget.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 and not ctx.isBL(ctx.lockedTarget.UserId)
               and not ctx.isHealing(ctx.lockedTarget.UserId)
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