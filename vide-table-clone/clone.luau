local vide = require("./packages/vide")
local source = vide.source
local effect = vide.effect
local root = vide.root

local sources = {
    a = source(1),
    b = source(1)
}

root(function()
    effect(function()
        print(`a: {sources.a()}`)
    end)

    effect(function()
        print(`b: {sources.b()}`)
    end)
end)

sources.a(2)
sources.b(2)

local clone = table.clone(sources)
clone.a(3)
clone.b(3)
