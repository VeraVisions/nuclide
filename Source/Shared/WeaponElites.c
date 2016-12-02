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

.int iClip_ELITES;

#ifdef SSQC
.int iMode_ELITES;
#else
int iWeaponMode_ELITES;
#endif

// Weapon Info
weaponinfo_t wptELITES = { 
	WEAPON_ELITES, 		// Identifier
	SLOT_SECONDARY,
	800, 				// Price
	CALIBER_9MM, 		// Caliber ID
	240, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	45, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.75, 				// Range Modifier
	TYPE_SEMI,
	0.15, 				// Attack-Delay
	4.6, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iClip_ELITES, 		// Clip Pointer
	-1,					// Accuracy Divisor
	0,					// Accuracy Offset
	0					// Max Inaccuracy
};

// Anim Table
enum {
	ANIM_ELITES_IDLE,
	ANIM_ELITES_IDLE_LEFTEMPTY,
	ANIM_ELITES_SHOOT_LEFT1,
	ANIM_ELITES_SHOOT_LEFT2,
	ANIM_ELITES_SHOOT_LEFT3,
	ANIM_ELITES_SHOOT_LEFT4,
	ANIM_ELITES_SHOOT_LEFT5,
	ANIM_ELITES_SHOOT_LEFTLAST,
	ANIM_ELITES_SHOOT_RIGHT1,
	ANIM_ELITES_SHOOT_RIGHT2,
	ANIM_ELITES_SHOOT_RIGHT3,
	ANIM_ELITES_SHOOT_RIGHT4,
	ANIM_ELITES_SHOOT_RIGHT5,
	ANIM_ELITES_SHOOT_RIGHTLAST,
	ANIM_ELITES_RELOAD,
	ANIM_ELITES_DRAW
};

void WeaponELITES_Draw( void ) {
#ifdef SSQC
	OpenCSGunBase_Draw();
	sound( self, CHAN_WEAPON, "weapons/elite_deploy.wav", 1, ATTN_IDLE ); // TODO: Move to the client...?
#else
	View_PlayAnimation( ANIM_ELITES_DRAW );
#endif
}

void WeaponELITES_PrimaryFire( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_PrimaryFire() == TRUE ) {
		// Play Sound
		sound( self, CHAN_WEAPON, "weapons/elite_fire.wav", 1, ATTN_NORM );
	}
#else
	int iRand = ceil( random() * 5 );
	if ( iWeaponMode_ELITES == 0 ) {
		if ( getstatf( STAT_CURRENT_CLIP ) == 1 ) {
			View_PlayAnimation( ANIM_ELITES_SHOOT_LEFTLAST );
		} else {
			if ( iRand == 1 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_LEFT1 );
			} else if ( iRand == 2 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_LEFT2 );
			} else if ( iRand == 3 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_LEFT3 );
			} else if ( iRand == 4 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_LEFT4 );
			} else {
				View_PlayAnimation( ANIM_ELITES_SHOOT_LEFT5 );
			}
		}
	} else {
		if ( getstatf( STAT_CURRENT_CLIP ) == 0 ) {
			View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHTLAST );
		} else {
			if ( iRand == 1 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHT1 );
			} else if ( iRand == 2 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHT2 );
			} else if ( iRand == 3 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHT3 );
			} else if ( iRand == 4 ) {
				View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHT4 );
			} else {
				View_PlayAnimation( ANIM_ELITES_SHOOT_RIGHT5 );
			}
		}
	}
	
	iWeaponMode_ELITES = 1 - iWeaponMode_ELITES;
#endif
}

void WeaponELITES_Reload( void ) {
#ifdef SSQC
	if ( OpenCSGunBase_Reload() == TRUE ) {
		// Play Sound
	}
#else
	View_PlayAnimation( ANIM_ELITES_RELOAD );
	iWeaponMode_ELITES = 0;
#endif
}
