--- A relation representing that an actor follows another actor.
--- @class HeldByRelation : Relation
--- @overload fun(): HeldByRelation
local HeldByRelation = prism.Relation:extend "HeldByRelation"

function HeldByRelation:generateInverse()
   return prism.relations.HoldsRelation
end

return HeldByRelation
