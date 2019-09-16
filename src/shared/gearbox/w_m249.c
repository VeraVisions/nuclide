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

/* Animations */
enum {
	M249_IDLE1,
	M249_IDLE2,
	M249_RELOAD1,
	M249_RELOAD2,
	M249_HOLSTER,
	M249_DRAW,
	M249_FIRE
};

void
w_m249_precache(void)
{
	precache_model("models/v_saw.mdl");
	precache_model("models/w_saw.mdl");
	precache_model("models/p_saw.mdl");
	precache_sound("weapons/saw_fire1.wav");
	precache_sound("weapons/saw_fire2.wav");
	precache_sound("weapons/saw_fire3.wav");
	precache_sound("weapons/saw_reload.wav");
	precache_sound("weapons/saw_reload2.wav");
}

int 
w_m249_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.m249_mag = 50;
	} else {
		if (pl.ammo_556 < 200) {
			pl.ammo_556 = bound(0, pl.ammo_556 + 50, 200);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_m249_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.m249_mag, pl.ammo_556, -1);
#endif
}

string
w_m249_wmodel(void)
{
	return "models/w_saw.mdl";
}

string
w_m249_pmodel(void)
{
	return "models/p_saw.mdl";
}

string
w_m249_deathmsg(void)
{
	return "";
}

void
w_m249_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_saw.mdl");
	Weapons_ViewAnimation(M249_DRAW);
#endif
}

void
w_m249_holster(void)
{
	Weapons_ViewAnimation(M249_DRAW);
}

void
w_m249_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(M249_RELOAD2);
		pl.a_ammo3 = 0;
		pl.w_attack_next = 2.45f;
		pl.w_idle_next = 15.0f;
		return;
	}

	if (random() < 0.5) {
		Weapons_ViewAnimation(M249_IDLE1);
	} else {
		Weapons_ViewAnimation(M249_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_m249_primary(void)
{
	player pl = (player)self;
	vector push;

	if (pl.a_ammo3 == 1) {
		w_m249_release();
		return;
	}

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.m249_mag <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(M249_FIRE);

	push = v_forward * -64;
	push[2] *= 0.25f; /* gravity duh */
	pl.velocity += push;

	/* actual firing */
#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-5,0,0]);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.052,0.052]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/saw_fire1.wav", 1, ATTN_NORM);
		break;
	case 1:
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/saw_fire2.wav", 1, ATTN_NORM);
		break;
	default:
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/saw_fire3.wav", 1, ATTN_NORM);
	}

	pl.m249_mag--;
#endif

	pl.w_attack_next = 0.075f;
	pl.w_idle_next = 10.0f;
}

void
w_m249_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		w_m249_release();
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 50) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
	Weapons_ViewAnimation(M249_RELOAD1);
#else
	if (pl.m249_mag >= 50) {
		return;
	}
	if (pl.ammo_556 <= 0) {
		return;
	}
	Weapons_ReloadWeapon(pl, player::m249_mag, player::ammo_556, 50);
	Weapons_UpdateAmmo(pl, pl.m249_mag, pl.ammo_556, __NULL__);
#endif

	pl.a_ammo3 = 1;
	pl.w_attack_next = pl.w_idle_next = 1.5f;
}

void
w_m249_crosshair(void)
{
#ifdef CSQC
	vector cross_pos;
	vector aicon_pos;

	/* crosshair */
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/ofch1.spr_0.tga",
		[24/72,0],
		[24/72, 24/72],
		[1,1,1],
		1.0,
		DRAWFLAG_NORMAL
	);

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/128,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo2_alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_m249_aimanim(void)
{
	return self.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

void
w_m249_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
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
			"sprites/640hudof01.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m249 =
{
	.id		= ITEM_M249,
	.slot		= 5,
	.slot_pos	= 0,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [96,208],
	.draw		= w_m249_draw,
	.holster	= w_m249_holster,
	.primary	= w_m249_primary,
	.secondary	= __NULL__,
	.reload		= w_m249_reload,
	.release	= w_m249_release,
	.crosshair	= w_m249_crosshair,
	.precache	= w_m249_precache,
	.pickup		= w_m249_pickup,
	.updateammo	= w_m249_updateammo,
	.wmodel		= w_m249_wmodel,
	.pmodel		= w_m249_pmodel,
	.deathmsg	= w_m249_deathmsg,
	.aimanim	= w_m249_aimanim,
	.hudpic		= w_m249_hudpic
};

#ifdef SSQC
void
weapon_m249(void)
{
	Weapons_InitItem(WEAPON_M249);
}
#endif

