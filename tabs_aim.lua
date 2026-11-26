-- purpose: Aim tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_AIM]
    ctx.newSection(p, "AUTO AIM",
        "- Auto Aim: locks the camera toward the best enemy inside the FOV radius.\n" ..
        "- FOV Circle: draws the aim field-of-view circle on screen.\n" ..
        "- Strength: how quickly the camera snaps to the target.\n" ..
        "- Priority: chooses which enemy Auto Aim targets first.\n" ..
        "- Aim Part: body part that Auto Aim points at.")
    ctx.newToggle(p, "Auto Aim", "AutoAim")
    ctx.newToggle(p, "FOV Circle", "AimFOV")
    ctx.newDropdown(p, "Strength", { "Smooth", "Medium", "Strong" }, ctx.opts.AimStrength, function(v) ctx.opts.AimStrength = v end)
    ctx.newDropdown(p, "Priority", { "Nearest", "Lowest HP" }, ctx.opts.AimPriority, function(v) ctx.opts.AimPriority = v end)
    ctx.newDropdown(p, "Aim Part", { "Head", "Body" }, ctx.opts.AimPart, function(v) ctx.opts.AimPart = v end)
    ctx.newSection(p, "VALUES",
        "- Smoothness: lower values snap faster, higher values look smoother.\n" ..
        "- FOV Radius: size of the aim area in pixels.\n" ..
        "- ESP Distance: maximum distance used for aim and ESP checks.")
    ctx.newNumber(p, "Smoothness", ctx.aimSmoothness, 0.02, 1, 0.02, 2, function(v) ctx.aimSmoothness = v end)
    ctx.newNumber(p, "FOV Radius", ctx.fovRadius, 20, 1000, 10, 0, function(v) ctx.fovRadius = v end)
    ctx.newNumber(p, "ESP Distance", ctx.aimEspDistance, 50, 5000, 50, 0, function(v) ctx.aimEspDistance = v end)
end
return M
