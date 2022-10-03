# Materials: VMap Commands {#mat_vmap}
## vmap_surfacelight
### Syntax {#syntax}

**vmap_surfacelight <intensity>**

### Overview {#overview}

The texture gives off light equal to the value set for it. The relative
surface area of the texture in the world affects the actual amount of
light that appears to be radiated.

To give off what appears to be the same amount of light, a smaller
texture must be significantly brighter than a larger texture.

Unless the
[vmap_lightImage](vmap_lightImage) or
[vmap_lightRGB](vmap_lightRGB) directive
is used to select a different source for the texture's light color
information, the color of the light will be the averaged color of the
texture.

If you want to change the distance/range of the surfacelight, use
[vmap_surfacelightDistance](vmap_surfaceLightDistance).