/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_grapple (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_bgrap.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Barnacle Grappling-Hook Weapon

*/

#ifdef CLIENT
/* because some people apparently prefer the worse quality one */
var int autocvar_cl_tonguemode = 0;
#endif

enum
{
	BARN_IDLE1,
	BARN_IDLE2,
	BARN_IDLE3,
	BARN_COUGH,
	BARN_HOLSTER,
	BARN_DRAW,
	BARN_FIRE,
	BARN_FIREWAIT,
	BARN_FIREREACH,
	BARN_FIRETRAVEL,
	BARN_FIRERELEASE
};

void
w_grapple_precache(void)
{
#ifdef SERVER
	precache_sound("weapons/bgrapple_cough.wav");
	precache_sound("weapons/bgrapple_fire.wav");
	precache_sound("weapons/bgrapple_impact.wav");
	precache_sound("weapons/bgrapple_pull.wav");
	precache_sound("weapons/bgrapple_release.wav");
	precache_sound("weapons/bgrapple_wait.wav");
	precache_model("sprites/_tongue.spr");
	precache_model("sprites/tongue.spr");
	precache_model("models/w_bgrap.mdl");
#else
	precache_model("models/v_bgrap.mdl");
	precache_model("models/v_bgrap_tonguetip.mdl");
	precache_model("models/p_bgrap.mdl");
#endif
}

void
w_grapple_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, -1, -1);
}

string
w_grapple_wmodel(void)
{
	return "models/w_bgrap.mdl";
}

string
w_grapple_pmodel(void)
{
	return "models/p_bgrap.mdl";
}

string
w_grapple_deathmsg(void)
{
	return "%s was assaulted by %s's Barnacle.";
}

void
w_grapple_draw(void)
{
	Weapons_SetModel("models/v_bgrap.mdl");
	Weapons_ViewAnimation(BARN_DRAW);
}

void
w_grapple_holster(void)
{
	Weapons_ViewAnimation(BARN_HOLSTER);
}

/* called once the tongue hits a wall */
void Grapple_Touch(void)
{
	player pl = (player)self.owner;
	pl.hook.movetype = MOVETYPE_NONE;
	pl.hook.touch = __NULL__;
	pl.hook.velocity = [0,0,0];
	pl.hook.solid = SOLID_NOT;
	pl.a_ammo1 = 1;
}

#ifdef CLIENT
/* draw the tongue from a to b */
float
grapple_predraw(void)
{
	vector forg = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones);
	vector morg = self.origin;
	vector fsize = [3,3];

	vector col1 = getlight(forg) / 255;
	vector col2 = getlight(morg) / 255;

	makevectors(view_angles);

	R_BeginPolygon(autocvar_cl_tonguemode == 1 ? "sprites/_tongue.spr_0.tga" : "sprites/tongue.spr_0.tga", 0, 0);
		R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
			[1,1], col1, 1.0f);
		R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
			[0,1], col1, 1.0f);
		R_PolygonVertex(morg - v_right * fsize[0] + v_up * fsize[1],
			[0,0], col2, 1.0f);
		R_PolygonVertex(morg + v_right * fsize[0] + v_up * fsize[1],
			[1,0], col2, 1.0f);
	R_EndPolygon();
	addentity(self);
	return PREDRAW_NEXT;
}
#endif

/* spawn and pull */
void
w_grapple_primary(void)
{
	player pl = (player)self;

	if (pl.hook != __NULL__) {
		/* play the looping reel anim once */
		if (pl.a_ammo1 == 1) {
			pl.a_ammo1 = 2;
			Weapons_ViewAnimation(BARN_FIRETRAVEL);
		} else if (pl.a_ammo1 == 2) {
			pl.hook.skin = 1; /* grappled */
		}

		if (pl.w_attack_next > 0.0) {
			return;
		}

#ifdef SERVER
		Weapons_MakeVectors();
		vector src = Weapons_GetCameraPos();
		traceline(src, src + (v_forward * 32), FALSE, pl);
		if (trace_ent.takedamage == DAMAGE_YES && trace_ent.iBleeds) {
			Damage_Apply(trace_ent, pl, 25, WEAPON_GRAPPLE, DMG_GENERIC);
		}
#endif
		pl.w_attack_next = 0.5f;
		return;
	}

	Weapons_MakeVectors();
	pl.hook = spawn();

#ifdef CLIENT
	/*setmodel(pl.hook, "models/v_bgrap_tonguetip.mdl");*/
	pl.hook.drawmask = MASK_ENGINE;
	pl.hook.predraw = grapple_predraw;
#else
	sound(pl, CHAN_WEAPON, "weapons/bgrapple_fire.wav", 1.0, ATTN_NORM);
	sound(pl, CHAN_VOICE, "weapons/bgrapple_pull.wav", 1.0, ATTN_NORM);
#endif
	setorigin(pl.hook, Weapons_GetCameraPos() + (v_forward * 16));
	pl.hook.owner = self;
	pl.hook.velocity = v_forward * 1500;
	pl.hook.movetype = MOVETYPE_FLYMISSILE;
	pl.hook.solid = SOLID_BBOX;
	pl.hook.angles = vectoangles(pl.hook.velocity);
	pl.hook.touch = Grapple_Touch;
	setsize(pl.hook, [0,0,0], [0,0,0]);
	Weapons_ViewAnimation(BARN_FIRE);
}

/* let go, hang */
void
w_grapple_secondary(void)
{
	player pl = (player)self;
	if (pl.hook == __NULL__) {
		return;
	}

	pl.hook.skin = 0; /* ungrappled */
}

/* de-spawn and play idle anims */
void
w_grapple_release(void)
{
	player pl = (player)self;

	if (pl.hook != __NULL__) {
		pl.a_ammo1 = 0; /* cache */
		pl.hook.skin = 0; /* ungrappled */
		remove(pl.hook);
#ifdef CLIENT
		Weapons_ViewAnimation(BARN_FIRERELEASE);
#else
		sound(pl, CHAN_VOICE, "weapons/bgrapple_release.wav", 1.0, ATTN_NORM);
#endif
		pl.w_idle_next = 1.0f;
		pl.hook = __NULL__;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(BARN_IDLE1);
		pl.w_idle_next = 2.566667f;
		break;
	case 2:
		Weapons_ViewAnimation(BARN_IDLE2);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(BARN_IDLE3);
		pl.w_idle_next = 1.35f;
		break;
	}
}

float
w_grapple_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_grapple_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof01.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_grapple =
{
	.name		= "grapple",
	.id		= ITEM_GRAPPLE,
	.slot		= 0,
	.slot_pos	= 3,
	.draw		= w_grapple_draw,
	.holster	= w_grapple_holster,
	.primary	= w_grapple_primary,
	.secondary	= w_grapple_secondary,
	.reload		= __NULL__,
	.release	= w_grapple_release,
	.crosshair	= __NULL__,
	.precache	= w_grapple_precache,
	.pickup		= __NULL__,
	.updateammo	= w_grapple_updateammo,
	.wmodel		= w_grapple_wmodel,
	.pmodel		= w_grapple_pmodel,
	.deathmsg	= w_grapple_deathmsg,
	.aimanim	= w_grapple_aimanim,
	.hudpic		= w_grapple_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_grapple(void)
{
	Weapons_InitItem(WEAPON_GRAPPLE);
}
#endif
