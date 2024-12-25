local ecr = require("./packages/ecr")

type T = {
    a: number,
    b: number
}

local T = ecr.component() :: T
local t: T = {
    a = 1,
    b = 2
}


local registry = ecr.registry()
local e = registry:create()

registry:set(e, T, t)
t.a = 2
t.b += 1

local t0 = registry:get(e, T)
print(t0.a, t0.b)