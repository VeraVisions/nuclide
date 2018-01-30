/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
.float netpmove_flags;

string sPModels[ CS_WEAPON_COUNT - 1 ] = {
	"models/p_knife.mdl",
	"models/p_usp.mdl",
	"models/p_glock18.mdl",
	"models/p_deagle.mdl",
	"models/p_p228.mdl",
	"models/p_elite.mdl",
	"models/p_fiveseven.mdl",
	"models/p_m3.mdl",
	"models/p_xm1014.mdl",
	"models/p_mp5.mdl",
	"models/p_p90.mdl",
	"models/p_ump45.mdl",
	"models/p_mac10.mdl",
	"models/p_tmp.mdl",
	"models/p_ak47.mdl",
	"models/p_sg552.mdl",
	"models/p_m4a1.mdl",
	"models/p_aug.mdl",
	"models/p_scout.mdl",
	"models/p_awp.mdl",
	"models/p_g3sg1.mdl",
	"models/p_sg550.mdl",
	"models/p_m249.mdl",
	"models/p_c4.mdl",
	"models/p_flashbang.mdl",
	"models/p_hegrenade.mdl",
	"models/p_smokegrenade.mdl"
};

//.float bonecontrol1; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol2; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol3; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol4; //Halflife model format bone controller. On player models, this typically affects the spine's yaw.
//.float bonecontrol5; //Halflife model format bone controller. This typically affects the mouth.
//.float subblendfrac; //Weird animation value specific to halflife models. On player models, this typically affects the spine's pitch.
//.float basesubblendfrac; // legs part.
.float subblend2frac; // Up/Down

static float Player_Gun_PreDraw (void) {
	self.entnum = self.owner.entnum; //so this entity gets its RF_EXTERNALMODEL flag rewritten as needed
	addentity(self);
	self.entnum = 0;	//so that findfloat won't find the wrong thing.
	return PREDRAW_NEXT;
}

void Player_Draw( void ) {
	if ( !self.eGunModel ) {
		self.eGunModel = spawn();
		self.eGunModel.classname = "pmodel";
		self.eGunModel.owner = self;
		self.eGunModel.predraw = Player_Gun_PreDraw;
		self.eGunModel.drawmask = MASK_ENGINE;
	}
	    
	// Only bother updating the model if the weapon has changed
	if ( self.fWeaponLast != self.weapon ) {
		if ( self.weapon ) {
			setmodel( self.eGunModel, sPModels[ self.weapon - 1 ] );
		} else {
			setmodel( self.eGunModel, "" );
		}
		self.fWeaponLast = self.weapon;
	    	
		// Update the bone index of the current p_ model so we can calculate the offset
		// Get the weapon bone ID for the current player model
		self.fWeaponBoneID = gettagindex( self, "Bip01 R Hand" );
		self.eGunModel.fWeaponBoneID = gettagindex( self.eGunModel, "Bip01 R Hand" );
	}

	Animation_PlayerUpdate();
	self.baseframe1time += frametime;
	self.frame1time += frametime;
		
	self.baseframe2time += frametime;
	self.frame2time += frametime;	
	
	self.bonecontrol5 = stof( getplayerkeyvalue( player_localnum, INFOKEY_P_VOIPLOUDNESS ) );
}

/*
=================
Player_PreDraw

Runs as part of the addentities builtin.
Responsible for player appearance/interpolation.
=================
*/
float Player_PreDraw( void ) {
	Player_Draw();
	addentity( self );
	return PREDRAW_NEXT;
}

/*
=================
Player_Predict

Runs before every frame is rendered.
Responsible for local player prediction.
=================
*/
void Player_Predict(void) {
	vector vOldOrigin = self.origin = self.netorigin;
	vector vOldAngles = self.angles = self.netangles;
	vector vOldVelocity = self.velocity = self.netvelocity;
	float fOldPMoveFlags = self.pmove_flags = self.netpmove_flags;
	
	// Don't predict if we're frozen/paused FIXME: FTE doesn't have serverkey_float yet!
	if ( serverkey( SERVERKEY_PAUSESTATE ) == "1" || ( ( getstati( STAT_GAMESTATE ) == GAME_FREEZE ) && ( getstati( STAT_HEALTH ) > 0 ) ) ) {
		pSeat->vPlayerOrigin = self.origin;
		vOldOrigin = pSeat->vPlayerOrigin;

		self.velocity = '0 0 0';
		vOldVelocity = self.velocity;
		fOldPMoveFlags = 0;
	} else {
		if ( getplayerkeyvalue( player_localnum, "*spec" ) == "0" ) {
			self.movetype = MOVETYPE_WALK;
		} else {
			self.movetype = MOVETYPE_NOCLIP;
		}

		if (self.pmove_flags & 0x80000) {
			self.flags |= FL_ONGROUND;
		} else {
			self.flags &~= FL_ONGROUND;
		}
		
		for ( int i = self.pmove_frame; i <= clientcommandframe; i++ ) {
			getinputstate( i );
			runplayerphysics();
		}
		
		if ( self.flags & FL_ONGROUND ) {
			self.pmove_flags |= 0x80000;
		}
	}
	pSeat->vPlayerOriginOld = pSeat->vPlayerOrigin;

	if ( ( self.flags & FL_ONGROUND ) && ( self.origin_z - pSeat->vPlayerOriginOld.z > 0 ) ) {
		pSeat->vPlayerOriginOld.z += frametime * 150;

		if ( pSeat->vPlayerOriginOld.z > self.origin_z ) {
			pSeat->vPlayerOriginOld.z = self.origin_z;
		}
		if ( self.origin_z - pSeat->vPlayerOriginOld.z > 18 ) {
			pSeat->vPlayerOriginOld.z = self.origin_z - 18;
		}
		pSeat->vPlayerOrigin.z += pSeat->vPlayerOriginOld.z - self.origin_z;
	} else {
		pSeat->vPlayerOriginOld.z = self.origin_z;
	}

	pSeat->vPlayerVelocity = self.velocity;

	if ( autocvar_cl_thirdperson == TRUE && getstatf( STAT_HEALTH ) > 0 ) {
		makevectors( view_angles );
		vector vStart = [ self.origin_x, self.origin_y, pSeat->vPlayerOriginOld.z + 8 ] + ( v_right * 4 );
		vector vEnd = vStart + ( v_forward * -48 ) + '0 0 8' + ( v_right * 4 );
		traceline( vStart, vEnd, FALSE, self );
		pSeat->vPlayerOrigin = trace_endpos + ( v_forward * 5 );
	} else {
		pSeat->vPlayerOrigin = [ self.origin_x, self.origin_y, pSeat->vPlayerOriginOld.z ];
	}

	self.movetype = MOVETYPE_NONE;
}

/*
=================
Player_Preupdate

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on (so any non-networked state updates locally).
=================
*/
void Player_PreUpdate( void ) {
	self.origin = self.netorigin;
	self.angles = self.netangles;
	self.velocity = self.netvelocity;
	self.pmove_flags = self.netpmove_flags;

	if ( getplayerkeyvalue( player_localnum, "*spec" ) == "0" ) {
		self.movetype = MOVETYPE_WALK;
	} else {
		self.movetype = MOVETYPE_NOCLIP;
	}

	if ( self.pmove_flags & 0x80000 ) {
		self.flags |= FL_ONGROUND;
	} else {
		self.flags &~= FL_ONGROUND;
	}
	
	//we want to predict an exact copy of the data in the new packet
	for ( ; self.pmove_frame <= servercommandframe; self.pmove_frame++ ) {
		if ( getinputstate( self.pmove_frame ) )
			runplayerphysics();
	}

	if ( self.flags & FL_ONGROUND ) {
		self.pmove_flags |= 0x80000;
	}

	//we now have self.pmove_flags set properly...
	
	self.movetype = MOVETYPE_NONE;
}
void Player_PostUpdate( void ) {
	self.netorigin = self.origin;
	self.netangles = self.angles;
	self.netvelocity = self.velocity;
	self.netpmove_flags = self.pmove_flags;
	self.pmove_frame = servercommandframe+1;
}
