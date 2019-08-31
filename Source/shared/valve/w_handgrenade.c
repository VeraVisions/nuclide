/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	HANDGRENADE_IDLE,
	HANDGRENADE_FIDGET,
	HANDGRENADE_PULLPIN,
	HANDGRENADE_THROW1,
	HANDGRENADE_THROW2,
	HANDGRENADE_THROW3,
	HANDGRENADE_HOLSTER,
	HANDGRENADE_DRAW
};

void w_handgrenade_precache(void)
{
	precache_sound("weapons/grenade/land.wav");
	precache_model("models/v_grenade.mdl");
	precache_model("models/w_grenade.mdl");
	precache_model("models/p_grenade.mdl");
}
void w_handgrenade_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_handgrenade, __NULL__);
#endif
}
string w_handgrenade_wmodel(void)
{
	return "models/w_grenade.mdl";
}
string w_handgrenade_pmodel(void)
{
	return "models/p_grenade.mdl";
}
string w_handgrenade_deathmsg(void)
{
	return "";
}

void w_handgrenade_pickup(void)
{
#ifdef SSQC
    player pl = (player)self;
	pl.ammo_handgrenade = bound(0, pl.ammo_handgrenade + 1, 10);
#endif
}


#ifdef SSQC
void w_handgrenade_throw(void)
{
	static void WeaponFrag_Throw_Explode( void )
	{
		Effect_CreateExplosion(self.origin);
		Damage_Radius(self.origin, self.owner, 150, 150 * 2.5f, TRUE);
		sound(self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
		remove(self);
	}
	
	static void WeaponFrag_Throw_Touch( void )
	{
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, self.origin, FALSE);
		}
		sound( self, CHAN_BODY, "weapons/grenade/land.wav", 1, ATTN_NORM );
		self.frame = 0;
	}

	player pl = (player)self;
	vector vPLAngle = pl.v_angle;
	if ( vPLAngle[0] < 0 ) {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 - 10) / 90.0);
	} else {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 + 10) / 90.0);
	}

	float flVel = (90 - vPLAngle[0]) * 5;
	if ( flVel > 1000 ) {
		flVel = 1000;
	}

	makevectors( vPLAngle );
	vector vecSrc = pl.origin + pl.view_ofs + v_forward * 16;
	vector vecThrow = v_forward * flVel + pl.velocity;

	entity eGrenade = spawn();
	eGrenade.owner = pl;
	eGrenade.classname = "remove_me";
	eGrenade.solid = SOLID_BBOX;
	//eGrenade.angles = vectoangles( vDir );
	eGrenade.velocity = vecThrow;
	eGrenade.movetype = MOVETYPE_BOUNCE;
	eGrenade.think = WeaponFrag_Throw_Explode;
	eGrenade.touch = WeaponFrag_Throw_Touch;
	eGrenade.nextthink = time + 4.0f;
	eGrenade.frame = 1;
	setmodel( eGrenade, "models/w_grenade.mdl" );
	eGrenade.frame = 1;
	setorigin( eGrenade, vecSrc );
	setsize( eGrenade, [0,0,0], [0,0,0] );
}
#endif

void w_handgrenade_draw(void)
{
	Weapons_SetModel("models/v_grenade.mdl");
	Weapons_ViewAnimation(HANDGRENADE_DRAW);
#ifdef SSQC
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_handgrenade, __NULL__);
#endif
}

void w_handgrenade_holster(void)
{
	
}
void w_handgrenade_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.a_ammo3 > 0) {
        return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_handgrenade <= 0) {
		return;
	}
#endif

#ifdef CSQC
	Weapons_ViewAnimation(HANDGRENADE_PULLPIN);
#endif
	pl.a_ammo3 = 1;

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 0.5f;
}
void w_handgrenade_secondary(void)
{
	
}
void w_handgrenade_reload(void)
{
	
}

void w_handgrenade_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,96/128], [24/256, 24/128], g_hud_color, 1, DRAWFLAG_ADDITIVE);
#endif
}


void w_handgrenade_release(void)
{
	player pl = (player)self;
	
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
#ifdef CSQC
		pl.a_ammo2--;
		Weapons_ViewAnimation(HANDGRENADE_THROW1);
#else
		pl.ammo_handgrenade--;
		Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_handgrenade, __NULL__);
		w_handgrenade_throw();
#endif
		pl.a_ammo3 = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.a_ammo3 == 2) {
#ifdef CSQC
		//Weapons_ViewAnimation(HANDGRENADE_DRAW);
#else
		if (!pl.ammo_handgrenade) {
			Weapons_RemoveItem(pl, WEAPON_HANDGRENADE);
		}
#endif
		pl.w_idle_next = 0.5f;
		pl.a_ammo3 = 0;
	}
}
float w_handgrenade_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}
void w_handgrenade_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_handgrenade =
{
	ITEM_HANDGRENADE,
	4,
	0,
	w_handgrenade_draw,
	w_handgrenade_holster,
	w_handgrenade_primary,
	w_handgrenade_secondary,
	w_handgrenade_reload,
	w_handgrenade_release,
	w_handgrenade_hud,
	w_handgrenade_precache,
	w_handgrenade_pickup,
	w_handgrenade_updateammo,
	w_handgrenade_wmodel,
	w_handgrenade_pmodel,
	w_handgrenade_deathmsg,
	w_handgrenade_aimanim,
	w_handgrenade_hudpic
};

#ifdef SSQC
void weapon_handgrenade(void) {
	Weapons_InitItem(WEAPON_HANDGRENADE);
}
#endif
