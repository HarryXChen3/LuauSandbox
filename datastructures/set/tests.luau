local testkit = require("./../testkit")

local TEST, CASE, CHECK, FINISH = testkit.test()
local function ARRAY_EQ<T>(a: Array<T>, b: Array<T>): boolean
    local n = #a
    local n_b = #b
    if n ~= n_b then
        return false
    end

    for i = 1, n do
        if a[i] ~= b[i] then
            return false
        end
    end

    return true
end

local function MAP_EQ<K, V>(a: Map<K, V>, b: Map<K, V>): boolean
    for k, v in a do
        if v ~= b[k] then
            return false
        end
    end

    return true
end

do
    local set = require("./set")
    local function _REPR<T>(set: set.Set<T>): string
        local s = "set {\n"
        s ..= ` size={set.size}\n`

        local sparse = "{"
        for k, v in set.sparse do
            sparse ..= `[{k}]={v}, `
        end
        sparse ..= "}"
        s ..= ` sparse={sparse}\n`

        local dense = "{"
        for i, v in set.dense do
            dense ..= `[{i}]={v}, `
        end
        dense ..= "}"

        s ..= ` dense={dense}\n`
        s ..= "}"
        return s
    end

    local function SPARSE<T>(dense: Array<T>): Map<T, number>
        local sparse: Map<T, number> = {}
        for i, v in dense do
            sparse[v] = i
        end

        return sparse
    end

    TEST("set:add()", function()
        do CASE "add n = 5"
            local N = 5
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            CHECK(s.size == N)

            local dense = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ(s.dense, dense))
            CHECK(MAP_EQ(s.sparse, SPARSE(dense)))
        end

        do CASE "add n = 1e2"
            local N = 1e2
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            CHECK(s.size == N)
        end

        do CASE "add n = 1e4"
            local N = 1e4
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            CHECK(s.size == N)
        end
    end)

    TEST("set:remove()", function()
        do CASE "add n, remove n"
            local N = 25
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = 1, N do
                s:remove(i)
            end

            CHECK(s.size == 0)

            local dense = {}
            CHECK(ARRAY_EQ(s.dense, dense))
            CHECK(MAP_EQ(s.sparse, SPARSE(dense)))
        end

        do CASE "add N, remove N"
            local N = 100
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = 1, N do
                s:remove(i)
            end

            CHECK(s.size == 0)

            local dense = {}
            CHECK(ARRAY_EQ(s.dense, dense))
            CHECK(MAP_EQ(s.sparse, SPARSE(dense)))
        end

        do CASE "add N, remove n"
            local N = 100
            local N_0 = 50
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = 1, N_0 do
                s:remove(i)
            end

            CHECK(s.size == N - N_0)
        end
    end)

    TEST("set:has()", function()
        do CASE "add n, has n"
            local N = 25
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = 1, N do
                CHECK(s:has(i))
            end
        end

        do CASE "add N, has N"
            local N = 100
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = 1, N do
                CHECK(s:has(i))
            end
        end

        do CASE "add N, has N >> N"
            local N = 100
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            for i = -N, 0 do
                CHECK(not s:has(i))
            end

            for i = 1, N do
                CHECK(s:has(i))
            end

            for i = N + 1, 2 * N do
                CHECK(not s:has(i))
            end
        end
    end)

    TEST("set:clear()", function()
        do CASE "add n, clear"
            local N = 25
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            s:clear()

            CHECK(s.size == 0)

            local dense = {}
            CHECK(ARRAY_EQ(s.dense, dense))
            CHECK(MAP_EQ(s.sparse, SPARSE(dense)))
        end

        do CASE "add n, clear, add n"
            local N = 25
            local s = set()

            for i = 1, N do
                s:add(i)
            end

            s:clear()

            for i = 1, N do
                s:add(i)
            end

            CHECK(s.size == N)

            local dense = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                            11, 12, 13, 14, 15, 16, 17, 18,
                            19, 20, 21, 22, 23, 24, 25}
            CHECK(ARRAY_EQ(s.dense, dense))
            CHECK(MAP_EQ(s.sparse, SPARSE(dense)))
        end
    end)
end

local success = FINISH()
if not success then error(nil, 0) end

return nil