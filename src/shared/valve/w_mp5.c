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

void
w_mp5_precache(void)
{
	precache_model("models/v_9mmar.mdl");
	precache_model("models/w_9mmar.mdl");
	precache_model("models/p_9mmar.mdl");
	precache_model("models/grenade.mdl");
	precache_sound("weapons/hks1.wav");
	precache_sound("weapons/hks2.wav");
	precache_sound("weapons/glauncher.wav");
}

int
w_mp5_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.mp5_mag = 25;
	} else {
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 25, MAX_A_9MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_mp5_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, pl.ammo_m203_grenade);
#endif
}

string
w_mp5_wmodel(void)
{
	return "models/w_9mmar.mdl";
}

string
w_mp5_pmodel(void)
{
	return "models/p_9mmar.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

void
w_mp5_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_9mmar.mdl");
	Weapons_ViewAnimation(MP5_DRAW);
#endif
}

void
w_mp5_holster(void)
{
	Weapons_ViewAnimation(MP5_DRAW);
}

void
w_mp5_primary(void)
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

	/* Actual firing */
#ifdef CSQC
	if (random() < 0.5) {
		Weapons_ViewAnimation(MP5_FIRE1);
	} else {
		Weapons_ViewAnimation(MP5_FIRE2);
	}

	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
	int r = (float)input_sequence % 4;
	Weapons_ViewPunchAngle([r-2,0,0]);
#else
	/* singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(), 8, [0.025,0.025], WEAPON_MP5);
	} else {
		TraceAttack_FireBullets(1, Weapons_GetCameraPos(), 8, [0.05,0.05], WEAPON_MP5);
	}

	if (random() < 0.5) {
		sound(pl, CHAN_WEAPON, "weapons/hks1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(pl, CHAN_WEAPON, "weapons/hks2.wav", 1.0f, ATTN_NORM);
	}

	pl.mp5_mag--;
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo3 <= 0) {
		return;
	}
 
	pl.a_ammo3--;
	Weapons_ViewPunchAngle([-10,0,0]);
	Weapons_ViewAnimation(MP5_GRENADE);
#else
	static void Grenade_ExplodeTouch(void) {
		Effect_CreateExplosion(self.origin);
		Damage_Radius(self.origin, self.owner, 100, 100 * 2.5f, TRUE, WEAPON_MP5);

		if (random() < 0.5) {
			sound(self, 1, "weapons/explode3.wav", 1, ATTN_NORM);
		} else {
			sound(self, 1, "weapons/explode4.wav", 1, ATTN_NORM);
		}
		remove(self);
	}

	if (pl.ammo_m203_grenade <= 0) {
		return;
	}

	Weapons_MakeVectors();
	entity gren = spawn();
	setmodel(gren, "models/grenade.mdl");
	setorigin(gren, Weapons_GetCameraPos() + (v_forward * 16));
	gren.owner = self;
	gren.velocity = v_forward * 800;
	gren.angles = vectoangles(gren.velocity);
	gren.avelocity[0] = random(-100, -500);
	gren.gravity = 0.5f;
	gren.movetype = MOVETYPE_BOUNCE;
	//gren.flags |= FL_LAGGEDMOVE;
	gren.solid = SOLID_BBOX;
	setsize(gren, [0,0,0], [0,0,0]);
	gren.touch = Grenade_ExplodeTouch;
	sound(pl, CHAN_WEAPON, "weapons/glauncher.wav", 1.0f, ATTN_NORM);
	pl.ammo_m203_grenade--;
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_reload(void)
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

#ifdef CSQC
	Weapons_ViewAnimation(MP5_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 50);
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 10.0f;
}

void
w_mp5_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 3;
	if (r == 1) {
		Weapons_ViewAnimation(MP5_IDLE1);
	} else {
		Weapons_ViewAnimation(MP5_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_mp5_crosshair(void)
{
#ifdef CSQC
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];

	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/crosshairs.spr_0.tga",
		[24/128,48/128],
		[0.1875, 0.1875],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	HUD_DrawAmmo3();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[0,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo2_alpha,
		DRAWFLAG_ADDITIVE
	);

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 74];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[48/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeat->ammo3_alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_mp5_aimanim(void)
{
	return self.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

void
w_mp5_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud1.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
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
void
weapon_9mmAR(void)
{
	Weapons_InitItem(WEAPON_MP5);
}

void
weapon_mp5(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif
