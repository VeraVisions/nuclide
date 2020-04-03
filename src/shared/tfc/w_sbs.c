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
	SBS_IDLE1,
	SBS_FIRE1,
	SBS_FIRE2,
	SBS_ADDSHELL,
	SBS_PUMP,
	SBS_START_RELOAD,
	SBS_DRAW,
	SBS_HOLSTER,
	SBS_IDLE2,
	SBS_IDLE3
};

enum
{
	SBS_IDLE,
	SBS_RELOAD_START,
	SBS_RELOAD,
	SBS_RELOAD_END
};

void
w_sbs_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_sbs.cock");
	Sound_Precache("weapon_sbs.fire");
	Sound_Precache("weapon_sbs.reload");
#endif
	precache_model("models/v_tfc_12gauge.mdl");
	precache_model("models/p_shotgun.mdl");
	precache_sound("weapons/dbarrel1.wav");
}

void
w_sbs_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#endif
}
string w_sbs_wmodel(void)
{
	return "models/ball.mdl";
}
string w_sbs_pmodel(void)
{
	return "models/p_shotgun.mdl";
}
string w_sbs_deathmsg(void)
{
	return "";
}

int
w_sbs_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;
	pl.shotgun_mag = bound(0, pl.shotgun_mag + 8, 8);
#endif
	return TRUE;
}

void
w_sbs_draw(void)
{
	Weapons_SetModel("models/v_tfc_12gauge.mdl");
	Weapons_ViewAnimation(SBS_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#endif
}

void
w_sbs_holster(void)
{
	Weapons_ViewAnimation(SBS_HOLSTER);
}

void
w_sbs_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 > SBS_IDLE) {
		return;
	}

	/* Ammo check */
#ifdef SSQC
	if (pl.shotgun_mag <= 0) {
		return;
	}
#else
	if (pl.a_ammo1 <= 0) {
		return;
	}
#endif

#ifdef SSQC
	TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, 6, [0.17365,0.04362], WEAPON_SBS);
	Sound_Play(pl, CHAN_WEAPON, "weapon_sbs.fire");
	pl.shotgun_mag--;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.a_ammo1--;
#endif
	Weapons_ViewAnimation(SBS_FIRE1);

	pl.w_attack_next = 0.75;
	pl.w_idle_next = 2.5f;
}

void
w_sbs_reload(void)
{
	player pl = (player)self;
#ifdef CSQC
	if (pl.a_ammo1 >= 8) {
		return;
	}
	if (pl.a_ammo2 <= 0) { 
		return;
	}
#else
	if (pl.shotgun_mag >= 8) {
		return;
	}
	if (pl.ammo_shells <= 0) {
		return;
	}
#endif
	
	if (pl.a_ammo3 > SBS_IDLE) {
		return;
	}
	pl.a_ammo3 = SBS_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_sbs_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == SBS_IDLE) {
		int r = floor(random(0,3));
		switch (r) {
		case 0:
			Weapons_ViewAnimation(SBS_IDLE1);
			break;
		case 1:
			Weapons_ViewAnimation(SBS_IDLE2);
			break;
		case 2:
			Weapons_ViewAnimation(SBS_IDLE3);
			break;
		}
		pl.w_idle_next = 15.0f;
	} else if (pl.a_ammo3 == SBS_RELOAD_START) {
		Weapons_ViewAnimation(SBS_START_RELOAD);
		pl.a_ammo3 = SBS_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.a_ammo3 == SBS_RELOAD) {
		Weapons_ViewAnimation(SBS_ADDSHELL);
#ifdef CSQC
		pl.a_ammo1++;
		pl.a_ammo2--;

		if (pl.a_ammo2 <= 0 || pl.a_ammo1 >= 8) {
			pl.a_ammo3 = SBS_RELOAD_END;
		}
#else
		pl.shotgun_mag++;
		pl.ammo_shells--;
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, pl.a_ammo3);
	 	Sound_Play(pl, CHAN_WEAPON, "weapon_sbs.reload");
		if (pl.ammo_shells <= 0 || pl.shotgun_mag >= 8) {
			pl.a_ammo3 = SBS_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.a_ammo3 == SBS_RELOAD_END) {
		Weapons_ViewAnimation(SBS_PUMP);
#ifdef SSQC
		Sound_Play(pl, CHAN_WEAPON, "weapon_sbs.cock");
#endif
		pl.a_ammo3 = SBS_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}
void
w_sbs_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_sbs_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_sbs_hudpic(int s, vector pos, float a)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/tfchud02.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/tfchud01.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_sbs =
{
	ITEM_SBS,
	1,
	0,
	"sprites/tfc_dmsg.spr_0.tga",
	[60,16],
	[0,144],
	w_sbs_draw,
	w_sbs_holster,
	w_sbs_primary,
	w_sbs_release,
	w_sbs_reload,
	w_sbs_release,
	w_sbs_crosshair,
	w_sbs_precache,
	w_sbs_pickup,
	w_sbs_updateammo,
	w_sbs_wmodel,
	w_sbs_pmodel,
	w_sbs_deathmsg,
	w_sbs_aimanim,
	w_sbs_hudpic
};
