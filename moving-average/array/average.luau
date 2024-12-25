--!native
--!optimize 2

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

export type MovingAverage = {
    _average: number,
    _samples: number,
    _n: number,
    _initial_sum: number,
    _window: Array<number>,

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
    if n < samples then
        local next_n = n + 1
        window[next_n] = num
        self._n = next_n

        local next_sum = self._initial_sum + num
        self._initial_sum = next_sum

        local next_average = next_sum / next_n
        self._average = next_average
        return next_average
    else
        local next_average = next_avg(samples, average, window[1], num)
        table.move(window, 2, n, 1)
        window[n] = num

        self._average = next_average
        return next_average
    end
end

local TABLE_MAX_N = 2^26
return function(samples: number): MovingAverage
    if samples <= 0 then
        error("samples cannot be <= 0!")
    elseif samples > TABLE_MAX_N then
        error(`samples cannot be > {TABLE_MAX_N}!`)
    end

    local average: MovingAverage = {
        _samples = samples,
        _average = 0,
        _n = 0,
        _initial_sum = 0,
        _window = (table.create(samples, false) :: unknown) :: Array<number>,

        compute = compute
    }

    return average
end
