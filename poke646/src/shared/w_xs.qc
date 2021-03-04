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
	XS_IDLE1,
	XS_IDLE2,
	XS_IDLE3,
	XS_SPINUP,
	XS_SPIN,
	XS_FIRE1,
	XS_FIRE2,
	XS_HOLSTER,
	XS_DRAW,
	XS_RELOAD
};

void
w_xs_precache(void)
{
	precache_sound("weapons/xs_moan1.wav");
	precache_sound("weapons/xs_moan2.wav");
	precache_sound("weapons/xs_moan3.wav");
	precache_sound("weapons/xs_reload.wav");
	precache_sound("weapons/xs_shot.wav");
	precache_sound("weapons/xs_windup.wav");

	precache_model("models/v_xs.mdl");
	precache_model("models/w_xs.mdl");
}

void
w_xs_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_xs_wmodel(void)
{
	return "models/w_xs.mdl";
}

void
w_xs_draw(void)
{
	Weapons_SetModel("models/v_xs.mdl");
	Weapons_ViewAnimation(XS_DRAW);
}

void
w_xs_holster(void)
{
	Weapons_ViewAnimation(XS_HOLSTER);
}

void
w_xs_primary(void)
{
/* TODO */
}

void
w_xs_secondary(void)
{

/* TODO Charge up, uses ammo similar to gauss */

}


void
w_xs_release(void)
{

}

void
w_xs_hudpic(int selected, vector pos, float a)
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

weapon_t w_xs =
{
	.name		= "xs",
	.id		= ITEM_XS,
	.slot		= 3,
	.slot_pos	= 0,
	.draw		= w_xs_draw,
	.holster	= w_xs_holster,
	.primary	= w_xs_primary,
	.secondary	= w_xs_secondary,
	.reload		= __NULL__,
	.release	= w_xs_release,
	.crosshair	= __NULL__,
	.precache	= w_xs_precache,
	.pickup		= __NULL__,
	.updateammo	= w_xs_updateammo,
	.wmodel		= w_xs_wmodel,
	.pmodel		= __NULL__,
	.deathmsg	= __NULL__,
	.aimanim	= __NULL__,
	.hudpic		= w_xs_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_xs(void)
{
	Weapons_InitItem(WEAPON_XS);
}
#endif
