prism.registerActor("Laser", function()
   return prism.Actor.fromComponents {
      prism.components.Name("Laser"),
      prism.components.Drawable { index = ">", color = prism.Color4.WHITE, size = 1 },
      prism.components.Position(),
      prism.components.Senses(),
      prism.components.Sight { range = 64, fov = true },
      prism.components.Collider { size = 1 },
      prism.components.Mover { "walk" },
      prism.components.LaserController(),
   }
end)
