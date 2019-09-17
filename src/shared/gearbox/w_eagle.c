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

enum
{
	EAGLE_IDLE1,
	EAGLE_IDLE2,
	EAGLE_IDLE3,
	EAGLE_IDLE4,
	EAGLE_IDLE5,
	EAGLE_SHOOT,
	EAGLE_SHOOT_EMPTY,
	EAGLE_RELOAD,
	EAGLE_RELOAD_NOSHOT,
	EAGLE_DRAW,
	EAGLE_HOLSTER
};

void
w_eagle_precache(void)
{
	precache_model("models/v_desert_eagle.mdl");
	precache_model("models/w_desert_eagle.mdl");
	precache_model("models/p_desert_eagle.mdl");

	precache_sound("weapons/desert_eagle_fire.wav");
	precache_sound("weapons/desert_eagle_sight.wav");
	precache_sound("weapons/desert_eagle_sight2.wav");
}

int
w_eagle_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.eagle_mag = 7;
	} else {
		if (pl.ammo_357 < 36) {
			pl.ammo_357 = bound(0, pl.ammo_357 + 7, 36);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_eagle_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.eagle_mag, pl.ammo_357, -1);
#endif
}

string
w_eagle_wmodel(void)
{
	return "models/w_desert_eagle.mdl";
}
string
w_eagle_pmodel(void)
{
	return "models/p_desert_eagle.mdl";
}
string
w_eagle_deathmsg(void)
{
	return "";
}

void
w_eagle_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_desert_eagle.mdl");
	Weapons_ViewAnimation(EAGLE_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.eagle_mag, pl.ammo_357, -1);
#endif
}

void
w_eagle_holster(void)
{
	Weapons_ViewAnimation(EAGLE_HOLSTER);
}

void
w_eagle_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	/* these idles don't support the 'empty' animation style */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.eagle_mag <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(EAGLE_IDLE1 + floor(random(0,5)));
	pl.w_idle_next = 15.0f;
}

void
w_eagle_primary(void)
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
	if (pl.eagle_mag <= 0) {
		return;
	}
#endif

	/* Actual firing */
	if (pl.a_ammo3 == 1) {
#ifdef SSQC
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 34, [0, 0], WEAPON_EAGLE);
#endif
		pl.w_attack_next = 0.5f;
	} else {
#ifdef SSQC
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 34,  [0.1,0.1], WEAPON_EAGLE);
#endif
		pl.w_attack_next = 0.2f;
	}

#ifdef SSQC
	sound(pl, CHAN_WEAPON, "weapons/desert_eagle_fire.wav", 1, ATTN_NORM);
	pl.eagle_mag--;
	Weapons_UpdateAmmo(pl, pl.eagle_mag, pl.ammo_357, -1);
#else
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-10,0,0]);

	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(EAGLE_SHOOT_EMPTY);
	} else {
		Weapons_ViewAnimation(EAGLE_SHOOT);
	}
#endif
}

void
w_eagle_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* toggle laser */
	pl.a_ammo3 = 1 - pl.a_ammo3;

#ifdef SSQC
	if (pl.a_ammo3) {
		sound(pl, 8, "weapons/desert_eagle_sight.wav", 1, ATTN_NORM);
	} else {
		sound(pl, 8, "weapons/desert_eagle_sight2.wav", 1, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 1.0f;
	w_eagle_release();
}

void
w_eagle_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 >= 7) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.eagle_mag >= 7) {
		return;
	}
	if (pl.ammo_357 <= 0) {
		return;
	}
#endif

	/* Audio-Visual bit */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(EAGLE_RELOAD);
	} else {
		Weapons_ViewAnimation(EAGLE_RELOAD_NOSHOT);
	}
#else
	Weapons_ReloadWeapon(pl, player::eagle_mag, player::ammo_357, 7);
	Weapons_UpdateAmmo(pl, pl.eagle_mag, pl.ammo_357, -1);
#endif

	pl.w_attack_next = 1.64f;
	pl.w_idle_next = 10.0f;
}

void
w_eagle_crosshair(void)
{
#ifdef CSQC
	player pl = (player)self;
	vector cross_pos;
	vector aicon_pos;

	/* crosshair/laser */
	if (pl.a_ammo3 == 1) {
		float lerp;
		vector jitter;
		Weapons_MakeVectors();
		vector src = pl.origin + pl.view_ofs;
		traceline(src, src + (v_forward * 256), FALSE, pl);
		lerp = Math_Lerp(18,6, trace_fraction);
		jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
		jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
		cross_pos = (video_res / 2) + ([-lerp,-lerp] / 2);
		drawsubpic(
			cross_pos + jitter,
			[lerp,lerp],
			"sprites/laserdot.spr_0.tga",
			[0,0],
			[1.0, 1.0],
			[1,1,1],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		cross_pos = (video_res / 2) + [-12,-12];
		drawsubpic(
			cross_pos,
			[24,24],
			"sprites/ofch1.spr_0.tga",
			[0,0],
			[24/72, 24/72],
			[1,1,1],
			1,
			DRAWFLAG_NORMAL
		);
	}

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
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
w_eagle_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void
w_eagle_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
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
			"sprites/640hudof01.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_eagle =
{
	.id		= ITEM_EAGLE,
	.slot		= 1,
	.slot_pos	= 2,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,240],
	.draw		= w_eagle_draw,
	.holster	= w_eagle_holster,
	.primary	= w_eagle_primary,
	.secondary	= w_eagle_secondary,
	.reload		= w_eagle_reload,
	.release	= w_eagle_release,
	.crosshair	= w_eagle_crosshair,
	.precache	= w_eagle_precache,
	.pickup		= w_eagle_pickup,
	.updateammo	= w_eagle_updateammo,
	.wmodel		= w_eagle_wmodel,
	.pmodel		= w_eagle_pmodel,
	.deathmsg	= w_eagle_deathmsg,
	.aimanim	= w_eagle_aimanim,
	.hudpic		= w_eagle_hudpic
};

#ifdef SSQC
void
weapon_eagle(void)
{
	Weapons_InitItem(WEAPON_EAGLE);
}
#endif
