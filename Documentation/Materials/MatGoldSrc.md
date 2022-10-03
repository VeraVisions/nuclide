# Materials: GoldSrc
Material definitions handle what footsteps and what impact effects are played against each texture in the game-world.
So when you walk on dirt, you can hear the difference; or when you shoot wood with a gun it will have splinters spawn instead of black bits and smoke.

*Note:* While Nuclide supports this for legacy BSP files, you are encouraged to define the material of a texture via the [surfaceparm](MatCommands.md) command in a **Material** instead.

## Details
Usually, a game in the GoldSrc engine would provide a `sound/materials.txt` file, where each line defines the properties for a single (or a series of) textures.

For example:

```
C CONCRETEWALL
```

Will make any surface **concrete** that starts with the name `CONCRETEWALL`. In vanilla Half-Life, the second argument (name) can only be 12 characters long.

It will also only compare the length of characters of the name above. So for example if you were to define:

```
C CONC
```

Then `CONCRETEWALL` would still be marked as concrete, and any other texture that starts with `CONC[...]`.

## Community Changes and Additions

In stock GoldSrc, the **materials.txt** can be overwritten by a modification, and users could customize the file on the client-side only for themselves. This means there was no map specific materials, and mods could not inherit Half-Life's materials, so mods would always have to manage a nearly duplicate file if they desired custom texture sounds.

A few mods tried to remedy this problem, the following below is methods
documented so far:

* maps/MAPNAME.mat
> Introduced in The Wastes (2003)

* maps/MAPNAME_materials.txt
> Convention by Andrew Lucas, creator of Trinity SDK, modeled after 
> MAPNAME_details.txt

* materials_file `PATH/FILE.txt` via the `worldspawn` entity 
> Introduced in Sven Co-op 5.0

All these methods are supported by Nuclide, as one goal is to implement
conventions by not only Valve but the community as well.

In addition Nuclide has also implemented a way of giving modifications
their own inheritable materials file:

```
sounds/materials_UNIQUENAME.txt
```

The idea here is that any mod or even map pack can include ONLY the textures
used, and no longer will anyone have to manage a near-clone of materials.txt

For repackaging or modding purposes, if you desire to give your map custom
sound definitions, we recommend **The Wastes** its method for individual maps, while
the Nuclide method should be used for Mods or Map Packs. We find these to be
the most clean and efficient way.

**NOTE**: We recommend only using materials text files for GoldSrc related modding
purposes. It is inefficient for modern projects as there are much better
standards already supported in Nuclide. Keep in mind, it takes memory to load
big text files, and lots of text files adds up over play sessions.

# Material List
In Nuclide, this is the currently supported list of material IDs:

| Material ID | Material Name |
|-------------|---------------|
| B           | Bloody Flesh  |
| C           | Concrete      |
| D           | Dirt          |
| F           | Flesh         |
| G           | Grate         |
| H           | Alien         |
| K           | Snow          |
| M           | Metal         |
| N           | Sand          |
| O           | Foliage       |
| P           | Computer      |
| S           | Slosh         |
| T           | Tile          |
| V           | Vent          |
| W           | Wood          |
| Y           | Glass         |


## Game differences
Listed below are definitions for various games and mods. Only the changes and additions are listed since the rest are identical.

The * indicates these definitions are not implemented in Nuclide

## GoldSrc
### Arrangement
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| B                 | Blue Texture        |
| N                 | Snow                |
| R                 | Red Texture         |
| U                 | Slime               |
| X                 | Yellow Texture      |
| Z                 | Black Texture       |

### Counter-Strike
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| N                 | Snow                |
| X                 | Grass               |
*Afraid of Monsters: DC, Natural Selection, and Snow War uses the same definitions.*

### Cry of Fear
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| B                 | Random Twig Snap    |
| H                 | Paper               |
| I                 | Mud                 |
| O                 | Sand                |
| P                 | Snow                |
| R                 | Gravel              |
| U                 | Grass               |
| Y                 | Broken Glass        |
| Z                 | Carpet              |

### Gunman Chronicles
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| G                 | Wood                |
| T                 | Rock                |
| V                 | Sand                |
| W                 | Unknown/Unused?     |

### Firearms
| **Material ID** | **Material Name**                     |
|-------------------|-----------------------------------------|
| B                 | Sandbag                                 |
| N                 | Snow                                    |
| U                 | No impact or decals, just smoke effects |

### Heart of Evil
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| U                 | Mud                 |

### Hostile Intent
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| A                 | Sand                |
| E                 | Foliage             |
| N                 | Snow                |
| R                 | Carpet              |
| U                 | Mud                 |
| Z                 | Grass               |

### Household DEATH!
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| H                 | Wood (Creaky)       |
| I                 | Grass               |

### Night at the Office
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| T                 | Carpet              |

### Opposing Force
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| O                 | Snow                |
*Science and Industry uses the same definitions as Opposing Force.*

### Poke646
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| M                 | Metal/Grate         |
| T                 | Wood/Tile           |
| G                 | Carpet/Grass        |

### Wasteland Half-Life
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| B                 | Barrel              |
| I                 | Sand                |
| N                 | Tinroof             |
| R                 | Rust                |
| U                 | Drywall             |
*The Wastes uses the same definitions.*

## Source
While Source has materials describing a surface with its **$surfaceprop** command, the GoldSrc way of describing materials with a 1-character symbol is still used to define which impact effect to use.

So be aware that a Source engine game may actually have more surface materials than this, these are solely the IDs associated with impact effects.

### Alien Swarm
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| 11                | Steam Pipe          |

Alien Swarm: Reactive Drop uses the same definitions.

### Counter-Strike: Global Offensive
| **Material ID** | **Material Name**       |
|-------------------|---------------------------|
| 11                | Mud                       |
| 12                | Sand Barrel               |
| 13                | Sand Barrel (Penetration) |
| 14                | Metal Shield              |

### Half-Life 2
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| A                 | Antlion             |
| B                 | Flesh (Bloody)      |
| H                 | Flesh (Antlion)     |
| K                 | Snow                |
| L                 | Plastic             |
| N                 | Sand                |
| I                 | Clip                |
| O                 | Foliage             |
| X                 | Fake                |
| -                 | No Decal            |

### Half-Life 2: Episode 2
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| E                 | Antlion Egg Sacks   |
| Z                 | Adviser Shield      |

### Insurgency
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| A                 | Fruit               |

*Day of Infamy uses the same definitions.*

### Left 4 Dead
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| J                 | Grass               |
| K                 | Mud                 |
| Q                 | Asphalt             |
| R                 | Brick               |
| U                 | Cardboard           |
| 1                 | Clay                |
| 2                 | Plaster             |
| 3                 | Rock                |
| 4                 | Rubber              |
| 5                 | Sheetrock           |
| 6                 | Cloth               |
| 7                 | Carpet              |
| 8                 | Paper               |
| 9                 | Upholstery          |
| 10                | Puddle              |

### Portal 2
| **Material ID** | **Material Name** |
|-------------------|---------------------|
| R                 | Reflective          |
