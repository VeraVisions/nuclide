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
	PIPE_IDLE1,
	PIPE_IDLE2,
	PIPE_IDLE3,
	PIPE_DRAW,
	PIPE_HOLSTER,
	PIPE_ATTACK1HIT,
	PIPE_ATTACK1MISS,
	PIPE_ATTACK2HIT,
	PIPE_ATTACK2MISS,
	PIPE_ATTACK3HIT,
	PIPE_ATTACK3MISS,
	PIPE_ATTACKBIGWIND,
	PIPE_ATTACKBIGHIT,
	PIPE_ATTACKBIGMISS,
	PIPE_ATTACKBIGLOOP
};

void
w_pipewrench_precache(void)
{
	precache_sound("weapons/pwrench_big_miss.wav");
	precache_sound("weapons/pwrench_big_hit1.wav");
	precache_sound("weapons/pwrench_big_hit2.wav");
	precache_sound("weapons/pwrench_big_hitbod1.wav");
	precache_sound("weapons/pwrench_big_hitbod2.wav");
	precache_sound("weapons/pwrench_miss1.wav");
	precache_sound("weapons/pwrench_miss2.wav");
	precache_sound("weapons/pwrench_hit1.wav");
	precache_sound("weapons/pwrench_hit2.wav");
	precache_sound("weapons/pwrench_hitbod1.wav");
	precache_sound("weapons/pwrench_hitbod2.wav");
	precache_sound("weapons/pwrench_hitbod3.wav");
	precache_model("models/v_pipe_wrench.mdl");
	precache_model("models/w_pipe_wrench.mdl");
	precache_model("models/p_pipe_wrench.mdl");
}

void
w_pipewrench_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_pipewrench_wmodel(void)
{
	return "models/w_pipe_wrench.mdl";
}

string
w_pipewrench_pmodel(void)
{
	return "models/p_pipe_wrench.mdl";
}

string
w_pipewrench_deathmsg(void)
{
	return "%s was assaulted by %s's Pipewrench.";
}

void
w_pipewrench_draw(void)
{
	Weapons_SetModel("models/v_pipe_wrench.mdl");
	Weapons_ViewAnimation(PIPE_DRAW);
}

void
w_pipewrench_holster(void)
{
	Weapons_ViewAnimation(PIPE_HOLSTER);
}

void
w_pipewrench_primary(void)
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

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.9f;
	} else {
		pl.w_attack_next = 0.7f;
	}
	pl.w_idle_next = 2.5f;

#ifdef CSQC
	int r = floor(random(0,3));
	switch (r) {
	case 0:
		anim = trace_fraction >= 1 ? PIPE_ATTACK1MISS:PIPE_ATTACK1HIT;
		break;
	case 1:
		anim = trace_fraction >= 1 ? PIPE_ATTACK2MISS:PIPE_ATTACK2HIT;
		break;
	default:
		anim = trace_fraction >= 1 ? PIPE_ATTACK3MISS:PIPE_ATTACK3HIT;
	}
	Weapons_ViewAnimation(anim);
#else
	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTopTemp(ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTopTemp(ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

	sound(pl, CHAN_WEAPON, "weapons/pwrench_miss1.wav", 1, ATTN_NORM);

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
			sound(pl, 8, "weapons/pwrench_hitbod1.wav", 1, ATTN_NORM);
		} else if (random() < 0.66) {
			sound(pl, 8, "weapons/pwrench_hitbod2.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/pwrench_hitbod3.wav", 1, ATTN_NORM);
		}
	} else {
		if (random() < 0.5) {
			sound(pl, 8, "weapons/pwrench_hit1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/pwrench_hit2.wav", 1, ATTN_NORM);
		}
	}
#endif
}

void
w_pipewrench_secondary(void)
{
	player pl = (player)self;

	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.a_ammo1 != 1) {
			Weapons_ViewAnimation(PIPE_ATTACKBIGWIND);
			pl.a_ammo1 = 1;
			pl.w_attack_next = 0.86f;
		}
	}
	pl.w_idle_next = 2.5f;
}

void
w_pipewrench_release(void)
{
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next > 0.0f) {
		return;
	}

	src = pl.origin + pl.view_ofs;
	Weapons_MakeVectors();
	traceline(src, src + v_forward * 64, FALSE, self);

	if (pl.a_ammo1 == 1) {
	#ifdef SSQC
		int hitsound = 0;
		string snd;
	#endif
		if (trace_fraction < 1.0) {
		#ifdef SSQC
			if (trace_ent.takedamage == DAMAGE_YES) {
				hitsound = floor(random(1, 2));
				/* TODO Damage is 45 - 200+ (?) */
				Damage_Apply(trace_ent, self, 200, trace_endpos, FALSE);
			}
 else {
				hitsound = 3;
			}
		#endif
			Weapons_ViewAnimation(PIPE_ATTACKBIGHIT);
			Weapons_ViewPunchAngle([-10,0,0]);
		} else {
			Weapons_ViewAnimation(PIPE_ATTACKBIGMISS);
		}

#ifdef SSQC
		snd = "weapons/pwrench_big_miss.wav";
		switch (hitsound) {
		case 1:
			snd = "weapons/pwrench_big_hitbod1.wav";
			break;
		case 2:
			snd = "weapons/pwrench_big_hitbod2.wav";
			break;
		case 3:
			snd = "weapons/pwrench_big_hit1.wav";
			break;
		}
		Weapons_PlaySound(pl, CHAN_WEAPON, snd, 1.0f, ATTN_NORM);
#endif
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 10.0f;
		pl.a_ammo1 = 0;
	}

	/* Pure cosmetics start here */
	if (pl.w_idle_next) {
		return;
	}

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(PIPE_IDLE1);
		pl.w_idle_next = 2.0f;
		break;
	case 1:
		Weapons_ViewAnimation(PIPE_IDLE2);
		pl.w_idle_next = 3.0f;
		break;
	case 2:
		Weapons_ViewAnimation(PIPE_IDLE3);
		pl.w_idle_next = 3.0f;
		break;
	}
}

float
w_pipewrench_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_pipewrench_hudpic(int selected, vector pos)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,0],
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
			[0,0],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_pipewrench =
{
	.id		= ITEM_PIPEWRENCH,
	.slot		= 0,
	.slot_pos	= 1,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [0,208],
	.draw		= w_pipewrench_draw,
	.holster	= w_pipewrench_holster,
	.primary	= w_pipewrench_primary,
	.secondary	= w_pipewrench_secondary,
	.reload		= __NULL__,
	.release	= w_pipewrench_release,
	.crosshair	= __NULL__,
	.precache	= w_pipewrench_precache,
	.pickup		= __NULL__,
	.updateammo	= w_pipewrench_updateammo,
	.wmodel		= w_pipewrench_wmodel,
	.pmodel		= w_pipewrench_pmodel,
	.deathmsg	= w_pipewrench_deathmsg,
	.aimanim	= w_pipewrench_aimanim,
	.hudpic		= w_pipewrench_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_pipewrench(void)
{
	Weapons_InitItem(WEAPON_PIPEWRENCH);
}
#endif
