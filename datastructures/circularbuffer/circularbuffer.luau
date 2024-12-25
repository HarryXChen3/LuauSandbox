--!native
--!optimize 2

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

export type CircularBuffer<T> = {
    head: number,
    tail: number,

    size: number,
    capacity: number,
    buf: Array<T>,

    add: (self: CircularBuffer<T>, k: T) -> (),
    remove: (self: CircularBuffer<T>) -> T,
    clear: (self: CircularBuffer<T>) -> (),
    iter: (self: CircularBuffer<T>) -> (() -> (number, T))
}

local function add<T>(self: CircularBuffer<T>, k: T)
    local head = self.head
    local tail = self.tail
    local size = self.size
    local capacity = self.capacity

    if tail >= head and size == capacity then
        self.head = (head % capacity) + 1
    else
        self.size += 1
    end

    local n = (tail % capacity) + 1
    self.buf[tail] = k
    self.tail = n
end

local function remove<T>(self: CircularBuffer<T>): T
    if self.size <= 0 then
        error("cannot remove from empty queue!")
    end

    local head = self.head
    local k = self.buf[head]

    self.buf[head] = nil
    self.head = (head % self.capacity) + 1
    self.size -= 1

    return k
end

local function clear<T>(self: CircularBuffer<T>)
    self.head = 1
    self.tail = 1
    self.size = 0
end

local function iter<T>(self: CircularBuffer<T>): () -> (number, T)
    local arr = self.buf
    local tail = if self.tail - 1 <= 0 then self.capacity + 1 else self.tail
    local i = self.head - 1
    return function()
        i += 1

        if i < tail then
            return i, arr[i]
        else
            return nil :: any, nil :: any
        end
    end
end

return function<T>(capacity: number): CircularBuffer<T>
    local queue: CircularBuffer<T> = {
        head = 1,
        tail = 1,

        size = 0,
        capacity = capacity,
        buf = table.create(capacity, false) :: any,

        add = add,
        remove = remove,
        clear = clear,
        iter = iter,
    }

    return queue
end