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

.int iMag_GLOCK18;

#ifdef SERVER
.int iMode_GLOCK18;
#else
int iWeaponMode_GLOCK18;
#endif

// Weapon Info
weaponinfo_t wptGLOCK18 = { 
	WEAPON_GLOCK18, 	// Identifier
	SLOT_SECONDARY,		// Slot
	400, 				// Price
	CALIBER_9MM, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	20, 				// Clip/MagSize
	25, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.75, 				// Range Modifier
	TYPE_SEMI,			// Firing Type
	0.15, 				// Attack-Delay
	2.1, 				// Reload-Delay
	iAmmo_9MM, 			// Caliber Pointer
	iMag_GLOCK18, 		// Clip Pointer
	200,				// Accuracy Divisor
	0.55,				// Accuracy Offset
	1.4,				// Max Inaccuracyy
	8,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.05,				// Armor penetration ratio
	ATYPE_ONEHAND,		// Animation Type
	SHELL_PISTOL
};

// Anim Table
enum
{
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

void WeaponGLOCK18_Draw(void) {
#ifdef SERVER
	BaseGun_Draw();
#else
	if (random() <= 0.5) {
		View_PlayAnimation(ANIM_GLOCK_DRAW1);
	} else {
		View_PlayAnimation(ANIM_GLOCK_DRAW2);
	}
#endif
}

void WeaponGLOCK18_PrimaryFire(void) {
#ifdef SERVER
	if (self.iMode_GLOCK18 == FALSE) {
		if (BaseGun_PrimaryFire() == TRUE) {
			sound(self, CHAN_WEAPON, "weapons/glock18-2.wav", 1, ATTN_NORM);
		}
	} else {
		if (self.iMag_GLOCK18 <= 0) {
			return;
		}
		
		for (int i = 0; i < 3; i++) {
			if (self.iMag_GLOCK18) {
				BaseGun_ShotMultiplierHandle(1);
				BaseGun_AccuracyCalc();
				TraceAttack_FireBullets(1, (self.origin + self.view_ofs), 25, [self.fAccuracy,self.fAccuracy], WEAPON_GLOCK18);
				self.iMag_GLOCK18 -= 1;
			}
		}
		self.fAttackFinished = time + 0.5;
		sound(self, CHAN_WEAPON, "weapons/glock18-1.wav", 1, ATTN_NORM);
		Client_SendEvent(self, EV_WEAPON_PRIMARYATTACK);
	}
#else
	if (iWeaponMode_GLOCK18 == FALSE) {
		if (getstatf(STAT_CURRENT_MAG) == 0) {
			View_PlayAnimation(ANIM_GLOCK_SHOOT_EMPTY);
		} else {
			View_PlayAnimation(ANIM_GLOCK_SHOOT);
		}
		BaseGun_ShotMultiplierHandle(1);
	} else {
		if (random() <= 0.5) {
			View_PlayAnimation(ANIM_GLOCK_SHOOT_BURST1);
		} else {
			View_PlayAnimation(ANIM_GLOCK_SHOOT_BURST2);
		}
		BaseGun_ShotMultiplierHandle(3);
	}
#endif
}

void WeaponGLOCK18_Secondary(void) {
#ifdef SERVER
	// Just switch the modes quickly
	self.iMode_GLOCK18 = 1 - self.iMode_GLOCK18;
	self.fAttackFinished = time + 0.2;
	
	// Tell the client that we switched modes, too
	Client_SendEvent(self, EV_WEAPON_SECONDARYATTACK);
	
	// TODO: Move to the clientside
	if (self.iMode_GLOCK18 == TRUE) {
		centerprint(self, "Switched to Burst-Fire mode");
	} else {
		centerprint(self, "Switched to Semi-Automatic mode");
	}
#else 
	iWeaponMode_GLOCK18 = 1 - iWeaponMode_GLOCK18;
#endif
}

void WeaponGLOCK18_Reload(void) {
#ifdef SERVER
	if (BaseGun_Reload() == TRUE) {
		// Play Sound
	}
#else
	if (random() <= 0.5) {
		View_PlayAnimation(ANIM_GLOCK_RELOAD1);
	} else {
		View_PlayAnimation(ANIM_GLOCK_RELOAD2);
	}
#endif
}
