local vide = require("./packages/vide")

local function insert<T>(src: vide.source<Array<T>>, t: T)
    local arr = vide.untrack(src)
    table.insert(arr, t)
    src(arr)
end

local function randfloat(from: number, to: number): number
    return math.random(from, to) + math.random()
end

local function Tile(position: () -> vector)
    print("rec.position:", debug.info(position, "f"))

    return vide.create "Frame" {
        Position = function()
            local p = position()
            print("read.position:", debug.info(position, "f"))
            print("read.position.val:", p)
            return p
        end,
    }
end

local function Draggable(position: vide.source<vector>): (vector) -> ()
    local input_pos = vide.source(vector.zero)

    vide.effect(function()
        local new_pos: vector = input_pos()

        print("set.position:", debug.info(position, "f"))
        print("set.position.val:", new_pos)

        position(new_pos)
    end)

    return input_pos
end

type _Instance = unknown
local function Tileable(component: (position: vide.source<vector>) -> _Instance): (vide.source<Array<_Instance>>, Array<thread>) 
    local tiles: vide.source<Array<_Instance>> = vide.source({})
    local tile: _Instance = nil

    local threads: Array<thread> = {}
    local destroys: Array<() -> ()> = {}
    vide.cleanup(function()
        for _, destroy in destroys do
            destroy()
        end
    end)

    vide.effect(function()
        if not tile then
            local new_pos = vide.source(vector.zero)
            local new = vide.untrack(function()
                return component(new_pos)
            end)

            local destroy, co = vide.root(function()
                local set = Draggable(new_pos)
                
                local run = true
                local co = coroutine.create(function()
                    while true do
                        if not run then
                            break
                        end

                        set(vector.create(randfloat(0, 1920), randfloat(0, 1080), 0))
                        coroutine.yield()
                    end
                end)

                vide.cleanup(function()
                    run = false

                    local success, err = pcall(coroutine.close, co)
                    if not success then
                        error(err)
                    end
                end)

                return co
            end)

            tile = new_pos

            table.insert(threads, co)
            table.insert(destroys, destroy)
            insert(tiles, new)
        end
    end)

    return tiles, threads
end

local function App(): (_Instance, Array<thread>)
    local tileable, threads = Tileable(Tile)
    return 
        vide.create "ScreenGui" {
            vide.create "Frame" {
                tileable
            }
        },
        threads
end

vide.root(function()
    local _, threads = App()
    while true do
        for _, thread in threads do
            coroutine.resume(thread)
        end
    end
end)