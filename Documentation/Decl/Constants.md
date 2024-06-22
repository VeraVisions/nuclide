# Decl/Defs {#scripting}

## Constants

Often you want to be able to use aliases for values inside your **EntityDef** files.

For that, you can have a name/value pair mapping inside a text file named `scripts/constants.txt`.

```
// some comments here
WEAPON_NONE	 0
WEAPON_CROWBAR 1
WEAPON_GLOCK 2
[...]
DEFAULT_NAME "Max"
```

And then you use the identifers in place of those constants. Similar to environment variables in the **UNIX** shell.

```
entityDef weapon_glock {
	"spawnclass" "NSItem"
	"inv_item" "$WEAPON_GLOCK"
	[...]
}
```
