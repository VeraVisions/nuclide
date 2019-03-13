/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

string __fullspawndata;

class CBaseEntity {
	string targetname;
	string target;
	
	void() CBaseEntity;

	virtual void() Init;
	virtual void(string, string) SpawnKey;
};

void CBaseEntity :: SpawnKey (string strField, string strKey) {
	switch ( strField ) {
		case "targetname":
			targetname = strKey;
			break;
		case "target":
			target = strKey;
			break;
		case "origin":
			origin = stov( strKey );
			setorigin( this, origin );
			break;
		case "angles":
			angles = stov( strKey );
			break;
		case "model":
			model = strKey;
			break;
		case "style":
			style = stof( strKey );
			break;
		case "color":
			color = stov( strKey );
			break;
		case "movetype":
			movetype = stof( strKey );
			break;
		case "solid":
			solid = stof( strKey );
			break;
		case "scale":
			scale = stof( strKey );
			break;
		default:
			//dprint(sprintf("Unknown field %s, value %s\n", strField, strKey));
	}
}

void CBaseEntity::Init(void)
{
	for (int i = 0; i < (tokenize(__fullspawndata) - 1); i += 2) {
		//dprint(sprintf("SpawnData: %s %s\n", argv(i), argv(i+1)));
		SpawnKey(argv(i), argv(i+1));
	}
}

void CBaseEntity::CBaseEntity(void)
{
	Init();
}
