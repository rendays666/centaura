-- purpose: basic reusable UI widgets
local M = {}
function M.setup(ctx)
    local opts = ctx.opts

    ctx.orderCounter = {}
    ctx.nextOrder = function(parent)
        ctx.orderCounter[parent] = (ctx.orderCounter[parent] or 0) + 1
        return ctx.orderCounter[parent]
    end

    ctx.newSection = function(parent, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(0, 200, 150)
        l.TextSize = 10
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = ctx.nextOrder(parent)
        l.Parent = parent
    end

    local NEEDS_RELOAD = { NoSpread = true, NoReload = true }
    ctx.newToggle = function(parent, text, key, onChange)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextSize = 11
        b.Font = Enum.Font.GothamSemibold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = ctx.nextOrder(parent)
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.Activated:Connect(function()
            local was = opts[key]
            opts[key] = not opts[key]
            b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
            b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
            if NEEDS_RELOAD[key] and not was and opts[key] then ctx.reequip() end
            if ctx.MODULES_OK and (key == "NoRecoil" or key == "NoSpread" or key == "NoCooldown" or key == "NoReload" or key == "OneHit") then ctx.apply() end
            if key == "AutoKill" or key == "SekaratMode" then
                for k in pairs(ctx.pending) do ctx.pending[k] = nil end
            end
            if onChange then onChange(opts[key]) end
            if ctx.requestSave then ctx.requestSave() end
        end)
    end
end
return M