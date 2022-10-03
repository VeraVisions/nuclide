# Materials: VMap Commands {#mat_vmap}
## vmap_clonematerial
### Syntax {#syntax}

**vmap_cloneMaterial <material>**

### Overview {#overview}

A material with this directive will inherit the target material's
properties and appearance. **Be careful, this can lead to an infinite
loop if a cloning material references another cloning material or
itself.**