# Materials: Commands {#mat_commands}
## normalmap
### Syntax

**normalmap <texturepath/texturename>**

### Overview

Specifies the default texture to use for any normalmap operations. This
depends heavily on which [GLSL program](Shaders) is used
inside the later stages. The dynamic lights will use this to determine
height information for light and shadows. So sometimes you want to skip
setting this.

### Creating normal maps to use with this command {#creating_normal_maps_to_use_with_this_command}

Check out our [Normal mapping guide](Normal_mapping_guide).

### See also {#see_also}

-   [diffusemap](diffusemap.md)
-   [specularmap](specularmap.md)
-   [fullbrightmap](fullbrightmap.md)
-   [uppermap](uppermap.md)
-   [lowermap](lowermap.md)
-   [reflectmask](reflectmask.md)
-   [reflectcube](reflectcube.md)