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

/*QUAKED weapon_ak47 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_ak47.mdl"

COUNTER-STRIKE (1999) ENTITY

AK-47 Weapon

- Buy Menu -
Price: $2500
Terrorists only weapon

*/

enum
{
	AK47_IDLE,
	AK47_RELOAD,
	AK47_DRAW,
	AK47_SHOOT1,
	AK47_SHOOT2,
	AK47_SHOOT3
};

void
w_ak47_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ak47.fire");
#endif
	precache_model("models/v_ak47.mdl");
	precache_model("models/w_ak47.mdl");
	precache_model("models/p_ak47.mdl");
}

void
w_ak47_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.ak47_mag, pl.ammo_762mm, -1);
#endif
}

string
w_ak47_wmodel(void)
{
	return "models/w_ak47.mdl";
}

string
w_ak47_pmodel(void)
{
	return "models/p_ak47.mdl";
}

string
w_ak47_deathmsg(void)
{
	return "";
}

int
w_ak47_pickup(int new)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.ak47_mag = 30;
	} else {
		if (pl.ammo_762mm < 90) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 30, 90);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_ak47_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_ak47.mdl");
	Weapons_ViewAnimation(AK47_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_ak47_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.ak47_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 36, [accuracy,accuracy], WEAPON_AK47);
	pl.ak47_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_AK47, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_AK47, 0.45f);
	
	Sound_Play(pl, CHAN_WEAPON, "weapon_ak47.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AK47_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AK47_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(AK47_SHOOT3);
		break;
	}

	pl.w_attack_next = 0.0955f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_ak47_reload(void)
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
	if (pl.ak47_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::ak47_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.ak47_mag, pl.ammo_762mm, -1);
#endif
	Weapons_ViewAnimation(AK47_RELOAD);

	pl.w_attack_next = 2.4f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_ak47_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_AK47 : ANIM_AIM_AK47;
}

void
w_ak47_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_ak47_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud11.spr_0.tga",
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
			"sprites/640hud11.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_ak47 =
{
	.id		= ITEM_AK47,
	.slot		= 0,
	.slot_pos	= 7,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [32,16],
	.ki_xy		= [192,16],
	.draw		= w_ak47_draw,
	.holster	= __NULL__,
	.primary	= w_ak47_primary,
	.secondary	= __NULL__,
	.reload		= w_ak47_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_ak47_hud,
	.precache	= w_ak47_precache,
	.pickup		= w_ak47_pickup,
	.updateammo	= w_ak47_updateammo,
	.wmodel		= w_ak47_wmodel,
	.pmodel		= w_ak47_pmodel,
	.deathmsg	= w_ak47_deathmsg,
	.aimanim	= w_ak47_aimanim,
	.hudpic		= w_ak47_hudpic
};

#ifdef SERVER
void
weapon_ak47(void)
{
	Weapons_InitItem(WEAPON_AK47);
}
#endif
