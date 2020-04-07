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

/*QUAKED weapon_9mmhandgun (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_9mmhandgun.mdl"

HALF-LIFE (1998) ENTITY

9mm Handgun/Glock Weapon
Same as weapon_glock

*/

/*QUAKED weapon_glock (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_9mmhandgun.mdl"

HALF-LIFE (1998) ENTITY

9mm Handgun/Glock Weapon
Same as weapon_9mmhandgun

*/

enum
{
	GLOCK_IDLE1,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD_EMPTY,
	GLOCK_RELOAD,
	GLOCK_DRAW,
	GLOCK_HOLSTER
};

void
w_glock_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_glock.fire");
#endif

	precache_model("models/v_9mmhandgun.mdl");
	precache_model("models/w_9mmhandgun.mdl");
	precache_model("models/p_9mmhandgun.mdl");
}

void
w_glock_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.glock_mag, pl.ammo_9mm, -1);
#endif
}

string
w_glock_wmodel(void)
{
	return "models/w_9mmhandgun.mdl";
}

string
w_glock_pmodel(void)
{
	return "models/p_9mmhandgun.mdl";
}

string
w_glock_deathmsg(void)
{
	return "";
}

int
w_glock_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.glock_mag = 18;
	} else {
		if (pl.ammo_9mm < MAX_A_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 18, MAX_A_9MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_glock_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_9mmhandgun.mdl");
	Weapons_ViewAnimation(GLOCK_DRAW);
#endif
}

void
w_glock_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(GLOCK_HOLSTER);
#endif
}

void
w_glock_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.glock_mag) {
		return;
	}
#endif

	/* actual firing */
#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-2,0,0]);

	if (pl.a_ammo1) {
		Weapons_ViewAnimation(GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(GLOCK_SHOOT_EMPTY);
	}
#else
	pl.glock_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet"), [0.01,0,01], WEAPON_GLOCK);
	Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);
#endif

	pl.w_attack_next = 0.3f;
	pl.w_idle_next = 5.0f;
}

void
w_glock_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

	/* ammo check */
#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.glock_mag) {
		return;
	}
#endif

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-2,0,0]);

	if (pl.a_ammo1) {
		Weapons_ViewAnimation(GLOCK_SHOOT);
	} else {
		Weapons_ViewAnimation(GLOCK_SHOOT_EMPTY);
	}
#else
	pl.glock_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, Skill_GetValue("plr_9mm_bullet"), [0.1,0.1], WEAPON_GLOCK);
	Sound_Play(pl, CHAN_WEAPON, "weapon_glock.fire");

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);
#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 5.0f;
}

void
w_glock_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 18) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}

	if (pl.a_ammo1) {
		Weapons_ViewAnimation(GLOCK_RELOAD);
	} else {
		Weapons_ViewAnimation(GLOCK_RELOAD_EMPTY);
	}
#else
	if (pl.glock_mag >= 18) {
		return;
	}
	if (pl.ammo_9mm <= 0) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::glock_mag, player::ammo_9mm, 18);
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 10.0f;
}

void
w_glock_release(void)
{
	player pl = (player)self;
	int r;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(GLOCK_IDLE2);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(GLOCK_IDLE3);
		pl.w_idle_next = 3.5f;
		break;
	default:
		Weapons_ViewAnimation(GLOCK_IDLE1);
		pl.w_idle_next = 3.75f;
		break;
	}
}

float
w_glock_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_glock_hud(void)
{
#ifdef CSQC
	vector cross_pos;
	vector aicon_pos;

	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/crosshairs.spr_0.tga",
		[0.1875,0],
		[0.1875, 0.1875],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

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
#endif
}

void
w_glock_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
			[0,45/256],
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
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_glock =
{
	ITEM_GLOCK,
	1,
	0,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_glock_draw,
	w_glock_holster,
	w_glock_primary,
	w_glock_secondary,
	w_glock_reload,
	w_glock_release,
	w_glock_hud,
	w_glock_precache,
	w_glock_pickup,
	w_glock_updateammo,
	w_glock_wmodel,
	w_glock_pmodel,
	w_glock_deathmsg,
	w_glock_aimanim,
	w_glock_hudpic
};

/* pickups */
#ifdef SSQC
void
weapon_9mmhandgun(void)
{
	Weapons_InitItem(WEAPON_GLOCK);
}

void
weapon_glock(void)
{
	Weapons_InitItem(WEAPON_GLOCK);
}
#endif
