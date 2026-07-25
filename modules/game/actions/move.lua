local MoveTarget = prism.Target():isVector2():range(1)

--- @class Move : Action
--- @field name string
--- @field targets Target[]
--- @field previousPosition Vector2
--- @overload fun(owner: Actor, destination: Vector2): Move
local Move = prism.Action:extend("Move")
Move.targets = { MoveTarget }

Move.requiredComponents = {
   prism.components.Mover,
}

--- @param level Level
--- @param destination Vector2
function Move:canPerform(level, destination)
   local mover = self.owner:expect(prism.components.Mover)

   -- we need to make a list of cells to check
   local moves = self:heldMoves(level, destination)

   local passable = true
   for _, move in ipairs(moves) do
      local actor, dest = move[1], move[2]

      -- TODO figure out if this is Holds or HeldBy
      local heldActorAtDest = level:query():at(dest.x, dest.y):relation(self.owner, prism.relations.HoldsRelation):first()
      passable = passable and
          (level:getCellPassableByActor(dest.x, dest.y, actor, actor:expect(prism.components.Mover).mask) or heldActorAtDest)
   end

   return passable
end

--- @param level Level
--- @param destination Vector2
function Move:perform(level, destination)
   local moves = self:heldMoves(level, destination)

   for _, move in ipairs(moves) do
      local actor, dest = move[1], move[2]
      prism.logger.info("move: ", actor, " from ", actor:getPosition(), " to ", dest)
      level:moveActor(actor, dest)
   end
end

--- Loop through the relations
--- @return table<Actor, Vector2>[]
function Move:heldMoves(level, destination)
   local moves = {}
   local relative = destination - self.owner:getPosition()

   for held, relation in pairs(self.owner:getRelations(prism.relations.HoldsRelation)) do
      ---@cast held Actor
      table.insert(moves, { held, held:getPosition() + relative })
   end

   -- put the player in last
   table.insert(moves, { self.owner, destination })

   return moves
end

return Move
