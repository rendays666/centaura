-- purpose: vehicle ESP via Highlight on the Vehicle model (tested autopull method)
local M = {}
function M.setup(ctx)
    local workspace = ctx.workspace
    local opts = ctx.opts

    local function vehiclesRoot()
        local map = workspace:FindFirstChild("Map")
        map = map and map:FindFirstChild("Map")
        return map and map:FindFirstChild("Vehicles")
    end

    ctx.vehicleESP = {}

    ctx.clearVehicleESP = function()
        for veh, hl in pairs(ctx.vehicleESP) do
            if hl then pcall(function() hl:Destroy() end) end
            ctx.vehicleESP[veh] = nil
        end
    end

    ctx.updateVehicleESP = function()
        if not opts.ArmorESP then ctx.clearVehicleESP(); return end
        local root = vehiclesRoot()
        if not root then ctx.clearVehicleESP(); return end

        local seen = {}
        for _, child in ipairs(root:GetChildren()) do
            local vehicle = child:FindFirstChild("Vehicle")
            if vehicle and not (ctx.isTankDestroyed and ctx.isTankDestroyed(child, vehicle)) then
                seen[vehicle] = true
                if not ctx.vehicleESP[vehicle] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = vehicle
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.6
                    hl.Parent = vehicle
                    ctx.vehicleESP[vehicle] = hl
                end
            end
        end

        for veh, hl in pairs(ctx.vehicleESP) do
            if not seen[veh] or not veh.Parent then
                if hl then pcall(function() hl:Destroy() end) end
                ctx.vehicleESP[veh] = nil
            end
        end
    end

    task.spawn(function()
        while not (ctx.gui and not ctx.gui.Parent) do
            task.wait(0.5)
            pcall(ctx.updateVehicleESP)
        end
    end)
end
return M
