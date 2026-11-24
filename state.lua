-- purpose: mutable runtime state shared across modules
local M = {}
function M.setup(ctx)
    ctx.lastTargeted = nil
    ctx.lockedTarget = nil
    ctx.currentTarget = nil
    ctx.lastKill = 0
    ctx.originals = {}
    ctx.pending = {}
    ctx.failCounts = {}
    ctx.blacklist = {}
    ctx.INSTANT_FIRERATE = 100000
    ctx.PENDING_TIMEOUT = 4.0
    ctx.FAIL_THRESHOLD = 3
    ctx.BLACKLIST_DURATION = 30
    ctx.STATUS = "Idle"

    ctx.fireTimes = { Bullet = {}, Damager = {} }

    ctx.armorCache = {}
    ctx.armorLastScan = 0
    ctx.armorLastShot = 0

    ctx.playerESPObjects = {}

    ctx.fovCircle = nil

    ctx.medicState = "IDLE"
    ctx.medicQueue = {}
    ctx.medicCurrentPatient = nil
    ctx.medicSavedCFrame = nil
    ctx.medicStateStart = 0
    ctx.medicLastScan = 0
    ctx.medicInitialPatientHP = 0
end
return M