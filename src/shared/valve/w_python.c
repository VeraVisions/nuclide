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
	PYTHON_IDLE1,
	PYTHON_FIDGET,
	PYTHON_FIRE1,
	PYTHON_RELOAD,
	PYTHON_HOLSTER,
	PYTHON_DRAW,
	PYTHON_IDLE2,
	PYTHON_IDLE3
};

void w_python_precache(void)
{
	precache_model("models/v_357.mdl");
	precache_model("models/w_357.mdl");
	precache_model("models/p_357.mdl");

	precache_sound("weapons/357_shot1.wav");
	precache_sound("weapons/357_shot2.wav");
}
void w_python_pickup(void)
{
	player pl = (player)self;
	pl.python_mag = 6;
}

void w_python_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, __NULL__);
#endif
}
string w_python_wmodel(void)
{
	return "models/w_357.mdl";
}
string w_python_pmodel(void)
{
	return "models/p_357.mdl";
}
string w_python_deathmsg(void)
{
	return "";
}

void w_python_draw(void)
{
	Weapons_SetModel("models/v_357.mdl");
	Weapons_ViewAnimation(PYTHON_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, __NULL__);
#endif
}

void w_python_holster(void)
{
	Weapons_ViewAnimation(PYTHON_HOLSTER);
}
void w_python_primary(void)
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
	if (pl.python_mag <= 0) {
		return;
	}
#endif

	/* Actual firing */
#ifdef SSQC
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.00873, 0.00873]);

	if (random() < 0.5) {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/357_shot1.wav", 1, ATTN_NORM);
	} else {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/357_shot2.wav", 1, ATTN_NORM);
	}
	pl.python_mag--;
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, __NULL__);
#else
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-10,0,0]);
#endif
	Weapons_ViewAnimation(PYTHON_FIRE1);
	pl.w_attack_next = 0.75f;
	pl.w_idle_next = 10.0f;
}

void w_python_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.5f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void w_python_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 >= 6) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.python_mag >= 6) {
		return;
	}
	if (pl.ammo_357 <= 0) {
		return;
	}
#endif

	/* Audio-Visual bit */
	Weapons_ViewAnimation(PYTHON_RELOAD);
#ifdef SSQC
	Weapons_ReloadWeapon(pl, player::python_mag, player::ammo_357, 6);
	Weapons_UpdateAmmo(pl, pl.python_mag, pl.ammo_357, __NULL__);	
#endif
	pl.w_attack_next = 3.25f;
	pl.w_idle_next = 10.0f;
}
void w_python_release(void)
{

	player pl = (player)self;
	if (pl.w_idle_next) {
		return;
	}
	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(PYTHON_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(PYTHON_IDLE2);
		break;
	case 2:
		Weapons_ViewAnimation(PYTHON_IDLE3);
		break;
	}
	pl.w_idle_next = 15.0f;
}
void w_python_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,0], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [24/256,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_python_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

void w_python_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_python =
{
	ITEM_PYTHON,
	1,
	1,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,32],
	w_python_draw,
	w_python_holster,
	w_python_primary,
	w_python_secondary,
	w_python_reload,
	w_python_release,
	w_python_crosshair,
	w_python_precache,
	w_python_pickup,
	w_python_updateammo,
	w_python_wmodel,
	w_python_pmodel,
	w_python_deathmsg,
	w_python_aimanim,
	w_python_hudpic
};

#ifdef SSQC
void weapon_357(void) {
	Weapons_InitItem(WEAPON_PYTHON);
}
void weapon_python(void) {
	Weapons_InitItem(WEAPON_PYTHON);
}
#endif
