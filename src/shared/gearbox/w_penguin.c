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
	PENGUIN_IDLE,
	PENGUIN_FIDGET1,
	PENGUIN_FIDGET2,
	PENGUIN_HOLSTER,
	PENGUIN_DRAW,
	PENGUIN_THROW
};

int
w_penguin_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_penguin < 10) {
		pl.ammo_penguin = bound(0, pl.ammo_penguin + 5, 10);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_penguin_draw(void)
{
	Weapons_SetModel("models/v_penguin.mdl");
	Weapons_ViewAnimation(PENGUIN_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_penguin, __NULL__);
#endif
}

void
w_penguin_holster(void)
{
	
}

#ifdef SSQC
void
penguin_ai(void)
{
	input_movevalues = [250,0,0];
	input_buttons = 0;
	input_impulse = 0;
	input_angles = self.angles;
	input_timelength = frametime;

	if (self.health <= 0) {
		return;
	}

	if (self.weapon <= 0.0 && self.aiment == __NULL__) {
		entity ef;
		float shortest = 999999;
		for (ef = world; (ef = findfloat(ef, movetype, MOVETYPE_WALK));) {
			float len = vlen(ef.origin - self.origin);
			if (ef.classname != "snark" && len < shortest && ef.health > 0) {
				self.owner = __NULL__;
				self.aiment = ef;
				shortest = len;
			}
		}
	} 

	if (self.aiment) {
		self.angles = input_angles = vectoangles(self.aiment.origin - self.origin);
	}

	if (self.aiment && self.weapon <= 0.0) {
		self.weapon = 0.5f + random();
		sound(self, CHAN_VOICE, sprintf("squeek/sqk_hunt%d.wav",floor(random(1,4))), 1.0, ATTN_NORM);
		input_buttons = 2;
		Damage_Apply(self, world, 1, self.origin, TRUE);

		makevectors(self.angles);
		traceline(self.origin, self.origin + (v_forward * 128), 0, self);

		if (trace_ent.takedamage == DAMAGE_YES) {
			float pit = 100 + random(0,10);
			sound(self, CHAN_BODY, "squeek/sqk_deploy1.wav", 1.0, ATTN_NORM, pit);
			Damage_Apply(trace_ent, self, 10, trace_endpos, FALSE);
		}

		if (self.aiment.health <= 0) {
			self.aiment = __NULL__;
		}
	}
	self.weapon -= frametime;
	runstandardplayerphysics(self);
}

void
penguin_die(int i)
{
	Effect_CreateExplosion(self.origin);
	Damage_Radius(self.origin, self.owner, 150, 150 * 2.5f, TRUE);
	sound(self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
	self.customphysics = __NULL__;
	self.vDeath = __NULL__;
	remove(self);
}

void
penguin_pain(int i)
{
	/* add stuff? */
}

void
w_penguin_deploy(void)
{
	entity pingu = spawn();
	pingu.owner = self;
	pingu.netname = "Penguin";
	pingu.classname = "snark"; /* so snarks and pingus don't attack e/o */
	setmodel(pingu, "models/w_penguin.mdl");
	makevectors(self.v_angle);
	setorigin(pingu, self.origin + v_forward * 32);
	pingu.solid = SOLID_BBOX;
	pingu.movetype = MOVETYPE_WALK;
	pingu.frame = 3; /* running like crazy. */
	pingu.customphysics = penguin_ai;
	pingu.angles = self.angles;
	pingu.health = 20;
	pingu.vPain = penguin_pain;
	pingu.takedamage = DAMAGE_YES;
	pingu.aiment = __NULL__;
	pingu.vDeath = penguin_die;
	pingu.weapon = 3.0f;
}
#endif

void
w_penguin_primary(void)
{
	player pl = (player)self;	
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_penguin <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(PENGUIN_THROW);

	/* Audio-Visual Bit */
#ifdef CSQC
	pl.a_ammo2--;
#else
	w_penguin_deploy();
	pl.ammo_penguin--;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_penguin, __NULL__);

	if (pl.a_ammo2 <= 0) {
		Weapons_RemoveItem(pl, WEAPON_SNARK);
	}
#endif

	pl.w_idle_next = 1.0f;
	pl.w_attack_next = 0.25f;

}

void
w_penguin_secondary(void)
{
	
}

void
w_penguin_reload(void)
{
	
}

void
w_penguin_release(void)
{
	int r;
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(PENGUIN_IDLE);
		pl.w_idle_next = 1.875f;
		break;
	case 1:
		Weapons_ViewAnimation(PENGUIN_FIDGET1);
		pl.w_idle_next = 4.375f;
		break;
	default:
		Weapons_ViewAnimation(PENGUIN_FIDGET2);
		pl.w_idle_next = 5.0f;
		break;
	}
}

void
w_penguin_precache(void)
{
	precache_model("models/w_penguin.mdl");
	precache_model("models/p_penguin.mdl");
	precache_model("models/v_penguin.mdl");	
	precache_sound("squeek/sqk_deploy1.wav");
	precache_sound("squeek/sqk_die1.wav");
	precache_sound("squeek/sqk_blast1.wav");
	precache_sound("squeek/sqk_hunt1.wav");
	precache_sound("squeek/sqk_hunt2.wav");
	precache_sound("squeek/sqk_hunt3.wav");
}

void
w_penguin_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_penguin, __NULL__);
#endif
}

string
w_penguin_wmodel(void)
{
	return "models/w_sqknest.mdl";
}

string
w_penguin_pmodel(void)
{
	return "models/p_penguin.mdl";
}

string
w_penguin_deathmsg(void)
{
	return "";
}


float
w_penguin_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_penguin_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,96/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_penguin_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hudof04.spr_0.tga",
			[0,180/256], [170/256,45/256],
			g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hudof03.spr_0.tga",
			[0,180/256], [170/256,45/256],
			g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_penguin =
{
	.id		= ITEM_PENGUIN,
	.slot		= 4,
	.slot_pos	= 4,
	.ki_spr		= "sprites/320hudof01.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [144,224],
	.draw		= w_penguin_draw,
	.holster	= w_penguin_holster,
	.primary	= w_penguin_primary,
	.secondary	= w_penguin_secondary,
	.reload		= w_penguin_reload,
	.release	= w_penguin_release,
	.crosshair	= __NULL__,
	.precache	= w_penguin_precache,
	.pickup		= w_penguin_pickup,
	.updateammo	= w_penguin_updateammo,
	.wmodel		= w_penguin_wmodel,
	.pmodel		= w_penguin_pmodel,
	.deathmsg	= w_penguin_deathmsg,
	.aimanim	= w_penguin_aimanim,
	.hudpic		= w_penguin_hudpic
};
