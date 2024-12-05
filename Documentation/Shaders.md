# Shaders {#shaders}

Shaders are referring to GPU-oriented pieces of a program, performing shading and rendering related functions instead of letting the engine handle it. 

In [FTE](https://www.fteqw.org/) you can specify a custom GLSL or HLSL shader using the [program](@ref program) command inside a [Material](@ref materials).

## Example Shader

This is a primitive shader file. It includes the vertex and fragment program.

It will respond to the [diffusemap](@ref diffuseMap) only, which is loaded
into the **d_f** variable. It can be modified from that point onwards.
The commented out line will turn all of the output red.

Give it a try, or something!

```
//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Example surface
//==============================================================================

!!ver 110
!!samps diffuse

#include "sys/defs.h"

varying vec2 tex_c;

#ifdef VERTEX_SHADER
void main ()
{
	tex_c = v_texcoord; /* get our texture coordinates, which we'll use for the texture2D command */
	gl_Position = ftetransform(); /* place vertex into the place FTE wants us to put them at */
}
#endif

#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 d_f = texture2D(s_diffuse, tex_c); /* load the fragment from our diffusemap sample */
	// d_f.rgb = vec3(1.0, 0.0, 0.0); /* turns out fragment (aka pixel) red */
	gl_FragColor = d_f; /* final pixel output is that of d_f */
}
#endif
```

## Dissecting GLSL shaders

When we pass `program <shadername>` in our Material, the engine will load `glsl/<shadername>.glsl` to handle the material for us.

The shader in question needs to define a `main` function for both a vertex and a fragment shader. That's what the **ifdef** pre-processor chunks are for in the above example.

At some point in the `main` function, we do have to set `gl_Position` and `gl_FragColor` respectively. Those can not be undefined.

## Frequently Asked Questions

### Can I keep my vertex and fragment/pixel shader as separate files from one another?

You can not have separate files handle vertex/fragment programs.
