# Material Command List {#mat_commands}

## fullbrightMap {#fullbrightMap}

### Syntax

**fullbrightMap \<texturepath/texturename\>**

### Overview

The texture is essentially a fullbright overlay on top of the
diffuse/albedomap.

Not all [Shaders](@ref shaders) support them. In some, like the
[unlit](@ref unlit) shader, the
[diffusemap](@ref diffusemap) is always
fullbright.
