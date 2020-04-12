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

.int iMag_AK47;

// Weapon Info
weaponinfo_t wptAK47 = { 
	WEAPON_AK47, 		// Identifier
	SLOT_PRIMARY,		// Slot
	2500, 				// Price
	CALIBER_762MM, 		// Caliber ID
	0.88, 				// Max Player Speed
	1, 					// Bullets Per Shot
	30, 				// Clip/MagSize
	36, 				// Damage Per Bullet
	2, 					// Penetration Multiplier
	8192, 				// Bullet Range
	0.98, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.0955, 			// Attack-Delay
	2.4, 				// Reload-Delay
	iAmmo_762MM, 		// Caliber Pointer
	iMag_AK47, 			// Clip Pointer
	200,				// Accuracy Divisor
	0.35,				// Accuracy Offset
	1.25,				// Max Inaccuracy
	4,					// Minimum Crosshair Distance
	4,					// Crosshair Movement Delta
	1.55,				// Armor penetration ratio
	ATYPE_AK47,			// Animation Type
	SHELL_RIFLE
};

// Anim Table
enum
{
	ANIM_AK47_IDLE,
	ANIM_AK47_RELOAD,
	ANIM_AK47_DRAW,
	ANIM_AK47_SHOOT1,
	ANIM_AK47_SHOOT2,
	ANIM_AK47_SHOOT3
};

void WeaponAK47_Draw(void) {
	#ifdef SERVER
	BaseGun_Draw();
	#else
	View_PlayAnimation(ANIM_AK47_DRAW);
	#endif
}

void WeaponAK47_PrimaryFire(void) {
	#ifdef SERVER
	if (BaseGun_PrimaryFire() == TRUE) {
		if (random() <= 0.5) {
			sound(self, CHAN_WEAPON, "weapons/ak47-1.wav", 1, ATTN_NORM);
		} else {
			sound(self, CHAN_WEAPON, "weapons/ak47-2.wav", 1, ATTN_NORM);
		}
	}
	#else
	int iRand = (int)floor(random(1, 4));
	if (iRand == 1) {
		View_PlayAnimation(ANIM_AK47_SHOOT1);
	} else if (iRand == 2) {
		View_PlayAnimation(ANIM_AK47_SHOOT2);
	} else {
		View_PlayAnimation(ANIM_AK47_SHOOT3);
	}
	
	BaseGun_ShotMultiplierHandle(1);
	#endif
}

void WeaponAK47_Reload(void) {
	#ifdef SERVER
	if (BaseGun_Reload() == TRUE) {
		// Play Sound
	}
	#else
	View_PlayAnimation(ANIM_AK47_RELOAD);
	#endif
}
