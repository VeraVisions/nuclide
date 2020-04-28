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

/*QUAKED weapon_p90 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_p90.mdl"

COUNTER-STRIKE (1999) ENTITY

FN P90 Weapon

- Buy Menu -
Price: $2350

*/

enum
{
	P90_IDLE,
	P90_RELOAD,
	P90_DRAW,
	P90_SHOOT1,
	P90_SHOOT2,
	P90_SHOOT3
};

void
w_p90_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_p90.fire");
#endif
	precache_model("models/v_p90.mdl");
	precache_model("models/w_p90.mdl");
	precache_model("models/p_p90.mdl");
}

void
w_p90_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.p90_mag, pl.ammo_57mm, -1);
#endif
}

string
w_p90_wmodel(void)
{
	return "models/w_p90.mdl";
}

string
w_p90_pmodel(void)
{
	return "models/p_p90.mdl";
}

string
w_p90_deathmsg(void)
{
	return "";
}

int
w_p90_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.p90_mag = 50;
		else
			pl.p90_mag = startammo;
	} else {
		if (pl.ammo_57mm < 100) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 50, 100);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_p90_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_p90.mdl");
	Weapons_ViewAnimation(P90_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 7;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_p90_primary(void)
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
	if (!pl.p90_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 175);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 26, [accuracy,accuracy], WEAPON_P90);
	pl.p90_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_MP5, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_p90.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(P90_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(P90_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(P90_SHOOT3);
		break;
	}

	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_p90_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 50) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.p90_mag >= 50) {
		return;
	}
	if (!pl.ammo_57mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::p90_mag, player::ammo_57mm, 50);
	Weapons_UpdateAmmo(pl, pl.p90_mag, pl.ammo_57mm, -1);
#endif

	Weapons_ViewAnimation(P90_RELOAD);
	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_p90_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_p90_hud(void)
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
w_p90_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud13.spr_0.tga",
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
			"sprites/640hud12.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p90 =
{
	.name		= "p90",
	.id			= ITEM_P90,
	.slot		= 0,
	.slot_pos	= 3,
	.allow_drop	= TRUE,
	.draw		= w_p90_draw,
	.holster	= __NULL__,
	.primary	= w_p90_primary,
	.secondary	= __NULL__,
	.reload		= w_p90_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_p90_hud,
	.precache	= w_p90_precache,
	.pickup		= w_p90_pickup,
	.updateammo	= w_p90_updateammo,
	.wmodel		= w_p90_wmodel,
	.pmodel		= w_p90_pmodel,
	.deathmsg	= w_p90_deathmsg,
	.aimanim	= w_p90_aimanim,
	.hudpic		= w_p90_hudpic
};

#ifdef SERVER
void
weapon_p90(void)
{
	Weapons_InitItem(WEAPON_P90);
}
#endif
