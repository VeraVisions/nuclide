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

enum
{
	DISP_IDLE1,
	DISP_IDLE2,
	DISP_SPINUP,
	DISP_SPIN,
	DISP_FIRE,
	DISP_DRAW,
	DISP_HOLSTER
};

void
w_displacer_precache(void)
{
	precache_sound("weapons/displacer_fire.wav");
	precache_sound("weapons/displacer_impact.wav");
	precache_sound("weapons/displacer_self.wav");
	precache_sound("weapons/displacer_spin.wav");
	precache_sound("weapons/displacer_spin2.wav");
	precache_sound("weapons/displacer_start.wav");
	precache_sound("weapons/displacer_teleport.wav");
	precache_sound("weapons/displacer_teleport_player.wav");
	precache_model("models/v_displacer.mdl");
	precache_model("models/w_displacer.mdl");
	precache_model("models/p_displacer.mdl");
}

void
w_displacer_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_displacer_wmodel(void)
{
	return "models/w_displacer.mdl";
}
string
w_displacer_pmodel(void)
{
	return "models/p_displacer.mdl";
}

string
w_displacer_deathmsg(void)
{
	return "%s was assaulted by %s's Displacer.";
}

void
w_displacer_draw(void)
{
	Weapons_SetModel("models/v_displacer.mdl");
	Weapons_ViewAnimation(DISP_DRAW);
}

void
w_displacer_holster(void)
{
	Weapons_ViewAnimation(DISP_HOLSTER);
}

void
w_displacer_primary(void)
{
/* TODO, 250 damage */
}

void
w_displacer_secondary(void)
{
/* TODO, self teleport */
}

void
w_displacer_release(void)
{

}

float
w_displacer_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_displacer_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof01.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_displacer =
{
	.id		= ITEM_DISPLACER,
	.slot		= 5,
	.slot_pos	= 1,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [48,208],
	.draw		= w_displacer_draw,
	.holster	= w_displacer_holster,
	.primary	= w_displacer_primary,
	.secondary	= w_displacer_secondary,
	.reload		= __NULL__,
	.release	= w_displacer_release,
	.crosshair	= __NULL__,
	.precache	= w_displacer_precache,
	.pickup		= __NULL__,
	.updateammo	= w_displacer_updateammo,
	.wmodel		= w_displacer_wmodel,
	.pmodel		= w_displacer_pmodel,
	.deathmsg	= w_displacer_deathmsg,
	.aimanim	= w_displacer_aimanim,
	.hudpic		= w_displacer_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_displacer(void)
{
	Weapons_InitItem(WEAPON_DISPLACER);
}
#endif
