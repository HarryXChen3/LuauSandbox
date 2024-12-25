local function cast(): ...number
    local t = {1, 2, 3, 4, 5, 6}
    return unpack(t) :: number
end

local function no_cast(): ...number
    local t = {1, 2, 3, 4, 5, 6}
    return unpack(t)
end

print("cast:", cast())
print("no_cast:", no_cast())