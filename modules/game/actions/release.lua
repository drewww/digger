---@class Release : Action
local Release = prism.Action:extend("Release")

local Target = prism.Target(prism.components.Holdable)

Release.targets = { Target }

function Release:canPerform(level, target)
   return true
end

function Release:perform(level, target)
   target:removeRelation(prism.relations.HeldByRelation, self.owner)
end

return Release
