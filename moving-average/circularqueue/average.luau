--!native
--!optimize 2
local circularqueue = require("./../../datastructures/circularqueue/circularqueue")

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

type CircularQueue = circularqueue.CircularQueue<number>
export type MovingAverage = {
    _average: number,
    _samples: number,
    _n: number,
    _initial_sum: number,
    _window: CircularQueue,

    compute: (self: MovingAverage, n: number?) -> number,
}

local function next_avg(n: number, prev_avg: number, last_n: number, next_n: number): number
    return prev_avg + ((next_n - last_n) / n)
end

local function compute(self: MovingAverage, num: number?): number
    local average = self._average
    if not num then
        return average
    end

    local n = self._n
    local samples = self._samples
    local window = self._window
    local window_dense = window.dense
    if n < samples then
        local next_n = n + 1
        self._n = next_n

        window:add(num)

        local next_sum = self._initial_sum + num
        self._initial_sum = next_sum

        local next_average = next_sum / next_n
        self._average = next_average
        return next_average
    else
        local next_average = next_avg(samples, average, window_dense[window.tail], num)
        self._average = next_average

        window:add(num)

        return next_average
    end
end

return function(samples: number): MovingAverage
    local average: MovingAverage = {
        _samples = samples,
        _average = 0,
        _n = 0,
        _initial_sum = 0,
        _window = circularqueue(samples),

        compute = compute
    }

    return average
end