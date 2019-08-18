/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

typedef struct
{
	int id; /* bitflag id */
	int slot;
	int slot_pos;

	void() draw;
	void() holster;
	void() primary;
	void() secondary;
	void() reload;
	void() release;
	void() crosshair;

	void() precache;
	void() pickup;
	string() vmodel;
	string() wmodel;
	string() pmodel;
	string() deathmsg;
	float() aimanim;
	void(int, vector) hudpic;
} weapon_t;

/* Weapon Indices for the weapon table */
enum
{
	WEAPON_NONE,
	WEAPON_CROWBAR,
	WEAPON_GLOCK,
	WEAPON_PYTHON,
	WEAPON_MP5,
	WEAPON_SHOTGUN,
	WEAPON_CROSSBOW,
	WEAPON_RPG,
	WEAPON_GAUSS,
	WEAPON_EGON,
	WEAPON_HORNETGUN,
	WEAPON_HANDGRENADE,
	WEAPON_SATCHEL,
	WEAPON_TRIPMINE,
	WEAPON_SNARK
};

/* What the weapons do support and stuff */
enum
{
	AMMO_9MM,
	AMMO_357,
	AMMO_BUCKSHOT,
	AMMO_M203_GRENADE,
	AMMO_BOLT,
	AMMO_ROCKET,
	AMMO_URANIUM,
	AMMO_HANDGRENADE,
	AMMO_SATCHEL,
	AMMO_TRIPMINE,
	AMMO_SNARK,
	AMMO_HORNET
};

void Weapons_DrawCrosshair(void);
void Decals_PlaceSmall(vector pos);
void Decals_PlaceBig(vector pos);
void Weapons_MakeVectors(void);
vector Weapons_GetCameraPos(void);
void Weapons_ViewAnimation(int i);
void Weapons_ViewPunchAngle(vector add);
void Weapons_PlaySound(entity t, float ch, string s, float vol, float at);
int Weapons_IsPresent(player pl, int w);

#ifdef SSQC
void Weapons_InitItem(int w);
float Weapons_GetAim(int w);
void Weapons_AddItem(player pl, int w);
void Weapons_RemoveItem(player pl, int w);
string Weapons_GetWorldmodel(int id);
void Weapons_UpdateAmmo(player pl, int a1, int a2, int a3);
void Weapons_ReloadWeapon(player pl, .int mag, .int ammo, int max);
#else
string Weapons_GetPlayermodel(int id);
int Weapons_GetAnimation(void);
void Weapons_HUDPic(int w, int s, vector pos);
#endif
