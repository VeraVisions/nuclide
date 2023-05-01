# MapTweaks

## Overview

This is a very customizable system that applies changes to levels/maps depending on a variable amount of parameters. It was invented specifically for Nuclide and designed to work together with [EntityDefs](Documentation/EntityDef.md).

## Syntax

All MapTweaks are defined within `scripts/maptweaks.txt`.

Let's take a look at an example **MapTweak**:

```
hldm_tweak
{
	when-cvar deathmatch equals 2
	when-serverinfo *bspversion equals 30

	replace weapon_gauss info_null
	replace weapon_egon info_null
}
```

The `hldm_tweaks` is just a user-defined name. It doesn't affect functionality.

The `when-cvar` and `when-serverinfo` lines are **checks**. each one is checked individually and only if all are positive will the `replace` lines take effect.

You can have as many lines in there as you like.

Other than `equals`, you can also use one of the following keywords when comparing values:

- **less-than**
- **greater-than**
- **is-not**

At this time, `when-cvar` and `when-serverinfo` only do comparisons on numbers. So you cannot check for strings at this time.