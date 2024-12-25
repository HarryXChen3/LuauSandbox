local vide = require("./packages/vide")
local source = vide.source
local switch = vide.switch
local root = vide.root

local src = source(false)

local function better_switch<K, V>(src: () -> K): ((map: Map<K, () -> V>) -> (() -> V?))
    return function()
        return function()
            return nil
        end
    end
end

local function pick<T>(map: Map<string, T?>): T?
    return nil
end

local b = {
    hi = "hello!",
    bye = "goodbye!"
}

local _a = pick(b)

root(function()
    local _swt0 = switch(src){
        [false] = function()
            return "hello!"
        end,

        [true] = function()
            return "goodbye!"
        end
    }

    local _swt1 = better_switch(src){
        [false] = function()
            return "hello!"
        end,

        [true] = function()
            return "goodbye!"
        end
    }
end)
