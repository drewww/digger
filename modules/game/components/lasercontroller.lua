--- A controller that, once activated, fires a ray of tiles out to the right
--- of its actor, testing each one in sequence out to its Sight range, and
--- digs out the first one whose Entity has a Rock component. Every cell the
--- beam passes through without digging is tagged with a Laser component, so
--- the beam's path can be rendered.
--- @class LaserController : Controller
--- @field active boolean Whether the laser is currently firing.
--- @overload fun(): LaserController
local LaserController = prism.components.Controller:extend "LaserController"

function LaserController:__new()
   self.active = false
   self.beamCells = {}
end

function LaserController:act(level, actor)
   -- Clear last turn's beam tags before retracing (or leaving off) the beam,
   -- so the visual trail doesn't linger after the laser moves on or is
   -- deactivated.
   self:clearBeam()

   if not self.active then return prism.actions.Wait(actor) end

   local position = actor:getPosition()
   local direction = prism.Vector2.RIGHT
   local range = actor:expect(prism.components.Sight):getRange()

   for i = 1, range do
      local target = position + direction * i

      if not level:inBounds(target:decompose()) then break end

      local cell = level:getCell(target:decompose())
      if cell then
         if cell:has(prism.components.Rock) then
            return prism.actions.Dig(actor, target, 1)
         end

         -- Mark cells the beam passes through but doesn't dig, for the
         -- visual effect drawn in GameLevelState:draw. Track them so we can
         -- clear the tag again next turn.
         cell:give(prism.components.Laser())
         table.insert(self.beamCells, cell)
      end
   end

   return prism.actions.Wait(actor)
end

--- Removes the Laser tag from every cell tagged by the last call to act.
--- @private
function LaserController:clearBeam()
   for _, cell in ipairs(self.beamCells) do
      if cell:has(prism.components.Laser) then cell:remove(prism.components.Laser) end
   end

   self.beamCells = {}
end

return LaserController
