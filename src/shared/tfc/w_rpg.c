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
w_rpg_precache(void)
{
	precache_model("models/v_tfc_rpg.mdl");
	precache_model("models/w_rpg.mdl");
	precache_model("models/p_rpg.mdl");
}

void
w_rpg_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_rpg_wmodel(void)
{
	return "models/w_rpg.mdl";
}
string
w_rpg_pmodel(void)
{
	return "models/p_rpg.mdl";
}

string
w_rpg_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_rpg_draw(void)
{
	Weapons_SetModel("models/v_tfc_rpg.mdl");
	Weapons_ViewAnimation(0);
}

float
w_rpg_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_rpg_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_rpg =
{
	.id		= ITEM_RPG,
	.slot		= 4,
	.slot_pos	= 0,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,96],
	.draw		= w_rpg_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_rpg_precache,
	.pickup		= __NULL__,
	.updateammo	= w_rpg_updateammo,
	.wmodel		= w_rpg_wmodel,
	.pmodel		= w_rpg_pmodel,
	.deathmsg	= w_rpg_deathmsg,
	.aimanim	= w_rpg_aimanim,
	.hudpic		= w_rpg_hudpic
};
