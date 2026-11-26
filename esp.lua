-- purpose: player ESP (BillboardGui) and FOV circle (GUI, no Drawing dependency)
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
            if obj.gui then pcall(function() obj.gui:Destroy() end) end
        end
        for k in pairs(playerESPObjects) do playerESPObjects[k] = nil end
    end

    local function makeLabel(parent, name, y, height, color)
        local l = Instance.new("TextLabel")
        l.Name = name
        l.Size = UDim2.new(1, 0, 0, height)
        l.Position = UDim2.new(0, 0, 0, y)
        l.BackgroundTransparency = 1
        l.TextColor3 = color
        l.TextSize = 12
        l.Font = Enum.Font.GothamBold
        l.TextStrokeTransparency = 0.25
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.Parent = parent
        return l
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
                    local _, onScreen = Cam:WorldToViewportPoint(head.Position)
                    local dist = (Cam.CFrame.Position - head.Position).Magnitude
                    if onScreen and dist <= ctx.aimEspDistance then
                        seen[plr] = true
                        local obj = playerESPObjects[plr]
                        if obj and (not obj.gui or not obj.gui.Parent) then
                            playerESPObjects[plr] = nil
                            obj = nil
                        end
                        if not obj then
                            local gui = Instance.new("BillboardGui")
                            gui.Name = "TREK_ESP"
                            gui.Adornee = head
                            gui.Size = UDim2.new(0, 160, 0, 46)
                            gui.StudsOffset = Vector3.new(0, 2.4, 0)
                            gui.AlwaysOnTop = true
                            gui.Parent = head
                            obj = {
                                gui = gui,
                                name = makeLabel(gui, "PlayerName", 0, 16, Color3.fromRGB(255, 255, 0)),
                                hp = makeLabel(gui, "PlayerHP", 15, 16, Color3.fromRGB(0, 255, 0)),
                                dist = makeLabel(gui, "PlayerDist", 30, 14, Color3.fromRGB(0, 180, 255)),
                            }
                            playerESPObjects[plr] = obj
                        end
                        obj.gui.Adornee = head
                        if opts.ESPShowNames then
                            obj.name.Text = plr.Name
                            obj.name.Visible = true
                        else
                            obj.name.Visible = false
                        end
                        if opts.ESPShowHP then
                            obj.hp.Text = "HP: " .. math.floor(hum.Health)
                            obj.hp.Visible = true
                        else
                            obj.hp.Visible = false
                        end
                        if opts.ESPShowDist then
                            obj.dist.Text = math.floor(dist) .. "m"
                            obj.dist.Visible = true
                        else
                            obj.dist.Visible = false
                        end
                    end
                end
            end
        end
        for plr, obj in pairs(playerESPObjects) do
            if not seen[plr] then
                if obj.gui then pcall(function() obj.gui:Destroy() end) end
                playerESPObjects[plr] = nil
            end
        end
    end

    -- FOV circle via ScreenGui so it works without the executor Drawing library.
    local oldFov = ctx.PG:FindFirstChild("TREK_FOV")
    if oldFov then oldFov:Destroy() end
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = "TREK_FOV"
    fovGui.ResetOnSpawn = false
    fovGui.IgnoreGuiInset = true
    fovGui.DisplayOrder = 998
    fovGui.Parent = ctx.PG

    local circle = Instance.new("Frame")
    circle.Name = "FOVCircle"
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 0
    circle.Visible = false
    circle.Parent = fovGui
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = circle

    ctx.fovGui = fovGui
    ctx.fovCircle = circle
end
return M
