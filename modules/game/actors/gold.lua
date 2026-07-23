prism.registerActor("Gold", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Gold"),
      prism.components.Drawable { index = "$", color = prism.Color4.YELLOW, size = 1 },
      prism.components.Position(),
      prism.components.Holdable(),
      prism.components.Pushable(),
      prism.components.Collider { size = 1 },
      prism.components.Mover { "walk" },
   }
end)
