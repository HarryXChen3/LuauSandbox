local vide = require("./packages/vide")
local source = vide.source
local effect = vide.effect
local indexes = vide.indexes
local root = vide.root

local rerun_count = 0

local t = source({{n = 2}, {n = 1}, {n = 4}, {n = 3}})
root(function()
    indexes(t, function(e, i)
        effect(function()
            rerun_count += 1

            local _ = e()
        end)

        return nil
    end)
end)

do
    local t0 = t()
    local t1 = table.clone(t0)

    table.sort(t1, function(a, b) return a.n < b.n end)
    t(t1)

    print(`reran {rerun_count} times!`)
end