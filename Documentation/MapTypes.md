# Map Making

## Which Format You Should Use

That depends on the job. If you want to work with a modern format, comparable to that of a  2004 game engine and beyond, any variant of Quake III Arena's BSP format can do.
We aim to support everything equally.

For a more authentic, 1990s experience you may want to use Quake II's format instead.

We have our own variant of the BSP format, which can be compiled by using [vmap](VMap.md).

### Quake BSP

This is the default format that all the Quake tools, such as [ericw-tools](https://ericwa.github.io/ericw-tools/) compile into. If you exceed limits, they generally will generate a **"BSP2"** file, which is something our engine also understands. The original engine and format only did monochrome color. This is no issue any longer because modern compilers output so called **lit** files, which contain colored lightmaps externally. If a Quake engine supports colored lights, they'll usually load them automatically.

However, creating non-planar surfaces or changing the lightmap quality on individual surfaces is not supported in this format. If you want to use features such as crouching or proning you have to compile your map with **BSPX** extensions. Other formats also include more features, which can help optimise the network and rendering performance of a level. So use of this format is discouraged by us. 

You can totally use it if you're going for a certain aesthetic, just be aware of its limitations. You cannot optimise levels beyond a certain point due to a lack of area-portals which were introduced with Quake II BSP.

### Quake II BSP

A better choice over Quake's standard BSP format. These support area-portals and proper detail brushes can help optimise the level even further.

### Quake III Arena BSP

**The recommended format.** Support for everything Quake II's BSP does, but you can now put a lot of detailed geometry into so called triangle soup, and design your own content volumes (beyond water, lava, slime), and surface flags (make bullets ricochet, or leak water) - make use of curved surfaces, massive maps with terrain and texture blending. Support for different lightmap scales per surface, and alternative vertex-lit levels can also give you tigter controls about lighting performance and visual fidelity.

### VMAP compiled BSP

Our own version of the Quake III Arena BSP format. It supports a bunch of new things.
The compiler doesn't read .shader files from `scripts/` but instead `.mat` files alongside the textures within the textures directory, as well as a custom patch/curve format.

Only use this if you really, really want to use the things we developed. You will have a smoother experience with most other formats right now.

### Other Formats

While the engine can read other formats, such as BSP30 and beyond - please ensure you do have the rights to use the tools in such fashion. For example, for developers coming from the Half-Life SDK you are not allowed to use compilers and versions deriving from the original sources to make maps for Nuclide based projects. You will have to negotiate a license with Valve or use a free-software tool such as [ericw-tools](https://ericwa.github.io/ericw-tools/).

## Recommended Tools

We don't require you to use WorldSpawn or VMAP. You can use any of the above formats, and whatever editor you like to use to get the job done.

Here's a list of popular editors we've seen people use successfully:

- NetRadiant-Custom
- TrenchBroom
- NetRadiant
- GtkRadiant
- QuArK
- JACK (proprietary)

However we do not provide support for any of them. Please talk to the developers of the respective tools if you're experiencing issues. First ensure that you're able to make levels for your target format.

For example, create an example map for Quake, test it in Quake and then copy it into your Nuclide directory after verifying it works and that the workflow is right for you.
You may need to switch tools if you're not comfortable, and only once you're fully set and familar with the map-making toolchain should you attempt to run the maps in Nuclide.

As map-making is a complicated process, a lot of issues you can run into while making levels for Nuclide, may actually be issues with the toolchain you're using to make the map. So verify it works in the target format's game of choice first.