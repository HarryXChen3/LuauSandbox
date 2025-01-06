local testkit = require("./../testkit")

local BENCH, START = testkit.benchmark()

local function TITLE(name: string)
    print()
    print(testkit.color.white(name))
end

do
    local set = require("./set")
    local queue: <T>() -> set.Queue<T> = set

    do TITLE "array"
        BENCH("table.insert() 1..1e6", function()
            local N = 1e6

            local t = {}
            for i = 1, START(N) do
                table.insert(t, i)
            end
        end)

        BENCH("set 1..1e6", function()
            local N = 1e6

            local t = {}
            for i = 1, START(N) do
                t[i] = i
            end
        end)

        BENCH("set 1..1e6, presized", function()
            local N = 1e6

            local t = table.create(N, false) :: any
            for i = 1, START(N) do
                t[i] = i
            end
        end)
    end

    do TITLE "queue:add()"
        BENCH("add 1..1e6", function()
            local N = 1e6
            local queue = queue()

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("start filled, add 1..1e6", function()
            local N = 1e6
            local queue = queue()

            for i = 1, N do
                queue:add(i)
            end

            for i = N + 1, START(N + N + 1) do
                queue:add(i)
            end
        end)
    end

    do TITLE "queue:clear()"
        BENCH("add 1..1e6, 1e6 capacity, clear", function()
            local N = 1e6
            local queue = queue()

            for n = 1, N do
                queue:add(n)
            end

            START(N)

            queue:clear()
        end)
    end
end