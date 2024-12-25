local arr: Array<string> = {}
local function iter(): () -> (number?, string?)
    local n = #arr
    local i = 0
    return function()
        i += 1

        if i <= n then
            return i, arr[i]
        else
            return nil, nil
        end
    end
end

for i, str in iter() do
    
end
