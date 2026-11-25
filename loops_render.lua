-- purpose: render-stepped UI updates
local M = {}
function M.setup(ctx)
    local Run = ctx.Run
    Run.RenderStepped:Connect(function()
        if ctx.fovCircle then
            pcall(function()
                ctx.fovCircle.Position = Vector2.new(ctx.Cam.ViewportSize.X / 2, ctx.Cam.ViewportSize.Y / 2)
                ctx.fovCircle.Radius = ctx.fovRadius
                ctx.fovCircle.Visible = ctx.opts.AutoAim and ctx.opts.AimFOV
            end)
        end
        if ctx.opts.AutoAim then
            local t = ctx.getBestAimEnemy()
            if t then
                local part = ctx.getTargetPart(t)
                if part then ctx.applyAimAt(part.Position) end
            end
        end
        pcall(ctx.updatePlayerESP)
    end)
end
return M