-- purpose: vehicle ESP (BillboardGui name + distance, Highlight) for workspace.Map.Map.Vehicles
local M = {}
function M.setup(ctx)
    local LP = ctx.LP
    local workspace = ctx.workspace

    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    ctx.vehicleESP = {}

    ctx.clearVehicleESP = function()
        for veh, obj in pairs(ctx.vehicleESP) do
            if obj.hl then pcall(function() obj.hl:Destroy() end) end
            if obj.gui then pcall(function() obj.gui:Destroy() end) end
            ctx.vehicleESP[veh] = nil
        end
    end

    -- Replaces the old Drawing-based vehicle ESP from esp.lua.
    ctx.updateVehicleESP = function()
        if not ctx.opts.ArmorESP then ctx.clearVehicleESP(); return end
        local root = vehiclesRoot()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local my = hrp and hrp.Position
        local seen = {}

        if root and my then
            for _, child in ipairs(root:GetChildren()) do
                local veh = child:FindFirstChild("Vehicle")
                local ref = veh and ctx.vehicleRef and ctx.vehicleRef(veh)
                if ref and ref.Parent then
                    local dist = (ref.Position - my).Magnitude
                    if dist <= ctx.CONFIG.MaxArmorDistance then
                        seen[veh] = true
                        local obj = ctx.vehicleESP[veh]
                        if not obj then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = veh:IsA("Model") and veh or ref
                            hl.FillColor = Color3.fromRGB(255, 170, 60)
                            hl.FillTransparency = 0.75
                            hl.OutlineColor = Color3.fromRGB(255, 220, 120)
                            hl.Parent = ref

                            local gui = Instance.new("BillboardGui")
                            gui.Adornee = ref
                            gui.Size = UDim2.new(0, 220, 0, 36)
                            gui.StudsOffset = Vector3.new(0, 3, 0)
                            gui.AlwaysOnTop = true
                            gui.Parent = ref

                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 220, 120)
                            label.TextSize = 14
                            label.Font = Enum.Font.GothamBold
                            label.TextStrokeTransparency = 0.2
                            label.Parent = gui

                            obj = { hl = hl, gui = gui, label = label }
                            ctx.vehicleESP[veh] = obj
                        end
                        local name = (veh.Parent and veh.Parent.Name) or veh.Name
                        if ctx.opts.ArmorESPShowDist then
                            obj.label.Text = string.format("%s  [%dm]", name, math.floor(dist))
                        else
                            obj.label.Text = name
                        end
                    end
                end
            end
        end

        for veh, obj in pairs(ctx.vehicleESP) do
            if not seen[veh] or not veh.Parent then
                if obj.hl then pcall(function() obj.hl:Destroy() end) end
                if obj.gui then pcall(function() obj.gui:Destroy() end) end
                ctx.vehicleESP[veh] = nil
            end
        end
    end

    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.2)
            pcall(ctx.updateVehicleESP)
        end
    end)
end
return M
