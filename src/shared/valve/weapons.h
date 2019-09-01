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
	void(player) updateammo;
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
void Decals_PlaceSmall(vector);
void Decals_PlaceBig(vector);
void Weapons_MakeVectors(void);
vector Weapons_GetCameraPos(void);
void Weapons_ViewAnimation(int);
void Weapons_ViewPunchAngle(vector);
void Weapons_PlaySound(entity, float, string, float, float);
int Weapons_IsPresent(player, int);
void Weapons_SetModel(string);
#ifdef SSQC
void Weapons_RefreshAmmo(player);
void Weapons_InitItem(int);
float Weapons_GetAim(int);
void Weapons_AddItem(player, int);
void Weapons_RemoveItem(player, int);
string Weapons_GetWorldmodel(int);
void Weapons_UpdateAmmo(player, int, int, int);
void Weapons_ReloadWeapon(player, .int, .int, int);
#else
string Weapons_GetPlayermodel(int);
int Weapons_GetAnimation(void);
void Weapons_HUDPic(int, int, vector);
#endif
