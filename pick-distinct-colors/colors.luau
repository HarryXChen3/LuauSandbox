local function hue_to_rgb(p: number, q: number, t: number): number
    if t < 0 then t += 1 end
    if t > 1 then t -= 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end

    return p
end

local function hsl_to_rgb(h: number, s: number, l: number): (number, number, number)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local q = if l < 0.5 then l * (1 + s) else l + s - l * s
        local p = 2 * l - q
        
        r = hue_to_rgb(p, q, h + 1/3)
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - 1/3)
    end
  
    return math.round(r * 255), math.round(g * 255), math.round(b * 255)
end

local function pick(n: number): (number, number, number)
    -- golden angle approximation
    --  see https://en.wikipedia.org/wiki/Golden_angle
    local GOLDEN_ANGLE = math.pi * (3 - math.sqrt(5))
    local HUE_MAX = 2 * math.pi

    local SATURATION = 0.8
    local LIGHTNESS = 0.8

    return hsl_to_rgb(((n * GOLDEN_ANGLE) % HUE_MAX) / HUE_MAX, SATURATION, LIGHTNESS)
end

local function main()
    local N = 50
    for i = 1, N do
        print(pick(i))
    end
end

main()