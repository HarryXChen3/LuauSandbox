type Map<K, V> = {[K]: V}

type Unit = {
    prefix: string,
    base: number,
    to_larger: number,
    to_smaller: number,
    order: number
}

type Units = Map<number, Unit>

local _UNITS: Units = {
    [4] = {
        prefix = "T",
        base = 1e+12,
        to_larger = 1e+12 + 1e+4,
        to_smaller = 1e+12 - 1e+2,
        order = 4
    },
    [3] = {
        prefix = "G",
        base = 1e+9,
        to_larger = 1e+9 + 1e+3,
        to_smaller = 1e+9 - 1e+3,
        order = 3
    },
    [2] = {
        prefix = "M",
        base = 1e+6,
        to_larger = 1e+6 + 1e+2,
        to_smaller = 1e+6 - 1e+2,
        order = 2
    },
    [1] = {
        prefix = "k",
        base = 1000,
        to_larger = 1200,
        to_smaller = 980,
        order = 1
    },
    [0] = {
        prefix = "",
        base = 1,
        to_larger = 1.2,
        to_smaller = 0.98,
        order = 0
    },
    [-1] = {
        prefix = "m",
        base = 0.001,
        to_larger = 0.0012,
        to_smaller = 0.0098,
        order = -1
    },
    [-2] = {
        prefix = "u",
        base = 1e-6,
        to_larger = 1e-6 + 1e-2,
        to_smaller = 1e-6 - 1e-2,
        order = -2
    },
    [-3] = {
        prefix = "n",
        base = 1e-9,
        to_larger = 1e-9 + 1e-3,
        to_smaller = 1e-9 - 1e-3,
        order = -3
    },
    [-4] = {
        prefix = "p",
        base = 1e-12,
        to_larger = 1e-12 + 1e-4,
        to_smaller = 1e-12 - 1e-4,
        order = -4
    }
}

local function convert_units(value: number, unit: string): (number, string)
    local sgn = math.sign(value)
    local abs_value = math.abs(value)

    local order = 0
    while abs_value >= 1000 and _UNITS[order + 1] do
        order += 1
        abs_value /= 1000
    end

    while abs_value ~= 0 and abs_value < 1 and _UNITS[order - 1] do
        order -= 1
        abs_value *= 1000
    end

    return sgn * abs_value, _UNITS[order].prefix .. unit
end

local function convert_units_with_differing_edges(value: number, base: string, prev: number?): (number, string, number)
    local sgn = math.sign(value)
    local abs_value = math.abs(value)

    local order = 0
    while abs_value >= 1000 and _UNITS[order + 1] do
        order += 1
        abs_value /= 1000
    end

    while abs_value ~= 0 and abs_value < 1 and _UNITS[order - 1] do
        order -= 1
        abs_value *= 1000
    end
    
    local unit = _UNITS[order]

    if prev then
        local prev_unit = _UNITS[prev]
        local diff = prev_unit.order - unit.order
        if diff == 1 and value >= prev_unit.to_smaller and _UNITS[order + 1] then
            abs_value /= 1000
            order += 1
        elseif diff == -1 and value <= unit.to_larger and _UNITS[order - 1] then
            abs_value *= 1000
            order -= 1
        end
    end

    return sgn * abs_value, _UNITS[order].prefix .. base, order
end

return table.freeze({
    convert_units = convert_units,
    convert_units_with_differing_edges = convert_units_with_differing_edges
})