prism.registerActor("Drill", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Drill"),
      prism.components.Drawable { index = ">", color = prism.Color4.LIME, size = 4 },
      prism.components.Position(),
      prism.components.Collider { allowedMovetypes = { "walk" }, size = 4 },
      prism.components.Senses(),
      prism.components.Mover { "walk" },
   }
end)
