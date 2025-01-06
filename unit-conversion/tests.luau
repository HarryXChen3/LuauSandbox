local testkit = require("./testkit")

local TEST, CASE, CHECK, FINISH = testkit.test()

do
    local units = require("./units")

    local function EPSILON_EQ(a: number, b: number): boolean
        return math.abs(a - b) < 1e-6
    end

    TEST("units.convert_units_with_differing_edges()", function()
        do CASE "0 to 0"
            local V0 = 1
            local V1 = 2
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0)
            CHECK(dis == "m")
            CHECK(unit == 0)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1)
            CHECK(dis == "m")
            CHECK(unit == 0)
        end

        do CASE "0 to 1, under limit"
            local V0 = 1
            local V1 = 1000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0)
            CHECK(dis == "m")
            CHECK(unit == 0)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1)
            CHECK(dis == "m")
            CHECK(unit == 0)
        end

        do CASE "0 to 1, over limit"
            local V0 = 1
            local V1 = 1400
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0)
            CHECK(dis == "m")
            CHECK(unit == 0)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)
        end

        do CASE "1 to 1"
            local V0 = 1000
            local V1 = 1600
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)
        end

        do CASE "1 to 2, under limit"
            local V0 = 1200
            local V1 = 1000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)
        end

        do CASE "1 to 2, over limit"
            local V0 = 1200
            local V1 = 1600000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e3)
            CHECK(dis == "km")
            CHECK(unit == 1)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e6)
            CHECK(dis == "Mm")
            CHECK(unit == 2)
        end

        do CASE "2 to 3, under limit"
            local V0 = 1600000
            local V1 = 1000000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e6)
            CHECK(dis == "Mm")
            CHECK(unit == 2)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e6)
            CHECK(dis == "Mm")
            CHECK(unit == 2)
        end

        do CASE "2 to 3, over limit"
            local V0 = 1600000
            local V1 = 2000000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e6)
            CHECK(dis == "Mm")
            CHECK(unit == 2)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e9)
            CHECK(dis == "Gm")
            CHECK(unit == 3)
        end

        do CASE "3 to 4, under limit"
            local V0 = 2000000000
            local V1 = 1000000000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e9)
            CHECK(dis == "Gm")
            CHECK(unit == 3)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e9)
            CHECK(dis == "Gm")
            CHECK(unit == 3)
        end

        do CASE "3 to 4, over limit"
            local V0 = 2000000000
            local V1 = 2000000000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e9)
            CHECK(dis == "Gm")
            CHECK(unit == 3)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 / 1e12)
            CHECK(dis == "Tm")
            CHECK(unit == 4)
        end

        do CASE "4 to BIG, under limit"
            local V0 = 1000000000000
            local V1 = 1000000000199
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e12)
            CHECK(dis == "Tm")
            CHECK(unit == 4)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(EPSILON_EQ(n, V1 / 1e12))
            CHECK(dis == "Tm")
            CHECK(unit == 4)
        end

        do CASE "4 to BIG, over limit"
            local V0 = 1000000000000
            local V1 = 20000000000000000
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0 / 1e12)
            CHECK(dis == "Tm")
            CHECK(unit == 4)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(EPSILON_EQ(n, V1 / 1e12))
            CHECK(dis == "Tm")
            CHECK(unit == 4)
        end

        do CASE "0 to -1, under limit"
            local V0 = 1
            local V1 = 0.99
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0)
            CHECK(dis == "m")
            CHECK(unit == 0)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            print(n, V1, unit)
            CHECK(n == V1)
            CHECK(dis == "m")
            CHECK(unit == 0)
        end

        do CASE "0 to -1, over limit"
            local V0 = 1
            local V1 = 0.0015
            local UNIT = "m"
            local n, dis, unit = units.convert_units_with_differing_edges(V0, UNIT)

            CHECK(n == V0)
            CHECK(dis == "m")
            CHECK(unit == 0)

            n, dis, unit = units.convert_units_with_differing_edges(V1, UNIT, unit)

            CHECK(n == V1 * 1e3)
            CHECK(dis == "mm")
            CHECK(unit == -1)
        end
    end)
end

local success = FINISH()
return function()
    if not success then error(nil, 0) end
end