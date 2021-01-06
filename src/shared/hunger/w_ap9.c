/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
 * Copyright (c) 2019-2020 Gethyn ThomasQuail <xylemon@posteo.net>
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
	AP9_IDLE,
	AP9_RELOAD,
	AP9_DRAW,
	AP9_SHOOT1,
	AP9_SHOOT2,
	AP9_SHOOT3
};

void
w_ap9_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ap9.fire");
#endif
	precache_model("models/v_ap9.mdl");
	precache_model("models/w_ap9.mdl");
	precache_model("models/p_ap9.mdl");
	precache_sound("weapons/ap9_bolt.wav");
	precache_sound("weapons/ap9_clipin.wav");
	precache_sound("weapons/ap9_clipout.wav");
}

void
w_ap9_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.ap9_mag, pl.ammo_ap9, -1);
#endif
}

string
w_ap9_wmodel(void)
{
	return "models/w_ap9.mdl";
}

string
w_ap9_pmodel(void)
{
	return "models/p_ap9.mdl";
}

string
w_ap9_deathmsg(void)
{
	return "%s was unloaded into from %s's AP9.";
}

int
w_ap9_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.ap9_mag = 40;
	} else {
		if (pl.ammo_ap9 < MAX_A_AP9) {
			pl.ammo_ap9 = bound(0, pl.ammo_ap9 + 40, MAX_A_AP9);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_ap9_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_ap9.mdl");
	Weapons_ViewAnimation(AP9_DRAW);
#endif
}

void
w_ap9_holster(void)
{

}

void
w_ap9_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.ap9_mag) {
		return;
	}
#endif

	/* actual firing */
#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AP9_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AP9_SHOOT2);
		break;
	case 2:
		Weapons_ViewAnimation(AP9_SHOOT3);
		break;
	}

#else
	pl.ap9_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.1,0.1], WEAPON_AP9);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ap9.fire");

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);
#endif

	pl.w_attack_next = 0.15f;
	pl.w_idle_next = 5.0f;
}

void
w_ap9_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.ap9_mag) {
		return;
	}
#endif

#ifdef CLIENT
	pl.a_ammo1 -= 3;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AP9_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AP9_SHOOT2);
		break;
	case 2:
		Weapons_ViewAnimation(AP9_SHOOT3);
		break;
	}
#else
	pl.ap9_mag -= 3;
	TraceAttack_FireBullets(3, pl.origin + pl.view_ofs, 8, [0.02,0.02], WEAPON_AP9);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ap9.fire");

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 5.0f;
}

void
w_ap9_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 40) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}

	Weapons_ViewAnimation(AP9_RELOAD);
#else
	if (pl.ap9_mag >= 40) {
		return;
	}
	if (pl.ammo_ap9 <= 0) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::ap9_mag, player::ammo_ap9, 40);
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 10.0f;
}

void
w_ap9_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.a_ammo1 == 0 && pl.a_ammo2 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(AP9_IDLE);
}

float
w_ap9_aimanim(void)
{
	return w_glock_aimanim();
}

void
w_ap9_hud(void)
{
	w_glock_hud();
}

void
w_ap9_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_ap9 =
{
	.name		= "ap9",
	.id			= ITEM_AP9,
	.slot		= 1,
	.slot_pos	= 2,
	.draw		= w_ap9_draw,
	.holster	= w_ap9_holster,
	.primary	= w_ap9_primary,
	.secondary	= w_ap9_secondary,
	.reload		= w_ap9_reload,
	.release	= w_ap9_release,
	.crosshair	= w_ap9_hud,
	.precache	= w_ap9_precache,
	.pickup		= w_ap9_pickup,
	.updateammo	= w_ap9_updateammo,
	.wmodel		= w_ap9_wmodel,
	.pmodel		= w_ap9_pmodel,
	.deathmsg	= w_ap9_deathmsg,
	.aimanim	= w_ap9_aimanim,
	.hudpic		= w_ap9_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_th_ap9(void)
{
	Weapons_InitItem(WEAPON_AP9);
}
#endif
