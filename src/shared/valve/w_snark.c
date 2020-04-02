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
	SNARK_IDLE,
	SNARK_FIDGET1,
	SNARK_FIDGET2,
	SNARK_HOLSTER,
	SNARK_DRAW,
	SNARK_THROW
};

#ifdef SSQC
class monster_snark:CBaseMonster
{
	void() monster_snark;

	virtual void() customphysics;
	virtual void(int) Death;
	virtual void(int) Pain;
	virtual void() Respawn;
};

void
monster_snark::customphysics(void)
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
		float shortest = 999999;
		for (entity ef = world; (ef = findfloat(ef, ::movetype, MOVETYPE_WALK));) {
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
		Sound_Play(self, CHAN_VOICE, "weapon_snark.hunt");
		input_buttons = 2;
		Damage_Apply(self, world, 1, 0, DMG_GENERIC);
			
		makevectors(self.angles);
		traceline(self.origin, self.origin + (v_forward * 128), 0, self);
			
		if (trace_ent.takedamage == DAMAGE_YES) {
			Sound_Play(self, CHAN_BODY, "weapon_snark.deploy");
			Damage_Apply(trace_ent, self.goalentity, 10, WEAPON_SNARK, DMG_GENERIC);
			Effect_CreateBlood(self.origin + [0,0,16], [1,0,0]);
		}

		if (self.aiment.health <= 0) {
			self.aiment = __NULL__;
		}
	}
	self.weapon -= frametime;	
	runstandardplayerphysics(self);
}

void
monster_snark::Death(int i)
{
	Effect_CreateBlood(self.origin + [0,0,16], [203,183,15] / 255);
	Sound_Play(self, CHAN_VOICE, "weapon_snark.die");
	Sound_Play(self, CHAN_BODY, "weapon_snark.blast");
	self.customphysics = __NULL__;
	remove(self);
}

void
monster_snark::Pain(int i)
{
	
}

void
monster_snark::Respawn(void)
{
	netname = "Snark";
	setmodel(this, "models/w_squeak.mdl");
	flags |= FL_MONSTER;
	solid = SOLID_BBOX;
	movetype = MOVETYPE_WALK;
	frame = 3; /* running like crazy. */
	angles = goalentity.angles;
	health = 20;
	takedamage = DAMAGE_YES;
	aiment = __NULL__;
	weapon = 1.0f;
}

void
monster_snark::monster_snark(void)
{
	Respawn();
}
#endif

int w_snark_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_snark < MAX_A_SNARK) {
		pl.ammo_snark = bound(0, pl.ammo_snark + 5, MAX_A_SNARK);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_snark_draw(void)
{
	Weapons_SetModel("models/v_squeak.mdl");
	Weapons_ViewAnimation(SNARK_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_snark, __NULL__);
#endif
}

void w_snark_holster(void)
{
	
}

#ifdef SSQC
void w_snark_deploy(void)
{
	monster_snark snark = spawn(monster_snark, owner: self, goalentity: self);
	makevectors(self.v_angle);
	setorigin(snark, self.origin + v_forward * 32);
}
#endif

void w_snark_primary(void)
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
	if (pl.ammo_snark <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(SNARK_THROW);

	/* Audio-Visual Bit */
#ifdef CSQC
	pl.a_ammo2--;
#else
	w_snark_deploy();
	pl.ammo_snark--;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_snark, __NULL__);

	if (pl.a_ammo2 <= 0) {
		Weapons_RemoveItem(pl, WEAPON_SNARK);
	}
#endif

	pl.w_idle_next = 1.0f;
	pl.w_attack_next = 0.25f;

}
void w_snark_secondary(void)
{
	
}
void w_snark_reload(void)
{
	
}
void w_snark_release(void)
{
	int r;
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SNARK_IDLE);
		pl.w_idle_next = 1.875f;
		break;
	case 1:
		Weapons_ViewAnimation(SNARK_FIDGET1);
		pl.w_idle_next = 4.375f;
		break;
	default:
		Weapons_ViewAnimation(SNARK_FIDGET2);
		pl.w_idle_next = 5.0f;
		break;
	}
}
void w_snark_precache(void)
{
	precache_model("models/w_squeak.mdl");
	precache_model("models/p_squeak.mdl");
	precache_model("models/v_squeak.mdl");

#ifdef SSQC
	Sound_Precache("weapon_snark.deploy");
	Sound_Precache("weapon_snark.die");
	Sound_Precache("weapon_snark.blast");
	Sound_Precache("weapon_snark.hunt");
#endif
}
void w_snark_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_snark, __NULL__);
#endif
}
string w_snark_wmodel(void)
{
	return "models/w_sqknest.mdl";
}
string w_snark_pmodel(void)
{
	return "models/p_squeak.mdl";
}
string w_snark_deathmsg(void)
{
	return "";
}


float w_snark_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void w_snark_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [96/256,96/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void w_snark_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga",
			[0,135/256], [170/256,45/256],
			g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga",
			[0,135/256], [170/256,45/256],
			g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_snark =
{
	ITEM_SNARK,
	4,
	3,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,208],
	w_snark_draw,
	w_snark_holster,
	w_snark_primary,
	w_snark_secondary,
	w_snark_reload,
	w_snark_release,
	w_snark_hud,
	w_snark_precache,
	w_snark_pickup,
	w_snark_updateammo,
	w_snark_wmodel,
	w_snark_pmodel,
	w_snark_deathmsg,
	w_snark_aimanim,
	w_snark_hudpic
};

#ifdef SSQC
void weapon_snark(void) {
	Weapons_InitItem(WEAPON_SNARK);
}
#endif
