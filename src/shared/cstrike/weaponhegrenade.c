/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

.int iAmmo_HEGRENADE;

// This is to keep track of us holding down the nade
#ifdef SSQC
.int iMode_HEGRENADE;
#endif

// Weapon Info
weaponinfo_t wptHEGRENADE = { 
	WEAPON_HEGRENADE, 	// Identifier
	SLOT_GRENADE,		// Slot
	200, 				// Price
	EXPLOSIVE_HE, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	1, 					// Clip/MagSize
	50, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	64, 				// Bullet Range
	0.75, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	1.0, 				// Attack-Delay
	1.0, 				// Reload-Delay
	iNull, 				// Caliber Pointer
	iAmmo_HEGRENADE,	// Clip Pointer
	1,					// Accuracy Divisor
	1.0,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	7,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_GRENADE,		// Animation Type
	FALSE
};

// Anim Table
enum {
	ANIM_HEGRENADE_IDLE1,
	ANIM_HEGRENADE_PULLPIN,
	ANIM_HEGRENADE_THROW,
	ANIM_HEGRENADE_DRAW,
};

void WeaponHEGRENADE_Draw( void ) {
#ifdef SSQC
	BaseMelee_Draw();
	self.iMode_HEGRENADE = GRENADE_UNREADY;
#else
	View_PlayAnimation( ANIM_HEGRENADE_DRAW );
#endif
}

void WeaponHEGRENADE_PrimaryFire( void ) {
#ifdef SSQC
	static void WeaponHEGRENADE_Release_Ready( void ) {
		self.iMode_HEGRENADE = GRENADE_READY;
	}
	
	if ( self.iMode_HEGRENADE != GRENADE_UNREADY ) {
		return;
	}
	
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	Animation_ShootWeapon( self );
	self.fAttackFinished = time + wptHEGRENADE.fAttackFinished;
	
	// Mark the nade as ready once the pin has been pulled
	self.iMode_HEGRENADE = GRENADE_PULLING;
	self.think = WeaponHEGRENADE_Release_Ready;
	self.nextthink = self.fAttackFinished;
#else
	View_PlayAnimation( ANIM_HEGRENADE_PULLPIN );
#endif
}

#ifdef SSQC
void WeaponHEGRENADE_Throw( void ) {
	static void WeaponHEGRENADE_Explode( void ) {
		Effect_CreateExplosion( self.origin );
		Damage_Radius( self.origin, self, 100, 512, TRUE );
		sound( self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM );
		remove( self );
	}
	static void Weapon_HEGRENADE_Touch( void ) {
		if ( other.solid == SOLID_TRIGGER ) {
			return;
		}
		if ( other == self.owner ) {
			return;
		}
		if ( ( other.classname == "func_breakable" ) && ( other.material == MATERIAL_GLASS ) ) {
			Damage_Apply( other, self, other.health, self.origin, FALSE, WEAPON_HEGRENADE);
		}
		
		sound( self, CHAN_WEAPON, "weapons/he_bounce-1.wav", 1, ATTN_NORM );
	}
	
	makevectors( self.v_angle );
	entity eNade = spawn();
	setorigin( eNade, ( self.origin + self.view_ofs ) + ( v_forward * 16 ) );
	setmodel( eNade, "models/w_hegrenade.mdl" );
	setsize( eNade, '-1 -1 -1', '1 1 1' );
	
	vector vDir = aim ( self, 100000 );
	eNade.owner = self;
	eNade.classname = "remove_me";
	eNade.solid = SOLID_TRIGGER; // This is so grenades will not get slowed down by windows they touch
	eNade.angles = vectoangles( vDir );
	eNade.velocity = ( vDir * 1000 );
	eNade.avelocity = ( v_forward * 1000 );
	eNade.movetype = MOVETYPE_BOUNCE;
	eNade.touch = Weapon_HEGRENADE_Touch;
	eNade.gravity = 0.5f;
	
	eNade.think = WeaponHEGRENADE_Explode;
	eNade.nextthink = time + 3.0f;
	
	self.iAmmo_HEGRENADE--;
	
	Radio_TeamMessage(RADIO_CT_FIREINHOLE, self.team);
	
	if ( !self.iAmmo_HEGRENADE ) {
		Weapon_SwitchBest();
	} else {
		Weapon_Draw( WEAPON_HEGRENADE );
	}
}
#endif

void WeaponHEGRENADE_Release( void ) {
#ifdef SSQC
	if ( self.iMode_HEGRENADE == GRENADE_READY ) {
		// Throw immediately
		WeaponHEGRENADE_Throw();
		self.iMode_HEGRENADE = GRENADE_UNREADY;
	} else if ( self.iMode_HEGRENADE == GRENADE_PULLING ) {
		// Trying to release the grenade before it's done pulling, throw asap
		self.iMode_HEGRENADE = GRENADE_UNREADY;
		self.think = WeaponHEGRENADE_Throw;
	}
#endif
}
