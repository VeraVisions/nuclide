# Material Command List {#mat_commands}

## normalMap {#normalMap}

### Syntax

**normalMap \<texturepath/texturename\>**

### Overview

Specifies the default texture to use for any normalmap operations. This
depends heavily on which [GLSL program](@ref shaders) is used
inside the later stages. The dynamic lights will use this to determine
height information for light and shadows. So sometimes you want to skip
setting this.

### Creating normal maps to use with this command {#creating_normal_maps_to_use_with_this_command}

Check out our [Normal mapping guide](@ref normal_mapping_guide).
