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
	CBAR_IDLE,
	CBAR_DRAW,
	CBAR_HOLSTER,
	CBAR_ATTACK1HIT,
	CBAR_ATTACK1MISS,
	CBAR_ATTACK2MISS,
	CBAR_ATTACK2HIT,
	CBAR_ATTACK3MISS,
	CBAR_ATTACK3HIT
};

void
w_shovel_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_crowbar.hit");
	Sound_Precache("weapon_crowbar.miss");
	Sound_Precache("weapon_crowbar.hitbody");
#endif
	precache_model("models/v_shovel.mdl");
	precache_model("models/w_shovel.mdl");
	precache_model("models/p_shovel.mdl");
}

void
w_shovel_updateammo(player pl)
{
	w_crowbar_updateammo(pl);
}

string
w_shovel_wmodel(void)
{
	return "models/w_shovel.mdl";
}
string
w_shovel_pmodel(void)
{
	return "models/p_shovel.mdl";
}

string
w_shovel_deathmsg(void)
{
	return "%s was buried by %s's Shovel.";
}

void
w_shovel_draw(void)
{
	Weapons_SetModel("models/v_shovel.mdl");
	Weapons_ViewAnimation(CBAR_DRAW);
}

void
w_shovel_holster(void)
{
	w_crowbar_holster();
}

void
w_shovel_primary(void)
{
	w_crowbar_primary();
}

void
w_shovel_release(void)
{
	w_crowbar_release();
}

float
w_shovel_aimanim(void)
{
	return w_crowbar_aimanim();
}

void
w_shovel_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
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
			"sprites/tfchud03.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_shovel =
{
	.name		= "shovel",
	.id			= ITEM_SHOVEL,
	.slot		= 0,
	.slot_pos	= 1,
	.draw		= w_shovel_draw,
	.holster	= w_shovel_holster,
	.primary	= w_shovel_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_shovel_release,
	.crosshair	= __NULL__,
	.precache	= w_shovel_precache,
	.pickup		= __NULL__,
	.updateammo	= w_shovel_updateammo,
	.wmodel		= w_shovel_wmodel,
	.pmodel		= w_shovel_pmodel,
	.deathmsg	= w_shovel_deathmsg,
	.aimanim	= w_shovel_aimanim,
	.hudpic		= w_shovel_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_th_shovel(void)
{
	Weapons_InitItem(WEAPON_SHOVEL);
}
#endif
