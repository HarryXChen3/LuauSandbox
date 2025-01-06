--!native
--!optimize 2

type Map<K, V> = {[K]: V}
type Array<T> = {[number]: T}

export type Set<T> = {
    size: number,
    sparse: Map<T, number?>,
    dense: Array<T>,

    add: (self: Set<T>, k: T) -> (),
    remove: (self: Set<T>, k: T) -> (),
    has: (self: Set<T>, k: T) -> boolean,
    clear: (self: Set<T>) -> (),
    iter: (self: Set<T>) -> (() -> (number, T))
}

export type ReadonlySet<T> = {
    size: number,
    has: (self: ReadonlySet<T>, k: T) -> boolean,
    iter: (self: ReadonlySet<T>) -> (() -> (number, T))
}

export type Queue<T> = {
    size: number,
    sparse: Map<T, number?>,
    dense: Array<T>,

    add: (self: Queue<T>, k: T) -> (),
    has: (self: Queue<T>, k: T) -> boolean,
    clear: (self: Queue<T>) -> (),
    iter: (self: Queue<T>) -> (() -> (number, T))
}

local function add<T>(self: Set<T>, k: T)
    if self.sparse[k] ~= nil then return end

    local n = self.size + 1; self.size = n
    self.sparse[k] = n
    self.dense[n] = k
end

local function remove<T>(self: Set<T>, k: T)
    local i = self.sparse[k]
    if i == nil then return end

    local n = self.size; self.size = n - 1
    local last = self.dense[n]

    self.dense[i] = last
    self.dense[n] = nil

    self.sparse[last] = i
    self.sparse[k] = nil
end

local function has<T>(self: Set<T>, k: T)
    return self.sparse[k] ~= nil
end

local function clear<T>(self: Set<T>)
    self.size = 0
    table.clear(self.sparse)
    table.clear(self.dense)
end

local function iter<T>(self: Set<T>): () -> (number, T)
    local arr = self.dense
    local n = self.size
    local i = 0
    return function()
        i += 1

        if i <= n then
            return i, arr[i]
        else
            return nil :: any, nil :: any
        end
    end
end

return function<T>(elements: Array<T>?): Set<T>
    local set: Set<T> = {
        size = 0,
        sparse = {},
        dense = {},

        add = add,
        remove = remove,
        has = has,
        clear = clear,
        iter = iter,
    }

    if elements then
        for _, v in elements do
            set:add(v)
        end
    end

    return set
end