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

/*QUAKED weapon_egon (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_egon.mdl"

HALF-LIFE (1998) ENTITY

Egon/Gluon-Gun Weapon

*/

enum
{
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void w_egon_precache(void)
{
	precache_model("models/v_egon.mdl");
	precache_model("models/w_egon.mdl");
	precache_model("models/p_egon.mdl");
}
void w_egon_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_uranium, __NULL__);
#endif
}
string w_egon_wmodel(void)
{
	return "models/w_egon.mdl";
}
string w_egon_pmodel(void)
{
	return "models/p_egon.mdl";
}
string w_egon_deathmsg(void)
{
	return "";
}

int w_egon_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_egon_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_egon.mdl");
	Weapons_ViewAnimation(EGON_DRAW);
	pl.w_idle_next = 1.0f;
}

void w_egon_holster(void)
{
	Weapons_ViewAnimation(EGON_HOLSTER);
}
void w_egon_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CLIENT
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_uranium <= 0) {
		return;
	}
#endif

#ifdef CLIENT
	if (Weapons_GetAnimation() == EGON_IDLE1)
		Weapons_ViewAnimation(EGON_ALTFIREON);
	else if (Weapons_GetAnimation() == EGON_ALTFIREON)
		Weapons_ViewAnimation(EGON_ALTFIRECYCLE);
	
	pl.a_ammo2--;
#else
	Weapons_MakeVectors();
	vector src = Weapons_GetCameraPos();
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);
	Damage_Radius(trace_endpos, pl, 14, 64, TRUE, DMG_ELECTRO);
	pl.ammo_uranium--;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_uranium, __NULL__);
#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}
void w_egon_secondary(void)
{
	w_egon_primary();
}
void w_egon_reload(void)
{
	
}
void w_egon_release(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (Weapons_GetAnimation() == EGON_ALTFIRECYCLE) {
		Weapons_ViewAnimation(EGON_ALTFIREOFF);
		pl.w_idle_next = 1.0f;
	} else {
		if (pl.w_idle_next > 0.0f) {
			return;
		}
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(EGON_FIDGET1);
			pl.w_idle_next = 2.666667f;
		} else {
			Weapons_ViewAnimation(EGON_IDLE1);
			pl.w_idle_next = 2.0f;
		}
	}
#endif	
}
void w_egon_crosshair(void)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_egon_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
}

void w_egon_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_egon =
{
	.name		= "egon",
	.id			= ITEM_EGON,
	.slot		= 3,
	.slot_pos	= 2,
	.draw		= w_egon_draw,
	.holster	= w_egon_holster,
	.primary	= w_egon_primary,
	.secondary	= w_egon_secondary,
	.reload		= w_egon_reload,
	.release	= w_egon_release,
	.crosshair	= w_egon_crosshair,
	.precache	= w_egon_precache,
	.pickup		= w_egon_pickup,
	.updateammo	= w_egon_updateammo,
	.wmodel		= w_egon_wmodel,
	.pmodel		= w_egon_pmodel,
	.deathmsg	= w_egon_deathmsg,
	.aimanim	= w_egon_aimanim,
	.hudpic		= w_egon_hudpic
};

#ifdef SERVER
void weapon_egon(void) {
	Weapons_InitItem(WEAPON_EGON);
}
#endif
