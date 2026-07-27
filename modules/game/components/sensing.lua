--- @class Sensing : Component
local Sensing = prism.Component:extend("Sensing")
Sensing.name = "Sensing"

function Sensing:__new()
   self.range = 6
   self.angle = math.pi / 2
end

return Sensing
