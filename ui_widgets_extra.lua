-- purpose: dropdown and action row widgets
local M = {}
function M.setup(ctx)
    ctx.newDropdown = function(parent, label, options, initialVal, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.42, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.56, 0, 0, 26)
        btn.Position = UDim2.new(0.44, 0, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
        btn.Text = initialVal
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local idx = 1
        for i, v in ipairs(options) do
            if v == initialVal then idx = i; break end
        end
        btn.Activated:Connect(function()
            idx = idx % #options + 1
            btn.Text = options[idx]
            callback(options[idx])
            if ctx.requestSave then ctx.requestSave() end
        end)
    end

    ctx.newActionRow = function(parent, btn1Text, btn1Fn, btn2Text, btn2Fn)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local b1 = Instance.new("TextButton")
        b1.Size = UDim2.new(0.5, -2, 1, 0)
        b1.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        b1.Text = btn1Text
        b1.TextColor3 = Color3.fromRGB(220, 220, 255)
        b1.TextSize = 11
        b1.Font = Enum.Font.GothamSemibold
        b1.BorderSizePixel = 0
        b1.Parent = row
        Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 4)
        b1.Activated:Connect(btn1Fn)
        local b2 = Instance.new("TextButton")
        b2.Size = UDim2.new(0.5, -2, 1, 0)
        b2.Position = UDim2.new(0.5, 2, 0, 0)
        b2.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
        b2.Text = btn2Text
        b2.TextColor3 = Color3.fromRGB(220, 220, 255)
        b2.TextSize = 11
        b2.Font = Enum.Font.GothamSemibold
        b2.BorderSizePixel = 0
        b2.Parent = row
        Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 4)
        b2.Activated:Connect(btn2Fn)
    end
end
return M