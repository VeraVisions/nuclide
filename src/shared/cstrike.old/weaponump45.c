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

.int iMag_UMP45;

// Weapon Info
weaponinfo_t wptUMP45 = { 
	WEAPON_UMP45, 		// Identifier
	SLOT_PRIMARY,		// Slot
	1700, 				// Price
	CALIBER_45ACP, 		// Caliber ID
	1.0, 				// Max Player Speed
	1, 					// Bullets Per Shot
	25, 				// Clip/MagSize
	30, 				// Damage Per Bullet
	1, 					// Penetration Multiplier
	4096, 				// Bullet Range
	0.82, 				// Range Modifier
	TYPE_AUTO,			// Firing Type
	0.105, 				// Attack-Delay
	3.5, 				// Reload-Delay
	iAmmo_45ACP, 		// Caliber Pointer
	iMag_UMP45, 		// Clip Pointer
	210,				// Accuracy Divisor
	0.5,				// Accuracy Offset
	1,					// Max Inaccuracy
	6,					// Minimum Crosshair Distance
	3,					// Crosshair Movement Delta
	1.0,				// Armor penetration ratio
	ATYPE_MP5,			// Animation Type
	SHELL_RIFLE
};

// Anim Table
enum
{
	ANIM_UMP45_IDLE,
	ANIM_UMP45_RELOAD,
	ANIM_UMP45_DRAW,
	ANIM_UMP45_SHOOT1,
	ANIM_UMP45_SHOOT2,
	ANIM_UMP45_SHOOT3
};

void WeaponUMP45_Draw(void) {
#ifdef SERVER
	BaseGun_Draw();
	//sound(self, CHAN_WEAPON, "weapons/ump45_boltslap.wav", 1, ATTN_IDLE); // TODO: Move to the client...?
#else
	View_PlayAnimation(ANIM_UMP45_DRAW);
#endif
}

void WeaponUMP45_PrimaryFire(void) {
#ifdef SERVER
	if (BaseGun_PrimaryFire() == TRUE) {
		sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
	}
#else
	int iRand = (int)floor(random(1, 4));
	
	if (iRand == 1) {
		View_PlayAnimation(ANIM_UMP45_SHOOT1);
	} else if (iRand == 2) {
		View_PlayAnimation(ANIM_UMP45_SHOOT2);
	} else {
		View_PlayAnimation(ANIM_UMP45_SHOOT3);
	}
	
	BaseGun_ShotMultiplierHandle(1);
#endif
}

void WeaponUMP45_Reload(void) {
	#ifdef SERVER
	if (BaseGun_Reload() == TRUE) {
		// Play Sound
	}
	#else
	View_PlayAnimation(ANIM_UMP45_RELOAD);
	#endif
}
