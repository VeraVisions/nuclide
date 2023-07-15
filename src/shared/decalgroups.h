/* Copyright (c) 2022, Vera Visions, L.L.C.  All rights reserved. */

/*
	Decal Property List Specs

	A decal group consists of one material per line:

	groupname
	{
		"textures/decals/foo" "1"
		"textures/decals/bar" "1"
	}

	And the weight is used to determine how often the decal gets used.
	If you're unsure, put in "1". 

	Also, any group named 'TranslationData' will be ignored.
	That group is used in Source Engine games to map the 'gamematerial'
	keys from surfaceproperties.txt over to a decal.

	The reason why we can't support it is simple:
	In Source, decals are tied to surfaceproperties and in GoldSrc
	the weapons are responsible for deciding which decals to use
	on a surface. We obviously cannot do both, but the GoldSrc way
	is the most appropriate one for our purposes.
	
*/

/* public API */
void DecalGroups_Init(void);
void DecalGroups_Place(string group, vector org);
int DecalGroups_NumForName(string group);

#ifdef CLIENT
void DecalGroups_Precache(void);
void DecalGroups_Receive(void);
#endif