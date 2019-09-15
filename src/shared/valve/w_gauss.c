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
	GAUSS_IDLE1,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE1,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

void w_gauss_release(void);

void w_gauss_precache(void)
{
	precache_model("models/v_gauss.mdl");
	precache_model("models/w_gauss.mdl");
	precache_model("models/p_gauss.mdl");
	precache_sound("weapons/gauss2.wav");
	precache_model("sprites/yelflare1.spr");
	precache_sound("weapons/electro4.wav");
	precache_sound("weapons/electro5.wav");
	precache_sound("weapons/electro6.wav");
	precache_sound("ambience/pulsemachine.wav");
}
void w_gauss_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_uranium, __NULL__);
#endif
}
string w_gauss_wmodel(void)
{
	return "models/w_gauss.mdl";
}
string w_gauss_pmodel(void)
{
	return "models/p_gauss.mdl";
}
string w_gauss_deathmsg(void)
{
	return "";
}

int w_gauss_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + 20, MAX_A_URANIUM);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_gauss_draw(void)
{
	Weapons_SetModel("models/v_gauss.mdl");
	Weapons_ViewAnimation(GAUSS_DRAW);
}

void w_gauss_holster(void)
{
	Weapons_ViewAnimation(GAUSS_HOLSTER);
}

#ifdef CSQC
void w_gauss_placeorbs(vector org)
{	
	static float glow_think(void) {
		if (self.alpha <= 0.0f) {
			remove(self);
			return PREDRAW_NEXT;
		}
		self.alpha -= (clframetime * 0.25);
		addentity(self);
		return PREDRAW_NEXT;
	}
	entity glow = spawn();
	glow.drawmask = MASK_ENGINE;
	setmodel(glow, "sprites/yelflare1.spr");
	setsize(glow, [0,0,0], [0,0,0]);
	setorigin(glow, org);
	glow.predraw = glow_think;
	glow.effects = EF_ADDITIVE;
	glow.alpha = 1.0f;
	glow.scale = 0.25f;
	glow.colormod = [255, 255, 0] / 255;
	glow.movetype = MOVETYPE_BOUNCE;
	glow.velocity[0] = random() - 0.5;
	glow.velocity[1] = random() - 0.5;
	glow.velocity[2] = random() * 8;
	glow.velocity *= 64;
}
void w_gauss_placeimpact(vector org)
{	
	static float glow_think(void) {
		if (self.alpha <= 0.0f) {
			remove(self);
			return PREDRAW_NEXT;
		}
		self.alpha -= (clframetime * 0.5);
		dynamiclight_add(self.origin, 256 * self.alpha, self.colormod);
		addentity(self);
		return PREDRAW_NEXT;
	}
	entity glow = spawn();
	glow.drawmask = MASK_ENGINE;
	setmodel(glow, "sprites/yelflare1.spr");
	setorigin(glow, org);
	glow.predraw = glow_think;
	glow.effects = EF_ADDITIVE;
	glow.alpha = 1.0f;
	glow.colormod = [255, 200, 0] / 255;
	
	for (int i = 0; i < 3; i++) {
		w_gauss_placeorbs(org);
	}
}
#endif

void w_gauss_fire(int one)
{
	player pl = (player)self;
	int iLoop = 10;

	Weapons_MakeVectors();
	vector src = Weapons_GetCameraPos();
	vector endpos = src + v_forward * 1024;
	traceline(src, endpos, FALSE, pl);
#ifdef SSQC
	sound(pl, CHAN_WEAPON, "weapons/gauss2.wav", 1, ATTN_NORM);
	int iDamage = one ? 20 : 200;

	if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) == "sky") {
		return;
	}

	if (trace_ent.takedamage == DAMAGE_YES) {
		Damage_Apply(trace_ent, self, iDamage, trace_endpos, FALSE);
		sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
	}
#else
	te_beam(world, gettaginfo(pSeat->eViewModel, 33), trace_endpos);

	if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) != "sky") {
		w_gauss_placeimpact(trace_endpos);
	} else {
		return;
	}
#endif
	if (one) {
		return;
	} else {
		/* Apply force */
		if (pl.flags & FL_ONGROUND) {
			pl.velocity += v_forward * -400;
		} else {	
			pl.velocity += v_forward * -800;
		}
	}

	// reflection equation:
	vector dir = v_forward;
	while (iLoop > 0) {
		float n;
		vector r;
		n = -dotproduct(trace_plane_normal, dir);
		r = 2 * trace_plane_normal * n + dir;
		dir = r;
		src = trace_endpos + (dir * 1);
		endpos = trace_endpos + (dir * 8192);
		traceline(src, endpos, FALSE, pl);
		te_beam(world, src, trace_endpos);
		iLoop--;
#ifdef SSQC
		if (trace_ent.takedamage == DAMAGE_YES) {
			Damage_Apply(trace_ent, self, iDamage, trace_endpos, FALSE);
			sound(trace_ent, CHAN_ITEM, sprintf("weapons/electro%d.wav", random(0,3)+4), 1, ATTN_NORM);
		}
		
		if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) != "sky") {
			Decals_PlaceGauss(trace_endpos);
		} else {
			break;
		}
#else
		if (getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos)) != "sky") {
			te_beam(world, src, trace_endpos);
			w_gauss_placeimpact(trace_endpos);
		} else {
			break;
		}
#endif
	}

}

void w_gauss_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 < 2) {
		return;
	}
#else
	if (pl.ammo_uranium < 2) {
		return;
	}
#endif

	Weapons_ViewAnimation(GAUSS_FIRE2);
#ifdef CSQC
	pl.a_ammo2 -= 2;
#else
	pl.ammo_uranium -= 2;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_uranium, __NULL__);	
#endif
	w_gauss_fire(1);

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}
void w_gauss_secondary(void)
{
	player pl = (player)self;

#ifdef CSQC
	if (pl.a_ammo3)
		soundupdate(pl, CHAN_WEAPON, "", 2, ATTN_NORM, 100 + (200 * (pl.a_ammo1/255)), 0, 0);
#endif
	
	if (pl.w_attack_next) {
		return;
	}
	pl.w_attack_next = 0.1f;

	/* Ammo check */
#ifdef CSQC
    if (pl.a_ammo2 <= 0) {
        if (pl.a_ammo3 > 0) {
			w_gauss_release();
		}
		return;
    }
#else
    if (pl.ammo_uranium <= 0) {
        if (pl.a_ammo3 > 0) {
            w_gauss_release();
        }
		return;
    }
#endif

#ifdef CSQC
	if (pl.a_ammo1 < 255)
		pl.a_ammo2--;
#else
	if (pl.a_ammo1 < 255)
		pl.ammo_uranium--;
	Weapons_UpdateAmmo(pl, pl.a_ammo1, pl.ammo_uranium, pl.a_ammo3);
#endif
	
	/* Set pitch sound shift */
	pl.a_ammo1 += 16;
	if (pl.a_ammo1 > 255) {
		pl.a_ammo1 = 255;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(GAUSS_SPIN);
		pl.a_ammo3 = 2;
		pl.w_idle_next = 0.0f;
	} else if (!pl.a_ammo3) {
		Weapons_ViewAnimation(GAUSS_SPINUP);
#ifdef CSQC
		sound(pl, CHAN_WEAPON, "ambience/pulsemachine.wav", 2, ATTN_NORM);
#endif
		pl.a_ammo3 = 1;
	}
}

void w_gauss_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	/* Reset the pitch sound shift */
	pl.a_ammo1 = 0;

	if (pl.a_ammo3 == 1) {
		pl.w_attack_next = 0.0f;
		pl.w_idle_next = 4.0f;
		w_gauss_primary();
		pl.a_ammo3 = 0;
		return;
	} else if (pl.a_ammo3 == 2) {
		w_gauss_fire(0);
		Weapons_ViewAnimation(GAUSS_FIRE1);
#ifdef CSQC	 
		soundupdate(pl, CHAN_WEAPON, "", -1, ATTN_NORM, 0, 0, 0);
#endif
		pl.w_attack_next = 1.5f;
		pl.w_idle_next = 4.0f;
		pl.a_ammo3 = 0;
		return;
	}

	int r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(GAUSS_IDLE2);
		pl.w_idle_next = 4.0f;
		break;
#ifndef GEARBOX
	case 2:
		Weapons_ViewAnimation(GAUSS_FIDGET);
		pl.w_idle_next = 3.0f;
		break;
#endif
	default:
		Weapons_ViewAnimation(GAUSS_IDLE1);
		pl.w_idle_next = 4.0f;
		break;
	}
}

void w_gauss_reload(void)
{
	
}

void w_gauss_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_gauss_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMGAUSS : ANIM_AIMGAUSS;
}

void w_gauss_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_gauss =
{
	ITEM_GAUSS,
	3,
	1,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,112],
	w_gauss_draw,
	w_gauss_holster,
	w_gauss_primary,
	w_gauss_secondary,
	w_gauss_reload,
	w_gauss_release,
	w_gauss_crosshair,
	w_gauss_precache,
	w_gauss_pickup,
	w_gauss_updateammo,
	w_gauss_wmodel,
	w_gauss_pmodel,
	w_gauss_deathmsg,
	w_gauss_aimanim,
	w_gauss_hudpic
};

#ifdef SSQC
void weapon_gauss(void) {
	Weapons_InitItem(WEAPON_GAUSS);
}
#endif
