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

enum {
	GP_IDLE1, // 3.75f
	GP_IDLE2, // 3.0f
	GP_FIRESINGLE, // 0.727273f
	GP_FIREFAST, // 0.2f
	GP_FIRECHARGE, // 3.0f
	GP_DRAW, // 1.071429f
	GP_HOLSTER, // 0.9375f
	SNIPER_IDLE1, // 3.0f
	SNIPER_IDLE2, // 3.0f
	SNIPER_FIDGET, // 3.0f
	SNIPER_SHOOT, // 0.357143
	SNIPER_DRAW, // 0.937500
	SNIPER_HOLSTER // 1.666667f
};

enum {
	GM_SINGLE,
	GM_CHARGE,
	GM_FAST,
	GM_SNIPER
};

void
w_gausspistol_draw(void)
{
	Weapons_SetModel("models/v_guasspistol.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(GP_DRAW);
}

void
w_gausspistol_holster(void)
{
	Weapons_ViewAnimation(GP_HOLSTER);
}

void
w_gausspistol_release(void)
{
	player pl = (player)self;

	pl.flags |= FL_SEMI_TOGGLED;

	if (pl.w_idle_next) {
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(GP_IDLE1);
		pl.w_idle_next = 3.75f;
		break;
	default:
		Weapons_ViewAnimation(GP_IDLE2);
		pl.w_idle_next = 3.0f;
	}
}

void
w_gausspistol_primary(void)
{
	vector src;
	int take = 1;
	player pl = (player)self;
	
	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}
	
	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags &= ~FL_SEMI_TOGGLED;
		return;
	}

	if (pl.w_attack_next > 0) {
		return;
	}

	/* ammo check */
	if (pl.a_ammo2 <= 0) {
		return;
	}

	if (pl.a_ammo3 == GM_CHARGE && pl.a_ammo2 < 10) {
		return;
	}

	switch (pl.a_ammo3) {
	case GM_FAST:
		Weapons_ViewAnimation(GP_FIREFAST);
#ifdef SSQC
		sound(self, CHAN_WEAPON, "weapons/gauss_fire4.wav", 1, ATTN_NORM);
#endif
		pl.w_attack_next = 0.15f;
		pl.w_idle_next = 2.5f;
		break;
	case GM_CHARGE:
		take = 10;
		Weapons_ViewAnimation(GP_FIRECHARGE);
#ifdef SSQC
		sound(self, CHAN_WEAPON, "weapons/gauss_fire2.wav", 1, ATTN_NORM);
		sound(self, 8, "weapons/gauss_charge.wav", 1, ATTN_NORM);
#endif
		pl.w_attack_next = 2.0f;
		pl.w_idle_next = 5.0f;
		break;
	default:
		pl.flags &= ~FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(GP_FIRESINGLE);
#ifdef SSQC
		sound(self, CHAN_WEAPON, "weapons/gauss_fire1.wav", 1, ATTN_NORM);
#endif
		pl.w_attack_next = 0.15f;
		pl.w_idle_next = 2.5f;
		break;
	}

	src = Weapons_GetCameraPos();

#ifdef SSQC
	pl.ammo_gauss -= take;
#else
	pl.a_ammo2 -= take;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-5,0,0]);
#endif
}

void
w_gausspistol_secondary(void)
{
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	pl.flags &= ~FL_SEMI_TOGGLED;

	/* activate menu */
	pl.a_ammo1 = 1;
	w_gausspistol_release();
}

void
w_gausspistol_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, pl.ammo_gauss, pl.gauss_mode);
#endif
}

string
w_gausspistol_wmodel(void)
{
	return "models/w_gauss.mdl";
}

string
w_gausspistol_pmodel(void)
{
	return "models/p_357.mdl";
}

string
w_gausspistol_deathmsg(void)
{
	return "%s kills %s with his Gauss-Pistol";
}

float
w_gausspistol_aimanim(void)
{
	return 0;
}

int
w_gausspistol_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_gauss < 150) {
		pl.ammo_gauss = bound(0, pl.ammo_gauss + 35, 150);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_gausspistol_hud(void)
{
#ifdef CSQC
	vector pos;
	player pl = (player)self;

	pos = video_mins + [video_res[0] - 125, video_res[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_gauss.tga",
			[32,16],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
		pos[1] += 8;
	}

	HUD_DrawAmmo2();
	
	/* menu */
	if (pl.a_ammo1 > 0) {
		pos = video_mins + (video_res / 2) + [-96,-72];

		/* far left */
		if (pl.a_ammo3 == GM_SINGLE) {
			drawsubpic(
				pos,
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[0/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [64,0],
				[128,144],
				"sprites/gausshud1.spr_0.tga",
				[64/192,0/144],
				[128/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.a_ammo3 == GM_CHARGE) {
			drawsubpic(
				pos,
				[64,144],
				"sprites/gausshud1.spr_0.tga",
				[0/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [64,0],
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[64/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [128,0],
				[64,144],
				"sprites/gausshud1.spr_0.tga",
				[128/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.a_ammo3 == GM_FAST) {
			drawsubpic(
				pos,
				[128,144],
				"sprites/gausshud1.spr_0.tga",
				[0/192,0/144],
				[128/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [128,0],
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[128/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		return;
	}

	pos = video_mins + (video_res / 2) + [-15,-15];
	drawsubpic(
		pos,
		[31,31],
		"sprites/crosshairs.spr_0.tga",
		[1/256,1/128],
		[31/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_gausspistol_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	drawpic(
		pos,
		"gfx/vgui/640_weapon_gaussPistol0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_gausspistol_precache(void)
{
	precache_model("models/v_guasspistol.mdl");
	precache_model("sprites/gausshud1.spr");
	precache_model("sprites/gausshud2.spr");
	precache_sound("weapons/gauss_fire4.wav");
	precache_sound("weapons/gauss_fire2.wav");
	precache_sound("weapons/gauss_fire1.wav");
	precache_sound("weapons/gauss_charge.wav");
}

weapon_t w_gausspistol =
{
	.id		= ITEM_GAUSSPISTOL,
	.slot		= 1,
	.slot_pos	= 0,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_gausspistol_draw,
	.holster	= w_gausspistol_holster,
	.primary	= w_gausspistol_primary,
	.secondary	= w_gausspistol_secondary,
	.reload		= __NULL__,
	.release	= w_gausspistol_release,
	.crosshair	= w_gausspistol_hud,
	.precache	= w_gausspistol_precache,
	.pickup		= w_gausspistol_pickup,
	.updateammo	= w_gausspistol_updateammo,
	.wmodel		= w_gausspistol_wmodel,
	.pmodel		= w_gausspistol_pmodel,
	.deathmsg	= w_gausspistol_deathmsg,
	.aimanim	= w_gausspistol_aimanim,
	.hudpic		= w_gausspistol_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_gausspistol(void)
{
	Weapons_InitItem(WEAPON_GAUSSPISTOL);
}
#endif

#ifdef CSQC
int
w_gausspistol_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	pl.a_ammo3 = bound(GM_SINGLE, pl.a_ammo3 - 1, GM_FAST);
	sendevent("w_gp_setmode", "i", pl.a_ammo3);
	return FALSE;
}

int
w_gausspistol_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	pl.a_ammo3 = bound(GM_SINGLE, pl.a_ammo3 + 1, GM_FAST);
	sendevent("w_gp_setmode", "i", pl.a_ammo3);
	return FALSE;
}
#else
void CSEv_w_gp_setmode_i(int f)
{
	player pl = (player)self;
	pl.a_ammo3 = f;
	pl.gauss_mode = f;
}
#endif
