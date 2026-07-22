local controls = require "controls"

--- @class GameLevelState : LevelState
--- A custom game level state responsible for initializing the level map,
--- handling input, and drawing the state to the screen.
---
--- @overload fun(display: Display): GameLevelState
local GameLevelState = spectrum.gamestates.LevelState:extend "GameLevelState"

--- @param display Display
function GameLevelState:__new(display)
   -- Construct a simple test map using MapBuilder.
   -- In a complete game, you'd likely extract this logic to a separate module
   -- and pass in an existing player object between levels.
   local builder = prism.LevelBuilder()

   builder:rectangle("fill", 0, 0, 64, 64, prism.cells.Wall)

   builder:rectangle("fill", 1, 1, 2, 63, prism.cells.Floor)

   builder:rectangle("fill", 32, 1, 35, 63, prism.cells.Floor)

   builder:rectangle("fill", 1, 20, 63, 23, prism.cells.Floor)

   local sizes = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 4, 5 }
   for i = 1, 200, 1 do
      local x, y = math.random(1, 63), math.random(1, 63)

      local size = sizes[math.random(1, #sizes)]

      builder:rectangle("fill", x, y, x + size, y + size, prism.cells.Floor)
   end

   for x = 1, 64 do
      for y = 1, 64 do
         local cell = builder:getCell(x, y)

         local colors = { prism.Color4.GREY, prism.Color4.DARKGREY, prism.Color4.BROWN, prism.Color4.GREY, prism.Color4
             .DARKGREY, prism.Color4.BROWN, prism.Color4.GREY, prism.Color4.DARKGREY, prism.Color4.BROWN, prism.Color4
             .GREY, prism.Color4.DARKGREY, prism.Color4.BROWN, prism.Color4.GREY, prism.Color4.DARKGREY, prism.Color4
             .BROWN, prism.Color4.GREY, prism.Color4.DARKGREY, prism.Color4.BROWN, prism.Color4.GREY, prism.Color4
             .DARKGREY, prism.Color4.BROWN, prism.Color4.GREY, prism.Color4.DARKGREY, prism.Color4.BROWN, prism.Color4
             .YELLOW }

         cell:expect(prism.components.Drawable).color = colors[math.random(1, #colors)]

         builder:set(x, y, cell)
      end
   end


   -- Add a small block of walls within the map

   -- Place the player character at a starting location
   builder:addActor(prism.actors.Player(), 1, 1)
   builder:addActor(prism.actors.Drill(), 2, 4)

   -- Add systems
   builder:addSystems(prism.systems.SensesSystem(), prism.systems.SightSystem())

   -- Initialize with the created level and display, the heavy lifting is done by
   -- the parent class.
   self.super.__new(self, builder:build(prism.cells.Wall), display)
end

function GameLevelState:handleMessage(message)
   self.super.handleMessage(self, message)

   -- Handle any messages sent to the level state from the level. LevelState
   -- handles a few built-in messages for you, like the decision you fill out
   -- here.

   -- This is where you'd process custom messages like advancing to the next
   -- level or triggering a game over.
end

-- updateDecision is called whenever there's an ActionDecision to handle.
function GameLevelState:updateDecision(dt, owner, decision)
   -- Controls need to be updated each frame.
   controls:update()

   -- Controls are accessed directly via table index.
   if controls.move.pressed then
      local destination = owner:getPosition() + controls.move.vector


      local pushable = self.level:query(prism.components.Pushable):at(destination:decompose()):first()

      local holdable = self.level:query(prism.components.Holdable):at(destination:decompose()):first()


      local dig = prism.actions.Dig(owner, destination, 1)
      local s, e = self.level:canPerform(dig)

      -- if something is held THEN do a push for that
      local holding = owner:getRelation(prism.relations.HoldsRelation)
      prism.logger.info("held item: ", holding)
      if holding then
         -- do a push + move on that item
         prism.logger.info("pushing HELD item")
         local push = prism.actions.Push(owner, holding, destination - owner:getPosition())

         if self:setAction(push) then return end
      end

      if self.level:canPerform(dig) then
         prism.logger.info("digging at " .. destination:decompose())
         if self:setAction(dig) then return end
      elseif holdable then
         prism.logger.info("grasp something")

         local hold = prism.actions.Hold(owner, holdable)
         if self:setAction(hold) then return end
      elseif pushable then
         prism.logger.info("pushing")
         local push = prism.actions.Push(owner, pushable, destination - owner:getPosition())

         if self:setAction(push) then return end
      else
         local move = prism.actions.Move(owner, destination)
         if self:setAction(move) then return end
      end
   end

   if controls.wait.pressed then self:setAction(prism.actions.Wait(owner)) end
end

function GameLevelState:draw()
   self.display:clear()

   local player = self.level:query(prism.components.PlayerController):first()

   if not player then
      -- You would normally transition to a game over state
      self.display:putLevel(self.level)
   else
      local position = player:expectPosition()

      local x, y = self.display:getCenterOffset(position:decompose())
      self.display:setCamera(x, y)

      local primary, secondary = self:getSenses()
      -- Render the level using the player’s senses
      self.display:beginCamera()
      self.display:putSenses(primary, secondary, self.level)
      self.display:endCamera()
   end

   -- custom terminal drawing goes here!

   -- Say hello!
   -- self.display:print(1, 1, "Hello prism!")

   -- Actually render the terminal out and present it to the screen.
   -- You could use love2d to translate and say center a smaller terminal or
   -- offset it for custom non-terminal UI elements. If you do scale the UI
   -- just remember that display:getCellUnderMouse expects the mouse in the
   -- display's local pixel coordinates
   self.display:draw()

   -- custom love2d drawing goes here!
end

function GameLevelState:resume()
   -- Run senses when we resume from e.g. Geometer.
   self.level:getSystem(prism.systems.SensesSystem):postInitialize(self.level)
end

return GameLevelState
