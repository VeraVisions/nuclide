/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
	string ki_spr;
	vector ki_size;
	vector ki_xy;

	void() draw;
	void() holster;
	void() primary;
	void() secondary;
	void() reload;
	void() release;
	void() crosshair;

	void() precache;
	int(int) pickup;
	void(player) updateammo;
	string() wmodel;
	string() pmodel;
	string() deathmsg;
	float() aimanim;
	void(int, vector, float) hudpic;
} weapon_t;

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
void Weapons_SetGeomset(string);
#ifdef SSQC
void Weapons_RefreshAmmo(player);
void Weapons_InitItem(int);
float Weapons_GetAim(int);
int Weapons_AddItem(player, int);
void Weapons_RemoveItem(player, int);
string Weapons_GetWorldmodel(int);
void Weapons_UpdateAmmo(player, int, int, int);
void Weapons_ReloadWeapon(player, .int, .int, int);
#else
string Weapons_GetPlayermodel(int);
int Weapons_GetAnimation(void);
void Weapons_HUDPic(int, int, vector, float);
#endif
