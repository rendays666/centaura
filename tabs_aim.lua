-- purpose: Aim tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_AIM]
    ctx.newSection(p, "AUTO AIM")
    ctx.newToggle(p, "Auto Aim", "AutoAim", nil,
        "Locks your camera toward the best enemy inside the FOV radius.")
    ctx.newToggle(p, "FOV Circle", "AimFOV", nil,
        "Draws the aim field-of-view circle on screen.")
    ctx.newDropdown(p, "Strength", { "Smooth", "Medium", "Strong" }, ctx.opts.AimStrength, function(v) ctx.opts.AimStrength = v end,
        "How quickly the camera snaps to the target.")
    ctx.newDropdown(p, "Priority", { "Nearest", "Lowest HP" }, ctx.opts.AimPriority, function(v) ctx.opts.AimPriority = v end,
        "Chooses which enemy Auto Aim targets first.")
    ctx.newDropdown(p, "Aim Part", { "Head", "Body" }, ctx.opts.AimPart, function(v) ctx.opts.AimPart = v end,
        "Body part that Auto Aim points at.")
    ctx.newSection(p, "VALUES")
    ctx.newNumber(p, "Smoothness", ctx.aimSmoothness, 0.02, 1, 0.02, 2, function(v) ctx.aimSmoothness = v end,
        "Lower values snap faster; higher values look smoother.")
    ctx.newNumber(p, "FOV Radius", ctx.fovRadius, 20, 1000, 10, 0, function(v) ctx.fovRadius = v end,
        "Size of the aim area in pixels.")
    ctx.newNumber(p, "ESP Distance", ctx.aimEspDistance, 50, 5000, 50, 0, function(v) ctx.aimEspDistance = v end,
        "Maximum distance used for aim and ESP checks.")
end
return M
