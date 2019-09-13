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
	MP5_IDLE1,
	MP5_IDLE2,
	MP5_GRENADE,
	MP5_RELOAD,
	MP5_DRAW,
#ifdef GEARBOX
	MP5_DEPLOY, /* not sure what this is about */
#endif
	MP5_FIRE1,
	MP5_FIRE2,
	MP5_FIRE3
};

void w_mp5_precache(void)
{
	precache_model("models/v_9mmar.mdl");
	precache_model("models/w_9mmar.mdl");
	precache_model("models/p_9mmar.mdl");
	precache_model("models/grenade.mdl");
	precache_sound("weapons/hks1.wav");
	precache_sound("weapons/hks2.wav");
	precache_sound("weapons/glauncher.wav");
}

int w_mp5_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.mp5_mag = 25;
	} else {
		if (pl.ammo_9mm < 250) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 25, 250);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void w_mp5_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif
}

string w_mp5_wmodel(void)
{
	return "models/w_9mmar.mdl";
}

string w_mp5_pmodel(void)
{
	return "models/p_9mmar.mdl";
}

string w_mp5_deathmsg(void)
{
	return "";
}

void w_mp5_draw(void)
{
	Weapons_SetModel("models/v_9mmar.mdl");
	Weapons_ViewAnimation(MP5_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif
}

void w_mp5_holster(void)
{
	Weapons_ViewAnimation(MP5_DRAW);
}

void w_mp5_primary(void)
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
	if (pl.mp5_mag <= 0) {
		return;
	}
#endif

	if (random() < 0.5) {
		Weapons_ViewAnimation(MP5_FIRE1);
	} else {
		Weapons_ViewAnimation(MP5_FIRE2);
	}

	/* Actual firing */
#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([random(-2, 2),0,0]);
#else
	/* Singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.02618,0.02618]);
	} else {
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.05234,0.05234]);
	}

	if (random() < 0.5) {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/hks1.wav", 1, ATTN_NORM);
	} else {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/hks2.wav", 1, ATTN_NORM);
	}
	
	pl.mp5_mag--;
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 10.0f;
}

void w_mp5_secondary(void)
{
	player pl = (player)self;
	
	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo3 <= 0) {
		return;
	}
	Weapons_ViewPunchAngle([-10,0,0]);
	pl.a_ammo3--;
#else

	static void Grenade_ExplodeTouch(void) {
		Effect_CreateExplosion( self.origin );
		Damage_Radius( self.origin, self.owner, 100, 100 * 2.5f, TRUE );
		sound( self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM );
		remove(self);
	}
	
	if (pl.ammo_m203_grenade <= 0) {
		return;
	}

	makevectors(self.v_angle);
	entity gren = spawn();
	setmodel(gren, "models/grenade.mdl");
	setorigin(gren, self.origin + self.view_ofs + (v_forward * 16));
	gren.owner = self;
	gren.velocity = v_forward * 800;
	gren.angles = vectoangles(gren.velocity);
	gren.avelocity[0] = random(-100, -500);
	gren.gravity = 0.5f;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setsize(gren, [0,0,0], [0,0,0]);
	gren.touch = Grenade_ExplodeTouch;
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/glauncher.wav", 1, ATTN_NORM);
	pl.ammo_m203_grenade--;
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif
	Weapons_ViewAnimation(MP5_GRENADE);
	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 10.0f;
}

void w_mp5_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 >= 50) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.mp5_mag >= 50) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(MP5_RELOAD);

#ifdef SSQC
	Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 50);
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 10.0f;
}

void w_mp5_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (random() < 0.5) {
		Weapons_ViewAnimation(MP5_IDLE1);
	} else {
		Weapons_ViewAnimation(MP5_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void w_mp5_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [24/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	HUD_DrawAmmo3();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
	aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 74];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo3_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_mp5_aimanim(void)
{
	return self.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}
void w_mp5_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_mp5 = {
	ITEM_MP5,
	2,
	0,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,48],
	w_mp5_draw,
	w_mp5_holster,
	w_mp5_primary,
	w_mp5_secondary,
	w_mp5_reload,
	w_mp5_release,
	w_mp5_crosshair,
	w_mp5_precache,
	w_mp5_pickup,
	w_mp5_updateammo,
	w_mp5_wmodel,
	w_mp5_pmodel,
	w_mp5_deathmsg,
	w_mp5_aimanim,
	w_mp5_hudpic
};

#ifdef SSQC
void weapon_9mmAR(void)
{
	Weapons_InitItem(WEAPON_MP5);
}

void weapon_mp5(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif

