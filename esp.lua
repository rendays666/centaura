-- purpose: player ESP drawings and FOV circle
local M = {}
function M.setup(ctx)
    local Players = ctx.Players
    local LP = ctx.LP
    local Cam = ctx.Cam
    local opts = ctx.opts

    ctx.playerESPObjects = ctx.playerESPObjects or {}
    local playerESPObjects = ctx.playerESPObjects

    ctx.clearPlayerESP = function()
        for _, obj in pairs(playerESPObjects) do
            for _, d in pairs(obj) do pcall(function() d:Remove() end) end
        end
        for k in pairs(playerESPObjects) do playerESPObjects[k] = nil end
    end

    ctx.updatePlayerESP = function()
        if not opts.PlayerESP then ctx.clearPlayerESP(); return end
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and ctx.isEnemy(plr) then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local headPos, onScreen = Cam:WorldToViewportPoint(head.Position)
                    local dist = (Cam.CFrame.Position - head.Position).Magnitude
                    if onScreen and dist <= ctx.aimEspDistance then
                        seen[plr] = true
                        if not playerESPObjects[plr] then
                            local okD, n, h, d = pcall(function()
                                local a = Drawing.new("Text"); a.Size = 16; a.Color = Color3.fromRGB(255, 255, 0); a.Center = true; a.Outline = true
                                local b = Drawing.new("Text"); b.Size = 14; b.Color = Color3.fromRGB(0, 255, 0); b.Center = true; b.Outline = true
                                local c = Drawing.new("Text"); c.Size = 14; c.Color = Color3.fromRGB(0, 180, 255); c.Center = true; c.Outline = true
                                return a, b, c
                            end)
                            if okD then playerESPObjects[plr] = { name = n, hp = h, dist = d } end
                        end
                        local obj = playerESPObjects[plr]
                        if obj then
                            if opts.ESPShowNames then
                                obj.name.Text = plr.Name
                                obj.name.Position = Vector2.new(headPos.X, headPos.Y - 32)
                                obj.name.Visible = true
                            else obj.name.Visible = false end
                            if opts.ESPShowHP then
                                obj.hp.Text = "HP: " .. math.floor(hum.Health)
                                obj.hp.Position = Vector2.new(headPos.X, headPos.Y - 14)
                                obj.hp.Visible = true
                            else obj.hp.Visible = false end
                            if opts.ESPShowDist then
                                obj.dist.Text = math.floor(dist) .. "m"
                                obj.dist.Position = Vector2.new(headPos.X, headPos.Y + 5)
                                obj.dist.Visible = true
                            else obj.dist.Visible = false end
                        end
                    end
                end
            end
        end
        for plr, obj in pairs(playerESPObjects) do
            if not seen[plr] then
                for _, d in pairs(obj) do pcall(function() d:Remove() end) end
                playerESPObjects[plr] = nil
            end
        end
    end

    ctx.fovCircle = nil
    pcall(function()
        ctx.fovCircle = Drawing.new("Circle")
        ctx.fovCircle.Visible = true
        ctx.fovCircle.Radius = ctx.fovRadius
        ctx.fovCircle.Color = Color3.fromRGB(255, 255, 255)
        ctx.fovCircle.Thickness = 1
        ctx.fovCircle.Transparency = 1
        ctx.fovCircle.Filled = false
    end)
end
return M