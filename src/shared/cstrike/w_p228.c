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

/*QUAKED weapon_ (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_p228.mdl"

COUNTER-STRIKE (1999) ENTITY

SIG P228 Weapon

- Buy Menu -
Price: $600

*/

enum
{
	P228_IDLE,
	P228_SHOOT1,
	P228_SHOOT2,
	P228_SHOOT3,
	P228_SHOOT_EMPTY,
	P228_RELOAD,
	P228_DRAW
};

void
w_p228_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_p228.fire");
#endif
	precache_model("models/v_p228.mdl");
	precache_model("models/w_p228.mdl");
	precache_model("models/p_p228.mdl");
	precache_sound("weapons/p228-1.wav");
	precache_sound("weapons/p228-2.wav");
}

void
w_p228_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.p228_mag, pl.ammo_357sig, -1);
#endif
}

string
w_p228_wmodel(void)
{
	return "models/w_p228.mdl";
}

string
w_p228_pmodel(void)
{
	return "models/p_p228.mdl";
}

string
w_p228_deathmsg(void)
{
	return "";
}

int
w_p228_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.p228_mag = 13;
	} else {
		if (pl.ammo_357sig < 26) {
			pl.ammo_357sig = bound(0, pl.ammo_357sig + 13, 26);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_p228_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_p228.mdl");
	Weapons_ViewAnimation(P228_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_p228_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.p228_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [accuracy,accuracy], WEAPON_P228);
	pl.p228_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_p228.fire");
#endif

	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(P228_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 3;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(P228_SHOOT1);
			break;
		case 1:
			Weapons_ViewAnimation(P228_SHOOT2);
			break;
		default:
			Weapons_ViewAnimation(P228_SHOOT3);
			break;
		}
	}

	pl.flags |= FL_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_p228_reload(void)
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
	if (pl.p228_mag >= 30) {
		return;
	}
	if (!pl.ammo_357sig) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::p228_mag, player::ammo_357sig, 13);
	Weapons_UpdateAmmo(pl, pl.p228_mag, pl.ammo_357sig, -1);
#endif

	Weapons_ViewAnimation(P228_RELOAD);
	pl.w_attack_next = 2.7f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_p228_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_p228_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [120/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_p228_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud13.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud12.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p228 =
{
	ITEM_P228,
	1,
	3,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_p228_draw,
	__NULL__,
	w_p228_primary,
	__NULL__,
	w_p228_reload,
	w_cstrike_weaponrelease,
	w_p228_hud,
	w_p228_precache,
	w_p228_pickup,
	w_p228_updateammo,
	w_p228_wmodel,
	w_p228_pmodel,
	w_p228_deathmsg,
	w_p228_aimanim,
	w_p228_hudpic
};

#ifdef SERVER
void
weapon_p228(void)
{
	Weapons_InitItem(WEAPON_P228);
}
#endif
