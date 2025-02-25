# Material Command List {#mat_commands}

## vmap_clonematerial
### Syntax

**vmap_cloneMaterial \<material\>**

### Overview

A material with this directive will inherit the target material's
properties and appearance. **Be careful, this can lead to an infinite
loop if a cloning material references another cloning material or
itself.**
