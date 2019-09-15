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
	CROSSBOW_IDLE1,
	CROSSBOW_IDLE2,
	CROSSBOW_FIDGET1,
	CROSSBOW_FIDGET2,
	CROSSBOW_FIRE1,
	CROSSBOW_FIRE2,
	CROSSBOW_FIRE3,
	CROSSBOW_RELOAD,
	CROSSBOW_DRAW1,
	CROSSBOW_DRAW2,
	CROSSBOW_HOLSTER1,
	CROSSBOW_HOLSTER2
};

void
w_crossbow_precache(void)
{
	precache_model("models/crossbow_bolt.mdl");
	precache_model("models/v_crossbow.mdl");
	precache_model("models/w_crossbow.mdl");
	precache_model("models/p_crossbow.mdl");
	precache_sound("weapons/xbow_reload1.wav");
	precache_sound("weapons/xbow_fire1.wav");
	precache_sound("weapons/xbow_hit1.wav");
	precache_sound("weapons/xbow_hitbod1.wav");
	precache_sound("weapons/xbow_hitbod2.wav");
}

void
w_crossbow_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, -1);
#endif
}

string
w_crossbow_wmodel(void)
{
	return "models/w_crossbow.mdl";
}

string
w_crossbow_pmodel(void)
{
	return "models/p_crossbow.mdl";
}

string
w_crossbow_deathmsg(void)
{
	return "";
}

int
w_crossbow_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.crossbow_mag = 5;
	} else {
		if (pl.ammo_bolt < MAX_A_BOLT) {
			pl.ammo_bolt = bound(0, pl.ammo_bolt + 5, MAX_A_BOLT);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_crossbow_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_crossbow.mdl");
	Weapons_ViewAnimation(CROSSBOW_DRAW1);
#endif
}

void
w_crossbow_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(CROSSBOW_HOLSTER1);
#endif
}

#ifdef SSQC
void Crossbolt_Touch(void) {
	/* explode mode, multiplayer */
	if (self.weapon) {
		Effect_CreateExplosion(self.origin);
		Damage_Radius(self.origin, self.owner, 50, 50 * 2.5f, TRUE);
		if (random() < 0.5) {
			sound(self, 1, "weapons/explode3.wav", 1.0f, ATTN_NORM);
		} else {
			sound(self, 1, "weapons/explode4.wav", 1.0f, ATTN_NORM);
		}
		remove(self);
		return;
	}

	/* walls, etc. */
	if (other.takedamage != DAMAGE_YES) {
		sound(self, 1, "weapons/xbow_hit1.wav", 1.0f, ATTN_NORM);
		remove(self);
		return;
	}

	/* anything else that can take damage */
	Damage_Apply(other, self.owner, 50, trace_endpos, FALSE);
	if (random() < 0.5) {
		sound(self, 1, "weapons/xbow_hitbod1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(self, 1, "weapons/xbow_hitbod2.wav", 1.0f, ATTN_NORM);
	}

	if (other.iBleeds == TRUE) {
		Effect_CreateSpark(self.origin, trace_plane_normal);
	} else {
		Effect_CreateBlood(self.origin, [0,0,0]);
	}
	remove(self);
}
#endif

void
w_crossbow_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.crossbow_mag <= 0) {
		return;
	}
#endif

#ifdef CSQC
	pl.a_ammo1--;

	if (pl.a_ammo1) {
		Weapons_ViewAnimation(CROSSBOW_FIRE1);
	} else {
		Weapons_ViewAnimation(CROSSBOW_FIRE3);
	}

	Weapons_ViewPunchAngle([-2,0,0]);
#else
	Weapons_MakeVectors();
	entity bolt = spawn();
	setmodel(bolt, "models/crossbow_bolt.mdl");
	setorigin(bolt, Weapons_GetCameraPos() + (v_forward * 16));
	bolt.owner = self;
	bolt.velocity = v_forward * 2000;
	bolt.movetype = MOVETYPE_FLYMISSILE;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.avelocity[2] = 10;
	bolt.touch = Crossbolt_Touch;
	bolt.weapon = pl.viewzoom == 1.0 ? 1 : 0;
	setsize(bolt, [0,0,0], [0,0,0]);

	pl.crossbow_mag--;

	if (pl.crossbow_mag > 0) {
		sound(pl, 8, "weapons/xbow_reload1.wav", 1.0f, ATTN_NORM);
	}

	sound(pl, CHAN_WEAPON, "weapons/xbow_fire1.wav", 1.0f, ATTN_NORM);
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, -1);
#endif

	pl.w_attack_next = 0.75f;
	pl.w_idle_next = 10.0f;
}

void
w_crossbow_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_crossbow_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef SSQC
	if (pl.ammo_bolt <= 0) {
		return;
	}
	if (pl.crossbow_mag >= 5) {
		return;
	}
#else
	if (pl.a_ammo1 >= 5) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#endif

#ifdef SSQC
	Weapons_ReloadWeapon(pl, player::crossbow_mag, player::ammo_bolt, 5);
	sound(pl, CHAN_ITEM, "weapons/xbow_reload1.wav", 1.0f, ATTN_NORM);
#else
	Weapons_ViewAnimation(CROSSBOW_RELOAD);
#endif

	pl.w_attack_next = 4.5f;
	pl.w_idle_next = 10.0f;
}

void
w_crossbow_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (random() < 0.75) {
		if (pl.a_ammo1) {
			Weapons_ViewAnimation(CROSSBOW_IDLE1);
		} else {
			Weapons_ViewAnimation(CROSSBOW_IDLE2);
		}
	} else {
		if (pl.a_ammo1) {
			Weapons_ViewAnimation(CROSSBOW_FIDGET1);
		} else {
			Weapons_ViewAnimation(CROSSBOW_FIDGET2);
		}
	}
#endif

	pl.w_idle_next = 3.0f;
}

void
w_crossbow_crosshair(void)
{
#ifdef CSQC
	vector cross_pos;
	vector aicon_pos;

	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/crosshairs.spr_0.tga",
		[72/128,0],
		[0.1875, 0.1875],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[96/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo2_alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_crossbow_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMBOW : ANIM_AIMBOW;
}

void
w_crossbow_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud2.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_crossbow =
{
	ITEM_CROSSBOW,
	2,
	2,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,80],
	w_crossbow_draw,
	w_crossbow_holster,
	w_crossbow_primary,
	w_crossbow_secondary,
	w_crossbow_reload,
	w_crossbow_release,
	w_crossbow_crosshair,
	w_crossbow_precache,
	w_crossbow_pickup,
	w_crossbow_updateammo,
	w_crossbow_wmodel,
	w_crossbow_pmodel,
	w_crossbow_deathmsg,
	w_crossbow_aimanim,
	w_crossbow_hudpic
};

#ifdef SSQC
void
weapon_crossbow(void)
{
	Weapons_InitItem(WEAPON_CROSSBOW);
}
#endif

