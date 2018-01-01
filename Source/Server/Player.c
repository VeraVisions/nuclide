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

string sPainSounds[5] = {
	"player/pl_pain2.wav",
	"player/pl_pain4.wav",
	"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"
};

/*
=================
Player_SendEntity
=================
*/
float Player_SendEntity( entity ePEnt, float fChanged ) {
	if ( self.health <= 0 && ePEnt != self ) {
		return FALSE;
	}
	
	WriteByte( MSG_ENTITY, ENT_PLAYER );
	WriteByte( MSG_ENTITY, self.modelindex );
	WriteCoord( MSG_ENTITY, self.origin_x );
	WriteCoord( MSG_ENTITY, self.origin_y );
	WriteCoord( MSG_ENTITY, self.origin_z );
	WriteCoord( MSG_ENTITY, self.v_angle_x );
	WriteCoord( MSG_ENTITY, self.angles_y );
	WriteCoord( MSG_ENTITY, self.angles_z );
	WriteShort( MSG_ENTITY, self.velocity_x );
	WriteShort( MSG_ENTITY, self.velocity_y );
	WriteShort( MSG_ENTITY, self.velocity_z );
	WriteFloat( MSG_ENTITY, self.flags );
	WriteByte( MSG_ENTITY, self.weapon );
	return TRUE;
}

/*
=================
Player_Pain
=================
*/
void Player_Pain( int iHitBody ) {
	if ( iHitBody == BODY_HEAD ) {
		Animation_PlayerTopTemp( ANIM_HEAD_FLINCH, 0.1f );
	} else {
		Animation_PlayerTopTemp( ANIM_GUT_FLINCH, 0.1f );
	}
	
	sound( self, CHAN_VOICE, sPainSounds[ floor( random() * 5 ) ], 1, ATTN_IDLE );
	self.velocity = '0 0 0';
}

/*
=================
Player_Death
=================
*/
void Player_Death( int iHitBody ) {
	if ( iHitBody == BODY_HEAD ) {
		sound( self, CHAN_VOICE, sprintf( "player/headshot%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, sprintf( "player/die%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
	}
			
	// Drop a corpse
	entity eCorpse = spawn();
	eCorpse.classname = "remove_me";
	setorigin( eCorpse, self.origin );
	setmodel( eCorpse, self.model );
	setsize( eCorpse, self.mins, self.maxs );
	eCorpse.angles = [ 0, self.angles_y, 0 ];
	eCorpse.movetype = MOVETYPE_BOUNCE;
	
	// Drop primary weapon as well as the bomb if present
	if ( self.fSlotPrimary ) {
		Weapon_DropWeapon( SLOT_PRIMARY );
	} else {
		if ( self.fSlotSecondary ) {
			Weapon_DropWeapon( SLOT_SECONDARY );
		}
	}
	if ( self.fSlotGrenade ) {
		Weapon_DropWeapon( SLOT_GRENADE );
	}
	
	// Make ourselves disappear
	self.modelindex = 0;
	
	if ( self.flags & FL_CROUCHING ) {
		eCorpse.frame = ANIM_CROUCH_DIE;
	} else {
		switch ( iHitBody ) {
			case BODY_HEAD:
				eCorpse.frame = ANIM_DIE_HEAD;
				break;
			case BODY_STOMACH:
				eCorpse.frame = ANIM_DIE_GUT;
				break;
			case BODY_LEGLEFT:
			case BODY_ARMLEFT:
				eCorpse.frame = ANIM_DIE_LEFT;
				break;
			case BODY_LEGRIGHT:
			case BODY_ARMRIGHT:
				eCorpse.frame = ANIM_DIE_RIGHT;
				break;
			default:
				eCorpse.frame = ANIM_DEATH1 + floor( random() * 3 );
				break;
		}
	}
	
	if ( self.flags & FL_CROUCHING ) {
		self.flags -= FL_CROUCHING;
		self.maxspeed = Player_GetMaxSpeed( 0 );
	}
	
	Spawn_MakeSpectator();
	self.classname = "player";
	self.health = 0;
	forceinfokey( self, "*dead", "1" ); 
	forceinfokey( self, "*team", ftos( self.team ) );
	
	if ( self.team == TEAM_T ) {
		iAlivePlayers_T--;
	} else if ( self.team == TEAM_CT ) {
		iAlivePlayers_CT--;
	} else if ( self.team == TEAM_VIP ) {
		iAlivePlayers_CT--; // For consistency
		Rules_RoundOver( TEAM_T, 2500, FALSE );
		return;
	}
	
	if ( ( iAlivePlayers_T == 0 ) && ( iAlivePlayers_CT == 0 ) ) {
		if ( ( iBombPlanted == FALSE ) || ( iBombZones > 0 ) ) {
			Rules_RoundOver( FALSE, 0, FALSE );
		} else {
			Rules_RoundOver( TEAM_T, 3600, FALSE );
		}
	} else {
		// If the bomb has been planted, T deaths don't matter anymore
		if ( ( self.team == TEAM_T ) && ( iAlivePlayers_T == 0 ) ) {
			if ( ( iBombPlanted == FALSE ) || ( iBombZones == 0 ) ) {
				Rules_RoundOver( TEAM_CT, 3600, FALSE );
			}
		} else if ( ( self.team == TEAM_CT ) && ( iAlivePlayers_CT == 0 ) ) {
			Rules_RoundOver( TEAM_T, 3600, FALSE );
		}
	}
}

/*
=================
Player_GetMaxSpeed
=================
*/
float Player_GetMaxSpeed( float fWeapon ) {
	if ( self.flags & FL_CROUCHING ) {
		return ( cvar( "sv_maxspeed" ) * wptTable[ fWeapon ].fSpeedM ) * 0.5;
	} else {
		return cvar( "sv_maxspeed" ) * wptTable[ fWeapon ].fSpeedM;
	}
}

/*
=================
Player_CrouchCheck
=================
*/
float Player_CrouchCheck( entity targ ) {
	vector vTrace = self.origin + '0 0 18';
	
	tracebox( vTrace, VEC_HULL_MIN, VEC_HULL_MAX, vTrace, FALSE, self );

	if ( trace_startsolid == FALSE ) {
		return TRUE;
	}
	
	return FALSE;
}

/*
=================
Player_CrouchDown
=================
*/
void Player_CrouchDown( void ) {
	if ( self.movetype != MOVETYPE_WALK ) {
		return;
	}

	if ( !( self.flags & FL_CROUCHING ) ) {
		setsize( self, VEC_CHULL_MIN, VEC_CHULL_MAX );
		setorigin( self, self.origin - '0 0 18' );
		self.flags = self.flags | FL_CROUCHING;
		self.view_ofs = VEC_PLAYER_CVIEWPOS;
		self.maxspeed = Player_GetMaxSpeed( self.weapon );
		self.iCrouchAttempt = TRUE;
		return;
	}

	self.iCrouchAttempt = FALSE;
}

/*
=================
Player_CrouchUp
=================
*/
void Player_CrouchUp( void ) {
	if ( self.movetype != MOVETYPE_WALK ) {
		return;
	}

	if ( ( self.flags & FL_CROUCHING ) && ( Player_CrouchCheck( self ) ) ) {
		setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
		setorigin( self, self.origin + '0 0 18' );
		self.velocity_z = self.velocity_z + 25;
		self.view_ofs = VEC_PLAYER_VIEWPOS;
		self.flags = ( self.flags - FL_CROUCHING );
		self.iCrouchAttempt = FALSE;
		self.maxspeed = Player_GetMaxSpeed( self.weapon );
		return;
	}

	self.iCrouchAttempt = TRUE;
}

/*
====================
Player_UseDown
====================
*/
void Player_UseDown( void ) {
	if ( self.health <= 0 ) {
		return;
	} else if ( !( self.flags & FL_USERELEASED ) ) {
		return;
	}
	
	vector vSource;
	entity eOriginalSelf;

	makevectors(self.v_angle);
	vSource = self.origin + self.view_ofs;
	traceline ( vSource, vSource + ( v_forward * 64 ), FALSE, self);
	
	if ( trace_ent.iUsable ) {
		if ( ( trace_ent.classname != "c4bomb" ) && ( trace_ent.classname != "func_pushable" ) ) {
			self.flags = ( self.flags - FL_USERELEASED );
			sound( self, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE );
		} 
		
		eActivator = self;
		eOriginalSelf = self;
		self = trace_ent;
		self.vUse();
		self = eOriginalSelf;
	} else {
		sound( self, CHAN_ITEM, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE );
		self.flags = ( self.flags - FL_USERELEASED );
	}
}

/*
====================
Player_UseUp
====================
*/
void Player_UseUp( void ) {
	if ( !( self.frags & FL_USERELEASED ) ) {
		self.flags = self.flags | FL_USERELEASED;
		self.fProgressBar = 0;
	}
}

/*
=================
PlayerPreThink

Run before physics
=================
*/
void PlayerPreThink( void ) { 
	Input_Handle();
	BaseGun_ShotMultiplierUpdate();
}

/*
=================
PlayerPreThink

Run after physics
=================
*/
void PlayerPostThink( void ) {
	Animation_PlayerUpdate();
	Footsteps_Update();
	
	self.SendFlags = 1;
}
