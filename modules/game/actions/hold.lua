---@class Hold : Action
local Hold = prism.Action:extend("Hold")

local Target = prism.Target(prism.components.Holdable)

Hold.targets = { Target }

function Hold:canPerform(level, target)
   return true
end

function Hold:perform(level, target)
   local visited = {}
   local stack = { target }
   visited[target] = true

   while #stack > 0 do
      ---@type Actor
      local current = table.remove(stack)

      current:addRelation(prism.relations.HeldByRelation, self.owner)

      local pos = current:getPosition()

      for _, dir in ipairs(prism.Vector2.neighborhood4) do
         local neighborPos = pos + dir
         local adjacent = level:query(prism.components.Holdable):at(neighborPos:decompose()):first()

         if adjacent and not visited[adjacent] then
            visited[adjacent] = true
            if not adjacent:hasRelation(prism.relations.HeldByRelation, self.owner) then
               table.insert(stack, adjacent)
            end
         end
      end
   end
end

return Hold
