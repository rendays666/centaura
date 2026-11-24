-- purpose: leaderboard window creation
local M = {}
function M.setup(ctx)
    local PG = ctx.PG

    ctx.lbGui = Instance.new("ScreenGui")
    ctx.lbGui.Name = "TREK_LB"
    ctx.lbGui.ResetOnSpawn = false
    ctx.lbGui.IgnoreGuiInset = true
    ctx.lbGui.DisplayOrder = 998
    ctx.lbGui.Parent = PG
    ctx.lbGui.Enabled = false

    ctx.lbMain = Instance.new("Frame")
    ctx.lbMain.Size = UDim2.new(0, 240, 0, 280)
    ctx.lbMain.Position = UDim2.new(0, 10, 0, 70)
    ctx.lbMain.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ctx.lbMain.BorderSizePixel = 0
    ctx.lbMain.Active = true
    ctx.lbMain.Parent = ctx.lbGui
    Instance.new("UICorner", ctx.lbMain).CornerRadius = UDim.new(0, 7)
    local lbStroke = Instance.new("UIStroke")
    lbStroke.Color = Color3.fromRGB(255, 200, 60)
    lbStroke.Thickness = 1.5
    lbStroke.Parent = ctx.lbMain
    ctx.lbTitleBar = Instance.new("Frame")
    ctx.lbTitleBar.Size = UDim2.new(1, 0, 0, 22)
    ctx.lbTitleBar.BackgroundTransparency = 1
    ctx.lbTitleBar.Parent = ctx.lbMain
    local lbTitle = Instance.new("TextLabel")
    lbTitle.Size = UDim2.new(1, -24, 1, 0)
    lbTitle.Position = UDim2.new(0, 6, 0, 0)
    lbTitle.BackgroundTransparency = 1
    lbTitle.Text = "Leaderboard"
    lbTitle.TextColor3 = Color3.fromRGB(255, 200, 60)
    lbTitle.TextSize = 11
    lbTitle.Font = Enum.Font.GothamBold
    lbTitle.TextXAlignment = Enum.TextXAlignment.Left
    lbTitle.Parent = ctx.lbTitleBar
    local lbX = Instance.new("TextButton")
    lbX.Size = UDim2.new(0, 18, 0, 18)
    lbX.Position = UDim2.new(1, -21, 0, 2)
    lbX.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
    lbX.Text = "X"
    lbX.TextColor3 = Color3.new(1, 1, 1)
    lbX.TextSize = 10
    lbX.Font = Enum.Font.GothamBold
    lbX.BorderSizePixel = 0
    lbX.Parent = ctx.lbTitleBar
    Instance.new("UICorner", lbX).CornerRadius = UDim.new(0, 3)
    lbX.Activated:Connect(function() ctx.lbGui.Enabled = false end)
    ctx.lbScroll = Instance.new("ScrollingFrame")
    ctx.lbScroll.Size = UDim2.new(1, -6, 1, -28)
    ctx.lbScroll.Position = UDim2.new(0, 3, 0, 24)
    ctx.lbScroll.BackgroundTransparency = 1
    ctx.lbScroll.BorderSizePixel = 0
    ctx.lbScroll.ScrollBarThickness = 4
    ctx.lbScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 60)
    ctx.lbScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ctx.lbScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ctx.lbScroll.Parent = ctx.lbMain
    local lbList = Instance.new("UIListLayout")
    lbList.Padding = UDim.new(0, 2)
    lbList.SortOrder = Enum.SortOrder.LayoutOrder
    lbList.Parent = ctx.lbScroll
end
return M