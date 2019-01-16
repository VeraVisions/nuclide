/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
	WriteShort( MSG_ENTITY, self.modelindex );
	WriteCoord( MSG_ENTITY, self.origin_x );
	WriteCoord( MSG_ENTITY, self.origin_y );
	WriteCoord( MSG_ENTITY, self.origin_z );
	WriteCoord( MSG_ENTITY, self.v_angle_x );
	WriteCoord( MSG_ENTITY, self.angles_y );
	WriteCoord( MSG_ENTITY, self.angles_z );
	WriteCoord( MSG_ENTITY, self.velocity_x );
	WriteCoord( MSG_ENTITY, self.velocity_y );
	WriteCoord( MSG_ENTITY, self.velocity_z );
	WriteFloat( MSG_ENTITY, self.flags );
	WriteFloat( MSG_ENTITY, self.pmove_flags );
	WriteByte( MSG_ENTITY, self.weapon );
	WriteByte( MSG_ENTITY, self.health );
	WriteFloat( MSG_ENTITY, self.movetype );
	WriteFloat( MSG_ENTITY, self.view_ofs[2] );
	return TRUE;
}

/*
=================
Player_Pain
=================
*/
void Player_Pain( int iHitBody ) {
	/*
	if ( iHitBody == BODY_HEAD ) {
		Animation_PlayerTopTemp( ANIM_HEAD_FLINCH, 0.25f );
	} else {
		Animation_PlayerTopTemp( ANIM_GUT_FLINCH, 0.25f );
	}*/
	
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

	Rules_CountPlayers();

	if ( self.team == TEAM_VIP ) {
		Rules_RoundOver( TEAM_T, 2500, FALSE );
		return;
	}

	Rules_DeathCheck();
}

/*
====================
Player_UseDown
====================
*/
void UseWorkaround( entity eTarget )
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}
void Player_UseDown( void ) {
	if ( self.health <= 0 ) {
		return;
	} else if ( !( self.flags & FL_USERELEASED ) ) {
		return;
	}
	
	vector vSource;

	makevectors(self.v_angle);
	vSource = self.origin + self.view_ofs;
	traceline ( vSource, vSource + ( v_forward * 64 ), FALSE, self);
	
	if (trace_ent.PlayerUse) {
		if ( ( trace_ent.classname != "c4bomb" ) && ( trace_ent.classname != "func_pushable" ) ) {
			self.flags = ( self.flags - FL_USERELEASED );
			sound( self, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE );
		} 
		
		UseWorkaround(trace_ent);
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
