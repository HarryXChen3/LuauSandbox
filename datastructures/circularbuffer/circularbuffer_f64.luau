--!native
--!optimize 2

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

export type CircularBuffer_f64 = {
    head: number,
    tail: number,

    size: number,
    capacity: number,
    buf: buffer,

    add: (self: CircularBuffer_f64, k: number) -> (),
    remove: (self: CircularBuffer_f64) -> number,
    clear: (self: CircularBuffer_f64) -> (),
    iter: (self: CircularBuffer_f64) -> (() -> (number, number))
}

local FLOAT64_SIZE = 8

local function add(self: CircularBuffer_f64, k: number)
    local head = self.head
    local tail = self.tail
    local size = self.size
    local capacity = self.capacity

    if tail >= head and size == capacity then
        self.head = (head + 1) % capacity
    else
        self.size += 1
    end

    local n = (tail + 1) % capacity
    buffer.writef64(self.buf, tail * FLOAT64_SIZE, k)
    self.tail = n
end

local function remove(self: CircularBuffer_f64): number
    if self.size <= 0 then
        error("cannot remove from empty queue!")
    end

    local head = self.head
    local buf = self.buf
    local k = buffer.readf64(buf, head * FLOAT64_SIZE)

    self.head = (head + 1) % self.capacity
    self.size -= 1

    return k
end

local function clear<T>(self: CircularBuffer_f64)
    self.head = 0
    self.tail = 0
    self.size = 0
end

local function iter(self: CircularBuffer_f64): () -> (number, number)
    local buf = self.buf
    local tail = if self.tail <= 0 then self.capacity else self.tail
    local i = self.head - 1
    return function()
        i += 1

        if i < tail then
            return i, buffer.readf64(buf, i * FLOAT64_SIZE)
        else
            return nil :: any, nil :: any
        end
    end
end

return function(capacity: number): CircularBuffer_f64
    local queue: CircularBuffer_f64 = {
        head = 0,
        tail = 0,

        size = 0,
        capacity = capacity,
        buf = buffer.create(capacity * FLOAT64_SIZE),

        add = add,
        remove = remove,
        clear = clear,
        iter = iter,
    }

    return queue
end