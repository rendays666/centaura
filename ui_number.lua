-- purpose: numeric stepper widget
local M = {}
function M.setup(ctx)
    ctx.newNumber = function(parent, label, initial, minV, maxV, stepV, decimals, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundTransparency = 1
        row.LayoutOrder = ctx.nextOrder(parent)
        row.Parent = parent
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 88, 0, 28)
        lbl.Position = UDim2.new(0, 0, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 30, 0, 28)
        minus.Position = UDim2.new(0, 90, 0, 2)
        minus.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
        minus.Text = "−"
        minus.TextColor3 = Color3.new(1, 1, 1)
        minus.TextSize = 20
        minus.Font = Enum.Font.GothamBold
        minus.BorderSizePixel = 0
        minus.AutoButtonColor = false
        minus.Parent = row
        Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 74, 0, 28)
        valLabel.Position = UDim2.new(0, 122, 0, 2)
        valLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        valLabel.Text = ""
        valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valLabel.TextSize = 13
        valLabel.Font = Enum.Font.GothamBold
        valLabel.BorderSizePixel = 0
        valLabel.Parent = row
        Instance.new("UICorner", valLabel).CornerRadius = UDim.new(0, 4)
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 30, 0, 28)
        plus.Position = UDim2.new(0, 198, 0, 2)
        plus.BackgroundColor3 = Color3.fromRGB(30, 140, 50)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(1, 1, 1)
        plus.TextSize = 18
        plus.Font = Enum.Font.GothamBold
        plus.BorderSizePixel = 0
        plus.AutoButtonColor = false
        plus.Parent = row
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
        local currentVal = initial
        local function fmt(v)
            if decimals > 0 then return string.format("%." .. decimals .. "f", v) end
            return tostring(math.floor(v + 0.5))
        end
        local function setVal(newVal)
            newVal = math.clamp(newVal, minV, maxV)
            newVal = math.floor(newVal / stepV + 0.5) * stepV
            if decimals == 0 then newVal = math.floor(newVal + 0.5) end
            currentVal = newVal
            valLabel.Text = fmt(currentVal)
            callback(currentVal)
        end
        valLabel.Text = fmt(currentVal)
        callback(currentVal)
        local holdActive = false
        local function startHold(dir)
            if holdActive then return end
            holdActive = true
            task.spawn(function()
                task.wait(0.4)
                while holdActive do
                    setVal(currentVal + dir * stepV)
                    task.wait(0.06)
                end
            end)
        end
        local function stopHold() holdActive = false end
        minus.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setVal(currentVal - stepV)
                startHold(-1)
            end
        end)
        minus.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopHold()
            end
        end)
        plus.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setVal(currentVal + stepV)
                startHold(1)
            end
        end)
        plus.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopHold()
            end
        end)
    end
end
return M