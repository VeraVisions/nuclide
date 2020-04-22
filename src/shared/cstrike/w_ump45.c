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

/*QUAKED weapon_ump45 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_ump45.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch UMP .45 ACP Weapon

- Buy Menu -
Price: $1700

*/

enum
{
	UMP45_IDLE,
	UMP45_RELOAD,
	UMP45_DRAW,
	UMP45_SHOOT1,
	UMP45_SHOOT2,
	UMP45_SHOOT3
};

void
w_ump45_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ump45.fire");
#endif
	precache_model("models/v_ump45.mdl");
	precache_model("models/w_ump45.mdl");
	precache_model("models/p_ump45.mdl");
}

void
w_ump45_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.ump45_mag, pl.ammo_45acp, -1);
#endif
}

string
w_ump45_wmodel(void)
{
	return "models/w_ump45.mdl";
}

string
w_ump45_pmodel(void)
{
	return "models/p_ump45.mdl";
}

string
w_ump45_deathmsg(void)
{
	return "";
}

int
w_ump45_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.ump45_mag = 25;
	} else {
		if (pl.ammo_45acp < AMMO_MAX_45ACP) {
			pl.ammo_45acp = bound(0, pl.ammo_45acp + 25, AMMO_MAX_45ACP);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_ump45_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_ump45.mdl");
	Weapons_ViewAnimation(UMP45_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_ump45_primary(void)
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
	if (!pl.ump45_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 210);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 30, [accuracy,accuracy], WEAPON_UMP45);
	pl.ump45_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_MP5, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_ump45.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(UMP45_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(UMP45_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(UMP45_SHOOT3);
		break;
	}

	pl.w_attack_next = 0.105f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_ump45_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 25) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.ump45_mag >= 25) {
		return;
	}
	if (!pl.ammo_45acp) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::ump45_mag, player::ammo_45acp, 25);
	Weapons_UpdateAmmo(pl, pl.ump45_mag, pl.ammo_45acp, -1);
#endif

	Weapons_ViewAnimation(UMP45_RELOAD);
	pl.w_attack_next = 3.5f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_ump45_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_ump45_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_ump45_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud16.spr_0.tga",
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
			"sprites/640hud16.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_ump45 =
{
	ITEM_UMP45,
	0,
	4,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_ump45_draw,
	__NULL__,
	w_ump45_primary,
	__NULL__,
	w_ump45_reload,
	w_cstrike_weaponrelease,
	w_ump45_hud,
	w_ump45_precache,
	w_ump45_pickup,
	w_ump45_updateammo,
	w_ump45_wmodel,
	w_ump45_pmodel,
	w_ump45_deathmsg,
	w_ump45_aimanim,
	w_ump45_hudpic
};

#ifdef SERVER
void
weapon_ump45(void)
{
	Weapons_InitItem(WEAPON_UMP45);
}
#endif
