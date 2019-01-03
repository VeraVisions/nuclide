/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef SSQC
.float fBombProgress;
#else
int iBombProgress;
#endif

// Weapon Info
weaponinfo_t wptC4BOMB = {
	WEAPON_C4BOMB, 		// Identifier
	SLOT_GRENADE,
	0, 					// Price
	EXPLOSIVE_C4, 		// Caliber ID
	1.0, 				// Max Player Speed
	0, 					// Bullets Per Shot
	0, 					// Clip/MagSize
	500, 				// Damage
	1, 					// Penetration Multiplier
	64, 				// Bullet Range
	1,	 				// Range Modifier
	TYPE_AUTO,
	0.0, 				// Attack-Delay
	0.0, 				// Reload-Delay
	iNull, 				// Caliber Pointer
	iNull, 				// Clip Pointer
	1,					// Accuracy Divisor
	1,					// Accuracy Offset
	1,					// Max Inaccuracy
	8,					// Minimum Crosshair Distance
	4,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_C4,			// Animation Type
	FALSE
};

// Anim Table
enum {
	ANIM_C4_IDLE,
	ANIM_C4_DRAW,
	ANIM_C4_DROP,
	ANIM_C4_ENTERCODE
};

#ifdef SSQC
var float fBeepTime; // Used for the beeping sounds that last 1.5 seconds
var float fDefuseProgress; // Used to track... the progress

static void WeaponC4BOMB_Use( void ) {
	if ( cvar( "developer" ) == 0 ) {
		if ( eActivator.team != TEAM_CT ) {
			return;
		}
	}
		
	// On first use, play defusing sound
	if ( self.eUser == world ) {
		sound( self, CHAN_VOICE, "weapons/c4_disarm.wav", 1.0, ATTN_NORM );
	}
		
	// Takes 10 seconds to defuse that thing!
	if ( fDefuseProgress > 10 ) {
		sound( self, CHAN_VOICE, "weapons/c4_disarmed.wav", 1.0, ATTN_NORM );
		Rules_RoundOver( TEAM_CT, 3500, TRUE );
		Radio_BroadcastMessage( RADIO_BOMBDEF );
		eActivator.fProgressBar = 0;
		iBombPlanted = FALSE;
		fBeepTime = 0;
		fDefuseProgress = 0;
		remove( self );
		return;
	}
		
	// If the user has the right equipment, make 10 seconds pass twice as fast
	if ( eActivator.iEquipment & EQUIPMENT_DEFUSALKIT ) {
		fDefuseProgress += 0.02;
	} else {
		fDefuseProgress += 0.01;
	}
		
	eActivator.fProgressBar = fDefuseProgress * 0.1;
		
	// Make sure WeaponC4BOMB_Think knows who the user is
	self.eUser = eActivator;
}

static void WeaponC4BOMB_Think( void ) {
	// If the guy who started using us stopped using us, reset the defuser counter
	if ( ( self.eUser != world ) && ( self.eUser.button5 == FALSE ) ) {
		self.eUser.fProgressBar = 0;
		self.eUser = world;
		fDefuseProgress = 0;
	}
		
	// If our time has passed, explode
	if ( self.fAttackFinished < time ) {
		// Terrorists win
		Rules_RoundOver( TEAM_T, 3500, FALSE );
			
		// Make it explode and hurt things
		Damage_Radius( self.origin, self, 500, 1024, FALSE );
		sound( self, CHAN_VOICE, "weapons/c4_explode1.wav", 1.0, ATTN_NONE );
			
		// Trigger all targets
		entity eBombChain = findradius( self.origin, iBombRadius );
			
		while ( eBombChain ) {
			if ( ( eBombChain.classname == "func_bomb_target" ) ) {
				entity eOld = self;
				self = eBombChain;
				Entities_UseTargets();
				self = eOld;
			}
			eBombChain = eBombChain.chain;
		}
			
		fBeepTime = 0;
		fDefuseProgress = 0;
		iBombPlanted = FALSE;
		remove( self );
		return;
	}
		
	// Only play sounds every once in a while
	if ( fBeepTime > time ) {
		return;
	}
	fBeepTime = time + 1.5;
		
	if ( self.fAttackFinished - time < 2 ) {
		sound( self, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NONE );
	} else if ( self.fAttackFinished - time < 5 ) {
		sound( self, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NORM );
	} else if ( self.fAttackFinished - time < 10 ) {
		sound( self, CHAN_VOICE, "weapons/c4_beep4.wav", 1.0, ATTN_NORM );
	} else if ( self.fAttackFinished - time < 20 ) {
		sound( self, CHAN_VOICE, "weapons/c4_beep3.wav", 1.0, ATTN_NORM );
	} else if ( self.fAttackFinished - time < 30 ) {
		sound( self, CHAN_VOICE, "weapons/c4_beep2.wav", 1.0, ATTN_NORM );
	} else {
		sound( self, CHAN_VOICE, "weapons/c4_beep1.wav", 1.0, ATTN_NORM );
	}
}

void WeaponC4BOMB_Drop( vector vBombPos, vector vNormal ) {
	// Do all the dirty entspawning stuff
	entity eBomb = spawn();
	eBomb.classname = "c4bomb";
	
	eBomb.solid = SOLID_BBOX;
	setmodel( eBomb, "models/w_c4.mdl" );
	setorigin( eBomb, vBombPos );
	setsize( eBomb, '-6 -6 0', '6 6 6' );
	
	eBomb.customphysics = WeaponC4BOMB_Think;
	eBomb.fAttackFinished = time + autocvar_mp_c4timer;
	eBomb.gflags = GF_USABLE;
	eBomb.PlayerUse = WeaponC4BOMB_Use;
	eBomb.owner = self;
	
	// Align the bomb to the wall
	vector vBombAngles = self.angles + '0 90 0';
	vBombAngles_x *= -1;
	makevectors( vBombAngles );
	vector vCoplanar = v_forward - ( v_forward * vNormal ) * vNormal;
	eBomb.angles = vectoangles( vCoplanar, vNormal );
	
	sound( eBomb, CHAN_WEAPON, "weapons/c4_plant.wav", 1.0, ATTN_IDLE );
	
	// Broadcast the bomb state
	Radio_BroadcastMessage( RADIO_BOMBPL );
	iBombPlanted = TRUE;
	
	// Tell the bomb-planter to get rid of the weapon!
	self.fSlotGrenade = self.fSlotGrenade - WEAPON_C4BOMB;
	Weapon_SwitchBest();
	//eprint( eBomb );
}
#endif

void WeaponC4BOMB_Draw( void ) {
#ifdef SSQC
	Client_SendEvent( self, EV_WEAPON_DRAW );
#else
	View_PlayAnimation( ANIM_C4_DRAW );
#endif
}

void WeaponC4BOMB_Release( void ) {
#ifdef SSQC
	self.fBombProgress = 0;
#else
	// TODO: This does not happen, yet
	View_PlayAnimation( ANIM_C4_IDLE );
	iBombProgress = 0;
#endif
}

void WeaponC4BOMB_PrimaryFire( void ) {
#ifdef SSQC
	vector source;
	source = self.origin + self.view_ofs;
	makevectors( self.v_angle );
	other = world;
	traceline( source, source + ( v_forward * 64 ), MOVE_OTHERONLY, self );

	// If we aren't aiming at a place or look in the wrong location... stop it
	if ( trace_fraction == 1 || self.fInBombZone == FALSE ) {
		Animation_ReloadWeapon( self );
		WeaponC4BOMB_Release();
		self.fAttackFinished = time + 1.0;
		return;
	}

	// Play the sequence at the start
	if ( self.fBombProgress == 0 ) {
		self.fBombProgress = time + 3.0f;
		self.fAttackFinished = self.fBombProgress;
		Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
		Animation_ShootWeapon( self );
	}

	// 3 seconds have passed, plant the bomb
	if ( self.fBombProgress <= time ) {
		self.fBombProgress = 0;
		WeaponC4BOMB_Drop( trace_endpos, trace_plane_normal );
	}
#else
	View_PlayAnimation( ANIM_C4_ENTERCODE );
#endif
}
