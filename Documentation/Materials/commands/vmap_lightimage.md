# Materials: VMap Commands {#mat_vmap}
## vmap_lightimage
### Syntax {#syntax}

**vmap_lightImage <texturepath>**

### Overview {#overview}

By default, surface lights use the average color of the source image to
generate the color of the light. vmap_lightImage specifies an alternate
image to be used for light color emission, radiosity color emission,
light filtering and alpha shadows. You can even use a light image with a
different alpha channel for blurrier alpha shadows. The light color is
averaged from the referenced texture. The texture must be the same size
as the base image map. vmap_lightImage should appear before
qer_editorImage.