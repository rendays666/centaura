-- purpose: ESP tab UI
local M = {}
function M.setup(ctx)
    local p = ctx.tabsFrame[ctx.T_ESP]
    ctx.newSection(p, "PLAYER ESP",
        "- Player ESP: draws a box around enemy players through walls.\n" ..
        "- Show Names: shows the player name on the box.\n" ..
        "- Show HP: shows the enemy's current HP on the box.\n" ..
        "- Show Distance: shows how far the enemy is from you on the box.")
    ctx.newToggle(p, "Player ESP", "PlayerESP")
    ctx.newToggle(p, "Show Names", "ESPShowNames")
    ctx.newToggle(p, "Show HP", "ESPShowHP")
    ctx.newToggle(p, "Show Distance", "ESPShowDist")
    ctx.newSection(p, "ARMOR / VEHICLE ESP",
        "- Tank/Armor ESP: highlights tanks and armored vehicles and shows their armor status.")
    ctx.newToggle(p, "Tank/Armor ESP", "ArmorESP")
end
return M
