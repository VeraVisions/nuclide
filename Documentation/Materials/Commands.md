# Material Command List {#mat_commands}

Here is a list of all the commands that can be contained within a material definition file, like a **mat** or a **shader** file.

There are three different kinds of commands:

- Surface Specific
- Stage/Layer Specific
- vmap Specific

Surface specific commands affect the entire surface, or sometimes whole brush-volume it belongs to. Example commands may be @ref surfaceparm.

Stage/Layer specific commands only affect one part of the rendering stage. Generally anything within a sub-block of braces (`{ }`) is a stage. It defines a layer to draw on top of the surface.

Due to how simple most surfaces are, you don't have to define a stage. It is often enough to set @ref mat_program, @ref diffuseMap and you're rendering a surface handled entirely by the GPU.

Some operations, such as @ref deformVertexes or @ref tcMod are done on the CPU. While you can use those, know that moving that action into a [Shader Program](@ref shaders) is recommended.