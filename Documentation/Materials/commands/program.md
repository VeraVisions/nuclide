# Materials: Commands {#mat_commands}
## program
**program** defines which GLSL/HLSL shader to load for a defined
material. It also accepts arguments that will recompile a shader with
certain permutations. This is kinda ugly,

Starting in [The Wastes](The_Wastes) 1.2, there are the
following shader programs available to you:

-   program [unlit](unlit_(Shader))
-   program [lightmapped](lightmapped_(Shader))
-   program [vertexlit](vertexlit_(Shader))
-   program [water](water_(Shader))
-   program [refract](refract_(Shader))