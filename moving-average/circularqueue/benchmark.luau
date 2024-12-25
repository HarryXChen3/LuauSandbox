local testkit = require("./../testkit")

local BENCH, START = testkit.benchmark()

local function TITLE(name: string)
    print()
    print(testkit.color.white(name))
end

do
    local average = require("./average")

    do TITLE "average:compute()"
        BENCH("compute 1..1e2, 1e2 samples", function()
            local N = 1e2
            local SAMPLES = 1e2
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e4, 1e6 samples", function()
            local N = 1e4
            local SAMPLES = 1e6
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e6, 1e6 samples", function()
            local N = 1e6
            local SAMPLES = 1e6
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e4, 1 samples", function()
            local N = 1e4
            local SAMPLES = 1
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e4, 10 samples", function()
            local N = 1e4
            local SAMPLES = 10
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e4, 1e2 samples", function()
            local N = 1e4
            local SAMPLES = 1e2
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)

        BENCH("compute 1..1e6, 1e4 samples", function()
            local N = 1e6
            local SAMPLES = 1e4
            local avg = average(SAMPLES)

            for i = 1, START(N) do
                avg:compute(i)
            end
        end)
    end
end