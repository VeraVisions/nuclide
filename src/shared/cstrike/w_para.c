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

/*QUAKED weapon_m249 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m249.mdl"

COUNTER-STRIKE (1999) ENTITY

FN M249 Para Weapon

- Buy Menu -
Price: $5750

*/

enum
{
	PARA_IDLE,
	PARA_SHOOT1,
	PARA_SHOOT2,
	PARA_RELOAD,
	PARA_DRAW
};

void
w_para_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_para.fire");
#endif
	precache_model("models/v_m249.mdl");
	precache_model("models/w_m249.mdl");
	precache_model("models/p_m249.mdl");
}

void
w_para_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, pl.para_mag, pl.ammo_556mmbox, -1);
#endif
}

string
w_para_wmodel(void)
{
	return "models/w_m249.mdl";
}

string
w_para_pmodel(void)
{
	return "models/p_m249.mdl";
}

string
w_para_deathmsg(void)
{
	return "";
}

int
w_para_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.para_mag = 100;
		else
			pl.para_mag = startammo;
	} else {
		if (pl.ammo_556mmbox < 200) {
			pl.ammo_556mmbox = bound(0, pl.ammo_556mmbox + 100, 200);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_para_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_m249.mdl");
	Weapons_ViewAnimation(PARA_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_para_primary(void)
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
	if (!pl.para_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 175);

#ifdef CLIENT
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 35, [accuracy,accuracy], WEAPON_PARA);
	pl.para_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_PARA, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_SHOOT_PARA, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_para.fire");
#endif

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(SCOUT_SHOOT2);
		break;
	}

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_para_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo1 >= 100) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.para_mag >= 100) {
		return;
	}
	if (!pl.ammo_556mmbox) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::para_mag, player::ammo_556mmbox, 100);
	Weapons_UpdateAmmo(pl, pl.para_mag, pl.ammo_556mmbox, -1);
#endif

	Weapons_ViewAnimation(PARA_RELOAD);
	pl.w_attack_next = 3.0f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_para_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_para_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_para_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud6.spr_0.tga",
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
			"sprites/640hud3.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_para =
{
	"para",
	ITEM_PARA,
	0,
	15,
	TRUE,
	w_para_draw,
	__NULL__,
	w_para_primary,
	__NULL__,
	w_para_reload,
	w_cstrike_weaponrelease,
	w_para_hud,
	w_para_precache,
	w_para_pickup,
	w_para_updateammo,
	w_para_wmodel,
	w_para_pmodel,
	w_para_deathmsg,
	w_para_aimanim,
	w_para_hudpic
};

#ifdef SERVER
void
weapon_para(void)
{
	Weapons_InitItem(WEAPON_PARA);
}
#endif
