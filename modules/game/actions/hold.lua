---@class Hold : Action
local Hold = prism.Action:extend("Hold")

local Target = prism.Target(prism.components.Holdable)

Hold.targets = { Target }

function Hold:canPerform(level, target)
   return true
end

function Hold:perform(level, target)
   target:addRelation(prism.relations.HeldByRelation, self.owner)
end

return Hold
