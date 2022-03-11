/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/* for AI identification purposes */
typedef enum
{
	WPNTYPE_INVALID,	/* no logic */
	WPNTYPE_RANGED,		/* will want to keep their distance mostly */
	WPNTYPE_THROW,		/* has to keep some distance, but not too far */
	WPNTYPE_CLOSE		/* have to get really close */
} weapontype_t;

typedef struct
{
	string name;
	int id; /* bitflag id */
	int slot;
	int slot_pos;
	int allow_drop;
	int weight; /* required for bestweapon */
	weapontype_t(void) type; /* required for bot-AI */

	void(void) draw;
	void(void) holster;
	void(void) primary;
	void(void) secondary;
	void(void) reload;
	void(void) release;

	void(int) predraw; /* predraw... */
	void(void) crosshair; /* postdraw... */

	int(void) isempty; /* kinda handy */

	void(void) precache;
	int(int, int) pickup;
	void(player) updateammo;
	string() wmodel;
	string() pmodel;
	string() deathmsg;
	float() aimanim;
	void(int, vector, float) hudpic;
} weapon_t;

void Weapons_Holster(void);
void Weapons_Primary(void);
void Weapons_Secondary(void);
void Weapons_Reload(void);
void Weapons_Release(void);
void Weapons_PreDraw(int);

float Weapons_GetAim(int);
void Weapons_Reload(void);
int Weapons_IsEmpty(player, int);
void Weapons_DrawCrosshair(void);
void Weapons_MakeVectors(void);
vector Weapons_GetCameraPos(void);
void Weapons_ViewAnimation(int);
void Weapons_ViewPunchAngle(vector);
int Weapons_IsPresent(player, int);
void Weapons_UpdateAmmo(base_player, int, int, int);
int Weapons_GetAnimation(void);
void Weapons_EnableModel(void);
void Weapons_DisableModel(void);
weapontype_t Weapons_GetType(player, int);

void Weapons_SetLeftModel(string);
void Weapons_SetRightModel(string);

void Weapons_SetRightGeomset(string);
void Weapons_SetLeftGeomset(string);

/* compat */
void Weapons_SetGeomset(string);
void Weapons_SetModel(string);

void Weapons_Sound(entity, float, string);

#ifdef CLIENT
string Weapons_GetPlayermodel(int);
void Weapons_HUDPic(int, int, vector, float);
#endif
