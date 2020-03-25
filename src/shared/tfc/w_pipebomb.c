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

void
w_pipebomb_precache(void)
{
	precache_model("models/v_tfgl.mdl");
	precache_model("models/w_pipebomb.mdl");
	precache_model("models/p_pipebomb.mdl");
}

void
w_pipebomb_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_pipebomb_wmodel(void)
{
	return "models/w_pipebomb.mdl";
}

string
w_pipebomb_pmodel(void)
{
	return "models/p_pipebomb.mdl";
}

string
w_pipebomb_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_pipebomb_draw(void)
{
	Weapons_SetModel("models/v_tfgl.mdl");
	Weapons_ViewAnimation(0);
}

float
w_pipebomb_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_pipebomb_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud02.spr_0.tga",
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
			"sprites/tfchud01.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_pipebomb =
{
	.id		= ITEM_PIPEBOMB,
	.slot		= 4,
	.slot_pos	= 1,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,112],
	.draw		= w_pipebomb_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_pipebomb_precache,
	.pickup		= __NULL__,
	.updateammo	= w_pipebomb_updateammo,
	.wmodel		= w_pipebomb_wmodel,
	.pmodel		= w_pipebomb_pmodel,
	.deathmsg	= w_pipebomb_deathmsg,
	.aimanim	= w_pipebomb_aimanim,
	.hudpic		= w_pipebomb_hudpic
};
