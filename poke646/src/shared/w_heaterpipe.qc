/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
	HPIPE_IDLE1,
	HPIPE_DRAW,
	HPIPE_HOLSTER,
	HPIPE_ATTACK1,
	HPIPE_ATTACK1MISS,
	HPIPE_ATTACK2MISS,
	HPIPE_ATTACK2,
	HPIPE_ATTACK3MISS,
	HPIPE_ATTACK3
};

void
w_heaterpipe_precache(void)
{
	precache_sound("weapons/pipe_hit1.wav");
	precache_sound("weapons/pipe_hit2.wav");
	precache_sound("weapons/pipe_miss.wav");

	precache_model("models/v_heaterpipe.mdl");
	precache_model("models/w_heaterpipe.mdl");
}

void
w_heaterpipe_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_heaterpipe_wmodel(void)
{
	return "models/w_heaterpipe.mdl";
}

void
w_heaterpipe_draw(void)
{
	Weapons_SetModel("models/v_heaterpipe.mdl");
	Weapons_ViewAnimation(HPIPE_DRAW);
}

void
w_heaterpipe_holster(void)
{
	Weapons_ViewAnimation(HPIPE_HOLSTER);
}

void
w_heaterpipe_primary(void)
{
/* TODO, attack slows to crawl & player breathes */
}

void
w_heaterpipe_release(void)
{

}

void
w_heaterpipe_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/hud640_01.spr_0.tga",
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
			"sprites/hud640_01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_heaterpipe =
{
	.name		= "heaterpipe",
	.id		= ITEM_HEATERPIPE,
	.slot		= 0,
	.slot_pos	= 0,
	.draw		= w_heaterpipe_draw,
	.holster	= w_heaterpipe_holster,
	.primary	= w_heaterpipe_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_heaterpipe_release,
	.crosshair	= __NULL__,
	.precache	= w_heaterpipe_precache,
	.pickup		= __NULL__,
	.updateammo	= w_heaterpipe_updateammo,
	.wmodel		= w_heaterpipe_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_heaterpipe_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_heaterpipe(void)
{
	Weapons_InitItem(WEAPON_HEATERPIPE);
}
#endif
