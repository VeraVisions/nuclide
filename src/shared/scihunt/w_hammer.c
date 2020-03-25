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
	HAMMER_IDLE1,
	HAMMER_DRAW,
	HAMMER_HOLSTER,
	HAMMER_ATTACK1,
	HAMMER_ATTACK2,
	HAMMER_IDLE2,
	HAMMER_IDLE3,
	HAMMER_HOLSTER2,
	HAMMER_HOLSTER3
};

void w_hammer_precache(void)
{
	precache_sound("sh/ham_hitbod1.wav");
	precache_sound("sh/ham_hitbod2.wav");
	precache_sound("sh/ham_hitbod3.wav");
	precache_sound("sh/ham_hitw.wav");
	precache_sound("sh/ham_swing.wav");
	precache_model("models/p_hammer.mdl");
	precache_model("models/v_hammer.mdl");
}

void w_hammer_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}
string w_hammer_pmodel(void)
{
	return "models/p_hammer.mdl";
}
string w_hammer_deathmsg(void)
{
	return "%s killed %s with hammer.";
}

void w_hammer_draw(void)
{
	Weapons_SetModel("models/v_hammer.mdl");
	Weapons_ViewAnimation(HAMMER_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

void w_hammer_holster(void)
{
	Weapons_ViewAnimation(HAMMER_HOLSTER);
}
void w_hammer_primary(void)
{
	player pl = (player)self;

	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.a_ammo1 != 1) {
			Weapons_ViewAnimation(HAMMER_HOLSTER2);
			pl.a_ammo1 = 1;
			pl.w_attack_next = 0.5f;
		}
	}
	pl.w_idle_next = 2.5f;
}
void w_hammer_secondary(void)
{
	player pl = (player)self;

	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.a_ammo1 != 2) {
			Weapons_ViewAnimation(HAMMER_HOLSTER3);
			pl.a_ammo1 = 2;
			pl.w_attack_next = 0.5f;
		}
	}
	pl.w_idle_next = 2.5f;
}
void w_hammer_reload(void)
{
	
}
void w_hammer_release(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

#ifdef SSQC
	int hitsound = 0;
	vector src = pl.origin + pl.view_ofs;
	makevectors(pl.v_angle);
	traceline(src, src + v_forward * 64, FALSE, self);
#endif

	if (pl.a_ammo1 == 1) {
	#ifdef SSQC
		if (trace_ent.takedamage) {
			hitsound = floor(random(1, 4));
    
			if (trace_ent.classname == "player")
				Damage_Apply(trace_ent, self, 50, WEAPON_HAMMER, DMG_BLUNT);
			else
				Damage_Apply(trace_ent, self, 100, WEAPON_HAMMER, DMG_BLUNT);

			if (trace_ent.classname == "monster_scientist") {
				trace_ent.movetype = MOVETYPE_TOSS;
				trace_ent.velocity = v_forward * 768 + v_up * 256;
			} else if (trace_ent.classname == "player") {
				trace_ent.velocity = v_forward * 768 + v_up * 256;
			}
		} else {
			if (trace_fraction < 1.0) {
				hitsound = 4;
			}
		}
	#endif
		Weapons_ViewAnimation(HAMMER_ATTACK1);
		pl.w_attack_next = 1.0f;
	} else if (pl.a_ammo1 == 2) {
#ifdef SSQC
	if (trace_ent.takedamage) {
		hitsound = floor(random(1, 4));
		Damage_Apply(trace_ent, self, 200, WEAPON_HAMMER, DMG_BLUNT);
	} else {
		if (trace_fraction < 1.0) {
			hitsound = 4;
		}   
	}
#endif
		Weapons_ViewAnimation(HAMMER_ATTACK2);
		pl.w_attack_next = 0.75f;
	}

#ifdef SSQC
	if (pl.a_ammo1 > 0) {
		string snd = "sh/ham_swing.wav";
		switch (hitsound) {
		case 1:
			snd = "sh/ham_hitbod1.wav";
			break;
		case 2:
			snd = "sh/ham_hitbod2.wav";
			break;
		case 3:
			snd = "sh/ham_hitbod3.wav";
			break;
		case 4:
			snd = "sh/ham_hitw.wav";
			break;
		}
		Weapons_PlaySound(pl, CHAN_WEAPON, snd, 1.0f, ATTN_NORM);
	}
#endif

	/* Reset the hack */
	pl.a_ammo1 = 0;

	/* Pure cosmetics start here */
	if (pl.w_idle_next) {
		return;
	}

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(HAMMER_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(HAMMER_IDLE2);
		break;
	case 2:
		Weapons_ViewAnimation(HAMMER_IDLE3);
		break;
	}
	pl.w_idle_next = 10.0f;
}

float w_hammer_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void w_hammer_hudpic(int s, vector pos, float a)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/hammer.spr_0.tga", [0,48/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/hammer.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_hammer =
{
	.id		= ITEM_HAMMER,
	.slot		= 0,
	.slot_pos	= 1,
	.ki_spr		= "sprites/hammer.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_hammer_draw,
	.holster	= w_hammer_holster,
	.primary	= w_hammer_primary,
	.secondary	= w_hammer_secondary,
	.reload		= w_hammer_reload,
	.release	= w_hammer_release,
	.crosshair	= __NULL__,
	.precache	= w_hammer_precache,
	.pickup		= __NULL__,
	.updateammo	= w_hammer_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= w_hammer_pmodel,
	.deathmsg	= w_hammer_deathmsg,
	.aimanim	= w_hammer_aimanim,
	.hudpic		= w_hammer_hudpic
};
