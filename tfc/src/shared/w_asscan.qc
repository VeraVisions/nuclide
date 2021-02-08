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

void
w_asscan_precache(void)
{
	precache_model("models/v_tfac.mdl");
	precache_model("models/w_asscan.mdl");
	precache_model("models/p_asscan.mdl");
}

void
w_asscan_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_asscan_wmodel(void)
{
	return "models/w_asscan.mdl";
}
string
w_asscan_pmodel(void)
{
	return "models/p_asscan.mdl";
}

string
w_asscan_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_asscan_draw(void)
{
	Weapons_SetModel("models/v_tfac.mdl");
	Weapons_ViewAnimation(0);
}

float
w_asscan_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_asscan_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,90/256],
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
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_asscan =
{
	.name		= "asscan",
	.id			= ITEM_ASSCAN,
	.slot		= 4,
	.slot_pos	= 2,
	.draw		= w_asscan_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_asscan_precache,
	.pickup		= __NULL__,
	.updateammo	= w_asscan_updateammo,
	.wmodel		= w_asscan_wmodel,
	.pmodel		= w_asscan_pmodel,
	.deathmsg	= w_asscan_deathmsg,
	.aimanim	= w_asscan_aimanim,
	.hudpic		= w_asscan_hudpic
};
