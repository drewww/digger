--- @class Facing : Component
--- @field direction Vector2
local Facing = prism.Component:extend("Facing")

Facing.name = "Facing"

--- @param dir? Vector2 The direction to face. Defaults to Vector2.RIGHT.
function Facing:__new(dir)
   self.direction = dir or prism.Vector2.RIGHT
end

return Facing
