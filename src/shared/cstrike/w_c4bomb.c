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

/*QUAKED weapon_c4bomb (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_c4.mdl"

COUNTER-STRIKE (1999) ENTITY

C4 Bomb Weapon, Bomb Defusal Gamemode Entity

Default arsenal for Terrorists

Can only be picked up by Terrorists and planted in
func_bombtarget brush entities.

*/

enum {
	C4_IDLE,
	C4_DRAW,
	C4_DROP,
	C4_ENTERCODE
};

enum {
	C4S_NONE,
	C4S_ENTERINGCODE,
	C4S_DROPPING,
	C4S_DONE
};

void
w_c4bomb_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_c4bomb.disarm");
	Sound_Precache("weapon_c4bomb.disarmed");
	Sound_Precache("weapon_c4bomb.explode");
	Sound_Precache("weapon_c4bomb.plant");
#endif
	precache_model("models/v_c4.mdl");
	precache_model("models/w_c4.mdl");
	precache_model("models/p_c4.mdl");
}

void
w_c4bomb_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.a_ammo1, pl.a_ammo2, pl.a_ammo3);
#endif
}

string
w_c4bomb_wmodel(void)
{
	return "models/w_c4.mdl";
}

string
w_c4bomb_pmodel(void)
{
	return "models/p_c4.mdl";
}

string
w_c4bomb_deathmsg(void)
{
	return "";
}

void
w_c4bomb_draw(void)
{
	Weapons_SetModel("models/v_c4.mdl");
	Weapons_ViewAnimation(C4_DRAW);
}

void
w_c4bomb_release(void)
{
	player pl = (player)self;
	
	if (pl.a_ammo1 == C4S_DROPPING) {
		if (pl.w_idle_next <= 0.0f) {
			pl.a_ammo1 = C4S_DONE;
#ifdef SSQC
			Weapons_RemoveItem(pl, WEAPON_C4BOMB);
#endif
		}
		return;
	}

	/* reset animation */
	if (pl.a_ammo1 != C4S_NONE) {
		Weapons_ViewAnimation(C4_IDLE);
	}
	pl.a_ammo1 = C4S_NONE;
	pl.w_idle_next = 0.0f;
	pl.flags &= ~FL_FROZEN;
}

void
w_c4bomb_primary(void)
{
	player pl = (player)self;
	
	pl.flags |= FL_FROZEN;

	switch (pl.a_ammo1) {
	case C4S_NONE:
			pl.a_ammo1 = C4S_ENTERINGCODE;
			Weapons_ViewAnimation(C4_ENTERCODE);
			pl.w_idle_next = 3.0f;
			break;
	case C4S_ENTERINGCODE:
			if (pl.w_idle_next <= 0.0f) {
				pl.a_ammo1 = C4S_DROPPING;
				Weapons_ViewAnimation(C4_DROP);
				pl.w_idle_next = 1.0f;
			}
			break;
	case C4S_DROPPING:
			w_c4bomb_release();
			break;
	default:
		break;
	}

	pl.w_attack_next = 0.0f;
}

float
w_c4bomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_c4bomb_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,96/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_c4bomb_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
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
			"sprites/640hud1.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_c4bomb =
{
	ITEM_C4BOMB,
	4,
	0,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_c4bomb_draw,
	__NULL__,
	w_c4bomb_primary,
	__NULL__,
	__NULL__,
	w_c4bomb_release,
	w_c4bomb_hud,
	w_c4bomb_precache,
	__NULL__,
	w_c4bomb_updateammo,
	w_c4bomb_wmodel,
	w_c4bomb_pmodel,
	w_c4bomb_deathmsg,
	w_c4bomb_aimanim,
	w_c4bomb_hudpic
};

#ifdef SSQC
void
weapon_c4bomb(void)
{
	Weapons_InitItem(WEAPON_C4BOMB);
}
#endif
