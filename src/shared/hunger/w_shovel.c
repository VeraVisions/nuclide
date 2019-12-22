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
	SHOVEL_IDLE,
	SHOVEL_DRAW,
	SHOVEL_HOLSTER,
	SHOVEL_ATTACK1HIT,
	SHOVEL_ATTACK1MISS,
	SHOVEL_ATTACK2MISS,
	SHOVEL_ATTACK2HIT,
	SHOVEL_ATTACK3MISS,
	SHOVEL_ATTACK3HIT
};

void
w_shovel_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_shovel.mdl");
	precache_model("models/w_shovel.mdl");
	precache_model("models/p_shovel.mdl");
}

void
w_shovel_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_shovel_wmodel(void)
{
	return "models/w_shovel.mdl";
}
string
w_shovel_pmodel(void)
{
	return "models/p_shovel.mdl";
}

string
w_shovel_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void
w_shovel_draw(void)
{
	Weapons_SetModel("models/v_shovel.mdl");
	Weapons_ViewAnimation(SHOVEL_DRAW);
}

void
w_shovel_holster(void)
{
	Weapons_ViewAnimation(SHOVEL_HOLSTER);
}

void
w_shovel_primary(void)
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
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}
	pl.w_idle_next = 2.5f;

#ifdef CSQC
	r = floor(random(0,3));
	switch (r) {
	case 0:
		anim = trace_fraction >= 1 ? SHOVEL_ATTACK1MISS:SHOVEL_ATTACK1HIT;
		break;
	case 1:
		anim = trace_fraction >= 1 ? SHOVEL_ATTACK2MISS:SHOVEL_ATTACK2HIT;
		break;
	default:
		anim = trace_fraction >= 1 ? SHOVEL_ATTACK3MISS:SHOVEL_ATTACK3HIT;
	}
	Weapons_ViewAnimation(anim);
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
		Damage_Apply(trace_ent, self, 10, WEAPON_SHOVEL, DMG_BLUNT );

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
w_shovel_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(SHOVEL_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_shovel_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_shovel_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,135/256],
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
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_shovel =
{
	.id		= ITEM_SHOVEL,
	.slot		= 0,
	.slot_pos	= 1,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_shovel_draw,
	.holster	= w_shovel_holster,
	.primary	= w_shovel_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_shovel_release,
	.crosshair	= __NULL__,
	.precache	= w_shovel_precache,
	.pickup		= __NULL__,
	.updateammo	= w_shovel_updateammo,
	.wmodel		= w_shovel_wmodel,
	.pmodel		= w_shovel_pmodel,
	.deathmsg	= w_shovel_deathmsg,
	.aimanim	= w_shovel_aimanim,
	.hudpic		= w_shovel_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_th_shovel(void)
{
	Weapons_InitItem(WEAPON_SHOVEL);
}
#endif
