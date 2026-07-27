--- @class Rock : Component
--- @field type "igneous" | "sedimentary" | "metamorphic"
--- @field strength number
local Rock = prism.Component:extend("Rock")
Rock.name = "Rock"

--- @param type "igneous" | "sedimentary" | "metamorphic"
--- @param strength number
function Rock:__new(type, strength)
   self.type = type
   self.strength = strength
end

return Rock
