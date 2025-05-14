/*
 * Copyright (c) 2024 Vera Visions LLC.
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

/*

This is the Client Game API. Used by client-side scriptobjects, hud progs etc.
There's no header because the main code is not supposed to use this.

*/

/* view functions */
float
Surface_ScreenWidth(void)
{
	return (g_vidsize[0]);
}

float
Surface_ScreenHeight(void)
{
	return (g_vidsize[1]);
}

vector
Surface_ScreenMins(void)
{
	return (video_mins);
}

vector
Surface_ScreenSize(void)
{
	return (g_vidsize);
}

vector
Surface_HUDMins(void)
{
	return (g_hudmins);
}

vector
Surface_HUDSize(void)
{
	return (g_hudres);
}

/* player functions */
vector
Player_GetCameraPosition(void)
{
	return (g_view.GetCameraOrigin());
}
vector
Player_GetCameraAngles(void)
{
	return (g_view.GetCameraAngle());
}
float
Player_GetHealth(void)
{
	return (pSeat->m_ePlayer.health);
}

float
Player_GetArmor(void)
{
	return (((ncPlayer)pSeat->m_ePlayer).armor);
}

float
Player_GetStamina(void)
{
	return (((ncPlayer)pSeat->m_ePlayer).GetStamina());
}

int
Player_GetTeam(void)
{
	return (int)getplayerkeyfloat(pSeat->m_ePlayer.entnum-1, "*team");
}

bool
Player_HasItem(string itemName)
{
	return (((ncPlayer)pSeat->m_ePlayer).HasItem(itemName));
}

bool
Player_IsSprinting(string itemName)
{
	return ((ncPlayer)pSeat->m_ePlayer).IsSprinting();
}

bool
Player_IsCrouching(string itemName)
{
	return ((ncPlayer)pSeat->m_ePlayer).IsCrouching();
}

bool
Player_IsProne(string itemName)
{
	return ((ncPlayer)pSeat->m_ePlayer).IsProne();
}

bool
Player_IsFalling(string itemName)
{
	return (((ncPlayer)pSeat->m_ePlayer).flags & FL_ONGROUND) ? false : true;
}

bool
Player_IsMoving(string itemName)
{
	if (pSeat->m_ePlayer.velocity[0] > 1.0f)
		return (true);
	if (pSeat->m_ePlayer.velocity[1] > 1.0f)
		return (true);
	if (pSeat->m_ePlayer.velocity[2] > 1.0f)
		return (true);
	if (pSeat->m_ePlayer.velocity[0] < -1.0f)
		return (true);
	if (pSeat->m_ePlayer.velocity[1] < -1.0f)
		return (true);
	if (pSeat->m_ePlayer.velocity[2] < -1.0f)
		return (true);

	return (false);
}

bool
Player_IsStanding(string itemName)
{
	return ((ncPlayer)pSeat->m_ePlayer).IsStanding();
}

bool
Player_IsLeaning(string itemName)
{
	return ((ncPlayer)pSeat->m_ePlayer).IsLeaning();
}


/* teamplay functions */
string
Team_GetName(int teamNumber)
{
	return serverkey(sprintf("team_%i", teamNumber));
}

vector
Team_GetColor(int teamNumber)
{
	return g_vec_null;
}

int
Team_GetScore(int teamNumber)
{
	return (int)serverkeyfloat(sprintf("teamscore_%i", teamNumber));
}

int
Team_GetPlayers(int teamNumber)
{
	return 0i;
}

int
Team_GetCount(void)
{
	return (int)serverkeyfloat("teams");
}

bool
Weapon_IsValid(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.IsWeapon());
	}

	return (false);
}

string
Weapon_GetTitle(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.m_weaponTitle);
	}

	return "Unknown";
}

string
Weapon_GetIcon(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.m_weaponHUDIcon);
	}

	return "Unknown";
}

string
Weapon_GetSelectedIcon(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.m_weaponHUDIconSel);
	}

	return "Unknown";
}

int
Weapon_GetSlot(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.m_weaponHUDSlot);
	}

	return -1i;
}

int
Weapon_GetSlotPos(entity weaponEntity)
{
	ncWeapon weapon = (ncWeapon)weaponEntity;

	if (weapon) {
		return (weapon.m_weaponHUDSlotPos);
	}

	return -1i;
}

int
Weapon_GetClip(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return (weapon.m_weaponClip);
	}

	return 0;
}

int
Weapon_MaxAmmo(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		if (weapon.m_primaryAmmoType >= 0) {
			return ammoMaxForNum(weapon.m_primaryAmmoType);
		}
	}

	return 0;
}

int
Weapon_GetClipSize(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return (weapon.m_weaponClipSize);
	}

	return 0;
}

bool
Weapon_UsesSecondaryAmmo(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return weapon.UsesSecondaryAmmo();
	}

	return (false);
}

int
Weapon_GetAmmo1(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return owner.GetReserveAmmo(weapon.m_primaryAmmoType);
	}

	return -1i;
}

int
Weapon_GetAmmo2(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return owner.GetReserveAmmo(weapon.m_secondaryAmmoType);
	}

	return -1i;
}

bool
Weapon_AmmoRequired(void)
{
	ncActor owner = (ncActor)pSeat->m_ePlayer;
	ncWeapon weapon = owner.m_activeWeapon;

	if (weapon) {
		return (weapon.m_fiAmmoRequired);
	}

	return (false);
}

entity
Weapon_GetActiveWeapon(void)
{
	return ((ncActor)pSeat->m_ePlayer).m_activeWeapon;
}

entity
Weapon_GetFirstWeaponInInventory(void)
{
#if 0
	return ((ncActor)pSeat->m_ePlayer).m_firstWeapon;
#else
	return ((ncActor)pSeat->m_ePlayer).SortWeaponChain();
#endif
}

entity
Weapon_GetLastWeaponInInventory(void)
{
	return ((ncActor)pSeat->m_ePlayer).m_firstWeapon.m_prevWeapon;
}

entity
Weapon_GetNextWeaponRelativeTo(entity weaponCheck)
{
	if (weaponCheck)
		return ((ncWeapon)weaponCheck).m_nextWeapon;

	return __NULL__;
}

entity
Weapon_GetPreviousWeaponRelativeTo(entity weaponCheck)
{
	if (weaponCheck)
		return ((ncWeapon)weaponCheck).m_prevWeapon;

	return __NULL__;
}

bool
Weapon_SelectWeapon(entity weaponCheck)
{
	if (weaponCheck) {
		ncWeapon_SelectWeapon((ncWeapon)weaponCheck);
		return (true);
	}

	return (false);
}

void
Draw_Rect(vector pos, vector size, vector rgb, float a)
{
	drawfill(pos, size, rgb, a);
}

void
Draw_RectOutline(vector pos, vector size, float thickness, vector rgb, float a)
{
	drawrect(pos, size, thickness, rgb, a);
}

void
Draw_RoundedBox(vector pos, vector size, vector rgb, float a)
{
	float tileScale = 1.0f;

	if (size[1] < 32) {
		tileScale = size[1] / 32;
	}

	vector tileSize = g_vec_null;
	tileSize[0] = tileSize[1] =  (16 * tileScale);


	drawpic(pos, "gfx/ui/m_topleft.tga", tileSize, rgb, a, 0);
	drawpic(pos + [size[0] - tileSize[0], 0], "gfx/ui/m_topright.tga", tileSize, rgb, a, 0);
	drawpic(pos + [0, size[1] - tileSize[1]], "gfx/ui/m_bottomleft.tga", tileSize, rgb, a, 0);
	drawpic(pos + [size[0] - tileSize[0], size[1] - tileSize[1]], "gfx/ui/m_bottomright.tga", tileSize, rgb, a, 0);

	if (size_x > 32) {
		drawpic(pos + [tileSize[0], 0], "gfx/ui/m_top.tga", [size[0] - (tileSize[0] * 2), tileSize[1]], rgb, a, 0);
		drawpic(pos + [tileSize[0], size[1] - tileSize[1]], "gfx/ui/m_bottom.tga", [size[0] - (tileSize[0] * 2), tileSize[1]], rgb, a, 0);
	}

	if (size_y > 32) {
		drawpic(pos + [0, tileSize[1]], "gfx/ui/m_left.tga", [tileSize[0], size[1] - (tileSize[0] * 2)], rgb, a, 0);
		drawpic(pos + [size[0] - tileSize[0], tileSize[1]], "gfx/ui/m_right.tga", [tileSize[0], size[1] - (tileSize[0] * 2)], rgb, a, 0);
		drawpic(pos + [tileSize[0], tileSize[1]], "gfx/ui/m_mid.tga", [size[0] - (tileSize[0] * 2), size[1] - (tileSize[0] * 2)], rgb, a, 0);
	}
}

void
Draw_Line(float thickness, vector pos1, vector pos2, vector rgb, float a)
{
	drawline(thickness, pos1, pos2, rgb, a);
}

void
Draw_Pic(vector pos, string material, vector size, vector rgb, float a, float imageFlags)
{
	drawpic(pos, material, size, rgb, a, imageFlags);
}

void
Draw_SubPic(vector pos, vector displaySize, string material, vector sourcePos, vector sourceSize, vector rgb, float a, float imageFlags)
{
	drawsubpic(pos, displaySize, material, sourcePos, sourceSize, rgb, a, imageFlags);
}
