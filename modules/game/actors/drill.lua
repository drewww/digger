prism.registerActor("Drill", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Drill"),
      prism.components.Drawable { index = ">", color = prism.Color4.LIME, size = 1 },
      prism.components.Position(),
      prism.components.Pushable(),
      prism.components.Collider { size = 1 },
      prism.components.Senses(),
      prism.components.Mover { "walk" },
   }
end)
