---@class Release : Action
local Release = prism.Action:extend("Release")

local Target = prism.Target(prism.components.Holdable)

Release.targets = { Target }

function Release:canPerform(level, target)
   return true
end

function Release:perform(level, target)
   prism.logger.info("releasing: ", target)
   target:removeRelation(prism.relations.HeldByRelation, self.owner)
   self.owner:expect(prism.components.Drawable).background = prism.Color4.TRANSPARENT
end

return Release
