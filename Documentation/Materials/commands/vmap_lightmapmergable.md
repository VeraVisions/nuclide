# Materials: VMap Commands {#mat_vmap}
## vmap_lightmapmergable
### Syntax {#syntax}

**vmap_lightmapMergable**

### Overview {#overview}

When specified, the compiler will attempt to merge all surfaces using
this material together onto lightmap sheets. This can drastically reduce
the artifacts occuring on surfaces like terrain where precision issues
might get you black spots along the lightmap seams. Definitely use this
across large collections of surfaces on which you expect smooth
transitions.