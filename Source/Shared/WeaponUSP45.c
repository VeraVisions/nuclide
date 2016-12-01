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

.int iClip_USP45;

#ifdef QWSSQC
.int iMode_USP45;
#else
int iWeaponMode_USP45;
#endif

// Weapon Info
weaponinfo_t wptUSP45 = { 
	WEAPON_USP45, 		// Identifier
	SLOT_SECONDARY,
	500, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	240, 				// Max Player Speed
	1, 					// Bullets Per Shot
	12, 				// Clip/MagSize
	34, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.79, 				// Range Modifier
	TYPE_SEMI,
	0.15, 				// Attack-Delay
	3.0, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iClip_USP45 		// Clip Pointer
};

enum {
	ANIM_USP45_IDLE,
	ANIM_USP45_SILENCER_SHOOT1,
	ANIM_USP45_SILENCER_SHOOT2,
	ANIM_USP45_SILENCER_SHOOT3,
	ANIM_USP45_SILENCER_SHOOTLAST,
	ANIM_USP45_SILENCER_RELOAD,
	ANIM_USP45_SILENCER_DRAW,
	ANIM_USP45_SILENCER_ADD,
	ANIM_USP45_IDLE2,
	ANIM_USP45_SHOOT1,
	ANIM_USP45_SHOOT2,
	ANIM_USP45_SHOOT3,
	ANIM_USP45_SHOOTLAST,
	ANIM_USP45_RELOAD,
	ANIM_USP45_DRAW,
	ANIM_USP45_SILENCER_REMOVE
};

void WeaponUSP45_Draw( void ) {
#ifdef QWSSQC
	OpenCSGunBase_Draw();
#else
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_DRAW );
	} else {
		View_PlayAnimation( ANIM_USP45_DRAW );
	}
#endif
}

void WeaponUSP45_PrimaryFire( void ) {
#ifdef QWSSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		if ( self.iMode_USP45 == TRUE ) {
			if ( random() <= 0.5 ) {
				sound( self, CHAN_WEAPON, "weapons/usp1.wav", 1, ATTN_NORM );
			} else {
				sound( self, CHAN_WEAPON, "weapons/usp2.wav", 1, ATTN_NORM );
			}
		} else {
			sound( self, CHAN_WEAPON, "weapons/usp_unsil-1.wav", 1, ATTN_NORM );
		}
	}
#else
	if ( getstatf( STAT_CURRENT_CLIP ) == 0 ) {
		if ( iWeaponMode_USP45 == TRUE ) {
			View_PlayAnimation( ANIM_USP45_SILENCER_SHOOTLAST );
		} else {
			View_PlayAnimation( ANIM_USP45_SHOOTLAST );
		}
	} else {
		int iRand = ceil( random() * 3 );
		
		if ( iRand == 1 ) {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT1 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT1 );
			}
		} else if ( iRand == 2 ) {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT2 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT2 );
			}
		} else {
			if ( iWeaponMode_USP45 == TRUE ) {
				View_PlayAnimation( ANIM_USP45_SILENCER_SHOOT3 );
			} else {
				View_PlayAnimation( ANIM_USP45_SHOOT3 );
			}
		}
	}
#endif
}

void WeaponUSP45_Secondary( void ) {
#ifdef QWSSQC
	// Just switch the modes quickly
	self.iMode_USP45 = 1 - self.iMode_USP45;
	self.fAttackFinished = time + 3.0;
	
	// Tell the client that we switched modes, too
	Client_SendEvent( self, EV_WEAPON_SECONDARYATTACK );
	
	if ( self.iMode_M4A1 == TRUE ) {
		sound( self, CHAN_WEAPON, "weapons/usp_silencer_on.wav", 1, ATTN_NORM );
	} else {
		sound( self, CHAN_WEAPON, "weapons/usp_silencer_off.wav", 1, ATTN_NORM );
	}
	
#else 
	iWeaponMode_USP45 = 1 - iWeaponMode_USP45;
	
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_ADD );
	} else {
		View_PlayAnimation( ANIM_USP45_SILENCER_REMOVE );
	}
#endif
}

void WeaponUSP45_Reload( void ) {
#ifdef QWSSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	if ( iWeaponMode_USP45 == TRUE ) {
		View_PlayAnimation( ANIM_USP45_SILENCER_RELOAD );
	} else {
		View_PlayAnimation( ANIM_USP45_RELOAD );
	}
#endif
}
