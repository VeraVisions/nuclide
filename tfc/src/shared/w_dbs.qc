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

enum
{
	DBS_IDLE1,
	DBS_FIRE1,
	DBS_FIRE2,
	DBS_ADDSHELL,
	DBS_PUMP,
	DBS_START_RELOAD,
	DBS_DRAW,
	DBS_HOLSTER,
	DBS_IDLE2,
	DBS_IDLE3
};

enum
{
	DBS_IDLE,
	DBS_RELOAD_START,
	DBS_RELOAD,
	DBS_RELOAD_END
};

void
w_dbs_precache(void)
{
	precache_model("models/v_tfc_shotgun.mdl");
	precache_model("models/w_shot2.mdl");
	precache_model("models/p_shot2.mdl");
	precache_sound("weapons/sbarrel1.wav");
	precache_sound("weapons/dbarrel1.wav");
	precache_sound("weapons/reload3.wav");
	precache_sound("weapons/scock1.wav");
}

void
w_dbs_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#endif
}
string w_dbs_wmodel(void)
{
	return "models/w_shot2.mdl";
}
string w_dbs_pmodel(void)
{
	return "models/p_shot2.mdl";
}
string w_dbs_deathmsg(void)
{
	return "";
}

int
w_dbs_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;
	pl.shotgun_mag = bound(0, pl.shotgun_mag + 8, 8);
#endif
	return TRUE;
}

void
w_dbs_draw(void)
{
	Weapons_SetModel("models/v_tfc_shotgun.mdl");
	Weapons_ViewAnimation(DBS_DRAW);
#ifdef SERVER
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#endif
}

void
w_dbs_holster(void)
{
	Weapons_ViewAnimation(DBS_HOLSTER);
}

void
w_dbs_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 > DBS_IDLE) {
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
	TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, 14, [0.17365,0.04362], WEAPON_DBS);
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/sbarrel1.wav", 1, ATTN_NORM);
	pl.shotgun_mag--;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, __NULL__);
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.a_ammo1--;
#endif
	Weapons_ViewAnimation(DBS_FIRE1);

	pl.w_attack_next = 0.75;
	pl.w_idle_next = 2.5f;
}

void
w_dbs_reload(void)
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
	if (pl.ammo_shells <= 0) {
		return;
	}
#endif
	
	if (pl.a_ammo3 > DBS_IDLE) {
		return;
	}
	pl.a_ammo3 = DBS_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_dbs_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == DBS_IDLE) {
		int r = floor(random(0,3));
		switch (r) {
		case 0:
			Weapons_ViewAnimation(DBS_IDLE1);
			break;
		case 1:
			Weapons_ViewAnimation(DBS_IDLE2);
			break;
		case 2:
			Weapons_ViewAnimation(DBS_IDLE3);
			break;
		}
		pl.w_idle_next = 15.0f;
	} else if (pl.a_ammo3 == DBS_RELOAD_START) {
		Weapons_ViewAnimation(DBS_START_RELOAD);
		pl.a_ammo3 = DBS_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.a_ammo3 == DBS_RELOAD) {
		Weapons_ViewAnimation(DBS_ADDSHELL);
#ifdef CLIENT
		pl.a_ammo1++;
		pl.a_ammo2--;

		if (pl.a_ammo2 <= 0 || pl.a_ammo1 >= 8) {
			pl.a_ammo3 = DBS_RELOAD_END;
		}
#else
		pl.shotgun_mag++;
		pl.ammo_shells--;
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_shells, pl.a_ammo3);
	 	sound(pl, CHAN_WEAPON, "weapons/reload3.wav", 1.0, ATTN_NORM);	
		if (pl.ammo_shells <= 0 || pl.shotgun_mag >= 8) {
			pl.a_ammo3 = DBS_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.a_ammo3 == DBS_RELOAD_END) {
		Weapons_ViewAnimation(DBS_PUMP);
#ifdef SERVER
		sound(pl, CHAN_WEAPON, "weapons/scock1.wav", 1.0, ATTN_NORM);
#endif
		pl.a_ammo3 = DBS_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}
void
w_dbs_crosshair(void)
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

float
w_dbs_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_dbs_hudpic(int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_dbs =
{
	.name		= "sbs",
	.id			= ITEM_DBS,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_dbs_draw,
	.holster	= w_dbs_holster,
	.primary	= w_dbs_primary,
	.secondary	= w_dbs_release,
	.reload		= w_dbs_reload,
	.release	= w_dbs_release,
	.crosshair	= w_dbs_crosshair,
	.precache	= w_dbs_precache,
	.pickup		= w_dbs_pickup,
	.updateammo	= w_dbs_updateammo,
	.wmodel		= w_dbs_wmodel,
	.pmodel		= w_dbs_pmodel,
	.deathmsg	= w_dbs_deathmsg,
	.aimanim	= w_dbs_aimanim,
	.hudpic		= w_dbs_hudpic
};
