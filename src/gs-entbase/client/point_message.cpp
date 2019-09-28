/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*QUAKED point_message (1 0 0) (-8 -8 -8) (8 8 8)
"message"	The message to display.
"radius"	The radius in which it will appear.

Client-side overlay/message that is projected in relation to its position
in 3D space.
Used for zoo and test maps in which less interactive overlays are desired.
*/

class point_message:CBaseEntity
{
	float radius;
	string message;
	void() point_message;
	virtual void(string, string) SpawnKey;
};

void point_message::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "radius":
			radius = stof(strKey);
			break;
		case "message":
			message = strKey;
			break;
		case "origin":
			origin = stov( strKey );
			setorigin( this, origin );
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}

void point_message::point_message(void)
{
	radius = 512;
	message = "No message";
	Init();
}
