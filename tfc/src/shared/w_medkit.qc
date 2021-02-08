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
w_medkit_precache(void)
{
	precache_model("models/v_tfc_medkit.mdl");
	precache_model("models/w_medkit.mdl");
	precache_model("models/p_medkit.mdl");
}

void
w_medkit_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_medkit_wmodel(void)
{
	return "models/w_medkit.mdl";
}
string
w_medkit_pmodel(void)
{
	return "models/p_medkit.mdl";
}

string
w_medkit_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_medkit_draw(void)
{
	Weapons_SetModel("models/v_tfc_medkit.mdl");
	Weapons_ViewAnimation(0);
}

float
w_medkit_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_medkit_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud06.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_medkit =
{
	.name		= "medkit",
	.id			= ITEM_MEDKIT,
	.slot		= 0,
	.slot_pos	= 1,
	.draw		= w_medkit_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_medkit_precache,
	.pickup		= __NULL__,
	.updateammo	= w_medkit_updateammo,
	.wmodel		= w_medkit_wmodel,
	.pmodel		= w_medkit_pmodel,
	.deathmsg	= w_medkit_deathmsg,
	.aimanim	= w_medkit_aimanim,
	.hudpic		= w_medkit_hudpic
};
