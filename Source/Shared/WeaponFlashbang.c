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

.int iAmmo_FLASHBANG;

// This is to keep track of us holding down the nade
#ifdef SSQC
.int iMode_FLASHBANG;
#endif

// Weapon Info
weaponinfo_t wptFLASHBANG = { 
	WEAPON_FLASHBANG, 	// Identifier
	SLOT_GRENADE,		// Slot
	200, 				// Price
	EXPLOSIVE_FLASH, 	// Caliber ID
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
	iAmmo_9MM, 			// Caliber Pointer
	iAmmo_FLASHBANG,	// Clip Pointer
	1,					// Accuracy Divisor
	1.0,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	7,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_GRENADE		// Animation Type
};

// Anim Table
enum {
	ANIM_FLASHBANG_IDLE1,
	ANIM_FLASHBANG_PULLPIN,
	ANIM_FLASHBANG_THROW,
	ANIM_FLASHBANG_DRAW,
};

void WeaponFLASHBANG_Draw( void ) {
#ifdef SSQC
	BaseMelee_Draw();
	self.iMode_FLASHBANG = GRENADE_UNREADY;
#else
	View_PlayAnimation( ANIM_FLASHBANG_DRAW );
#endif
}

void WeaponFLASHBANG_PrimaryFire( void ) {
#ifdef SSQC
	static void WeaponFLASHBANG_Release_Ready( void ) {
		self.iMode_FLASHBANG = GRENADE_READY;
	}
	
	if ( self.iMode_FLASHBANG != GRENADE_UNREADY ) {
		return;
	}
	
	Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
	Animation_ShootWeapon( self );
	self.fAttackFinished = time + wptFLASHBANG.fAttackFinished;
	
	// Mark the nade as ready once the pin has been pulled
	self.iMode_FLASHBANG = GRENADE_PULLING;
	self.think = WeaponFLASHBANG_Release_Ready;
	self.nextthink = self.fAttackFinished;
#else
	View_PlayAnimation( ANIM_FLASHBANG_PULLPIN );
#endif
}

#ifdef SSQC
void WeaponFLASHBANG_Throw( void ) {
	static void WeaponFLASHBANG_Explode( void ) {
		vector vNorm;
		float fDot;
		
		for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
			traceline( self.origin + '0 0 32', eFind.origin, FALSE, self );
			if ( trace_fraction == 1 ) {
				makevectors ( eFind.angles );
				vNorm = normalize ( self.origin - eFind.origin );
				fDot = vNorm * v_forward;
				
				if ( fDot > 0.5 ) {
					Effect_CreateFlash( eFind );
				}
			}
		}
		
		if ( random() < 0.5 ) {
			sound( self, CHAN_WEAPON, "weapons/flashbang-1.wav", 1, ATTN_NORM );
		} else {
			sound( self, CHAN_WEAPON, "weapons/flashbang-2.wav", 1, ATTN_NORM );
		}
		remove( self );
	}
	static void Weapon_FLASHBANG_Touch( void ) {
		if ( other.solid == SOLID_TRIGGER ) {
			return;
		}
		if ( other == self.owner ) {
			return;
		}
		if ( other.classname == "func_breakable" ) {
			Damage_Apply( other, self, 50, self.origin, FALSE );
		}
		sound( self, CHAN_WEAPON, sprintf( "weapons/grenade_hit%d.wav", floor( random() * 3 ) + 1 ), 1, ATTN_NORM );
	}
	
	makevectors( self.v_angle );
	entity eNade = spawn();
	setorigin( eNade, ( self.origin + self.view_ofs ) + ( v_forward * 16 ) );
	setmodel( eNade, "models/w_flashbang.mdl" );
	setsize( eNade, '-1 -1 -1', '1 1 1' );
	
	vector vDir = aim ( self, 100000 );
	eNade.classname = "remove_me";
	eNade.owner = self;
	eNade.solid = SOLID_TRIGGER;
	eNade.angles = vectoangles( vDir );
	eNade.velocity = ( vDir * 800 );
	eNade.avelocity = ( v_forward * 600 );
	eNade.movetype = MOVETYPE_BOUNCE;
	eNade.touch = Weapon_FLASHBANG_Touch;
	
	eNade.think = WeaponFLASHBANG_Explode;
	eNade.nextthink = time + 3.0f;
	
	self.iAmmo_FLASHBANG--;
	
	if ( !self.iAmmo_FLASHBANG ) {
		Weapon_SwitchBest();
	} else {
		Weapon_Draw( WEAPON_FLASHBANG );	
	}
}
#endif

void WeaponFLASHBANG_Release( void ) {
#ifdef SSQC
	if ( self.iMode_FLASHBANG == GRENADE_READY ) {
		// Throw immediately
		WeaponFLASHBANG_Throw();
		self.iMode_FLASHBANG = GRENADE_UNREADY;
	} else if ( self.iMode_FLASHBANG == GRENADE_PULLING ) {
		// Trying to release the grenade before it's done pulling, throw asap
		self.iMode_FLASHBANG = GRENADE_UNREADY;
		self.think = WeaponFLASHBANG_Throw;
	}
#endif
}
