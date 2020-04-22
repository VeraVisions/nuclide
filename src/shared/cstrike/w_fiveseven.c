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

/*QUAKED weapon_fiveseven (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_fiveseven.mdl"

COUNTER-STRIKE (1999) ENTITY

Five-SeveN Weapon

- Buy Menu -
Price: $750

*/

enum
{
	FIVESEVEN_IDLE,
	FIVESEVEN_SHOOT1,
	FIVESEVEN_SHOOT2,
	FIVESEVEN_SHOOT_EMPTY,
	FIVESEVEN_RELOAD,
	FIVESEVEN_DRAW
};

void
w_fiveseven_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_fiveseven.fire");
#endif
	precache_model("models/v_fiveseven.mdl");
	precache_model("models/w_fiveseven.mdl");
	precache_model("models/p_fiveseven.mdl");
}

void
w_fiveseven_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.fiveseven_mag, pl.ammo_57mm, -1);
#endif
}

string
w_fiveseven_wmodel(void)
{
	return "models/w_fiveseven.mdl";
}

string
w_fiveseven_pmodel(void)
{
	return "models/p_fiveseven.mdl";
}

string
w_fiveseven_deathmsg(void)
{
	return "";
}

int
w_fiveseven_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.fiveseven_mag = 20;
	} else {
		if (pl.ammo_57mm < 40) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 20, 40);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_fiveseven_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_fiveseven.mdl");
	Weapons_ViewAnimation(FIVESEVEN_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_fiveseven_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.fiveseven_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 25, [accuracy,accuracy], WEAPON_FIVESEVEN);
	pl.fiveseven_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_fiveseven.fire");
#endif

	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(FIVESEVEN_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(FIVESEVEN_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(FIVESEVEN_SHOOT2);
			break;
		}
	}

	pl.flags |= FL_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_fiveseven_reload(void)
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
	if (pl.fiveseven_mag >= 20) {
		return;
	}
	if (!pl.ammo_57mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::fiveseven_mag, player::ammo_57mm, 20);
	Weapons_UpdateAmmo(pl, pl.fiveseven_mag, pl.ammo_57mm, -1);
#endif

	Weapons_ViewAnimation(FIVESEVEN_RELOAD);
	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_fiveseven_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_fiveseven_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [120/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_fiveseven_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud15.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud14.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_fiveseven =
{
	ITEM_FIVESEVEN,
	1,
	5,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_fiveseven_draw,
	__NULL__,
	w_fiveseven_primary,
	__NULL__,
	w_fiveseven_reload,
	w_cstrike_weaponrelease,
	w_fiveseven_hud,
	w_fiveseven_precache,
	w_fiveseven_pickup,
	w_fiveseven_updateammo,
	w_fiveseven_wmodel,
	w_fiveseven_pmodel,
	w_fiveseven_deathmsg,
	w_fiveseven_aimanim,
	w_fiveseven_hudpic
};

#ifdef SERVER
void
weapon_fiveseven(void)
{
	Weapons_InitItem(WEAPON_FIVESEVEN);
}
#endif
