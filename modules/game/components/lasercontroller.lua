--- A controller that, once activated, fires a ray of tiles out to the right
--- of its actor, testing each one in sequence out to its Sight range, and
--- digs out the first one whose Entity has a Rock component.
--- @class LaserController : Controller
--- @field active boolean Whether the laser is currently firing.
--- @overload fun(): LaserController
local LaserController = prism.components.Controller:extend "LaserController"

function LaserController:__new()
   self.active = false
end

function LaserController:act(level, actor)
   if not self.active then return prism.actions.Wait(actor) end

   local position = actor:getPosition()
   local direction = prism.Vector2.RIGHT
   local range = actor:expect(prism.components.Sight):getRange()

   for i = 1, range do
      local target = position + direction * i

      if not level:inBounds(target:decompose()) then break end

      local cell = level:getCell(target:decompose())
      if cell and cell:has(prism.components.Rock) then
         return prism.actions.Dig(actor, target, 1)
      end
   end

   return prism.actions.Wait(actor)
end

return LaserController
