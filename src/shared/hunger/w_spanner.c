/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 * Copyright (c) 2019 Gethyn ThomasQuail <xylemon@posteo.net>
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
	SPAN_IDLE,
	SPAN_ATTACK1,
	SPAN_ATTACK2,
	SPAN_UNUSED,
	SPAN_DRAW,
	SPAN_HOLSTER
};

void
w_spanner_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_tfc_spanner.mdl");
	precache_model("models/backpack.mdl");
	precache_model("models/p_spanner.mdl");
}

void
w_spanner_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_spanner_wmodel(void)
{
	return "models/backpack.mdl";
}
string
w_spanner_pmodel(void)
{
	return "models/p_spanner.mdl";
}

string
w_spanner_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void
w_spanner_draw(void)
{
	Weapons_SetModel("models/v_tfc_spanner.mdl");
	Weapons_ViewAnimation(SPAN_DRAW);
}

void
w_spanner_holster(void)
{
	Weapons_ViewAnimation(SPAN_HOLSTER);
}

void
w_spanner_primary(void)
{
	int anim = 0;
	int r;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.375f;
	} else {
		pl.w_attack_next = 0.20f;
	}
	pl.w_idle_next = 2.5f;

#ifdef CSQC

	if (random() < 0.5) {
		Weapons_ViewAnimation(SPAN_ATTACK1);
		} else {
		Weapons_ViewAnimation(SPAN_ATTACK2);
		}
#else
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
		Damage_Apply(trace_ent, self, 10, WEAPON_SPANNER, DMG_BLUNT );

		if (!trace_ent.iBleeds) {
			return;
		}

		r = floor(random(0,3));
		switch (r) {
		case 0:
			sound(pl, 8, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
			break;
		case 1:
			sound(pl, 8, "weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
			break;
		case 2:
			sound(pl, 8, "weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
			break;
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
w_spanner_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(SPAN_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_spanner_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_spanner_hudpic(int selected, vector pos)
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

weapon_t w_spanner =
{
	.id		= ITEM_SPANNER,
	.slot		= 0,
	.slot_pos	= 2,
	.ki_spr		= "sprites/tfc_dmsg.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,48],
	.draw		= w_spanner_draw,
	.holster	= w_spanner_holster,
	.primary	= w_spanner_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_spanner_release,
	.crosshair	= __NULL__,
	.precache	= w_spanner_precache,
	.pickup		= __NULL__,
	.updateammo	= w_spanner_updateammo,
	.wmodel		= w_spanner_wmodel,
	.pmodel		= w_spanner_pmodel,
	.deathmsg	= w_spanner_deathmsg,
	.aimanim	= w_spanner_aimanim,
	.hudpic		= w_spanner_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_th_spanner(void)
{
	Weapons_InitItem(WEAPON_SPANNER);
}
#endif
