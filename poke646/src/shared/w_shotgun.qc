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

enum
{
	SHOTGUN_IDLE1,
	SHOTGUN_FIRE1,
	SHOTGUN_RELOAD,
	SHOTGUN_PUMP,
	SHOTGUN_START_RELOAD,
	SHOTGUN_DRAW,
	SHOTGUN_HOLSTER,
	SHOTGUN_IDLE2
};

enum
{
	SHOTTY_IDLE,
	SHOTTY_RELOAD_START,
	SHOTTY_RELOAD,
	SHOTTY_RELOAD_END
};

void w_shotgun_precache(void)
{
	precache_model("models/v_shotgun.mdl");
	precache_model("models/w_shotgun.mdl");
	precache_model("models/p_shotgun.mdl");
	precache_sound("weapons/sbarrel1.wav");
	precache_sound("weapons/dbarrel1.wav");
	precache_sound("weapons/reload3.wav");
	precache_sound("weapons/scock1.wav");
}
void w_shotgun_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#endif
}
string w_shotgun_wmodel(void)
{
	return "models/w_shotgun.mdl";
}
string w_shotgun_pmodel(void)
{
	return "models/p_shotgun.mdl";
}
string w_shotgun_deathmsg(void)
{
	return "";
}

int w_shotgun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.shotgun_mag = 8;
	} else {
		if (pl.ammo_buckshot < 125) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 8, 125);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void w_shotgun_draw(void)
{
	Weapons_SetModel("models/v_shotgun.mdl");
	Weapons_ViewAnimation(SHOTGUN_DRAW);
#ifdef SERVER
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#endif
}

void w_shotgun_holster(void)
{
	Weapons_ViewAnimation(SHOTGUN_HOLSTER);
}
void w_shotgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 > SHOTTY_IDLE) {
		return;
	}

	/* Ammo check */
#ifdef SERVER
	if (pl.shotgun_mag <= 0) {
		return;
	}
#else
	if (pl.a_ammo1 <= 0) {
		return;
	}
#endif

#ifdef SERVER
	/* Singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(6, pl.origin + pl.view_ofs, 5, [0.08716,0.08716], WEAPON_SHOTGUN);
	} else {
		TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, 5, [0.08716,0.04362], WEAPON_SHOTGUN);
	}
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/dbarrel1.wav", 1, ATTN_NORM);
	pl.shotgun_mag--;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.a_ammo1--;
#endif
	Weapons_ViewAnimation(SHOTGUN_FIRE1);

	pl.w_attack_next = 1.1f;
	pl.w_idle_next = 2.5f;
}
void w_shotgun_reload(void)
{
	player pl = (player)self;
#ifdef CLIENT
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
	if (pl.ammo_buckshot <= 0) {
		return;
	}
#endif
	
	if (pl.a_ammo3 > SHOTTY_IDLE) {
		return;
	}
	pl.a_ammo3 = SHOTTY_RELOAD_START;
	pl.w_idle_next = 0.0f;
}
void w_shotgun_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.a_ammo3 == SHOTTY_IDLE && pl.a_ammo1 == 0 && pl.a_ammo2 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == SHOTTY_IDLE) {
		int r = floor(random(0,2));
		switch (r) {
		case 0:
			Weapons_ViewAnimation(SHOTGUN_IDLE1);
			break;
		case 1:
			Weapons_ViewAnimation(SHOTGUN_IDLE2);
			break;
		}
		pl.w_idle_next = 15.0f;
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_START) {
		Weapons_ViewAnimation(SHOTGUN_START_RELOAD);
		pl.a_ammo3 = SHOTTY_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.a_ammo3 == SHOTTY_RELOAD) {
		Weapons_ViewAnimation(SHOTGUN_RELOAD);
#ifdef CLIENT
		pl.a_ammo1++;
		pl.a_ammo2--;

		if (pl.a_ammo2 <= 0 || pl.a_ammo1 >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#else
		pl.shotgun_mag++;
		pl.ammo_buckshot--;
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, pl.a_ammo3);
	 	sound(pl, CHAN_WEAPON, "weapons/reload3.wav", 1.0, ATTN_NORM);	
		if (pl.ammo_buckshot <= 0 || pl.shotgun_mag >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_END) {
		Weapons_ViewAnimation(SHOTGUN_PUMP);
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/scock1.wav", 1.0, ATTN_NORM);
#endif
		pl.a_ammo3 = SHOTTY_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}
void w_shotgun_crosshair(void)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_shotgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void w_shotgun_hudpic(int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_shotgun =
{
	.name		= "shotgun",
	.id		= ITEM_SHOTGUN,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_shotgun_draw,
	.holster	= w_shotgun_holster,
	.primary	= w_shotgun_primary,
	.secondary	= __NULL__,
	.reload		= w_shotgun_reload,
	.release	= w_shotgun_release,
	.crosshair	= __NULL__,
	.precache	= w_shotgun_precache,
	.pickup		= w_shotgun_pickup,
	.updateammo	= w_shotgun_updateammo,
	.wmodel		= w_shotgun_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_shotgun_hudpic
};

#ifdef SERVER
void weapon_shotgun(void) {
	Weapons_InitItem(WEAPON_SHOTGUN);
}
#endif
