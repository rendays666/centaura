-- purpose: logging buffer, clipboard export, fatal reporting
local M = {}
function M.setup(ctx)
    ctx.LOG_BUF = {}
    ctx.COPY_FN = setclipboard or toclipboard or writeclipboard or nil
    ctx.L = function(m)
        m = tostring(m)
        table.insert(ctx.LOG_BUF, m)
        if #ctx.LOG_BUF > 500 then table.remove(ctx.LOG_BUF, 1) end
        pcall(function() print("[TREK] " .. m) end)
    end
    ctx.saveLogToClipboard = function()
        if ctx.COPY_FN then
            return pcall(ctx.COPY_FN, "[TREK LOG]\n" .. table.concat(ctx.LOG_BUF, "\n"))
        end
        return false
    end
    ctx.FATAL = function(e)
        ctx.L("FATAL: " .. tostring(e))
        ctx.L(debug.traceback())
        ctx.saveLogToClipboard()
    end
end
return M