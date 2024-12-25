export type Source<T> = (() -> T) & ((value: T) -> T)
export type N = number
export type S = {
    a: number,
    b: number
}

local t = {
    SourceA = function() return {} end :: Source<Array<N>>,
    SourceB = function() return {} end :: Source<Array<N>>,
    SourceC = function() return {} end :: Source<Array<N>>
}

local mt = {}

function mt.insert<T>(into: Source<Array<T>>, e: T): Array<T>
    return {}
end

function mt.set_remote_scheduler_data(a: N)
    
end

function mt.get_remote_scheduler_data(a: N): Source<S>
    return function()
        return {
            a = 1,
            b = 2
        }
    end
end

return setmetatable(t, {__index = mt})