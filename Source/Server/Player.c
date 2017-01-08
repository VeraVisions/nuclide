/*
OpenCS Project
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

/*float Player_SendEntity( entity ePEnt, float fChanged ) {
	WriteByte( MSG_ENTITY, ENT_PLAYER );
	WriteByte( MSG_ENTITY, fChanged );
	WriteCoord( MSG_ENTITY, self.origin_x );
	WriteCoord( MSG_ENTITY, self.origin_y );
	WriteCoord( MSG_ENTITY, self.origin_z );
	WriteCoord( MSG_ENTITY, self.angles_x );
	WriteCoord( MSG_ENTITY, self.angles_y );
	WriteCoord( MSG_ENTITY, self.angles_z );
	WriteByte( MSG_ENTITY, self.modelindex );
	
	if ( fChanged & PLAYER_SENDFLAG_INGAME ) {
		WriteCoord( MSG_ENTITY, self.velocity_x );
		WriteCoord( MSG_ENTITY, self.velocity_y );
		WriteCoord( MSG_ENTITY, self.velocity_z );
		WriteFloat( MSG_ENTITY, self.flags );
	}
	return TRUE;
}*/

string sPainSounds[5] = {
	"player/pl_pain2.wav",
	"player/pl_pain4.wav",
	"player/pl_pain5.wav",
	"player/pl_pain6.wav",
	"player/pl_pain7.wav"
};

void Player_Pain( int iHitBody ) {
	if ( iHitBody == BODY_HEAD ) {
		Animation_PlayerTop( ANIM_HEAD_FLINCH, 0.1f );
	} else {
		Animation_PlayerTop( ANIM_GUT_FLINCH, 0.1f );
	}
	
	sound( self, CHAN_VOICE, sPainSounds[ floor( random() * 5 ) ], 1, ATTN_IDLE );
	self.velocity = '0 0 0';
}

void Player_Death( int iHitBody ) {
	if ( iHitBody == BODY_HEAD ) {
		sound( self, CHAN_VOICE, sprintf( "player/headshot%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, sprintf( "player/die%d.wav", floor( ( random() * 3 ) + 1 ) ), 1, ATTN_NORM );
	}
			
	// Drop a corpse
	entity eCorpse = spawn();
	setorigin( eCorpse, self.origin );
	setmodel( eCorpse, self.model );
	setsize( eCorpse, self.mins, self.maxs );
	eCorpse.angles = [ 0, self.angles_y, 0 ];
	eCorpse.movetype = MOVETYPE_BOUNCE;
	
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
	
	if ( ( iAlivePlayers_T == 0 ) && ( iAlivePlayers_CT == 0 ) && ( iBombPlanted == FALSE ) ) {
		Rules_RoundOver( FALSE, 3600, FALSE );
	} else {
		// If the bomb has been planted, T deaths don't matter anymore
		if ( ( iAlivePlayers_T == 0 ) && ( iBombPlanted == FALSE ) ) {
			Rules_RoundOver( TEAM_CT, 3600, FALSE );
		} else if ( iAlivePlayers_CT == 0 ) {
			Rules_RoundOver( TEAM_T, 3600, FALSE );
		}
	}
}

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
	float fCheck = FALSE;
	vector vTrace = self.origin + '0 0 20';
	
	tracebox( vTrace, VEC_HULL_MIN, VEC_HULL_MAX, vTrace, FALSE, self );

	if ( trace_startsolid == FALSE ) {
		fCheck = TRUE;
	}
	
	return fCheck;
}

/*
=================
Player_CrouchDown
=================
*/
void Player_CrouchDown( void ) {
	if( self.movetype != MOVETYPE_WALK ) {
		return;
	}

	if( !( self.flags & FL_CROUCHING ) ) {
		setsize( self, VEC_CHULL_MIN, VEC_CHULL_MAX );
		self.flags = self.flags | FL_CROUCHING;
		self.view_ofs = VEC_PLAYER_CVIEWPOS;
		self.velocity_z = self.velocity_z + 50;
		self.maxspeed = Player_GetMaxSpeed( self.weapon );
		self.iCrouchAttempt = 1;
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

	if ( ( self.flags & FL_CROUCHING ) && ( !self.velocity_z ) && ( Player_CrouchCheck( self ) ) ) {
		setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );

		setorigin( self, self.origin + '0 0 18');
		self.velocity_z = self.velocity_z + 16;
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
		if ( trace_ent.classname != "c4bomb" ) {
			self.flags = ( self.flags - FL_USERELEASED );
			sound( self, CHAN_WEAPON, "common/wpn_select.wav", 0.25, ATTN_IDLE );
		} 
		
		eActivator = self;
		eOriginalSelf = self;
		self = trace_ent;
		self.vUse();
		self = eOriginalSelf;
	} else {
		sound( self, CHAN_WEAPON, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE );
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

void PlayerPreThink( void ) { 
	Input_Handle();
	OpenCSGunBase_ShotMultiplierUpdate();
	
	if ( !( self.flags & FL_ONGROUND ) ){
		self.fFallVelocity = -self.velocity_z;
	} 
}

void PlayerPostThink( void ) {
	Animation_PlayerUpdate();
	
	if ( ( self.flags & FL_ONGROUND ) && ( self.health > 0 ) && ( self.fFallVelocity > 100 )) {
		if ( self.fFallVelocity > 580 ) {
			self.fFallVelocity -= 580;
			float fFallDamage = self.fFallVelocity * ( 200 / ( 1024 - 580 ) );
			Damage_Apply( self, world, fFallDamage, self.origin );
		} 
		self.fFallVelocity = 0;
	}
}
