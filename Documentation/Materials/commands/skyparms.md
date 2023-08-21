# Materials: Commands {#mat_commands}
## skyparms
### Overview

**skyParms <farbox> <cloudheight> <nearbox>**

Specifies how to use the surface as a sky, including an optional far box
(stars, moon, etc), optional cloud layers with any shader attributes,
and an optional near box (mountains in front of the clouds, etc). Some
of the VMAP specific commands use this as a reference as to what skybox
to use for color, intensity etc.

The renderer will take it into account only if you do not supply any
Stages in the material.

**farbox**: Specifies a set of files to use as an environment box
behind all cloudlayers. Specify "-" for no farbox, or a file base name.
A base name of "env/test" would look for files "env/test_rt.tga",
"env/test_lf.tga", "env/test_ft.tga", "env/test_bk.tga",
"env/test_up.tga", "env/test_dn.tga" to use as the right / left / front
/ back / up / down sides.

**cloudheight**: controls apparent curvature of the cloud layers -
lower numbers mean more curvature (and thus more distortion at the
horizons). Higher height values create "flatter" skies with less horizon
distortion. Think of height as the radius of a sphere on which the
clouds are mapped. Good ranges are 64 to 256. The default value is 128.

**nearbox**: Specified as farbox, to be alpha blended ontop of the
clouds. This has not be tested in a long time, so it probably doesn't
actually work. Set to "-" to ignore.

### Example Sky Material {#example_sky_material}
```
   // Vera Visions Material
   {
       qer_editorImage textures/skies/dune.tga
       skyParms textures/skies/dune/bg 256 -
       noPicMip
       noMipmaps
       
       surfaceParm sky
       surfaceParm noimpact
       surfaceParm nolightmap
       surfaceParm nodlight
       {
           program skybox
           map $cube:textures/skies/dune/bg
           map textures/skies/clouds/dunecloud.tga
           map textures/skies/clouds/dunecloud_layer.tga
       }
   }
```