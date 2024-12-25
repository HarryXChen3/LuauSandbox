local testkit = require("./../testkit")

local TEST, CASE, CHECK, FINISH = testkit.test()

do
    local average = require("./average")
    local function COMPUTE(n: number, samples: number)
        local N = n
        local SAMPLES = samples
        local avg = average(SAMPLES)

        local sum = 0
        local ignore_sum = 0
        local _avg__compute = avg.compute
        for i = 1, N do
            local out = _avg__compute(avg, i)
            sum += i

            if i <= SAMPLES then
                CHECK(sum / i == out)
            else
                ignore_sum += (i - SAMPLES)
                CHECK((sum - ignore_sum) / SAMPLES == out)
            end
        end
    end

    TEST("average:compute()", function()
        do CASE "compute n == samples, 1 sample"
            COMPUTE(1, 1)
        end

        do CASE "compute n > samples, 1 samples"
            COMPUTE(1, 4)
        end

        do CASE "compute n == samples, 2 samples"
            COMPUTE(2, 2)
        end

        do CASE "compute n < samples, 2 samples"
            COMPUTE(1, 2)
        end

        do CASE "compute n > samples, 2 samples"
            COMPUTE(4, 2)
        end

        do CASE "compute n == samples, 10 samples"
            COMPUTE(10, 10)
        end

        do CASE "compute n < samples, 10 samples"
            COMPUTE(5, 10)
        end

        do CASE "compute n > samples, 10 samples"
            COMPUTE(15, 10)
        end

        do CASE "compute n << samples, 1e4 samples"
            COMPUTE(10, 1e4)
        end

        do CASE "compute n >> samples, 10 samples"
            COMPUTE(1e4, 10)
        end

        do CASE "compute n >> samples, 1e2 samples"
            COMPUTE(1e6, 1e2)
        end
    end)
end

local success = FINISH()
if not success then error(nil, 0) end