/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void CSQC_ambient_generic( string sSample, float fVolume, float fAttenuation, float fLoop, float lFORate ) {
	//print( sprintf( "SOUND: %s, %f, %d\n%d %d %d", sSample, fVolume, fAttenuation, self.origin_x, self.origin_y, self.origin_z ) );
	static void LFOHack (void) {
		sound( self, CHAN_VOICE, self.classname, self.movetype, self.style, 0, 0 );
		self.nextthink = self.solid + time;
	}
	// Hack
	if ( lFORate ) {
		self.classname = sSample;
		self.movetype = fVolume;
		self.style = fAttenuation;
		self.think = LFOHack;
		self.solid = lFORate / 10;
		self.nextthink = self.solid + time;
		fLoop = FALSE;
	}
	
	/*if ( fLoop ) {
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, SOUNDFLAG_FORCELOOP );
	} else {*/
		sound( self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, 0 );
	//}
}

/*
=================
CSQC_Ent_Update

Called whenever an entity is sent manually via .SendFlags and so on
=================
*/
void CSQC_Ent_Update( float flIsNew ) {
	float fEntType = readbyte();
	
	if( fEntType == ENT_PLAYER ) {
		if ( flIsNew == TRUE ) {
			self.classname = "player";
			self.solid = SOLID_SLIDEBOX;
			self.predraw = Player_PreDraw;
			self.drawmask = MASK_ENGINE;
			self.customphysics = Empty;
			setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
		}

		self.modelindex = readshort();
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		self.flUpAngle = readcoord() / 90;
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		self.velocity_x = readcoord();
		self.velocity_y = readcoord();
		self.velocity_z = readcoord();
		self.flags = readfloat();
		self.pmove_flags = readfloat();
		self.weapon = readbyte();
		self.health = readbyte();
		self.movetype = readfloat();
		self.view_ofs[2] = readfloat();
		setorigin( self, self.origin );
		
		if (self.health < self.oldhealth) {
			Animation_PlayerTopTemp( ANIM_GUT_FLINCH, 0.1f );
		}
		self.oldhealth = self.health;
	} else if ( fEntType == ENT_AMBIENTSOUND ) {
		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		setorigin( self, self.origin );
		
		CSQC_ambient_generic( readstring(), readfloat(), readbyte(), readbyte(), readbyte() );
	} else if ( fEntType == ENT_SPRITE ) {
		Sprite_Animated();
	} else if ( fEntType == ENT_SPRAY ) {
		Spraylogo_Parse();
	} else if ( fEntType == ENT_DECAL ) {
		string decalname = "";
		string decalshader = "";

		self.origin_x = readcoord();
		self.origin_y = readcoord();
		self.origin_z = readcoord();
		
		self.angles_x = readcoord();
		self.angles_y = readcoord();
		self.angles_z = readcoord();
		
		self.color_x = 1.0f - ( readbyte() / 255 );
		self.color_y = 1.0f - ( readbyte() / 255 );
		self.color_z = 1.0f - ( readbyte() / 255 );
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

/*
=================
CSQC_Ent_Remove

Self explanatory
=================
*/
void CSQC_Ent_Remove( void ) {
	if ( self.eGunModel ) {
		remove( self.eGunModel );
	}
	
	soundupdate( self, CHAN_VOICE, "", -1, ATTN_IDLE, 0, 0, 0 );
	remove( self );
}

