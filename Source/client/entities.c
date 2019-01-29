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
void CSQC_Ent_Update(float flIsNew)
{
	float fEntType = readbyte();
	
	if ( fEntType == ENT_PLAYER ) {
		Player_ReadEntity(flIsNew);
	} else if ( fEntType == ENT_SPRITE ) {
		Sprite_Animated();
	} else if ( fEntType == ENT_SPRAY ) {
		Spraylogo_Parse();
	} else if ( fEntType == ENT_DECAL ) {
		string decalname = "";
		string decalshader = "";

		self.origin[0] = readcoord();
		self.origin[1] = readcoord();
		self.origin[2] = readcoord();
		
		self.angles[0] = readcoord();
		self.angles[1] = readcoord();
		self.angles[2] = readcoord();
		
		self.color[0] = 1.0f - ( readbyte() / 255 );
		self.color[1] = 1.0f - ( readbyte() / 255 );
		self.color[2] = 1.0f - ( readbyte() / 255 );
		self.classname = readstring();
		self.size = drawgetimagesize(self.classname);

		if (serverkeyfloat("*bspversion") == 30) {
			decalname = sprintf("decal_%s", self.classname);
			decalshader = sprintf("{\npolygonOffset\n{\nclampmap %s\nblendFunc filter\n}\n}", self.classname);
			shaderforname(decalname, decalshader);
			self.classname = decalname;
		}
		
		makevectors( self.angles );
		float surf = getsurfacenearpoint(world, self.origin);
		vector s_dir = getsurfacepointattribute(world, surf, 0, SPA_S_AXIS);
		vector t_dir = getsurfacepointattribute(world, surf, 0, SPA_T_AXIS);
		self.mins = v_up / self.size[0];
		self.maxs = t_dir / self.size[1];

		self.predraw = Effect_Decal;
		self.drawmask = MASK_ENGINE;
	}
}
