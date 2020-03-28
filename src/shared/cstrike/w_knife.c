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
	KNIFE_IDLE,
	KNIFE_RELOAD,
	KNIFE_DRAW,
	KNIFE_SHOOT1,
	KNIFE_SHOOT2,
	KNIFE_SHOOT3
};

void
w_knife_precache(void)
{
	precache_model("models/v_knife.mdl");
	precache_model("models/w_knife.mdl");
	precache_model("models/p_knife.mdl");
}

void
w_knife_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_knife_wmodel(void)
{
	return "models/w_knife.mdl";
}

string
w_knife_pmodel(void)
{
	return "models/p_knife.mdl";
}

string
w_knife_deathmsg(void)
{
	return "";
}

void
w_knife_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_knife.mdl");
	Weapons_ViewAnimation(KNIFE_DRAW);
#endif
}

void
w_knife_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(KNIFE_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(KNIFE_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(KNIFE_SHOOT3);
		break;
	}
#endif

	pl.w_attack_next = 0.0955f;
}

float
w_knife_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_knife_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud11.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud10.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_knife =
{
	ITEM_KNIFE,
	2,
	0,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_knife_draw,
	__NULL__,
	w_knife_primary,
	__NULL__,
	__NULL__,
	__NULL__,
	__NULL__,
	w_knife_precache,
	__NULL__,
	w_knife_updateammo,
	w_knife_wmodel,
	w_knife_pmodel,
	w_knife_deathmsg,
	w_knife_aimanim,
	w_knife_hudpic
};

#ifdef SSQC
void
weapon_knife(void)
{
	Weapons_InitItem(WEAPON_KNIFE);
}
#endif
