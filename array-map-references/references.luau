type T = {
    a: Map<string, number>,
    b: Array<number>,
    c: number
}

local t: T = {
    a = {hi = 1, bye = 2},
    b = {1, 2, 3, 4, 5},
    c = 0
}

local function dump(o: {[any]: any}): string
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function f(ref: T): T
    local a = ref.a
    a["nice weather today!"] = 3
    ref.a["not really, its raining..."] = 4

    local b = ref.b
    table.insert(b, 6)
    table.insert(ref.b, 7)

    local c = ref.c
    c += 1
    ref.c += 1

    print(`inside: {dump(ref)}`)
    return ref
end

local r = f(t)
print(`outside-direct: {dump(t)}`)
print(`outside-return: {dump(r)}`)