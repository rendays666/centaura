-- purpose: enemy armor/vehicle model detection (humans and tank-like machines)
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local TeamsSvc = ctx.TeamsSvc
    local workspace = ctx.workspace

    ctx.matchTeamByPrefix = function(nameLower)
        for _, team in ipairs(TeamsSvc:GetTeams()) do
            local full = team.Name:lower()
            local p3 = full:sub(1, math.min(3, #full))
            if #full >= 3 and nameLower:sub(1, #full) == full then return team end
            if #p3 == 3 and nameLower:sub(1, 3) == p3 then return team end
        end
        return nil
    end

    ctx.looksLikeVehicle = function(name)
        local n = name:lower()
        for _, kw in ipairs({ "gun", "turret", "tank", "vehicle", "machinegun", "mg",
            "artillery", "cannon", "apc", "halftrack", "jeep", "truck", "plane",
            "fighter", "bomber", "walker", "mech", "brownie", "destroyer" }) do
            if n:find(kw) then return true end
        end
        return false
    end

    ctx.isEnemyOwner = function(model)
        local tv = model:FindFirstChild("Team")
        if tv and tv:IsA("ObjectValue") and tv.Value then
            return tv.Value ~= LP.Team
        end
        local cr = model:FindFirstChild("Creator")
        if cr and cr:IsA("ObjectValue") then
            local pl = cr.Value
            if pl and pl:IsA("Player") then
                if pl.Team then return pl.Team ~= LP.Team end
                return false
            end
        end
        for _, team in ipairs(TeamsSvc:GetTeams()) do
            local bv = model:FindFirstChild(team.Name)
            if bv and bv:IsA("BoolValue") then
                return (team ~= LP.Team) == bv.Value
            end
        end
        local n = model.Name:lower()
        local matched = ctx.matchTeamByPrefix(n)
        if matched then return matched ~= LP.Team end
        local p = model.Parent
        local depth = 0
        while p and p ~= workspace and depth < 3 do
            local pm = ctx.matchTeamByPrefix(p.Name:lower())
            if pm then return pm ~= LP.Team end
            p = p.Parent
            depth = depth + 1
        end
        return false
    end

    ctx.isEnemyEntity = function(model)
        if not model or not LP.Team then return false end
        if model:FindFirstAncestorOfClass("Player") then return false end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health <= 0 then return false end
            if hum.Team then return hum.Team ~= LP.Team end
        end
        return ctx.isEnemyOwner(model)
    end

    ctx.isEnemyModel = ctx.isEnemyEntity

    ctx.scanEnemyArmor = function()
        local list, seen = {}, {}
        local playerChars = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then playerChars[p.Character] = true end
        end

        local function add(model)
            if not model or seen[model] or playerChars[model] then return end
            seen[model] = true
            if ctx.isEnemyEntity(model) then list[#list + 1] = model end
        end

        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Humanoid") and d.Health > 0 then
                local model = d.Parent
                if model and model:IsA("Model") then
                    local hasArmor = model:FindFirstChild("BrowPlate") ~= nil
                    if not hasArmor then
                        for _, p in ipairs(model:GetDescendants()) do
                            if p:IsA("BasePart") and p:GetAttribute("Armored") then
                                hasArmor = true
                                break
                            end
                        end
                    end
                    if hasArmor or ctx.looksLikeVehicle(model.Name) then add(model) end
                end
            elseif d:IsA("BasePart") then
                if d:GetAttribute("Armored") or d.Name == "Plate" then
                    add(d:FindFirstAncestorOfClass("Model"))
                end
            elseif d:IsA("Model") and ctx.looksLikeVehicle(d.Name) then
                add(d)
            end
        end
        return list
    end
end
return M
