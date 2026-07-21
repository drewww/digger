---@class Dig : Action
local Dig = prism.Action:extend("Dig")

local Power = prism.Target():isType("number")
local Target = prism.Target():isPrototype(prism.Vector2)

Dig.targets = { Target, Power }

function Dig:canPerform(level, target, power)
   local cell = level:getCell(target:decompose())

   return cell:has(prism.components.Diggable)
end

function Dig:perform(level, target, power)
   local cell = level:getCell(target:decompose())

   local floor = prism.cells.Floor()
   floor:expect(prism.components.Drawable).index = ":"
   floor:expect(prism.components.Drawable).color = cell:expect(prism.components.Drawable).color

   level:setCell(target.x, target.y, floor)
end

return Dig
