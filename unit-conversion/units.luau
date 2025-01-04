type Map<K, V> = {[K]: V}

export type Unit = number
export type UnitData = {
    pos: Unit,

    prefix: string,
    base: number,
    to_larger: number,
    to_smaller: number,
}

export type Units = Map<Unit, UnitData>

local UNITS: Units = {
    [4] = {
        pos = 4,

        prefix = "T",
        base = 1e+12,
        to_larger = 1e+12 + 1e+4,
        to_smaller = 1e+12 - 1e+4
    },
    [3] = {
        pos = 3,
        
        prefix = "G",
        base = 1e+9,
        to_larger = 1e+9 + 1e+3,
        to_smaller = 1e+9 - 1e+3
    },
    [2] = {
        pos = 2,

        prefix = "M",
        base = 1e+6,
        to_larger = 1e+6 + 1e+2,
        to_smaller = 1e+6 - 1e+2
    },
    [1] = {
        pos = 1,

        prefix = "k",
        base = 1000,
        to_larger = 1200,
        to_smaller = 980
    },
    [0] = {
        pos = 0,

        prefix = "",
        base = 1,
        to_larger = 1.2,
        to_smaller = 0.98
    },
    [-1] = {
        pos = -1,

        prefix = "m",
        base = 0.001,
        to_larger = 0.0012,
        to_smaller = 0.0008
    },
    [-2] = {
        pos = -2,

        prefix = "u",
        base = 1e-6,
        to_larger = 1e-6 + 2e-7,
        to_smaller = 1e-6 - 4e-7
    },
    [-3] = {
        pos = -3,

        prefix = "n",
        base = 1e-9,
        to_larger = 1e-9 + 2e-10,
        to_smaller = 1e-9 - 6e-10
    },
    [-4] = {
        pos = -4,

        prefix = "p",
        base = 1e-12,
        to_larger = 1e-12 + 2e-13,
        to_smaller = 1e-12 - 8e-13
    }
}

local function convert_units(value: number, base: string): (number, string, Unit)
    local sgn = math.sign(value)
    local abs_value = math.abs(value)

    local pos = 0
    local unit = UNITS[pos]
    local min_value = unit.base
    while abs_value >= min_value and unit do
        local next_pos = pos + 1
        local next_unit = UNITS[next_pos]
        if not next_unit then
            break
        end

        pos = next_pos
        abs_value /= (next_unit.base / unit.base)
        unit = next_unit
    end

    while abs_value ~= 0 and abs_value < 1 and unit do
        local next_pos = pos - 1
        local next_unit = UNITS[next_pos]
        if not next_unit then
            break
        end

        pos = next_pos
        abs_value *= (unit.base / next_unit.base)
        unit = next_unit
    end

    return sgn * abs_value, unit.prefix .. base, pos
end

local function convert_units_with_differing_edges(value: number, base: string, prev: number?): (number, string, Unit)
    local sgn = math.sign(value)
    local abs_value = math.abs(value)

    local pos = 0
    local unit = UNITS[pos]
    local min_value = unit.base
    while abs_value >= min_value and unit do
        local next_pos = pos + 1
        local next_unit = UNITS[next_pos]
        if not next_unit then
            break
        end

        pos = next_pos
        abs_value /= (next_unit.base / unit.base)
        unit = next_unit
    end

    while abs_value ~= 0 and abs_value < 1 and unit do
        local next_pos = pos - 1
        local next_unit = UNITS[next_pos]
        if not next_unit then
            break
        end

        pos = next_pos
        abs_value *= (unit.base / next_unit.base)
        unit = next_unit
    end

    if prev then
        local prev_unit = UNITS[prev]
        local diff = prev_unit.pos - unit.pos
        
        if diff == 1 and value >= prev_unit.to_smaller then
            pos += 1
            abs_value /= (prev_unit.base / unit.base)
            unit = prev_unit
        elseif diff == -1 and value <= unit.to_larger then
            pos -= 1
            abs_value *= (unit.base / prev_unit.base)
            unit = prev_unit
        end
    end

    return sgn * abs_value, unit.prefix .. base, pos
end

return table.freeze({
    UNITS = UNITS,

    convert_units = convert_units,
    convert_units_with_differing_edges = convert_units_with_differing_edges
})