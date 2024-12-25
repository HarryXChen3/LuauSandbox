--!native
--!optimize 2

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

export type CircularQueue<T> = {
    head: number,
    tail: number,

    size: number,
    capacity: number,
    sparse: Map<T, number?>,
    dense: Array<T>,

    add: (self: CircularQueue<T>, k: T) -> (),
    remove: (self: CircularQueue<T>) -> T,
    has: (self: CircularQueue<T>, k: T) -> boolean,
    clear: (self: CircularQueue<T>) -> (),
    iter: (self: CircularQueue<T>) -> (() -> (number, T))
}

local function add<T>(self: CircularQueue<T>, k: T)
    if self.sparse[k] ~= nil then
        error("cannot add duplicate element to set-backed queue!")
    end

    local head = self.head
    local tail = self.tail
    local size = self.size
    local capacity = self.capacity

    if tail >= head and size == capacity then
        self.sparse[self.dense[head]] = nil
        self.head = (head % capacity) + 1
    else
        self.size += 1
    end

    local n = (tail % capacity) + 1
    self.sparse[k] = tail
    self.dense[tail] = k
    self.tail = n
end

local function remove<T>(self: CircularQueue<T>): T
    if self.size <= 0 then
        error("cannot remove from empty queue!")
    end

    local head = self.head
    local k = self.dense[head]

    self.sparse[k] = nil
    self.dense[head] = nil
    self.head = (head % self.capacity) + 1
    self.size -= 1

    return k
end

local function has<T>(self: CircularQueue<T>, k: T)
    return self.sparse[k] ~= nil
end

local function clear<T>(self: CircularQueue<T>)
    self.head = 1
    self.tail = 1
    self.size = 0
    table.clear(self.sparse)
    table.clear(self.dense)
end

local function iter<T>(self: CircularQueue<T>): () -> (number, T)
    local arr = self.dense
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

return function<T>(capacity: number): CircularQueue<T>
    local queue: CircularQueue<T> = {
        head = 1,
        tail = 1,

        size = 0,
        capacity = capacity,
        sparse = {},
        dense = table.create(capacity, false) :: any,

        add = add,
        remove = remove,
        has = has,
        clear = clear,
        iter = iter,
    }

    return queue
end