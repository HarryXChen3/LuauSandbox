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

local function BUF(a: Array<number>): buffer
    local OFFSET = 8

    local size = #a
    local buf = buffer.create(size * OFFSET)
    for i = 0, size - 1 do
        local n = a[i + 1]
        if n == nil then
            continue
        end

        buffer.writef64(buf, i * OFFSET, n)
    end

    return buf
end

local function BUF_EQ_IGNORE_SIZE(a: buffer, b: buffer, offset: number?, len: number?): boolean
    local n = buffer.len(a)
    local n_b = buffer.len(b)
    if n_b < n then
        n = n_b
    end

    local OFFSET = 8
    local from = if offset then offset * OFFSET else 0
    local to = if len then math.min(n, (from + len) * OFFSET) - 1 else n - 1
    for i = from, to, OFFSET do
        local lhs = buffer.readf64(a, i)
        local rhs = buffer.readf64(b, i)

        if lhs ~= rhs then
            return false
        end
    end

    return true
end

do
    local circularbuffer = require("./circularbuffer")
    local function _REPR<T>(cb: circularbuffer.CircularBuffer<T>): string
        local s = "circularbuffer {\n"
        s ..= ` head={cb.head}\n`
        s ..= ` tail={cb.tail}\n`
        s ..= ` size={cb.size}\n`
        s ..= ` capacity={cb.capacity}\n`

        local buf = "{"
        for i, v in cb.buf do
            buf ..= `[{i}]={v}, `
        end
        buf ..= "}"

        s ..= ` buf={buf}\n`
        s ..= "}"
        return s
    end

    TEST("circularbuffer:add()", function()
        do CASE "add n < capacity"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            CHECK(c.size == N)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == N + 1)

            local buf = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity"
            local CAPACITY = 5
            local c = circularbuffer(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local buf = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity + 1"
            local CAPACITY = 5
            local c = circularbuffer(CAPACITY)

            for i = 1, CAPACITY + 1 do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == 2)

            local buf = {6, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == 2 * capacity"
            local CAPACITY = 5
            local c = circularbuffer(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local buf = {6, 7, 8, 9, 10}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end
    end)

    TEST("circularbuffer:remove()", function()
        do CASE "add n < capacity, remove 1"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local r = c:remove()
            CHECK(r == 1)

            CHECK(c.size == N - 1)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == N + 1)

            local buf = {nil :: any, 2, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n < capacity, remove 2"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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

            local buf = {nil :: any, nil :: any, 3, 4, 5}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n < capacity, remove n"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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

            local buf = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity, remove n"
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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

            local buf = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n > capacity, remove capacity"
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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

            local buf = {}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity, remove 1, add 1"
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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

            local buf = {11, 2, 3, 4, 5, 6, 7, 8, 9, 10}
            CHECK(ARRAY_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add 0, remove 1 throws"
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

            local success, msg = pcall(c.remove, c)
            CHECK(not success)
            CHECK(string.len(msg) > 0)
        end
    end)

    TEST("circularbuffer:iter()", function()
        do CASE "add n < capacity, iter"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer(CAPACITY)

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
            local c = circularbuffer(CAPACITY)

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
            local c = circularbuffer(CAPACITY)

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

do
    local circularbuffer_f64 = require("./circularbuffer_f64")
    local function _REPR(cb: circularbuffer_f64.CircularBuffer_f64): string
        local s = "circularbuffer_f64 {\n"
        s ..= ` head={cb.head}\n`
        s ..= ` tail={cb.tail}\n`
        s ..= ` size={cb.size}\n`
        s ..= ` capacity={cb.capacity}\n`

        local OFFSET = 8
        local buf = cb.buf
        local buf_str = "{"
        for i = 0, buffer.len(buf) - 1, OFFSET do
            buf_str ..= `[{i}]={buffer.readf64(buf, i)}, `
        end
        buf_str ..= "}"

        s ..= ` buf={buf_str}\n`
        s ..= "}"
        return s
    end

    TEST("circularbuffer_f64:add()", function()
        do CASE "add n < capacity"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            CHECK(c.size == N)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 0)
            CHECK(c.tail == N)

            local buf = BUF({1, 2, 3, 4, 5})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity"
            local CAPACITY = 5
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 0)
            CHECK(c.tail == 0)

            local buf = BUF({1, 2, 3, 4, 5})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity + 1"
            local CAPACITY = 5
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY + 1 do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local buf = BUF({6, 2, 3, 4, 5})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == 2 * capacity"
            local CAPACITY = 5
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 0)
            CHECK(c.tail == 0)

            local buf = BUF({6, 7, 8, 9, 10})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end
    end)

    TEST("circularbuffer_f64:remove()", function()
        do CASE "add n < capacity, remove 1"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local r = c:remove()
            CHECK(r == 1)

            CHECK(c.size == N - 1)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == N)

            local buf = BUF({nil :: any, 2, 3, 4, 5})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf, 1))
        end

        do CASE "add n < capacity, remove 2"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local r1 = c:remove()
            CHECK(r1 == 1)

            local r2 = c:remove()
            CHECK(r2 == 2)

            CHECK(c.size == N - 2)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 2)
            CHECK(c.tail == N)

            local buf = BUF({nil :: any, nil :: any, 3, 4, 5})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf, 2))
        end

        do CASE "add n < capacity, remove n"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            for i = 1, N do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == N)
            CHECK(c.tail == N)

            local buf = BUF({})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity, remove n"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            for i = 1, CAPACITY do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 0)
            CHECK(c.tail == 0)

            local buf = BUF({})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n > capacity, remove capacity"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            for i = CAPACITY + 1, 2 * CAPACITY do
                local r = c:remove()
                CHECK(r == i)
            end

            CHECK(c.size == 0)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 0)
            CHECK(c.tail == 0)

            local buf = BUF({})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add n == capacity, remove 1, add 1"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            local r = c:remove()
            CHECK(r == 1)

            c:add(CAPACITY + 1)
            CHECK(c.size == CAPACITY)
            CHECK(c.capacity == CAPACITY)
            CHECK(c.head == 1)
            CHECK(c.tail == 1)

            local buf = BUF({11, 2, 3, 4, 5, 6, 7, 8, 9, 10})
            CHECK(BUF_EQ_IGNORE_SIZE(c.buf, buf))
        end

        do CASE "add 0, remove 1 throws"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            local success, msg = pcall(c.remove, c)
            CHECK(not success)
            CHECK(string.len(msg :: any) > 0)
        end
    end)

    TEST("circularbuffer_f64:iter()", function()
        do CASE "add n < capacity, iter"
            local N = 5
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                c:add(i)
            end

            local expect = 0
            for i, n in c:iter() do
                CHECK(expect == i)
                CHECK(expect == n - 1)
                expect += 1
            end
            CHECK(expect == N)
        end

        do CASE "add n == capacity, iter"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                c:add(i)
            end

            local expect = 0
            for i, n in c:iter() do
                CHECK(expect == i)
                CHECK(expect == n - 1)
                expect += 1
            end
            CHECK(expect == CAPACITY)
        end

        do CASE "add n > capacity, iter"
            local CAPACITY = 10
            local c = circularbuffer_f64(CAPACITY)

            for i = 1, 2 * CAPACITY do
                c:add(i)
            end

            local expect = CAPACITY
            for i, n in c:iter() do
                CHECK(expect - CAPACITY == i)
                CHECK(expect == n - 1)
                expect += 1
            end
            CHECK(expect == 2 * CAPACITY)
        end
    end)
end

local success = FINISH()
if not success then error(nil, 0) end

return nil