prism.registerActor("Drill", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Drill"),
      prism.components.Drawable { index = "}", color = prism.Color4.WHITE, size = 1 },
      prism.components.Position(),
      prism.components.Holdable(),
      prism.components.Pushable(),
      prism.components.Digger(),
      prism.components.Collider { size = 1 },
      prism.components.Mover { "walk" },
   }
end)
