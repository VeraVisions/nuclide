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
w_tranquil_precache(void)
{
	precache_model("models/v_tfc_pistol.mdl");
	precache_model("models/w_tranquil.mdl");
	precache_model("models/p_tranquil.mdl");
}

void
w_tranquil_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_tranquil_wmodel(void)
{
	return "models/w_tranquil.mdl";
}
string
w_tranquil_pmodel(void)
{
	return "models/p_tranquil.mdl";
}

string
w_tranquil_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_tranquil_draw(void)
{
	Weapons_SetModel("models/v_tfc_pistol.mdl");
	Weapons_ViewAnimation(0);
}

float
w_tranquil_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_tranquil_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
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
			"sprites/tfchud06.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_tranquil =
{
	.id		= ITEM_TRANQUIL,
	.slot		= 1,
	.slot_pos	= 2,
	.ki_spr		= "sprites/tfc_dmsg.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,176],
	.draw		= w_tranquil_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_tranquil_precache,
	.pickup		= __NULL__,
	.updateammo	= w_tranquil_updateammo,
	.wmodel		= w_tranquil_wmodel,
	.pmodel		= w_tranquil_pmodel,
	.deathmsg	= w_tranquil_deathmsg,
	.aimanim	= w_tranquil_aimanim,
	.hudpic		= w_tranquil_hudpic
};
