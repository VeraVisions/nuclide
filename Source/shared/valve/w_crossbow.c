/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	CROSSBOW_IDLE1,
	CROSSBOW_IDLE2,
	CROSSBOW_FIDGET1,
	CROSSBOW_FIDGET2,
	CROSSBOW_FIRE1,
	CROSSBOW_FIRE2,
	CROSSBOW_FIRE3,
	CROSSBOW_RELOAD,
	CROSSBOW_DRAW1,
	CROSSBOW_DRAW2,
	CROSSBOW_HOLSTER1,
	CROSSBOW_HOLSTER2
};

void w_crossbow_precache(void)
{
	precache_model("models/crossbow_bolt.mdl");
	precache_model("models/v_crossbow.mdl");
	precache_model("models/w_crossbow.mdl");
	precache_model("models/p_crossbow.mdl");
	precache_sound("weapons/xbow_reload1.wav");
	precache_sound("weapons/xbow_fire1.wav");
	precache_sound("weapons/xbow_hit1.wav");
	precache_sound("weapons/xbow_hitbod1.wav");
	precache_sound("weapons/xbow_hitbod2.wav");
}
string w_crossbow_vmodel(void)
{
	return "models/v_crossbow.mdl";
}
string w_crossbow_wmodel(void)
{
	return "models/w_crossbow.mdl";
}
string w_crossbow_pmodel(void)
{
	return "models/p_crossbow.mdl";
}
string w_crossbow_deathmsg(void)
{
	return "";
}
void w_crossbow_pickup(void)
{
#ifdef SSQC
	player pl = (player)self;
	pl.crossbow_mag = bound(0, pl.crossbow_mag + 5, 5);
#endif
}
void w_crossbow_draw(void)
{
	player pl = (player)self;

#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, __NULL__);
#endif

	if (pl.a_ammo1) {
        Weapons_ViewAnimation(CROSSBOW_DRAW1);
    } else {
        Weapons_ViewAnimation(CROSSBOW_DRAW2);
    }
}

void w_crossbow_holster(void)
{
	player pl = (player)self;
	if (pl.a_ammo1) {
		Weapons_ViewAnimation(CROSSBOW_HOLSTER1);
	} else {
		Weapons_ViewAnimation(CROSSBOW_HOLSTER2);
	}
}
void w_crossbow_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

#ifdef SSQC
	static void Crossbolt_Touch(void) {
		Effect_CreateSpark(self.origin, trace_plane_normal);
		
		if (self.weapon) {
			Effect_CreateExplosion(self.origin);
			Damage_Radius(self.origin, self.owner, 40, 40 * 2.5, TRUE);
			sound(self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
		}
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 50, trace_endpos, FALSE);
			if (random() < 0.5) {
				Weapons_PlaySound(self, CHAN_WEAPON, "weapons/xbow_hitbod1.wav", 1, ATTN_NORM);
			} else {
				Weapons_PlaySound(self, CHAN_WEAPON, "weapons/xbow_hitbod2.wav", 1, ATTN_NORM);
			}
		} else {
			Weapons_PlaySound(self, CHAN_WEAPON, "weapons/xbow_hit1.wav", 1, ATTN_NORM);
		}
		remove(self);
	}
	
	if (!pl.crossbow_mag) {
		return;
	}	
	
	Weapons_MakeVectors();
	entity bolt = spawn();
	setmodel(bolt, "models/crossbow_bolt.mdl");
	setorigin(bolt, Weapons_GetCameraPos() + (v_forward * 16));
	bolt.owner = self;
	bolt.velocity = v_forward * 2000;
	bolt.movetype = MOVETYPE_FLY;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.avelocity[2] = 10;
	bolt.touch = Crossbolt_Touch;
	bolt.weapon = pl.viewzoom == 1.0 ? 1 : 0;
	setsize(bolt, [0,0,0], [0,0,0]);

	if (pl.crossbow_mag) {	
		Weapons_PlaySound(pl, CHAN_ITEM, "weapons/xbow_reload1.wav", 1, ATTN_NORM);
	}

	pl.crossbow_mag--;
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, __NULL__);
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/xbow_fire1.wav", 1, ATTN_NORM);
#else
	Weapons_ViewPunchAngle([-2,0,0]);
#endif
	if (pl.a_ammo1) {
        Weapons_ViewAnimation(CROSSBOW_FIRE1);
    } else {
        Weapons_ViewAnimation(CROSSBOW_FIRE3);
    }
	pl.w_attack_next = 0.75f;
	pl.w_idle_next = 10.0f;
}
void w_crossbow_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}
void w_crossbow_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
#ifdef SSQC
	if (pl.ammo_bolt <= 0) {
		return;
	}
	if (pl.crossbow_mag >= 5) {
		return;
	}
#else
	if (pl.a_ammo1 >= 5) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#endif

#ifdef SSQC
	Weapons_ReloadWeapon(pl, player::crossbow_mag, player::ammo_bolt, 5);
	Weapons_UpdateAmmo(pl, pl.crossbow_mag, pl.ammo_bolt, __NULL__);
#else
	Weapons_PlaySound(pl, CHAN_ITEM, "weapons/xbow_reload1.wav", 1, ATTN_NORM);
#endif
	Weapons_ViewAnimation(CROSSBOW_RELOAD);
	pl.w_attack_next = 4.5f;
	pl.w_idle_next = 10.0f;
}
void w_crossbow_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (random() < 0.75) {
		if (pl.a_ammo1) {
			Weapons_ViewAnimation(CROSSBOW_IDLE1);
		} else {
			Weapons_ViewAnimation(CROSSBOW_IDLE2);
		}
	} else {
		if (pl.a_ammo1) {
			Weapons_ViewAnimation(CROSSBOW_FIDGET1);
		} else {
			Weapons_ViewAnimation(CROSSBOW_FIDGET2);
		}
	}
	pl.w_idle_next = 3.0f;
}
void w_crossbow_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,0], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
#endif
}

float w_crossbow_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMBOW : ANIM_AIMBOW;
}

void w_crossbow_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_crossbow =
{
	ITEM_CROSSBOW,
	2,
	2,
	w_crossbow_draw,
	w_crossbow_holster,
	w_crossbow_primary,
	w_crossbow_secondary,
	w_crossbow_reload,
	w_crossbow_release,
	w_crossbow_crosshair,
	w_crossbow_precache,
	w_crossbow_pickup,
	w_crossbow_vmodel,
	w_crossbow_wmodel,
	w_crossbow_pmodel,
	w_crossbow_deathmsg,
	w_crossbow_aimanim,
	w_crossbow_hudpic
};

#ifdef SSQC
void weapon_crossbow(void) {
	Weapons_InitItem(WEAPON_CROSSBOW);
}
#endif

