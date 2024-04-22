/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifndef NEW_INVENTORY
/* for AI identification purposes */
typedef enum
{
	WPNTYPE_INVALID,	/* no logic */
	WPNTYPE_RANGED,		/* will want to keep their distance mostly */
	WPNTYPE_THROW,		/* has to keep some distance, but not too far */
	WPNTYPE_CLOSE,		/* have to get really close */
	WPNTYPE_FULLAUTO,	/* for things that need to be held down */
	WPNTYPE_SEMI		/* semi automatic */
} weapontype_t;

typedef struct
{
	string name;
	int id; /* bitflag id */
	int slot;
	int slot_pos;
	int allow_drop;
	int weight; /* required for bestweapon */
	void(void) precache;
	string() wmodel;
	string() deathmsg;

	/* NSClientPlayer specific */
	string(NSClientPlayer) pmodel;
	float(NSClientPlayer) aimanim;
	weapontype_t(NSClientPlayer) type; /* required for bot-AI */
	void(NSClientPlayer) draw;
	void(NSClientPlayer) holster;
	void(NSClientPlayer) primary;
	void(NSClientPlayer) secondary;
	void(NSClientPlayer) reload;
	void(NSClientPlayer) release;
	int(NSClientPlayer, int, int) pickup;
	void(NSClientPlayer) updateammo;

	void(NSClientPlayer, int) predraw; /* predraw... */
	void(NSClientPlayer) postdraw; /* postdraw... */

	int(NSClientPlayer) isempty; /* kinda handy */
	void(NSClientPlayer, int, vector, float) hudpic;
} weapon_t;

void Weapons_Init(void);
void Weapons_Draw(NSClientPlayer pl);
void Weapons_Holster(NSClientPlayer pl);
void Weapons_Primary(NSClientPlayer pl);
void Weapons_Secondary(NSClientPlayer pl);
void Weapons_Reload(NSClientPlayer pl);
void Weapons_Release(NSClientPlayer pl);
void Weapons_PreDraw(NSClientPlayer pl, int);

float Weapons_GetAim(NSClientPlayer, int);
int Weapons_IsEmpty(NSClientPlayer, int);
void Weapons_DrawCrosshair(NSClientPlayer pl);
void Weapons_MakeVectors(NSClientPlayer pl);
vector Weapons_GetCameraPos(NSClientPlayer pl);
void Weapons_ViewAnimation(NSClientPlayer pl, int);
void Weapons_ViewPunchAngle(NSClientPlayer pl, vector);
int Weapons_IsPresent(NSClientPlayer, int);
void Weapons_UpdateAmmo(NSClientPlayer, int, int, int);
int Weapons_GetAnimation(NSClientPlayer pl);
void Weapons_EnableModel(void);
void Weapons_DisableModel(void);
weapontype_t Weapons_GetType(NSClientPlayer, int);

void Weapons_SetLeftModel(string);
void Weapons_SetRightModel(string);

void Weapons_SetRightGeomset(string);
void Weapons_SetLeftGeomset(string);

/* compat */
void Weapons_SetGeomset(string);
void Weapons_SetModel(string);

void Weapons_Sound(entity, float, string);
string Weapons_GetWorldmodel(int);

#ifdef CLIENT
string Weapons_GetPlayermodel(NSClientPlayer, int);
void Weapons_HUDPic(NSClientPlayer, int, int, vector, float);
#endif
#else
#endif