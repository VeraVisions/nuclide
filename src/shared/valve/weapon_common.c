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

void Weapons_SetModel(string mdl)
{
#ifdef CSQC
	setmodel(pSeat->eViewModel, mdl);
#endif	
}

void Weapons_Draw(void)
{
	player pl = (player)self;
	int i = pl.activeweapon;

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;
	pl.viewzoom = 1.0f;

	if (g_weapons[i].draw != __NULL__) {
		g_weapons[i].draw();
	}
#ifdef SSQC
	if (g_weapons[i].updateammo != __NULL__) {
		g_weapons[i].updateammo(pl);
	}
#endif
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
	player pl = (player)pSeat->ePlayer;
	View_PlayAnimation(i);
#else
	player pl = (player)self;
#endif
	pl.weapontime = 0.0f;
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

void Weapons_RefreshAmmo(player pl)
{
	if (g_weapons[pl.activeweapon].updateammo != __NULL__) {
		g_weapons[pl.activeweapon].updateammo(pl);
    }
}

void Weapons_SwitchBest(player pl)
{
	entity oldself = self;
	self = pl;
	for (int i = 0; i < g_weapons.length; i++) {
		if (pl.g_items & g_weapons[i].id) {
			pl.activeweapon = i;
			break;
		}
	}
	Weapons_Draw();
	self = oldself;
}

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

void Weapons_RemoveItem(player pl, int w)
{
	pl.g_items &= ~g_weapons[w].id;
	Weapons_SwitchBest(pl);
}

void Weapons_InitItem(int w)
{
	item_pickup it = (item_pickup)self;
	spawnfunc_item_pickup();
	it.setitem(w);
}

void Weapons_UpdateAmmo(player pl, int a1, int a2, int a3)
{
	/* no change */
	if (a1 == -1) {
		a1 = pl.a_ammo1;
	}
	if (a2 == -1) {
		a2 = pl.a_ammo2;
	}
	if (a3 == -1) {
		a3 = pl.a_ammo3;
	}

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
