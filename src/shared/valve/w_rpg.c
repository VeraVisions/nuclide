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
	RPG_IDLE,
	RPG_FIDGET,
	RPG_RELOAD,
	RPG_FIRE2,
	RPG_HOLSTER1,
	RPG_DRAW1,
	RPG_HOLSTER2,
	RPG_DRAW_UL,
	RPG_IDLE_UL,
	RPG_FIDGET_UL,
};

void w_rpg_precache(void)
{
	precache_model("models/v_rpg.mdl");
	precache_model("models/w_rpg.mdl");
	precache_model("models/p_rpg.mdl");
	precache_model("models/rpgrocket.mdl");
	precache_model("sprites/laserdot.spr");
	precache_sound("weapons/rocketfire1.wav");
}
void w_rpg_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, __NULL__);
#endif
}
string w_rpg_wmodel(void)
{
	return "models/w_rpg.mdl";
}
string w_rpg_pmodel(void)
{
	return "models/p_rpg.mdl";
}
string w_rpg_deathmsg(void)
{
	return "";
}

void w_rpg_pickup(void)
{
#ifdef SSQC
	player pl = (player)self;
	pl.rpg_mag = bound(0, pl.rpg_mag + 1, 1);
#endif
}

void w_rpg_draw(void)
{
	Weapons_SetModel("models/v_rpg.mdl");
	Weapons_ViewAnimation(RPG_DRAW1);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, __NULL__);
#endif
}

void w_rpg_holster(void)
{
	
}
void w_rpg_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0) {
		return;
	}
#else
	if (pl.rpg_mag <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(RPG_FIRE2);

#ifdef CSQC
	pl.a_ammo1--;
#else
	static void Rocket_Touch(void) {
		Effect_CreateExplosion(self.origin);
		Damage_Radius(self.origin, self.owner, 150, 150 * 2.5f, TRUE);
		sound(self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
		remove(self);
	}
	static void Rocket_BuildSpeed(void){
		/* Calculate new direction */
		makevectors(self.owner.v_angle);
		traceline(self.owner.origin, self.owner.origin + v_forward * 8096, FALSE, self.owner);
		self.angles = vectoangles(trace_endpos - self.origin);

		/* Increase speed towards it */
		makevectors(self.angles);
		self.velocity += (v_forward * 2000) * frametime;
		self.nextthink = time;
	}

	Weapons_MakeVectors();
	entity rocket = spawn();
	setmodel(rocket, "models/rpgrocket.mdl");
	setorigin(rocket, Weapons_GetCameraPos() + (v_forward * 16));
	rocket.owner = self;
	rocket.movetype = MOVETYPE_FLY;
	rocket.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	rocket.gravity = 0.5f;
	rocket.velocity = (v_forward * 250);
	rocket.angles = vectoangles(rocket.velocity);
	rocket.avelocity[2] = 10;
	rocket.touch = Rocket_Touch;
	rocket.think = Rocket_BuildSpeed;
	rocket.nextthink = time + 0.15f;
	setsize(rocket, [0,0,0], [0,0,0]);
	sound(self, CHAN_WEAPON, "weapons/rocketfire1.wav", 1, ATTN_NORM);
	pl.rpg_mag--;
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, __NULL__);
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}
void w_rpg_secondary(void)
{
	
}
void w_rpg_reload(void)
{
	player pl = (player)self;
	

	if (pl.w_attack_next > 0) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 >= 1) {
		return;
	}
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.rpg_mag >= 1) {
		return;
	}
	if (pl.ammo_rocket <= 0) {
		return;
	}
#endif

	/* Audio-Visual Bit */
#ifdef SSQC
	Weapons_ReloadWeapon(pl, player::rpg_mag, player::ammo_rocket, 1);
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, __NULL__);
#endif
	Weapons_ViewAnimation(RPG_RELOAD);	

	pl.w_attack_next = 2.25f;
	pl.w_idle_next = 10.0f;
}
void w_rpg_release(void)
{
	
}

float w_rpg_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMRPG : ANIM_AIMRPG;
}

void w_rpg_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

void w_rpg_laser(void)
{
#ifdef CSQC
	player pl = (player)self;

	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 8192), FALSE, pl);

	/*makevectors(vectoangles(trace_endpos - pl.origin));
	vector forg = trace_endpos + (v_forward * -16);
	vector fsize = [64, 64];
	
	makevectors(view_angles);
	R_BeginPolygon("sprites/640hud7.spr_0.tga", 1, 0);
	R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1], [1,1], [1,1,1], 1.0f);
	R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1], [0,1], [1,1,1], 1.0f);
	R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1], [0,0], [1,1,1], 1.0f);
	R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1], [1,0], [1,1,1], 1.0f);
	R_EndPolygon();*/
	static vector cross_pos;
	vector lasersize = [8,8] * (1-trace_fraction);
	cross_pos = (video_res / 2) - (lasersize/2);
	drawpic(cross_pos, "sprites/laserdot.spr_0.tga", lasersize, [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [120/256,72/128], [24/256, 24/128], g_hud_color, 1, DRAWFLAG_ADDITIVE);
#endif
}

weapon_t w_rpg =
{
	ITEM_RPG,
	3,
	0,
	w_rpg_draw,
	w_rpg_holster,
	w_rpg_primary,
	w_rpg_secondary,
	w_rpg_reload,
	w_rpg_release,
	w_rpg_laser,
	w_rpg_precache,
	w_rpg_pickup,
	w_rpg_updateammo,
	w_rpg_wmodel,
	w_rpg_pmodel,
	w_rpg_deathmsg,
	w_rpg_aimanim,
	w_rpg_hudpic
};

#ifdef SSQC
void weapon_rpg(void) {
	Weapons_InitItem(WEAPON_RPG);
}
#endif

