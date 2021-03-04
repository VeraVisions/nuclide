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
	CML_IDLE1,
	CML_IDLE2,
	CML_IDLE3,
	CML_IDLE4,
	CML_FIRE1,
	CML_RELOAD,
	CML_DRAWBACK,
	CML_UNDRAW,
	CML_DRAW,
	CML_UNUSED,
	CML_HOLSTER
};

void
w_cmlwbr_precache(void)
{
	precache_sound("weapons/cmlwbr_drawback.wav");
	precache_sound("weapons/cmlwbr_fire.wav");
	precache_sound("weapons/cmlwbr_reload.wav");
	precache_sound("weapons/cmlwbr_undraw.wav");
	precache_sound("weapons/cmlwbr_zoom.wav");

	precache_model("models/v_cmlwbr.mdl");
	precache_model("models/w_crossbow.mdl");
}

void
w_cmlwbr_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_cmlwbr_wmodel(void)
{
	return "models/w_crossbow.mdl";
}

void
w_cmlwbr_draw(void)
{
	Weapons_SetModel("models/v_cmlwbr.mdl");
	Weapons_ViewAnimation(CML_DRAW);
}

void
w_cmlwbr_holster(void)
{
	Weapons_ViewAnimation(CML_HOLSTER);
}

void
w_cmlwbr_primary(void)
{
/* TODO, attack slows to crawl & player breathes */
}

void
w_cmlwbr_secondary(void)
{

}


void
w_cmlwbr_release(void)
{

}

void
w_cmlwbr_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/hud640_03.spr_0.tga",
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
			"sprites/hud640_03.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_cmlwbr =
{
	.name		= "cmlwbr",
	.id		= ITEM_CMLWBR,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_cmlwbr_draw,
	.holster	= w_cmlwbr_holster,
	.primary	= w_cmlwbr_primary,
	.secondary	= w_cmlwbr_secondary,
	.reload		= __NULL__,
	.release	= w_cmlwbr_release,
	.crosshair	= __NULL__,
	.precache	= w_cmlwbr_precache,
	.pickup		= __NULL__,
	.updateammo	= w_cmlwbr_updateammo,
	.wmodel		= w_cmlwbr_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_cmlwbr_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_cmlwbr(void)
{
	Weapons_InitItem(WEAPON_CMLWBR);
}
#endif
