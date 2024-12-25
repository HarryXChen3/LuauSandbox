--!nonstrict
local vide = require("./packages/vide")

local function fix_type<T>(a: unknown): T
    return a :: T
end

local function insert<T>(src: vide.source<Array<T>>, t: T)
    local arr = vide.untrack(src)
    table.insert(arr, t)
    src(arr)
end

local function randfloat(from: number, to: number): number
    return math.random(from, to) + math.random()
end

local function lerpvec(from: vector, to: vector, t: number): vector
    local fx, fy, fz = fix_type(from).X, fix_type(from).Y, fix_type(from).Z
    local tx, ty, tz = fix_type(to).X, fix_type(to).Y, fix_type(to).Z

    return vector.create(
        fx + (tx - fx) * t,
        fy + (ty - fy) * t,
        fz + (tz - fz) * t
    )
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

type _Instance = unknown
type _Action = {
    priority: number,
    callback: (_Instance) -> ()
}
type _UserInputType = unknown
type _UserInputState = unknown
type _InputObject = {
    UserInputType: _UserInputType,
    UserInputState: _UserInputState,
    Position: vector
}

local Enum = {
    UserInputType = {
        MouseMovement = newproxy(),
        MouseButton1 = newproxy(),
        Touch = newproxy()
    },
    UserInputState = {
        Begin = newproxy(),
        End = newproxy()
    }
}

local function Draggable(position: vide.source<vector>): (
    _Action,
    (_InputObject, vector) -> (),
    (_InputObject, boolean) -> (),
    (_InputObject, boolean) -> ()
)
    local dragging = vide.source(false)
    local drag_start = vide.source(vector.zero)

    local start_pos = vide.source(position())
    local input_pos = vide.source(vector.zero)

    return 
        vide.action(function(of)
            vide.effect(function()
                local from = vide.untrack(start_pos)
                local delta: vector = input_pos() - vide.untrack(drag_start)
                local new_pos: vector = from + delta

                print("set.position:", debug.info(position, "f"))
                print("set.position.val:", new_pos)

                position(new_pos)
            end)
        end),
        function(input: _InputObject, pos: vector)
            local input_type = input.UserInputType
            if not dragging() and
                (input_type == Enum.UserInputType.MouseButton1
                    or input_type == Enum.UserInputType.Touch)
            then
                dragging(true)
                drag_start(input.Position)
                start_pos(pos)
            end
        end,
        function(input: _InputObject, game_processed: boolean)
            if game_processed then
                return
            end
            
            local input_type = input.UserInputType
            if dragging() and 
                (input_type == Enum.UserInputType.MouseMovement
                    or input_type == Enum.UserInputType.Touch)
            then
                input_pos(input.Position)
            end
        end,
        function(input: _InputObject, game_processed: boolean)
            if game_processed then
                return
            end
            
            local input_state = input.UserInputState
            if input_state == Enum.UserInputState.End and dragging() then
                dragging(false)
            end
        end
end


type Tilemap = Array<Array<vide.source<vector>?>>

local function Tileable(
    asking_size: () -> vector,
    component: (position: vide.source<vector>) -> _Instance
): (vide.source<Array<_Instance>>, Array<thread>) 
    local tiles: vide.source<Array<_Instance>> = vide.source({})
    local tilemap: Tilemap = {}

    local threads: Array<thread> = {}
    local destroys: Array<() -> ()> = {}
    vide.cleanup(function()
        for _, destroy in destroys do
            destroy()
        end
    end)

    vide.effect(function()
        local size = asking_size()
        local half_abs_size = size / 2

        for nx = -1, 1 do
            for ny = -1, 1 do
                local n = vector.create(nx, ny, 0)
                local idx0: vector = n + vector.one
                local idx1: vector = fix_type(idx0) + vector.one
                local tile_pos: vector = idx0 * size + half_abs_size

                local row = tilemap[fix_type(idx1).Y]
                if not row or (row and not row[fix_type(idx1).X]) then
                    local new_pos = vide.source(tile_pos)
                    local new = vide.untrack(function()
                        return component(new_pos)
                    end)

                    local destroy, co = vide.root(function()
                        local action, begin, changed, ended = Draggable(new_pos)
                        
                        action.callback(new)

                        local run = true
                        local co = coroutine.create(function()
                            local last_input = vector.zero
                            while true do
                                if not run then
                                    break
                                end

                                local start = last_input
                                local goal = vector.create(randfloat(0, 1920), randfloat(0, 1080), 0)
                                local begin_input: _InputObject = {
                                    UserInputType = Enum.UserInputType.MouseButton1,
                                    UserInputState = Enum.UserInputState.Begin,
                                    Position = start
                                }

                                begin(begin_input, vide.untrack(new_pos))

                                for t = 0, 1, 0.01 do
                                    local change_input: _InputObject = {
                                        UserInputType = Enum.UserInputType.MouseMovement,
                                        UserInputState = Enum.UserInputState.Begin,
                                        Position = lerpvec(start, goal, t)
                                    }

                                    changed(change_input, false)
                                end

                                ended(
                                    {
                                        UserInputType = Enum.UserInputType.MouseButton1,
                                        UserInputState = Enum.UserInputState.End,
                                        Position = goal
                                    },
                                    false
                                )

                                last_input = goal
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

                    if not row then
                        tilemap[fix_type(idx1).Y] = {new_pos}
                    elseif not row[fix_type(idx1).X] then
                        tilemap[fix_type(idx1).Y][fix_type(idx1).X] = new_pos
                    end

                    table.insert(threads, co)
                    table.insert(destroys, destroy)
                    insert(tiles, new)
                end
            end
        end
    end)

    return tiles, threads
end

local function App(): (_Instance, Array<thread>)
    local tile_size = vide.source(vector.create(100, 100, 0))

    local tileable, threads = Tileable(tile_size, Tile)
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
