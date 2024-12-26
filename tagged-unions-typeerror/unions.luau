type A0 = { a: string }
type B0 = A0 & { b: number }
type C0 = A0 & { c: number }

type BC0 = B0 | C0

do
    local x: BC0 = { a = "", b = 0 }

    x.a = "hi!"
end

type A1 = { a: string }
type B1 = { b: number }
type C1 = { c: number }

type BC1 = (A1 & (B1 | C1))

do
    local x: BC1 = { a = "", b = 0 }

    x.a = "hi!"
end