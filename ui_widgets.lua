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

    -- shared info popup, created on first use and reused
    ctx.showInfo = function(title, body)
        if not ctx.gui then return end
        local pop = ctx.infoPopup
        if not pop or not pop.frame.Parent then
            local pf = Instance.new("Frame")
            pf.Size = UDim2.new(0, 280, 0, 200)
            pf.Position = UDim2.new(0.5, -140, 0.5, -100)
            pf.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
            pf.BorderSizePixel = 0
            pf.Active = true
            pf.ZIndex = 200
            pf.Parent = ctx.gui
            Instance.new("UICorner", pf).CornerRadius = UDim.new(0, 8)
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0, 220, 160)
            stroke.Thickness = 1.5
            stroke.Parent = pf
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -34, 0, 22)
            t.Position = UDim2.new(0, 8, 0, 6)
            t.BackgroundTransparency = 1
            t.TextColor3 = Color3.fromRGB(0, 220, 160)
            t.TextSize = 12
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextWrapped = true
            t.ZIndex = 201
            t.Parent = pf
            local bl = Instance.new("TextLabel")
            bl.Size = UDim2.new(1, -16, 1, -58)
            bl.Position = UDim2.new(0, 8, 0, 32)
            bl.BackgroundTransparency = 1
            bl.TextColor3 = Color3.fromRGB(220, 220, 230)
            bl.TextSize = 10
            bl.Font = Enum.Font.Gotham
            bl.TextXAlignment = Enum.TextXAlignment.Left
            bl.TextYAlignment = Enum.TextYAlignment.Top
            bl.TextWrapped = true
            bl.ZIndex = 201
            bl.Parent = pf
            local close = Instance.new("TextButton")
            close.Size = UDim2.new(0, 22, 0, 22)
            close.Position = UDim2.new(1, -28, 0, 5)
            close.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
            close.Text = "X"
            close.TextColor3 = Color3.new(1, 1, 1)
            close.TextSize = 11
            close.Font = Enum.Font.GothamBold
            close.BorderSizePixel = 0
            close.AutoButtonColor = false
            close.ZIndex = 202
            close.Parent = pf
            Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
            close.Activated:Connect(function() pf.Visible = false end)
            pop = { frame = pf, title = t, body = bl }
            ctx.infoPopup = pop
        end
        pop.title.Text = title or "Info"
        pop.body.Text = body or ""
        pop.frame.Visible = true
    end

    ctx.toggleInfo = function(title, body)
        local pop = ctx.infoPopup
        if pop and pop.frame.Visible and pop.title.Text == title then
            pop.frame.Visible = false
        else
            ctx.showInfo(title, body)
        end
    end

    ctx.newInfoButton = function(title, body)
        local ib = Instance.new("TextButton")
        ib.Size = UDim2.new(0, 18, 0, 18)
        ib.BackgroundColor3 = Color3.fromRGB(50, 75, 115)
        ib.Text = "i"
        ib.TextColor3 = Color3.fromRGB(230, 235, 255)
        ib.TextSize = 12
        ib.Font = Enum.Font.GothamBold
        ib.BorderSizePixel = 0
        ib.AutoButtonColor = false
        ib.ZIndex = 10
        Instance.new("UICorner", ib).CornerRadius = UDim.new(1, 0)
        ib.Activated:Connect(function() ctx.toggleInfo(title, body) end)
        return ib
    end

    local NEEDS_RELOAD = { NoSpread = true, NoReload = true }
    ctx.newToggle = function(parent, text, key, onChange, info)
        local hasInfo = info ~= nil
        local host = parent
        if hasInfo then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.LayoutOrder = ctx.nextOrder(parent)
            row.Parent = parent
            host = row
        end
        local b = Instance.new("TextButton")
        b.Size = hasInfo and UDim2.new(1, -22, 1, 0) or UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextSize = 11
        b.Font = Enum.Font.GothamSemibold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = ctx.nextOrder(host)
        b.Parent = host
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        if hasInfo then
            local ib = ctx.newInfoButton(text, info)
            ib.Position = UDim2.new(1, -20, 0, 5)
            ib.Parent = host
        end
        b.Activated:Connect(function()
            local was = opts[key]
            opts[key] = not opts[key]
            b.BackgroundColor3 = opts[key] and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
            b.Text = text .. "  [" .. (opts[key] and "ON" or "OFF") .. "]"
            if NEEDS_RELOAD[key] and not was and opts[key] then ctx.reequip() end
            if ctx.MODULES_OK and (key == "NoRecoil" or key == "NoSpread" or key == "NoCooldown" or key == "NoReload" or key == "OneHit") then ctx.apply() end
            if key == "AutoKill" or key == "SekaratMode" then
                for k in pairs(ctx.pending) do ctx.pending[k] = nil end
                for k in pairs(ctx.retryAt) do ctx.retryAt[k] = nil end
            end
            if onChange then onChange(opts[key]) end
            if ctx.requestSave then ctx.requestSave() end
        end)
    end
end
return M
