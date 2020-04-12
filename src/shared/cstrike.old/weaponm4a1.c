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

.int iMag_M4A1;

#ifdef SERVER
.int iMode_M4A1;
#else
int iWeaponMode_M4A1;
#endif

// Weapon Info
weaponinfo_t wptM4A1 = { 
	WEAPON_M4A1, 		// Identifier
	SLOT_PRIMARY,		// Slot
	3100, 				// Price
	CALIBER_556MM, 		// Caliber ID
	0.92, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	33, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.97, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.0875, 				// Attack-Delay
	3.1, 				// Reload-Delay
	iAmmo_556MM, 		// Caliber Pointer
	iMag_M4A1, 			// Clip Pointer
	220,				// Accuracy Divisor
	0.3,				// Accuracy Offset
	1.0,				// Max Inaccuracy
	4,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.4,				// Armor penetration ratio
	ATYPE_RIFLE,		// Animation Type
	SHELL_RIFLE
};

enum
{
	ANIM_M4A1_IDLE,
	ANIM_M4A1_SILENCER_SHOOT1,
	ANIM_M4A1_SILENCER_SHOOT2,
	ANIM_M4A1_SILENCER_SHOOT3,
	ANIM_M4A1_SILENCER_RELOAD,
	ANIM_M4A1_SILENCER_DRAW,
	ANIM_M4A1_SILENCER_ADD,
	ANIM_M4A1_IDLE2,
	ANIM_M4A1_SHOOT1,
	ANIM_M4A1_SHOOT2,
	ANIM_M4A1_SHOOT3,
	ANIM_M4A1_RELOAD,
	ANIM_M4A1_DRAW,
	ANIM_M4A1_SILENCER_REMOVE
};

void WeaponM4A1_Draw(void) {
#ifdef SERVER
	BaseGun_Draw();
#else
	if (iWeaponMode_M4A1 == TRUE) {
		View_PlayAnimation(ANIM_M4A1_SILENCER_DRAW);
	} else {
		View_PlayAnimation(ANIM_M4A1_DRAW);
	}
#endif
}

void WeaponM4A1_PrimaryFire(void) {
#ifdef SERVER
	if (BaseGun_PrimaryFire() == TRUE) {
		if (self.iMode_M4A1 == TRUE) {
			sound(self, CHAN_WEAPON, "weapons/m4a1-1.wav", 1, ATTN_NORM);
		} else {
			if (random() <= 0.5) {
				sound(self, CHAN_WEAPON, "weapons/m4a1_unsil-1.wav", 1, ATTN_NORM);
			} else {
				sound(self, CHAN_WEAPON, "weapons/m4a1_unsil-2.wav", 1, ATTN_NORM);
			}
		}
	}
#else
	int iRand = (int)floor(random(1, 4));
		
	if (iRand == 1) {
		if (iWeaponMode_M4A1 == TRUE) {
			View_PlayAnimation(ANIM_M4A1_SILENCER_SHOOT1);
		} else {
			View_PlayAnimation(ANIM_M4A1_SHOOT1);
		}
	} else if (iRand == 2) {
		if (iWeaponMode_M4A1 == TRUE) {
			View_PlayAnimation(ANIM_M4A1_SILENCER_SHOOT2);
		} else {
			View_PlayAnimation(ANIM_M4A1_SHOOT2);
		}
	} else {
		if (iWeaponMode_M4A1 == TRUE) {
			View_PlayAnimation(ANIM_M4A1_SILENCER_SHOOT3);
		} else {
			View_PlayAnimation(ANIM_M4A1_SHOOT3);
		}
	}
	BaseGun_ShotMultiplierHandle(1);
#endif
}

void WeaponM4A1_Secondary(void) {
#ifdef SERVER
	// Just switch the modes quickly
	self.iMode_M4A1 = 1 - self.iMode_M4A1;
	self.fAttackFinished = time + 2;
	
	// Tell the client that we switched modes, too
	Client_SendEvent(self, EV_WEAPON_SECONDARYATTACK);
#else 
	iWeaponMode_M4A1 = 1 - iWeaponMode_M4A1;
	
	if (iWeaponMode_M4A1 == TRUE) {
		View_PlayAnimation(ANIM_M4A1_SILENCER_ADD);
	} else {
		View_PlayAnimation(ANIM_M4A1_SILENCER_REMOVE);
	}
#endif
}

void WeaponM4A1_Reload(void) {
#ifdef SERVER
	if (BaseGun_Reload() == TRUE) {
		// Play Sound
	}
#else
	if (iWeaponMode_M4A1 == TRUE) {
		View_PlayAnimation(ANIM_M4A1_SILENCER_RELOAD);
	} else {
		View_PlayAnimation(ANIM_M4A1_RELOAD);
	}
#endif
}
