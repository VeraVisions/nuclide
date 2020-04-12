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

/*QUAKED weapon_tmp (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_tmp.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr Tactical Weapon

- Buy Menu -
Price: $1250

*/

enum
{
	TMP_IDLE,
	TMP_RELOAD,
	TMP_DRAW,
	TMP_SHOOT1,
	TMP_SHOOT2,
	TMP_SHOOT3
};

void
w_tmp_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_tmp.fire");
#endif
	precache_model("models/v_tmp.mdl");
	precache_model("models/w_tmp.mdl");
	precache_model("models/p_tmp.mdl");
}

void
w_tmp_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.tmp_mag, pl.ammo_9mm, -1);
#endif
}

string
w_tmp_wmodel(void)
{
	return "models/w_tmp.mdl";
}

string
w_tmp_pmodel(void)
{
	return "models/p_tmp.mdl";
}

string
w_tmp_deathmsg(void)
{
	return "";
}

int
w_tmp_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.tmp_mag = 30;
	} else {
		if (pl.ammo_9mm < 90) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 30, 90);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_tmp_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_tmp.mdl");
	Weapons_ViewAnimation(TMP_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 7;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_tmp_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.tmp_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 26, [accuracy,accuracy], WEAPON_TMP);
	pl.tmp_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_tmp.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(TMP_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(TMP_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(TMP_SHOOT3);
		break;
	}

	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_tmp_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 30) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.tmp_mag >= 30) {
		return;
	}
	if (!pl.ammo_9mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::tmp_mag, player::ammo_9mm, 30);
	Weapons_UpdateAmmo(pl, pl.tmp_mag, pl.ammo_9mm, -1);
#endif

	Weapons_ViewAnimation(TMP_RELOAD);
	pl.w_attack_next = 2.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_tmp_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_tmp_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_tmp_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
			[0,0],
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
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_tmp =
{
	ITEM_TMP,
	0,
	6,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_tmp_draw,
	__NULL__,
	w_tmp_primary,
	__NULL__,
	w_tmp_reload,
	w_cstrike_weaponrelease,
	w_tmp_hud,
	w_tmp_precache,
	w_tmp_pickup,
	w_tmp_updateammo,
	w_tmp_wmodel,
	w_tmp_pmodel,
	w_tmp_deathmsg,
	w_tmp_aimanim,
	w_tmp_hudpic
};

#ifdef SERVER
void
weapon_tmp(void)
{
	Weapons_InitItem(WEAPON_TMP);
}
#endif
