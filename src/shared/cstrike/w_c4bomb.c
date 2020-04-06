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

enum {
	C4BOMB_IDLE,
	C4BOMB_RELOAD,
	C4BOMB_DRAW,
	C4BOMB_SHOOT1,
	C4BOMB_SHOOT2,
	C4BOMB_SHOOT3
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
	precache_model("models/v_c4bomb.mdl");
	precache_model("models/w_c4bomb.mdl");
	precache_model("models/p_c4bomb.mdl");
}

void
w_c4bomb_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_c4bomb_wmodel(void)
{
	return "models/w_c4bomb.mdl";
}

string
w_c4bomb_pmodel(void)
{
	return "models/p_c4bomb.mdl";
}

string
w_c4bomb_deathmsg(void)
{
	return "";
}

void
w_c4bomb_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_c4bomb.mdl");
	Weapons_ViewAnimation(C4BOMB_DRAW);
#endif
}

void
w_c4bomb_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(C4BOMB_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(C4BOMB_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(C4BOMB_SHOOT3);
		break;
	}
#endif

	pl.w_attack_next = 0.0955f;
}

float
w_c4bomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
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
	__NULL__,
	__NULL__,
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
