
/* Some games want to read from textures/, others from materials/ */
var string autocvar_material_pathPrefix = "textures";


/** Loads a named material from a path in the virtual filesystem.
The path can have a prefix, defined by the cvar `material_pathPrefix`.

@param materialName Name of the material to load.
@return The final material handle. */
string
precache_material(string materialName)
{
	string newPath = "";

	if (STRING_SET(autocvar_material_pathPrefix)) {
		float prefixLength = strlen(autocvar_material_pathPrefix);

		/* avoid recursion! */
		if (substring(materialName, 0, prefixLength) != autocvar_material_pathPrefix) {
			newPath = strcat(autocvar_material_pathPrefix, "/", materialName);
		} else {
			newPath = materialName;
		}
	} else {
		newPath = materialName;
	}

#ifdef SERVER
	return newPath;
#else
	return precache_pic(newPath, 0);
#endif
}
