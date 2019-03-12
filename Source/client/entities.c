/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update(float new)
{
	float t;
	t = readbyte();

	switch (t) {
	case ENT_PLAYER:
		Player_ReadEntity(new);
		break;
	case ENT_SPRITE:
		Sprite_Animated();
		break;
	case ENT_SPRAY:
		Spraylogo_Parse();
		break;
	case ENT_DECAL:
		Decal_Parse();
		break;
	default:
		error("Unknown entity type update received.\n");
	}
}
