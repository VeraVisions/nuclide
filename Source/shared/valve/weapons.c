/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef SSQC
void Decals_Init(void);
#endif

weapon_t w_null = {};
weapon_t g_weapons[] = {
	w_null,
	w_crowbar,
	w_glock,
	w_python,
	w_mp5,
	w_shotgun,
	w_crossbow,
	w_rpg,
	w_gauss,
	w_egon,
	w_hornetgun,
	w_handgrenade,
	w_satchel,
	w_tripmine,
	w_snark
};

void Weapons_Init(void)
{
	for (int i = 0; i < g_weapons.length; i++) {
		if (g_weapons[i].precache != __NULL__) {
			g_weapons[i].precache();
		}
	}
	
#ifdef SSQC
	Decals_Init();
#endif
}

void Weapons_Draw(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	pl.w_attack_next = Math_Time() + 0.5f;
	pl.w_idle_next = Math_Time() + 2.5f;

	if (g_weapons[i].draw != __NULL__) {
		g_weapons[i].draw();
	}
}

void Weapons_Holster(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].holster != __NULL__) {
		g_weapons[i].holster();
	}
}

void Weapons_Primary(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].primary != __NULL__) {
		g_weapons[i].primary();
	}
}

void Weapons_Secondary(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].secondary != __NULL__) {
		g_weapons[i].secondary();
	}
}

void Weapons_Reload(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].reload != __NULL__) {
		g_weapons[i].reload();
	}
}

void Weapons_Release(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].release != __NULL__) {
		g_weapons[i].release();
	}
}

void Weapons_DrawCrosshair(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;
	if (g_weapons[i].crosshair != __NULL__) {
		g_weapons[i].crosshair();
	}
}

string Weapons_GetViewmodel(int id)
{
	if (g_weapons[id].vmodel != __NULL__) {
		return g_weapons[id].vmodel();
	}
	
	return "";
}

string Weapons_GetWorldmodel(int id)
{
	if (g_weapons[id].wmodel != __NULL__) {
		return g_weapons[id].wmodel();
	}
	
	return "";
}

string Weapons_GetPlayermodel(int id)
{
	if (g_weapons[id].pmodel != __NULL__) {
		return g_weapons[id].pmodel();
	}
	
	return "";
}

string Weapons_GetDeathmessage(int id)
{
	if (g_weapons[id].deathmsg != __NULL__) {
		return g_weapons[id].deathmsg();
	}
	
	return "";
}

#ifdef CSQC
void Weapons_HUDPic(int id, int s, vector pos)
{
	if (g_weapons[id].hudpic != __NULL__) {
		g_weapons[id].hudpic(s, pos);
	}
}
#endif

void Weapons_MakeVectors(void)
{
#ifdef SSQC
	player pl = (player)self;
	makevectors(pl.v_angle);
#else
	makevectors(view_angles);
#endif
}

void Weapons_ViewAnimation(int i)
{
#ifdef CSQC
	View_PlayAnimation(i);
#else
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EV_VIEWMODEL );
	WriteByte( MSG_MULTICAST, i );
	msg_entity = self;
	multicast( [0,0,0], MULTICAST_ONE );
#endif
}

void Weapons_ViewPunchAngle(vector add)
{
#ifdef CSQC
	View_AddPunchAngle(add);

#endif
}

void Weapons_PlaySound(entity t, float ch, string s, float vol, float at)
{
#ifdef SSQC
	sound(t, ch, s, vol, at);
#endif
}

#ifdef SSQC
entity g_decals;
#define DECALS_MAX 16
void Decals_Init(void)
{
	entity nextdecal = spawn();
	g_decals = nextdecal;
	for ( int i = 0; i <= DECALS_MAX; i++ ) {
		nextdecal.classname = "decal";
		nextdecal.owner = spawn();
		
		if ( i == DECALS_MAX ) {
			nextdecal.owner = g_decals;
		} else {
			nextdecal = nextdecal.owner;
		}
	}
}

entity Decals_Next(void)
{
	entity ret = g_decals;
	g_decals = g_decals.owner;
	return ret;
}
#endif

void Weapons_PlaceDecal(void)
{
#ifdef SSQC
	entity decal = Decals_Next();
	decal.think = infodecal;
	decal.texture = sprintf("{shot%d", floor(random(1,6)));
	decal.nextthink = time /*+ 0.1f*/;
	setorigin(decal, trace_endpos);
#endif
}
void Weapons_PlaceBigDecal(void)
{
#ifdef SSQC
	entity decal = Decals_Next();
	decal.think = infodecal;
	decal.texture = sprintf("{bigshot%d", floor(random(1,6)));
	decal.nextthink = time /*+ 0.1f*/;
	setorigin(decal, trace_endpos);
	Effect_Impact(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
#endif
}

int Weapons_IsPresent(player pl, int w)
{
	if (pl.items & g_weapons[w].id) {
		return TRUE;
	} else {
		return FALSE;
	}
}

#ifdef SSQC
void Weapons_AddItem(player pl, int w)
{
	entity oldself = self;
	self = pl;
	pl.items |= g_weapons[w].id;
	pl.activeweapon = w;

	if (g_weapons[w].pickup != __NULL__) {
		g_weapons[w].pickup();
	}

	Weapons_Draw();
	self = oldself;
}

void Weapons_InitItem(int w)
{
	itemweapon it = (itemweapon)self;
	spawnfunc_itemweapon();
	it.setitem(w);
}

void Weapons_UpdateAmmo(player pl, int a1, int a2, int a3)
{
	/* Networked as bytes, since we don't need more. Clamp to avoid errors */
	pl.a_ammo1 = bound(0, a1, 255);
	pl.a_ammo2 = bound(0, a2, 255);
	pl.a_ammo3 = bound(0, a3, 255);
}

void Weapons_ReloadWeapon(player pl, .int mag, .int ammo, int max)
{
	int iNeed = max - pl.(mag);
	int iHave = pl.(ammo);

	if ( iNeed > iHave ) {
		pl.(mag) += iHave;
		pl.(ammo) = 0;
	} else {
		pl.(mag) += iNeed;
		pl.(ammo) -= iNeed;
	}
} 
#endif



