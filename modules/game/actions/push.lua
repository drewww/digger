---@class Push : Action
local Push = prism.Action:extend("Push")

local Target = prism.Target(prism.components.Pushable)

local Direction = prism.Target():isPrototype(prism.Vector2)

Push.targets = { Target, Direction }

function Push:canPerform(level, target, direction)
   -- could contain the source of the push (owner) is not in direct contact?

   return true
end

function Push:perform(level, target, direction)
   -- test if we need to do a dig for any tile we would be moving into.

   -- if this was a 1x1, we would simply take position and add the direction. for nxn, it's complicated.

   -- start without digging

   -- trigger a move action
   local move = prism.actions.Move(target, target:getPosition() + direction)

   if level:canPerform(move) then
      level:perform(move)
      level:perform(prism.actions.Move(self.owner, self.owner:getPosition() + direction))
   end
end

return Push
