-- purpose: tab bar and tab frames
local M = {}
function M.setup(ctx)
    local main = ctx.main
    local TITLE_H = ctx.TITLE_H
    local TABROW_H = ctx.TABROW_H
    local FRAME_H = ctx.FRAME_H
    local STATUS_H = ctx.STATUS_H

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -6, 0, TABROW_H)
    tabBar.Position = UDim2.new(0, 3, 0, TITLE_H)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = main
    ctx.tabBar = tabBar

    ctx.tabsFrame = {}
    ctx.tabButtons = {}
    local positions = {
        UDim2.new(0, 0, 0, 0), UDim2.new(1 / 3, 0, 0, 0), UDim2.new(2 / 3, 0, 0, 0),
        UDim2.new(0, 0, 0, 22), UDim2.new(1 / 3, 0, 0, 22), UDim2.new(2 / 3, 0, 0, 22),
    }
    for i, name in ipairs(ctx.tabNames) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / 3, -2, 0, 20)
        b.Position = positions[i]
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        b.Text = name
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Parent = tabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
        ctx.tabButtons[name] = b
    end

    local CONTENT_Y = TITLE_H + TABROW_H + 2
    local CONTENT_H = FRAME_H - CONTENT_Y - STATUS_H - 2
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -6, 0, CONTENT_H)
    content.Position = UDim2.new(0, 3, 0, CONTENT_Y)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    ctx.content = content

    for _, name in ipairs(ctx.tabNames) do
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 4
        sf.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 140)
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.ScrollingDirection = Enum.ScrollingDirection.Y
        sf.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        sf.Visible = false
        sf.Parent = content
        local ll = Instance.new("UIListLayout")
        ll.Padding = UDim.new(0, 3)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Parent = sf
        Instance.new("UIPadding", sf).PaddingBottom = UDim.new(0, 6)
        Instance.new("UIPadding", sf).PaddingTop = UDim.new(0, 2)
        ctx.tabsFrame[name] = sf
    end

    ctx.switchTab = function(name)
        for n, frame in pairs(ctx.tabsFrame) do frame.Visible = (n == name) end
        for n, btn in pairs(ctx.tabButtons) do
            btn.BackgroundColor3 = (n == name) and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(40, 40, 58)
        end
    end
    for name, btn in pairs(ctx.tabButtons) do
        btn.Activated:Connect(function() ctx.switchTab(name) end)
    end
    ctx.switchTab(ctx.T_COMBAT)
end
return M