--- A relation representing that an actor follows another actor.
--- @class HoldsRelation : Relation
--- @overload fun(): HoldsRelation
local HoldsRelation = prism.Relation:extend "HoldsRelation"

function HoldsRelation:generateInverse()
   return prism.relations.HeldByRelation
end

return HoldsRelation
