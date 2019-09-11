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
	WRENCH_IDLE,
	WRENCH_ATTACK1,
	WRENCH_ATTACK2,
	WRENCH_USE,
	WRENCH_DRAW,
	WRENCH_HOLSTER
};

void
w_wrench_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_tfc_spanner.mdl");
	precache_model("models/p_spanner.mdl");
}

void
w_wrench_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_wrench_wmodel(void)
{
	return "models/ball.mdl";
}
string
w_wrench_pmodel(void)
{
	return "models/p_spanner.mdl";
}

string
w_wrench_deathmsg(void)
{
	return "%s was assaulted by %s's wrench.";
}

void
w_wrench_draw(void)
{
	Weapons_SetModel("models/v_tfc_spanner.mdl");
	Weapons_ViewAnimation(WRENCH_DRAW);
}

void
w_wrench_holster(void)
{
	Weapons_ViewAnimation(WRENCH_HOLSTER);
}

void
w_wrench_primary(void)
{
	int anim = 0;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		anim = WRENCH_ATTACK1;
		break;
	default:
		anim = WRENCH_ATTACK2;
	}
	Weapons_ViewAnimation(anim);

	if (trace_fraction < 1.0) {
		pl.w_attack_next = 0.25f;
	} else {
		pl.w_attack_next = 0.5f;
	}

	pl.w_idle_next = 2.5f;

#ifdef SSQC
	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTopTemp(ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTopTemp(ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

	sound(pl, CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM);

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		Effect_CreateBlood(trace_endpos, [0,0,0]);
	} else {
		Effect_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, self, 10, trace_endpos, FALSE );

		if (!trace_ent.iBleeds) {
			return;
		}

		if (random() < 0.33) {
			sound(pl, 8, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
		} else if (random() < 0.66) {
			sound(pl, 8, "weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
		}
	} else {
		if (random() < 0.5) {
			sound(pl, 8, "weapons/cbar_hit1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/cbar_hit2.wav", 1, ATTN_NORM);
		}
	}
#endif
}

void
w_wrench_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(WRENCH_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_wrench_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_wrench_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
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
			"sprites/tfchud03.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_wrench =
{
	.id		= ITEM_WRENCH,
	.slot		= 0,
	.slot_pos	= 3,
	.ki_spr		= "sprites/tfc_dmsg.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,48],
	.draw		= w_wrench_draw,
	.holster	= w_wrench_holster,
	.primary	= w_wrench_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_wrench_release,
	.crosshair	= __NULL__,
	.precache	= w_wrench_precache,
	.pickup		= __NULL__,
	.updateammo	= w_wrench_updateammo,
	.wmodel		= w_wrench_wmodel,
	.pmodel		= w_wrench_pmodel,
	.deathmsg	= w_wrench_deathmsg,
	.aimanim	= w_wrench_aimanim,
	.hudpic		= w_wrench_hudpic
};
