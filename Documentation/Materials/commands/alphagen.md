# Materials: Commands {#mat_commands}
## alphagen
### Syntax

**alphaGen <func>**

### Overview

The alpha channel can be specified like the [rgb channels](rgbgen.md). If not specified, it
defaults to 1.0.

### Functions {#functions}

#### portal {#portal}

This rendering stage keyword is used in conjunction with the
[surfaceparm](surfaceparm.md) keyword
portal. The function accomplishes the "fade" that causes the scene in
the portal to fade from view. Specifically, it means "Generate alpha
values based on the distance from the viewer to the portal."

Use `alphaGen portal` on the last rendering pass.