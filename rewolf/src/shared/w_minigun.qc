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
	MG_IDLE, // 2.0f
	MG_FIDGET, // 2.6f
	MG_FIRE, // 0.333333f
	MG_SPINUP, // 2.0f
	MG_FIRELOOP, // 0.666667f
	MG_SPINDOWN, // 2.0f
	MG_DRAW, // 1.5f
	MG_IDLELOOP, // 0.666667f
	MG_HOLSTER // 1.5f
};

void
w_minigun_draw(void)
{
	Weapons_SetModel("models/v_mechagun.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(MG_DRAW);
}

void
w_minigun_holster(void)
{
	Weapons_ViewAnimation(MG_DRAW);
}

void
w_minigun_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next) {
		return;
	}

	if (pl.menu_active == 1) {
		Weapons_ViewAnimation(MG_IDLELOOP);
		pl.w_idle_next = 0.666667f;
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(MG_IDLE);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(MG_FIDGET);
		pl.w_idle_next = 2.0f;
	}
}

void
w_minigun_primary(void)
{
	vector src;
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	if (pl.ammo_minigun <= 0) {
		w_minigun_release();
		return;
	}

	src = Weapons_GetCameraPos();

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_minigun.fire");
#else
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-2,0,0]);
#endif

	pl.ammo_minigun--;

	if (pl.menu_active == 1) {
#ifdef CLIENT
		Weapons_ViewAnimation(MG_FIRELOOP);
#else
		TraceAttack_FireBullets(1, src, 8, [0.1,0.1], WEAPON_MINIGUN);
#endif
		pl.w_attack_next = 0.1f;
		pl.w_idle_next = 0.1f;
	} else {

#ifdef CLIENT
		Weapons_ViewAnimation(MG_FIRE);
#else
		TraceAttack_FireBullets(1, src, 8, [0.05,0.05], WEAPON_MINIGUN);
#endif
		pl.w_attack_next = 0.25f;
		pl.w_idle_next = 2.5f;
	}
}

void
w_minigun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

#ifdef SERVER
	if (pl.menu_active == 0) {
		Sound_Play(pl, 8, "weapon_minigun.spinup");
	} else {
		Sound_Play(pl, 8, "weapon_minigun.spindown");
	}
#else
	if (pl.menu_active == 0) {
		Weapons_ViewAnimation(MG_SPINUP);
	} else {
		Weapons_ViewAnimation(MG_SPINDOWN);
	}
#endif
	pl.menu_active = 1 - pl.menu_active;

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 2.0f;
}

void
w_minigun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_minigun, -1);
}

string
w_minigun_wmodel(void)
{
	return "models/w_mechagun.mdl";
}

string
w_minigun_pmodel(void)
{
	return "models/p_9mmar.mdl";
}

string
w_minigun_deathmsg(void)
{
	return "";
}

float
w_minigun_aimanim(void)
{
	return 0;
}

int
w_minigun_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_minigun < 100) {
		pl.ammo_minigun = bound(0, pl.ammo_minigun + 30, 100);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_minigun_hud(void)
{
#ifdef CLIENT
	vector pos;
	pos = g_hudmins + (g_hudres / 2) + [-23,-15];

	drawsubpic(
		pos,
		[47,31],
		"sprites/crosshairs.spr_0.tga",
		[67/256,1/128],
		[47/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	pos = g_hudmins + [g_hudres[0] - 125, g_hudres[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_minigun.tga",
			[32,16],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
		pos[1] += 8;
	}
	HUD_DrawAmmo2();
#endif
}

void
w_minigun_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_minigun0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_minigun_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_minigun.fire");
	Sound_Precache("weapon_minigun.spindown");
	Sound_Precache("weapon_minigun.spinup");
#endif
	precache_model("models/v_mechagun.mdl");
	precache_model("models/w_mechagun.mdl");
	precache_model("models/p_9mmar.mdl");
}

weapon_t w_minigun =
{
	.name		= "minigun",
	.id		= ITEM_MINIGUN,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_minigun_draw,
	.holster	= w_minigun_holster,
	.primary	= w_minigun_primary,
	.secondary	= w_minigun_secondary,
	.reload		= __NULL__,
	.release	= w_minigun_release,
	.crosshair	= w_minigun_hud,
	.precache	= w_minigun_precache,
	.pickup		= w_minigun_pickup,
	.updateammo	= w_minigun_updateammo,
	.wmodel		= w_minigun_wmodel,
	.pmodel		= w_minigun_pmodel,
	.deathmsg	= w_minigun_deathmsg,
	.aimanim	= w_minigun_aimanim,
	.hudpic		= w_minigun_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_minigun(void)
{
	Weapons_InitItem(WEAPON_MINIGUN);
}
#endif
