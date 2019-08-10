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

void Weapons_Init(void)
{
	for (int i = 0; i < g_weapons.length; i++) {
		if (g_weapons[i].precache != __NULL__) {
			g_weapons[i].precache();
		}
	}
}

void Weapons_Draw(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;

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

#ifdef SSQC
float Weapons_GetAim(int id)
{
	if (g_weapons[id].aimanim != __NULL__) {
		return g_weapons[id].aimanim();
	}
	
	return 0;
}
#endif

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

vector Weapons_GetCameraPos(void)
{
#ifdef SSQC
	return self.origin + self.view_ofs;
#else
	return pSeat->vPlayerOrigin + self.view_ofs;
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

#ifdef CSQC
int View_GetAnimation(void);
int Weapons_GetAnimation(void)
{
	return View_GetAnimation();
}
#endif

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

int Weapons_IsPresent(player pl, int w)
{
	if (pl.g_items & g_weapons[w].id) {
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
	pl.g_items |= g_weapons[w].id;
	pl.activeweapon = w;

	if (g_weapons[w].pickup != __NULL__) {
		g_weapons[w].pickup();
	}

	Weapons_Draw();
	self = oldself;
}

void Weapons_InitItem(int w)
{
	item_pickup it = (item_pickup)self;
	spawnfunc_item_pickup();
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