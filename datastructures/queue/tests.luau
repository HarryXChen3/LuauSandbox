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

do
    local queue = require("./queue")
    local function _REPR<T>(queue: queue.Queue<T>): string
        local s = "queue {\n"
        s ..= ` first={queue.first}\n`
        s ..= ` last={queue.last}\n`
        s ..= ` size={queue:size()}\n`

        local e = "{"
        for k, v in queue.e do
            e ..= `[{k}]={v}, `
        end
        e ..= "}"
        s ..= ` e={e}\n`

        return s
    end

    TEST("queue:enqueue()", function()
        do CASE "add n = 5"
            local N = 5
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q.first == 1)
            CHECK(q.last == N)

            local e = {1, 2, 3, 4, 5}
            CHECK(ARRAY_EQ(q.e, e))
        end

        do CASE "add n = 1e2"
            local N = 1e2
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q.first == 1)
            CHECK(q.last == N)
        end

        do CASE "add n = 1e4"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q.first == 1)
            CHECK(q.last == N)
        end
    end)

    TEST("queue:peek()", function()
        do CASE "add n, peek n"
            local N = 5
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            for i = 1, N do
                CHECK(q:peek() == i)
                q:dequeue()
            end
        end

        do CASE "add N, peek N"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            for i = 1, N do
                CHECK(q:peek() == i)
                q:dequeue()
            end
        end
    end)

    TEST("queue:dequeue()", function()
        do CASE "add n, dequeue n"
            local N = 5
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            for i = 1, N do
                CHECK(q:dequeue() == i)
            end

            CHECK(q.first == N + 1)
            CHECK(q.last == N)

            local e = {}
            CHECK(ARRAY_EQ(q.e, e))
        end

        do CASE "add N, dequeue N"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            for i = 1, N do
                CHECK(q:dequeue() == i)
            end

            CHECK(q.first == N + 1)
            CHECK(q.last == N)

            local e = {}
            CHECK(ARRAY_EQ(q.e, e))
        end
    end)

    TEST("queue:size()", function()
        do CASE "add n, size"
            local N = 5
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q:size() == N)
        end

        do CASE "add N, size"
            local N = 1e6
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q:size() == N)
        end
    end)

    TEST("queue:is_empty()", function()
        do CASE "add 0, is_empty"
            local q = queue()

            CHECK(q:is_empty())
        end

        do CASE "add n, is_empty"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(not q:is_empty())
        end

        do CASE "add n, remove n, is_empty"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            for i = 1, N do
                q:dequeue()
            end

            CHECK(q:is_empty())
        end

        do CASE "add n, clear, is_empty"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            q:clear()

            CHECK(q:is_empty())
        end
    end)

    TEST("queue:clear()", function()
        do CASE "add n, clear"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            q:clear()

            CHECK(q.first == 1)
            CHECK(q.last == 0)
        end

        do CASE "add n, clear, add n"
            local N = 1e4
            local q = queue()

            for i = 1, N do
                q:enqueue(i)
            end

            q:clear()

            for i = 1, N do
                q:enqueue(i)
            end

            CHECK(q.first == 1)
            CHECK(q.last == N)
        end
    end)
end

local success = FINISH()
return function()
    if not success then error(nil, 0) end
end