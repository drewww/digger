prism.registerCell("Wall", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Wall"),
      prism.components.Drawable { index = "#" },
      prism.components.Rock("igneous", 10),
      prism.components.Collider(),
      prism.components.Diggable(),
      prism.components.Opaque(),
   }
end)
