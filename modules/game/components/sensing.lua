--- @class Sensing : Component
local Sensing = prism.Component:extend("Sensing")
Sensing.name = "Sensing"

function Sensing:__new()
   self.range = 12
   self.angle = math.pi / 2
end

--- Computes the list of locations within this sensor's range and field of view.
--- Locations are included if they fall within `self.range` tiles of `location`
--- both by the engine's default grid distance (consistent with how range is
--- measured elsewhere, e.g. `Vector2:getRange`/`Target:range`) and by
--- Euclidean distance (which rounds off the far corners so the cone doesn't
--- reach further diagonally than it does straight ahead), and within
--- `self.angle` radians (total arc, centered on `facing`) of the facing
--- direction.
--- @param location Vector2 The origin location to sense from.
--- @param facing Vector2 The direction the sensor is facing.
--- @return Vector2[] locations The locations within range and angle of the sensor.
function Sensing:getLocationsInRange(location, facing)
   local locations = {}

   local normalizedFacing = facing:normalize()
   local halfAngle = self.angle / 2
   local cosHalfAngle = math.cos(halfAngle)

   -- A small tolerance so that tiles sitting exactly on the edge of the cone
   -- (e.g. the diagonals when `angle` is a clean multiple of 90 degrees)
   -- aren't excluded due to floating point rounding in the trig above.
   local epsilon = 1e-9

   local radius = math.ceil(self.range)
   for x = -radius, radius do
      for y = -radius, radius do
         local offset = prism.Vector2(x, y)
         local candidate = location + offset

         -- Grid distance keeps range consistent with the rest of the engine,
         -- but on its own it lets the far corners of the cone reach further
         -- (diagonally) than the range in tiles actually implies. Also
         -- requiring the Euclidean distance to be in range trims those
         -- corners back into a rounded cap.
         local inGridRange = location:getRange(candidate) <= self.range
         local inEuclideanRange = offset:length() <= self.range

         if inGridRange and inEuclideanRange then
            if x == 0 and y == 0 then
               table.insert(locations, candidate)
            else
               local direction = offset:normalize()
               local dot = normalizedFacing.x * direction.x + normalizedFacing.y * direction.y

               if dot >= cosHalfAngle - epsilon then table.insert(locations, candidate) end
            end
         end
      end
   end

   return locations
end

return Sensing
