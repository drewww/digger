local controls = require "controls"

--- Starts at (x, y) and randomly walks a vein of gold through the rock,
--- turning each wall tile it visits along the way into a floor tile with a
--- Gold actor, so gold clumps together instead of appearing as scattered
--- isolated tiles.
--- @param builder LevelBuilder
--- @param rng RNG
--- @param x integer
--- @param y integer
local function digGoldVein(builder, rng, x, y)
   local directions = prism.Vector2.neighborhood4
   local length = rng:random(4, 10)

   for i = 1, length do
      if x < 1 or x > 64 or y < 1 or y > 64 then break end

      local cell = builder:getCell(x, y)
      if cell and cell:has(prism.components.Opaque) then
         builder:set(x, y, prism.cells.Floor())
         builder:addActor(prism.actors.Gold(), x, y)
      end

      local dir = directions[rng:random(1, #directions)]
      x, y = x + dir.x, y + dir.y
   end
end

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

   local seed = love.timer.getTime()
   local rng = prism.RNG(seed)
   builder:addSeed(seed)

   builder:rectangle("fill", 0, 0, 64, 64, prism.cells.Wall)

   builder:rectangle("fill", 1, 1, 5, 5, prism.cells.Floor)

   local sizes = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 4, 5 }
   for i = 1, 200, 1 do
      local x, y = rng:random(1, 63), rng:random(1, 63)

      local size = sizes[rng:random(1, #sizes)]

      builder:rectangle("fill", x, y, x + size, y + size, prism.cells.Floor)
   end

   -- Offset the noise sample to a random point so each level gets a
   -- different, but still deterministic, distribution of rock types.
   local nox, noy = rng:random(1, 10000), rng:random(1, 10000)

   for x = 1, 64 do
      for y = 1, 64 do
         local cell = builder:getCell(x, y)

         if cell:has(prism.components.Opaque) then
            local noise = love.math.perlinNoise(x / 4 + nox, y / 4 + noy)

            local rockType, color
            if noise > 0.5 then
               rockType = "igneous"
               color = prism.Color4.DARKGREY
            else
               rockType = "sedimentary"
               color = prism.Color4.GREY
            end

            cell:give(prism.components.Rock(rockType, 1))
            cell:expect(prism.components.Drawable).color = color
            builder:set(x, y, cell)

            -- Occasionally seed a gold vein here and let it wander through
            -- the rock, rather than scattering single isolated gold tiles.
            if rng:random(1, 300) == 1 then digGoldVein(builder, rng, x, y) end
         end
      end
   end


   -- Add a small block of walls within the map

   -- Place the player character at a starting location
   builder:addActor(prism.actors.Player(), 1, 1)
   builder:addActor(prism.actors.Drill(), 2, 4)

   builder:addActor(prism.actors.Laser(), 3, 5)

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

   if controls.release.pressed then
      prism.logger.info("release pressed")
      for held, relation in pairs(owner:getRelations(prism.relations.HoldsRelation)) do
         prism.logger.info("releasing: ", held)
         self.level:tryPerform(prism.actions.Release(owner, held))
      end
   end

   if controls.sense.pressed then
      if owner:has(prism.components.Sensing) then
         owner:remove(prism.components.Sensing)
      else
         owner:give(prism.components.Sensing())
      end
   end

   -- Controls are accessed directly via table index.
   if controls.move.pressed then
      local destination = owner:getPosition() + controls.move.vector

      -- Update facing based on the direction entered, even if the resulting
      -- action (dig/push/hold/move) ends up failing or doing nothing.
      if owner:has(prism.components.Facing) then
         owner:expect(prism.components.Facing).direction = controls.move.vector:normalize()
      end

      local pushable = self.level:query(prism.components.Pushable):at(destination:decompose()):first()

      local holdable = self.level:query(prism.components.Holdable):at(destination:decompose()):first()

      local laser = self.level:query(prism.components.LaserController):at(destination:decompose()):first()


      local dig = prism.actions.Dig(owner, destination, 1)
      local canDig = not owner:has(prism.components.Sensing) and self.level:canPerform(dig)

      -- if something is held THEN do a push for that
      -- local holding = owner:getRelation(prism.relations.HoldsRelation)
      -- prism.logger.info("held item: ", holding)
      -- if holding then
      --    -- do a push + move on that item
      --    prism.logger.info("pushing HELD item")
      --    local push = prism.actions.Push(owner, holding, destination - owner:getPosition())

      --    if self:setAction(push) then return end
      -- end

      if canDig then
         prism.logger.info("digging at " .. destination:decompose())
         if self:setAction(dig) then return end
      elseif holdable and not holdable:hasRelation(prism.relations.HeldByRelation, owner) then
         prism.logger.info("grasp something")

         local hold = prism.actions.Hold(owner, holdable)
         if self:setAction(hold) then return end
      elseif pushable and not pushable:hasRelation(prism.relations.HeldByRelation, owner) then
         prism.logger.info("pushing")
         local push = prism.actions.Push(owner, pushable, destination - owner:getPosition())

         if self:setAction(push) then return end
      elseif laser then
         prism.logger.info("activating laser")
         laser:expect(prism.components.LaserController).active = true

         if self:setAction(prism.actions.Wait(owner)) then return end
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


      if player:has(prism.components.Sensing) then
         -- compute what we can see.
         local sensing = player:expect(prism.components.Sensing)

         local map = {}

         -- loop through everything within range and field of view
         local facing = player:has(prism.components.Facing) and player:expect(prism.components.Facing).direction or
             prism.Vector2.RIGHT
         local locations = sensing:getLocationsInRange(player:getPosition(), facing)

         self.display:beginCamera()
         for _, loc in ipairs(locations) do
            local x, y = loc:decompose()
            if self.level:inBounds(x, y) then
               local cell = self.level:getCell(x, y)
               local agent = self.level:query():at(x, y):first()

               self.display:putBG(x, y, prism.Color4.DARKGREY)

               -- Only report rock types and gold; ignore everything else.
               if agent then
                  local name = agent:expect(prism.components.Name).name
                  if name == "Gold" then map[name] = (map[name] or 0) + 1 end
               elseif cell and cell:has(prism.components.Rock) then
                  local label = cell:expect(prism.components.Rock).type
                  map[label] = (map[label] or 0) + 1
               end
            end
         end
         self.display:endCamera()


         self.display:print(1, 1, "TRICORDER: ", prism.Color4.WHITE)

         -- Sort entries by frequency, descending.
         local entries = {}
         for name, count in pairs(map) do
            table.insert(entries, { name = name, count = count })
         end
         table.sort(entries, function(a, b) return a.count > b.count end)

         local i = 2
         for _, entry in ipairs(entries) do
            local color = entry.name == "Gold" and prism.Color4.YELLOW or prism.Color4.WHITE
            self.display:print(1, i, entry.name .. "=" .. entry.count, color)
            i = i + 1
         end
      end
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
