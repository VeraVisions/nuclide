/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_sniperrifle (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m40a1.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Sniper-Rifle Weapon

*/

enum
{
	SNIPER_DRAW,
	SNIPER_IDLE1,
	SNIPER_FIRE1,
	SNIPER_FIRE2,
	SNIPER_RELOAD1,
	SNIPER_RELOAD2,
	SNIPER_RELOAD3,
	SNIPER_IDLE2,
	SNIPER_HOLSTER,
	SNIPER_DRAW
};

void
w_sniperrifle_precache(void)
{
#ifdef SERVER
	precache_model("models/w_m40a1.mdl");
	precache_sound("weapons/sniper_fire.wav");
#else
	precache_model("models/v_m40a1.mdl");
	precache_model("models/p_m40a1.mdl");
#endif
}

int
w_sniperrifle_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.sniper_mag = 5;
	} else {
		if (pl.ammo_762 < 15) {
			pl.ammo_762 = bound(0, pl.ammo_762 + 5, 15);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_sniperrifle_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_762, __NULL__);
}

string
w_sniperrifle_wmodel(void)
{
	return "models/w_m40a1.mdl";
}

string
w_sniperrifle_pmodel(void)
{
	return "models/p_m40a1.mdl";
}

string
w_sniperrifle_deathmsg(void)
{
	return "";
}

void
w_sniperrifle_draw(void)
{
	Weapons_SetModel("models/v_m40a1.mdl");
	Weapons_ViewAnimation(SNIPER_DRAW);
#ifdef SERVER
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_762, __NULL__);
#endif
}

void
w_sniperrifle_holster(void)
{
	Weapons_ViewAnimation(SNIPER_HOLSTER);
}

void
w_sniperrifle_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.sniper_mag <= 0) {
		return;
	}
#else
	if (pl.sniper_mag <= 0) {
		return;
	}
#endif

	/* Actual firing */
#ifdef SERVER
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.00873, 0.00873], WEAPON_SNIPERRIFLE);
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/sniper_fire.wav", 1, ATTN_NORM);

	pl.sniper_mag--;
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_762, __NULL__);
#else
	pl.sniper_mag--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-10,0,0]);

	if (pl.sniper_mag) {
		Weapons_ViewAnimation(SNIPER_FIRE1);
	} else {
		Weapons_ViewAnimation(SNIPER_FIRE2);
	}
#endif

	pl.w_attack_next = 1.75f;
	pl.w_idle_next = 10.0f;
}

void
w_sniperrifle_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.25f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_sniperrifle_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.sniper_mag >= 5) {
		return;
	}
	if (pl.ammo_762 <= 0) {
		return;
	}
#else
	if (pl.sniper_mag >= 5) {
		return;
	}
	if (pl.ammo_762 <= 0) {
		return;
	}
#endif

	/* Audio-Visual bit */
	/* TODO has a couple reloading states */
	Weapons_ViewAnimation(SNIPER_RELOAD1);
#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::sniper_mag, player::ammo_762, 5);
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_762, __NULL__);
#endif
	pl.w_attack_next = 2.3f;
	pl.w_idle_next = 10.0f;
}
void
w_sniperrifle_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.sniper_mag == 0 && pl.ammo_762 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 2;
	if (r == 1) {
		Weapons_ViewAnimation(SNIPER_IDLE1);
	} else {
		Weapons_ViewAnimation(SNIPER_IDLE2);
	}
	pl.w_idle_next = 15.0f;
}
void
w_sniperrifle_crosshair(void)
{
#ifdef CLIENT
	player pl = (player)self;
	static vector cross_pos;

	if (pl.viewzoom == 1.0f) {
		cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
		drawsubpic(
			cross_pos,
			[24,24],
			"sprites/ofch1.spr_0.tga",
			[0,48/72],
			[24/72, 24/72],
			[1,1,1],
			1,
			DRAWFLAG_NORMAL
		);
	} else {
		cross_pos = g_hudmins + (g_hudres / 2) + [-128,-128];
		drawsubpic(
			cross_pos,
			[256,256],
			"sprites/ofch2.spr_0.tga",
			[0,0],
			[1, 1],
			[1,1,1],
			1,
			DRAWFLAG_NORMAL
		);
	}

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [24/256,72/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_sniperrifle_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void
w_sniperrifle_hudpic(int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hudof04.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hudof03.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_sniperrifle =
{
	.name		= "sniperrifle",
	.id			= ITEM_SNIPERRIFLE,
	.slot		= 5,
	.slot_pos	= 2,
	.draw		= w_sniperrifle_draw,
	.holster	= w_sniperrifle_holster,
	.primary	= w_sniperrifle_primary,
	.secondary	= w_sniperrifle_secondary,
	.reload		= w_sniperrifle_reload,
	.release	= w_sniperrifle_release,
	.crosshair	= w_sniperrifle_crosshair,
	.precache	= w_sniperrifle_precache,
	.pickup		= w_sniperrifle_pickup,
	.updateammo	= w_sniperrifle_updateammo,
	.wmodel		= w_sniperrifle_wmodel,
	.pmodel		= w_sniperrifle_pmodel,
	.deathmsg	= w_sniperrifle_deathmsg,
	.aimanim	= w_sniperrifle_aimanim,
	.hudpic		= w_sniperrifle_hudpic
};

#ifdef SERVER
void
weapon_sniperrifle(void)
{
	Weapons_InitItem(WEAPON_SNIPERRIFLE);
}
#endif
