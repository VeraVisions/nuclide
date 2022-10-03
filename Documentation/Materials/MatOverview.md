# Materials

**Materials**, also formerly known **Q3 shaders** or wrongly referred to as just **shaders** are scripts that define texture and surface properties.

## History

In the idTech series of engines, **id Tech 3/Quake III Arena** was the first to introduce such a system, wrongly referred to back then as **shaders**. This was before vertex and fragment shaders were commonplace in the video-game asset pipeline.

They effectively merged the Quake texture-prefix hacks and Quake II .wal surface flags into one plain text format.

Starting with **id Tech 4/Doom III** in 2004, the name of **shader** was changed to **material** to avoid confusion with proper GPU oriented vertex and fragment shaders.

FTE has since coupled the old 'shader' syntax with proper GPU shaders using the [program](MatCommands.md) material command.

## What is a Material?
Materials are short text scripts that define the properties of a surface as it appears and functions in a game world (or compatible editing tool). By convention, the documents that contain these scripts usually has the same name as the texture set which contains the textures being modified (e.g; base, hell, castle, etc,). Several specific materials have also been created to handle special cases, like liquids, sky and special effects. 

## Usage

When the engine looks for a texture, it will look for a material file in the file-tree first, then attempt to 'make one up' if only an image file is present. A rendereable surface will **always** have a material. The question is whether you provide it, or if the engine has to automatically generate one internally.

The file extension for materials in Nuclide is .mat. There are two ways of defining materials:

* A large .shader script file containing multiple materials inside the **./scripts/** folder (not recommended)
* One small .mat file with the same path as the texture. E.g: **models/weapons/handcannon/w_handcannon/w_handcannon.mat** handles **models/weapons/handcannon/w_handcannon/w_handcannon.tga** 

A material file consists of a series of surface attributes (global scope) and rendering instructions formatted within braces ("{" and "}"). Below you can see a simple example of syntax and format for a single process, including the VMAP keywords or 'Surface Parameters', which follow the first bracket and a single bracketed 'stage':

```
  // Vera Visions Material
  {
    diffusemap textures/common/lava.tga
    vmap_tessSize 64
    {
      program unlit
      blendFunc add
    }
  }
```

The first line is a simple comment. All the official textures are marked that way.

`diffusemap` defines a texture sampler to associate with the material, it'll also be used by the real-time lights to render an impacted surface, hence why it's defined at a global scope. Other materials may need to be aware of it. The compiler also uses it to compute radiosity.

`vmap_tessSize` will tell the BSP compiler to tesselate the surface in a specific way. This affects the entire surface and not just a single rendering stage, hence why it's defined at a global scope.

We then follow into the territory of defining specific rendering instructions within braces ("{" and "}"), most of the time that's not needed if we're defining a simple, opaque material. However in this case we want to make sure that we have 1 rendering stage that blends additively. Things such as real-time lights and the BSP compiler ignore these additional stages entirely.

`program unlit` will tell it not to be affected by lighting and just use a simple fullbright shader.

`blendFunc add` will now tell the renderer that this surface is no longer opaque and will be blended with whatever equation will result in an additive blend.

[You can read more about those commands in detail right here.](MatCommands.md)

## Engine generated materials
If no material definition for a surface is present, the engine will create an internal one.
It's generally a primitive material using the internal **defaultwall** shader if it's a world texture, the **defaultskin** texture if it's a model, or a **default2d** if it's a HUD element.

## Legacy materials

You can support old-style Q3A materials alongside modern shader oriented ones.
```
    {
        if $programs
            program vertexlit
            diffusemap "models/weapons/handcannon/w_handcannon.dds"
            normalmap "models/weapons/handcannon/w_handcannon_normal.dds"
        else
            {
                map "models/weapons/handcannon/w_handcannon.tga"
                rgbGen lightingDiffuse
            }
        endif
    }
```
Here everything inside the **if $programs** block will only ever load if it's capable of handling the GLSL.
So if you have a card only performing well under the GL 1.X pipeline, the **else** path will take priority.
This means less graphical fidelity, but generally better performance on those old chipsets.

All of Quake III's shading language is supported in the else block.
