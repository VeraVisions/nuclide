/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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
		if ( iBombPlanted == TRUE ) {
			Rules_RoundOver( TEAM_T, 3600, FALSE );
		} else {
			Rules_RoundOver( FALSE, 0, FALSE );
		}
	} else {
		if ( ( self.team == TEAM_T ) && ( iAlivePlayers_T == 0 ) ) {
			if ( iBombPlanted == FALSE ) {
				Rules_RoundOver( TEAM_CT, 3600, FALSE );
			}
		} else if ( ( self.team == TEAM_CT ) && ( iAlivePlayers_CT == 0 ) ) {
			Rules_RoundOver( TEAM_T, 3600, FALSE );
		}
	}
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
