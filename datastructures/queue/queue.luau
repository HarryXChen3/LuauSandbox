--!native
--!optimize 2

export type Queue<T> = {
    first: number,
    last: number,
    e: Array<T>,

    enqueue: (self: Queue<T>, v: T) -> (),
    peek: (self: Queue<T>) -> T,
    dequeue: (self: Queue<T>) -> T,
    size: (self: Queue<T>) -> number,
    is_empty: (self: Queue<T>) -> boolean,
    clear: (self: Queue<T>) -> ()
}

local function enqueue<T>(self: Queue<T>, v: T)
    local last = self.last + 1
    self.last = last
    self.e[last] = v
end

local function peek<T>(self: Queue<T>): T
    return self.e[self.first]
end

local function dequeue<T>(self: Queue<T>): T
    local first = self.first
    if first > self.last then
        error("cannot dequeue from empty queue!", 2)
    end

    local value = self.e[first]
    self.e[first] = nil
    self.first += 1

    return value
end

local function size<T>(self: Queue<T>): number
    return self.last - self.first + 1
end

local function is_empty<T>(self: Queue<T>): boolean
    return self.first > self.last
end

local function clear<T>(self: Queue<T>)
    self.first = 1
    self.last = 0
end

return function<T>(elements: Array<T>?): Queue<T>
    local queue: Queue<T> = {
        first = 1,
        last = 0,
        e = {},

        enqueue = enqueue,
        peek = peek,
        dequeue = dequeue,
        size = size,
        is_empty = is_empty,
        clear = clear
    }

    if elements then
        for _, v in elements do
            queue:enqueue(v)
        end
    end

    return queue
end