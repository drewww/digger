--- @class Sensing : Component
local Sensing = prism.Component:extend("Sensing")
Sensing.name = "Sensing"

function Sensing:__new()
   self.range = 12
   self.angle = math.pi / 2
end

--- Computes the list of locations within this sensor's range and field of view.
--- Locations are included if they fall within `self.range` tiles of `location`
--- and within `self.angle` radians (total arc, centered on `facing`) of the
--- facing direction.
--- @param location Vector2 The origin location to sense from.
--- @param facing Vector2 The direction the sensor is facing.
--- @return Vector2[] locations The locations within range and angle of the sensor.
function Sensing:getLocationsInRange(location, facing)
   local locations = {}

   local normalizedFacing = facing:normalize()
   local halfAngle = self.angle / 2

   local radius = math.ceil(self.range)
   for x = -radius, radius do
      for y = -radius, radius do
         local offset = prism.Vector2(x, y)

         if offset:length() <= self.range then
            if offset:length() == 0 then
               table.insert(locations, location + offset)
            else
               local direction = offset:normalize()
               local dot = normalizedFacing.x * direction.x + normalizedFacing.y * direction.y
               dot = math.max(-1, math.min(1, dot))
               local angleBetween = math.acos(dot)

               if angleBetween <= halfAngle then
                  table.insert(locations, location + offset)
               end
            end
         end
      end
   end

   return locations
end

return Sensing
