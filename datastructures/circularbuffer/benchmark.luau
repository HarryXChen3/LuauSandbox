local testkit = require("./../testkit")

local BENCH, START = testkit.benchmark()

local function TITLE(name: string)
    print()
    print(testkit.color.white(name))
end

do
    local circularbuffer = require("./circularbuffer")
    local circularbuffer_f64 = require("./circularbuffer_f64")

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

    do TITLE "circularbuffer:add()"
        BENCH("add 1..1e6, 1e6 capacity", function()
            local N = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("add 1..1e6, 1e4 capacity", function()
            local N = 1e6
            local CAPACITY = 1e4
            local queue = circularbuffer(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("add 1..1e6, 1e2 capacity", function()
            local N = 1e6
            local CAPACITY = 1e2
            local queue = circularbuffer(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("start filled, add 1..1e6, 1e2 capacity", function()
            local N = 1e6
            local CAPACITY = 1e2
            local queue = circularbuffer(CAPACITY)

            for i = 1, CAPACITY do
                queue:add(i)
            end

            for i = CAPACITY + 1, START(CAPACITY + N + 1) do
                queue:add(i)
            end
        end)

        BENCH("start filled, add 1..1e6, 10 capacity", function()
            local N = 1e6
            local CAPACITY = 10
            local queue = circularbuffer(CAPACITY)

            for i = 1, CAPACITY do
                queue:add(i)
            end

            for i = CAPACITY + 1, START(CAPACITY + N + 1) do
                queue:add(i)
            end
        end)
    end

    do TITLE "circularbuffer:remove()"
        BENCH("add 1..1e6, 1e6 capacity, remove 1..1e2", function()
            local N = 1e6
            local REMOVE = 1e2
            local CAPACITY = 1e6
            local queue = circularbuffer(CAPACITY)

            for i = 1, N do
                queue:add(i)
            end

            for i = 1, START(REMOVE) do
                queue:remove()
            end
        end)

        BENCH("add 1..1e6, 1e6 capacity, remove 1..1e6", function()
            local N = 1e6
            local REMOVE = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer(CAPACITY)

            for i = 1, N do
                queue:add(i)
            end

            for i = 1, START(REMOVE) do
                queue:remove()
            end
        end)
    end

    do TITLE "circularbuffer:clear()"
        BENCH("add 1..1e6, 1e6 capacity, clear", function()
            local N = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer(CAPACITY)

            for n = 1, N do
                queue:add(n)
            end

            START(N)

            queue:clear()
        end)
    end

    do TITLE "circularbuffer_f64:add()"
        BENCH("add 1..1e6, 1e6 capacity", function()
            local N = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("add 1..1e6, 1e4 capacity", function()
            local N = 1e6
            local CAPACITY = 1e4
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("add 1..1e6, 1e2 capacity", function()
            local N = 1e6
            local CAPACITY = 1e2
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, START(N) do
                queue:add(i)
            end
        end)

        BENCH("start filled, add 1..1e6, 1e2 capacity", function()
            local N = 1e6
            local CAPACITY = 1e2
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                queue:add(i)
            end

            for i = CAPACITY + 1, START(CAPACITY + N + 1) do
                queue:add(i)
            end
        end)

        BENCH("start filled, add 1..1e6, 10 capacity", function()
            local N = 1e6
            local CAPACITY = 10
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, CAPACITY do
                queue:add(i)
            end

            for i = CAPACITY + 1, START(CAPACITY + N + 1) do
                queue:add(i)
            end
        end)
    end

    do TITLE "circularbuffer_f64:remove()"
        BENCH("add 1..1e6, 1e6 capacity, remove 1..1e2", function()
            local N = 1e6
            local REMOVE = 1e2
            local CAPACITY = 1e6
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                queue:add(i)
            end

            for i = 1, START(REMOVE) do
                queue:remove()
            end
        end)

        BENCH("add 1..1e6, 1e6 capacity, remove 1..1e6", function()
            local N = 1e6
            local REMOVE = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer_f64(CAPACITY)

            for i = 1, N do
                queue:add(i)
            end

            for i = 1, START(REMOVE) do
                queue:remove()
            end
        end)
    end

    do TITLE "circularbuffer_f64:clear()"
        BENCH("add 1..1e6, 1e6 capacity, clear", function()
            local N = 1e6
            local CAPACITY = 1e6
            local queue = circularbuffer_f64(CAPACITY)

            for n = 1, N do
                queue:add(n)
            end

            START(N)

            queue:clear()
        end)
    end
end