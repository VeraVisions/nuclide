/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_g3sg1 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_g3sg1.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch G3/SG-1 Weapon

- Buy Menu -
Price: $5000

*/

enum
{
	G3SG1_IDLE,
	G3SG1_SHOOT1,
	G3SG1_SHOOT2,
	G3SG1_RELOAD,
	G3SG1_DRAW
};

void
w_g3sg1_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_g3sg1.fire");
#endif
	precache_model("models/v_g3sg1.mdl");
	precache_model("models/w_g3sg1.mdl");
	precache_model("models/p_g3sg1.mdl");
}

void
w_g3sg1_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif
}

string
w_g3sg1_wmodel(void)
{
	return "models/w_g3sg1.mdl";
}

string
w_g3sg1_pmodel(void)
{
	return "models/p_g3sg1.mdl";
}

string
w_g3sg1_deathmsg(void)
{
	return "";
}

int
w_g3sg1_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.g3sg1_mag = 20;
	} else {
		if (pl.ammo_762mm < 60) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 20, 60);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_g3sg1_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_g3sg1.mdl");
	Weapons_ViewAnimation(G3SG1_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_g3sg1_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.g3sg1_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 80, [accuracy,accuracy], WEAPON_G3SG1);
	pl.g3sg1_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_g3sg1.fire");
#endif

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(SCOUT_SHOOT2);
		break;
	}

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_g3sg1_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.45f;
	} else if (pl.viewzoom == 0.45f) {
		pl.viewzoom = 0.1f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_g3sg1_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 20) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.g3sg1_mag >= 20) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::g3sg1_mag, player::ammo_762mm, 20);
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(G3SG1_RELOAD);
	pl.w_attack_next = 4.6f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_g3sg1_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_g3sg1_hud(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_g3sg1_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud2.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_g3sg1 =
{
	ITEM_G3SG1,
	0,
	13,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_g3sg1_draw,
	__NULL__,
	w_g3sg1_primary,
	w_g3sg1_secondary,
	w_g3sg1_reload,
	w_cstrike_weaponrelease,
	w_g3sg1_hud,
	w_g3sg1_precache,
	w_g3sg1_pickup,
	w_g3sg1_updateammo,
	w_g3sg1_wmodel,
	w_g3sg1_pmodel,
	w_g3sg1_deathmsg,
	w_g3sg1_aimanim,
	w_g3sg1_hudpic
};

#ifdef SERVER
void
weapon_g3sg1(void)
{
	Weapons_InitItem(WEAPON_G3SG1);
}
#endif
