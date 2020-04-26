/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
	SNIPER_IDLE,
	SNIPER_RELOAD,
	SNIPER_DRAW,
	SNIPER_FIRE
};

void
w_sniper2_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sniper.fire");
#endif
	precache_model("models/v_hkg36.mdl");
	precache_model("models/w_hkg36.mdl");
	precache_model("models/p_hkg36.mdl");
}

int
w_sniper2_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.sniper_mag = 5;
	} else {
		if (pl.ammo_sniper < MAX_A_SNIPER) {
			pl.ammo_sniper = bound(0, pl.ammo_sniper + 5, MAX_A_SNIPER);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_sniper2_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.sniper_mag, pl.ammo_sniper, -1);
#endif
}

string
w_sniper2_wmodel(void)
{
	return "models/w_hkg36.mdl";
}

string
w_sniper2_pmodel(void)
{
	return "models/p_hkg36.mdl";
}

string
w_sniper2_deathmsg(void)
{
	return "%s was taken out by %s's Sniper.";
}

void
w_sniper2_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_hkg36.mdl");
	Weapons_ViewAnimation(SNIPER_DRAW);
#endif
}

void
w_sniper2_holster(void)
{
}

void
w_sniper2_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SNIPER_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 1:
		Weapons_ViewAnimation(SNIPER_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	}

	pl.w_idle_next = 15.0f;
}

void
w_sniper2_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.sniper_mag <= 0) {
		return;
	}
#endif

	/* Actual firing */
#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_SMALL);
	Weapons_ViewPunchAngle([-20,0,0]);
	Weapons_ViewAnimation(SNIPER_FIRE);
#else
	pl.sniper_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.008, 0.008], WEAPON_SNIPER);

	Sound_Play(pl, CHAN_WEAPON, "weapon_sniper.fire");
#endif


	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.1f;
	} else {
		pl.w_attack_next = 1.0f;
	}

	pl.w_idle_next = 10.0f;
}

void
w_sniper2_secondary(void)
{
	w_sniper_secondary();
}

void
w_sniper2_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 5) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
	Weapons_ViewAnimation(SNIPER_RELOAD);
#else
	if (pl.sniper_mag >= 5) {
		return;
	}
	if (pl.ammo_sniper <= 0) {
		return;
	}
	Weapons_ReloadWeapon(pl, player::sniper_mag, player::ammo_sniper, 5);
#endif
	pl.w_attack_next = 3.82f;
	pl.w_idle_next = 5.0f;
}

void
w_sniper2_crosshair(void)
{
#ifdef CLIENT
	w_sniper_crosshair();
#endif
}

float
w_sniper2_aimanim(void)
{
	return w_crossbow_aimanim();
}

void
w_sniper2_hudpic(int selected, vector pos, float a)
{
	w_sniper_hudpic(selected, pos, a);
}

weapon_t w_sniper2 =
{
	.name		= "sniper2",
	.id			= ITEM_SNIPER2,
	.slot		= 2,
	.slot_pos	= 4,
	.draw		= w_sniper2_draw,
	.holster	= w_sniper2_holster,
	.primary	= w_sniper2_primary,
	.secondary	= w_sniper2_secondary,
	.reload		= w_sniper2_reload,
	.release	= w_sniper2_release,
	.crosshair	= w_sniper2_crosshair,
	.precache	= w_sniper2_precache,
	.pickup		= w_sniper2_pickup,
	.updateammo	= w_sniper2_updateammo,
	.wmodel		= w_sniper2_wmodel,
	.pmodel		= w_sniper2_pmodel,
	.deathmsg	= w_sniper2_deathmsg,
	.aimanim	= w_sniper2_aimanim,
	.hudpic		= w_sniper2_hudpic
};

/* pickups */
#ifdef SERVER
void
weapon_th_sniper(void)
{
	Weapons_InitItem(WEAPON_SNIPER2);
}
#endif
