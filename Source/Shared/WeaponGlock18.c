/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

.int iMag_GLOCK18;

#ifdef SSQC
.int iMode_GLOCK18;
#else
int iWeaponMode_GLOCK18;
#endif

// Weapon Info
weaponinfo_t wptGLOCK18 = { 
	WEAPON_GLOCK18, 	// Identifier
	SLOT_SECONDARY,
	400, 				// Price
	CALIBER_9MM, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	20, 				// Clip/MagSize
	25, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.75, 				// Range Modifier
	TYPE_SEMI,
	0.15, 				// Attack-Delay
	2.1, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iMag_GLOCK18, 	// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracyy
	8,
	3
};

// Anim Table
enum {
	ANIM_GLOCK_IDLE1,
	ANIM_GLOCK_IDLE2,
	ANIM_GLOCK_IDLE3,
	ANIM_GLOCK_SHOOT_BURST1,
	ANIM_GLOCK_SHOOT_BURST2,
	ANIM_GLOCK_SHOOT,
	ANIM_GLOCK_SHOOT_EMPTY,
	ANIM_GLOCK_RELOAD1,
	ANIM_GLOCK_DRAW1,
	ANIM_GLOCK_UNUSED1,
	ANIM_GLOCK_UNUSED2,
	ANIM_GLOCK_DRAW2,
	ANIM_GLOCK_RELOAD2
};

void WeaponGLOCK18_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_GLOCK_DRAW1 );
	} else {
		View_PlayAnimation( ANIM_GLOCK_DRAW2 );
	}
	Sound_Delayed( "weapons/slideback1.wav", 1.0, 0.5 );
#endif
}

void WeaponGLOCK18_PrimaryFire( void ) {
#ifdef SSQC
	if ( self.iMode_GLOCK18 == FALSE ) {
		if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
			sound( self, CHAN_WEAPON, "weapons/glock18-2.wav", 1, ATTN_NORM );
		}
	} else {
		if ( (self.iMag_GLOCK18 - 3 ) < 0 ) {
			return FALSE;
		}
		OpenCSGunBase_AccuracyCalc();
		TraceAttack_FireBullets( 3 );
		
		self.iMag_GLOCK18 -= 3;
		self.fAttackFinished = time + 0.5;
		
		sound( self, CHAN_WEAPON, "weapons/glock18-1.wav", 1, ATTN_NORM );
		Client_SendEvent( self, EV_WEAPON_PRIMARYATTACK );
		OpenCSGunBase_ShotMultiplierHandle( 3 );
	}
#else
	if ( iWeaponMode_GLOCK18 == FALSE ) {
		if ( getstatf( STAT_CURRENT_MAG ) == 0 ) {
			View_PlayAnimation( ANIM_GLOCK_SHOOT_EMPTY );
		} else {
			View_PlayAnimation( ANIM_GLOCK_SHOOT );
		}
		OpenCSGunBase_ShotMultiplierHandle( 1 );
	} else {
		if ( random() <= 0.5 ) {
			View_PlayAnimation( ANIM_GLOCK_SHOOT_BURST1 );
		} else {
			View_PlayAnimation( ANIM_GLOCK_SHOOT_BURST2 );
		}
		OpenCSGunBase_ShotMultiplierHandle( 3 );
	}
#endif
}

void WeaponGLOCK18_Secondary( void ) {
#ifdef SSQC
	// Just switch the modes quickly
	self.iMode_GLOCK18 = 1 - self.iMode_GLOCK18;
	self.fAttackFinished = time + 0.2;
	
	// Tell the client that we switched modes, too
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
	
	// TODO: Move to the clientside
	if ( self.iMode_GLOCK18 == TRUE ) {
		centerprint( self, "Switched to Burst-Fire mode" );
	} else {
		centerprint( self, "Switched to Semi-Automatic mode" );
	}
#else 
	iWeaponMode_GLOCK18 = 1 - iWeaponMode_GLOCK18;
#endif
}

void WeaponGLOCK18_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	if ( random() <= 0.5 ) {
		View_PlayAnimation( ANIM_GLOCK_RELOAD1 );
		Sound_Delayed( "weapons/clipout1.wav", 1.0, 0.6 );
		Sound_Delayed( "weapons/clipin1.wav", 1.0, 1.2 );
		Sound_Delayed( "weapons/sliderelease1.wav", 1.0, 1.9 );
	} else {
		View_PlayAnimation( ANIM_GLOCK_RELOAD2 );
		Sound_Delayed( "weapons/clipout1.wav", 1.0, 0.6 );
		Sound_Delayed( "weapons/clipin1.wav", 1.0, 1.0 );
		Sound_Delayed( "weapons/sliderelease1.wav", 1.0, 1.7 );
	}
#endif
}
