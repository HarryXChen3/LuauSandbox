local vide = require("./packages/vide")
local source = vide.source

type Instance = {__T: "Instance"}
type TextLabel = {__T: "TextLabel"} & Instance
type Frame = {__T: "Frame"} & Instance
type UIListLayout = {__T: "UIListLayout"} & Instance

type CreateFor<T, U> = (n: T) -> ((props: {[string | number]: Instance | unknown}) -> U)
type Create = CreateFor<"TextLabel", TextLabel>
    & CreateFor<"Frame", Frame>
    & CreateFor<"UIListLayout", UIListLayout>

local create: Create = vide.create

local items = source {
    create "TextLabel" { Text = "A" }
}

local function List(props: {children: () -> Array<Instance>})
    return create "Frame" {
        create "UIListLayout" {},
        props.children
    }
end

List { children = items } -- creates a list with text label "A"

items {
    create "TextLabel" { Text = "B" },
    create "TextLabel" { Text = "C" } 
}

-- this will automatically unparent text label "A", and parent labels "B" and "C"