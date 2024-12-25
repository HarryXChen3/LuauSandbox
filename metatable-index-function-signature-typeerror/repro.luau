local mod = require("./mod")

local a_provider: mod.Source<number> = function()
    return 1
end

local b: mod.Source<mod.S> = mod.get_remote_scheduler_data(a_provider())
