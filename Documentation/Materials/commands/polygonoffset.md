# Materials: Commands {#mat_commands}
## polygonoffset
### Syntax {#syntax}

**polygonOffset <value>**

### Overview {#overview}

Surfaces rendered with the polygonOffset keyword are rendered slightly
off the polygon's surface. This is typically used for wall markings and
"decals." The distance between the offset and the polygon is variable.
If no value is supplied a distance of 1 is assumed, however this is
meant for backwards compatibility. Being explicit will help grepping
values later in case you need to find all surfaces with just a
polygonOffset of 1.