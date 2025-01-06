local testkit = require("./../testkit")

local TEST, CASE, CHECK, FINISH = testkit.test()
local function ARRAY_EQ_IGNORE_SIZE<T>(a: Array<T>, b: Array<T>): boolean
    local n = #a
    local n_b = #b
    if n_b < n then
        n = n_b
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
    local circularqueue = require("./circularqueue")
    local function _REPR<T>(queue: circularqueue.CircularQueue<T>): string
        local s = "circularqueue {\n"
        s ..= ` head={queue.head}\n`
        s ..= ` tail={queue.tail}\n`
        s ..= ` size={queue.size}\n`
        s ..= ` capacity={queue.capacity}\n`

        local sparse = "{"
        for k, v in queue.sparse do
            sparse ..= `[{k}]={v}, `
        end
        sparse ..= "}"
        s ..= ` sparse={sparse}\n`

        local dense = "{"
        for i, v in queue.dense do
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

    TEST("circularqueue:add()", function()
        do CASE "add n < capacity"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            CHECK(c.size == N)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == N + 1)

            local dense = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity"
            local CAPACITY = 5
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity + 1"
            local CAPACITY = 5
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY + 1 do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == 2)

            local dense = {6, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == 2 * capacity"
            local CAPACITY = 5
            local c = circularqueue(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {6, 7, 8, 9, 10}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end
    end)

    TEST("circularqueue:remove()", function()
        do CASE "add n < capacity, remove 1"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local r = c:remove()
            CHECK(r == 1)

            CHECK(c.size == N - 1)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == N + 1)

            local dense = {nil :: any, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n < capacity, remove 2"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local r1 = c:remove()
            CHECK(r1 == 1)

            local r2 = c:remove()
            CHECK(r2 == 2)

            CHECK(c.size == N - 2)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 3)
            CHECK(c.tail == N + 1)

            local dense = {nil :: any, nil :: any, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n < capacity, remove n"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            for i = 1, N do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == N + 1)
            CHECK(c.tail == N + 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity, remove n"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            for i = 1, CAPACITY do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n > capacity, remove capacity"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            for i = CAPACITY + 1, 2 * CAPACITY do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity, remove 1, add 1"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            local r = c:remove()
            CHECK(r == 1)

            c:add(CAPACITY + 1)
            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == 2)

            local dense = {11, 2, 3, 4, 5, 6, 7, 8, 9, 10}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add 0, remove 1 throws"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            local success, msg = pcall(c.remove, c)
            CHECK(not success)
            CHECK(string.len(msg) > 0)
        end
    end)

    TEST("circularqueue:has()", function()
        do CASE "add n < capacity, has n"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            for i = 1, N do
                CHECK(c:has(i))
            end
        end

        do CASE "add n == capacity, has n"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            for i = 1, CAPACITY do
                CHECK(c:has(i))
            end
        end

        do CASE "add n > capacity, has capacity"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            for i = CAPACITY + 1, 2 * CAPACITY do
                CHECK(c:has(i))
            end
        end
    end)

    TEST("circularqueue:clear()", function()
        do CASE "add n < capacity, clear"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            c:clear()

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity, clear"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            c:clear()
            
            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n > capacity, clear"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            c:clear()
            
            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense)))
        end

        do CASE "add n == capacity, clear, add 1"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            c:clear()
            
            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local dense1 = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense1))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense1)))

            c:add(1)
            
            CHECK(c.size == 1)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 2)

            local dense2 = {1}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.dense, dense2))
            CHECK(MAP_EQ(c.sparse, SPARSE(dense2)))
        end
    end)

    TEST("circularqueue:iter()", function()
        do CASE "add n < capacity, iter"
            local N = 5
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local expect = 1
            for i, n in c:iter() do
                CHECK(expect == i)
                CHECK(expect == n)
                expect += 1
            end
            CHECK(expect == N + 1)
        end

        do CASE "add n == capacity, iter"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            local expect = 1
            for i, n in c:iter() do
                CHECK(expect == i)
                CHECK(expect == n)
                expect += 1
            end
            CHECK(expect == CAPACITY + 1)
        end

        do CASE "add n > capacity, iter"
            local CAPACITY = 10
            local c = circularqueue(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            local expect = CAPACITY + 1
            for i, n in c:iter() do
                CHECK(expect - CAPACITY == i)
                CHECK(expect == n)
                expect += 1
            end
            CHECK(expect == 2 * CAPACITY + 1)
        end
    end)
end

local success = FINISH()
if not success then error(nil, 0) end

return nil