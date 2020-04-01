/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 * Copyright (c) 2019 Gethyn ThomasQuail <xylemon@posteo.net>
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

enum
{
	SNIPER_IDLE1,
	SNIPER_UNUSED1,
	SNIPER_FIRE1,
	SNIPER_DRAW,
	SNIPER_HOLSTER,
	SNIPER_IDLE2
};

void
w_sniper_precache(void)
{
	precache_model("models/v_tfc_sniper.mdl");
	precache_model("models/w_isotopebox.mdl");
	precache_model("models/p_sniper.mdl");

	precache_sound("weapons/sniper.wav");
	precache_sound("weapons/reload3.wav");
}

int
w_sniper_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.sniper_mag = 5;
	} else {
		if (pl.ammo_sniper < MAX_A_SNIPER) {
			pl.ammo_sniper = bound(0, pl.ammo_sniper + 5, MAX_A_SNIPER);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_sniper_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_sniper, -1);
#endif
}

string
w_sniper_wmodel(void)
{
	return "models/w_isotopebox.mdl";
}

string
w_sniper_pmodel(void)
{
	return "models/p_sniper.mdl";
}

string
w_sniper_deathmsg(void)
{
	return "";
}

void
w_sniper_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_tfc_sniper.mdl");
	Weapons_ViewAnimation(SNIPER_DRAW);
#endif
}

void
w_sniper_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SNIPER_HOLSTER);
#endif
}

void
w_sniper_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(SNIPER_DRAW);
		pl.a_ammo3 = 0;
		pl.w_attack_next = 0.0f;
		pl.w_idle_next = 15.0f;
		return;
	}

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SNIPER_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 1:
		Weapons_ViewAnimation(SNIPER_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	}

	pl.w_idle_next = 15.0f;
}

void
w_sniper_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.sniper_mag <= 0) {
		return;
	}
#endif

	/* Actual firing */
#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-20,0,0]);
	Weapons_ViewAnimation(SNIPER_FIRE1);
#else
	pl.sniper_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.008, 0.008], WEAPON_SNIPER);

	sound(pl, CHAN_WEAPON, "weapons/sniper.wav", 1, ATTN_NORM);
#endif


	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.1f;
	} else {
		pl.w_attack_next = 1.0f;
	}

	pl.w_idle_next = 10.0f;
}

void
w_sniper_secondary(void)
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
w_sniper_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		w_sniper_release();
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 5) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
	Weapons_ViewAnimation(SNIPER_HOLSTER);
#else
	if (pl.sniper_mag >= 5) {
		return;
	}
	if (pl.ammo_sniper <= 0) {
		return;
	}
	sound(pl, CHAN_WEAPON, "weapons/reload3.wav", 1, ATTN_NORM);
	Weapons_ReloadWeapon(pl, player::sniper_mag, player::ammo_sniper, 5);
#endif

	pl.a_ammo3 = 1;
	pl.w_attack_next = 2.5f;
	pl.w_idle_next = 2.0f;
}

void
w_sniper_crosshair(void)
{
#ifdef CSQC
	player pl = (player)self;
	static vector cross_pos;
	vector aicon_pos;

	if (pl.viewzoom < 1.0f) {
		drawfill(
			g_hudmins,
			g_hudres,
			[0,0.2,0],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		cross_pos = g_hudmins + (g_hudres / 2) + [-128,-104];
		drawpic(
			cross_pos,
			"sprites/nmxhair2.spr_0.tga",
			[256,208],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
	} else {

		cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
		drawsubpic(
			cross_pos,
			[24,24],
			"sprites/crosshairs.spr_0.tga",
			[48/128,0],
			[24/128,24/128],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
	}

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo2_alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_sniper_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void
w_sniper_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud02.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_sniper =
{
	.id		= ITEM_SNIPER,
	.slot		= 2,
	.slot_pos	= 3,
	.ki_spr		= "sprites/tfc_dmsg.spr_0.tga",
	.ki_size	= [60,16],
	.ki_xy		= [0,96],
	.draw		= w_sniper_draw,
	.holster	= w_sniper_holster,
	.primary	= w_sniper_primary,
	.secondary	= w_sniper_secondary,
	.reload		= w_sniper_reload,
	.release	= w_sniper_release,
	.crosshair	= w_sniper_crosshair,
	.precache	= w_sniper_precache,
	.pickup		= w_sniper_pickup,
	.updateammo	= w_sniper_updateammo,
	.wmodel		= w_sniper_wmodel,
	.pmodel		= w_sniper_pmodel,
	.deathmsg	= w_sniper_deathmsg,
	.aimanim	= w_sniper_aimanim,
	.hudpic		= w_sniper_hudpic
};

/* pickups */
#ifdef SSQC
void
weapon_einar1(void)
{
	Weapons_InitItem(WEAPON_SNIPER);
}
#endif
