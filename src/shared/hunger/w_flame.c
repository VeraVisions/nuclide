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
	FLAME_IDLE1,
	FLAME_FIDGET1,
	FLAME_ALTFIREON,
	FLAME_ALTFIRECYCLE,
	FLAME_ALTFIREOFF,
	FLAME_FIRE1,
	FLAME_FIRE2,
	FLAME_FIRE3,
	FLAME_FIRE4,
	FLAME_DRAW,
	FLAME_HOLSTER
};

void
w_flame_precache(void)
{
	precache_model("sound/weapons/flmfire2.wav");
	precache_model("sprites/fthrow.spr");
	precache_model("models/v_egon.mdl");
	precache_model("models/w_egon.mdl");
	precache_model("models/p_egon.mdl");
}
void
w_flame_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_gas, __NULL__);
#endif
}
string
w_flame_wmodel(void)
{
	return "models/w_egon.mdl";
}
string
w_flame_pmodel(void)
{
	return "models/p_egon.mdl";
}
string
w_flame_deathmsg(void)
{
	return "";
}

int
w_flame_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_gas < MAX_A_GAS) {
		pl.ammo_gas = bound(0, pl.ammo_gas + 20, MAX_A_GAS);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_flame_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_egon.mdl");
	Weapons_ViewAnimation(FLAME_DRAW);
	pl.w_idle_next = 1.0f;
}

void
w_flame_holster(void)
{
	Weapons_ViewAnimation(FLAME_HOLSTER);
}


#ifdef SSQC
void
Flame_Touch(void) {

	if (other.takedamage != DAMAGE_YES) {
		remove(self);
		return;
	}


	/* anything else that can take damage */
	Damage_Apply(other, self.owner, 40, WEAPON_FLAME, DMG_BURN);

	remove(self);
}
#endif


void w_flame_primary(void)
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
	if (pl.ammo_gas <= 0) {
		return;
	}
#endif

#ifdef CSQC
	if (Weapons_GetAnimation() == FLAME_IDLE1)
		Weapons_ViewAnimation(FLAME_ALTFIREON);
	else if (Weapons_GetAnimation() == FLAME_ALTFIREON)
		Weapons_ViewAnimation(FLAME_ALTFIRECYCLE);
	
	pl.a_ammo2--;
#else

	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/flmfire2.wav", 1, ATTN_NORM);
	Weapons_MakeVectors();
	entity flame = spawn();
	setmodel(flame, "sprites/fthrow.spr");
	setorigin(flame, Weapons_GetCameraPos() + (v_forward * 16));
	flame.owner = self;
	flame.velocity = v_forward * 300;
	flame.movetype = MOVETYPE_FLYMISSILE;
	flame.solid = SOLID_BBOX;
	//flame.flags |= FL_LAGGEDMOVE;
	flame.angles = vectoangles(flame.velocity);
	flame.avelocity[2] = 10;
	flame.touch = Flame_Touch;
	/*frame.think = Flame_Touch;
	flame.nextthink = time + 2.0f;*/
	flame.effects |= EF_BRIGHTLIGHT;
	setsize(flame, [0,0,0], [0,0,0]);
	pl.ammo_gas--;
#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}
void
w_flame_secondary(void)
{
	
}
void
w_flame_reload(void)
{
	
}
void
w_flame_release(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (Weapons_GetAnimation() == FLAME_ALTFIRECYCLE) {
		Weapons_ViewAnimation(FLAME_ALTFIREOFF);
		pl.w_idle_next = 1.0f;
	} else {
		if (pl.w_idle_next > 0.0f) {
			return;
		}
		Weapons_ViewAnimation(FLAME_IDLE1);
	}
#endif	
}
void
w_flame_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = video_mins + (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_flame_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMEGON : ANIM_AIMEGON;
}

void 
w_flame_hudpic(int selected, vector pos)
{
#ifdef CSQC

if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,45/256],
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
			[0,0/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_flame =
{
	.id		= ITEM_FLAME,
	.slot		= 3,
	.slot_pos	= 2,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [32,16],
	.ki_xy		= [0,192],
	.draw		= w_flame_draw,
	.holster	= __NULL__,
	.primary	= w_flame_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_flame_release,
	.crosshair	= w_flame_crosshair,
	.precache	= w_flame_precache,
	.pickup		= w_flame_pickup,
	.updateammo	= w_flame_updateammo,
	.wmodel		= w_flame_wmodel,
	.pmodel		= w_flame_pmodel,
	.deathmsg	= w_flame_deathmsg,
	.aimanim	= w_flame_aimanim,
	.hudpic		= w_flame_hudpic
};


#ifdef SSQC
void
weapon_egon(void) {
	Weapons_InitItem(WEAPON_FLAME);
}
#endif
