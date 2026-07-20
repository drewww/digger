prism.registerActor("Player", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Player"),
      prism.components.Drawable { index = "@", color = prism.Color4.BLUE, size = 4 },
      prism.components.Position(),
      prism.components.Collider { allowedMovetypes = { "walk" }, size = 4 },
      prism.components.PlayerController(),
      prism.components.Senses(),
      prism.components.Sight { range = 64, fov = true },
      prism.components.Mover { "walk" },
   }
end)
