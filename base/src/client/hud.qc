#pragma PROGS_DAT  "../../hud.dat"

#include "../../../src/client/api.h"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;

font_s FONT_HUD;
var string g_ammoPic;

void
HUD_Init(void)
{
	font.Load("fonts/font16.font", FONT_HUD);
	g_ammoPic = 0;
}

void
HUD_Draw(void)
{

	vector hud_mins = screen.HUDMins();
	vector hud_size = screen.HUDSize();
	vector hudSize = hud_size;
	vector iconPos = hud_mins + (hudSize / 2);
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;

	string healthValue = ftos(player.GetHealth());
	string armorValue = ftos(player.GetArmor());
	string ammoValue = ftos(weapon.GetAmmo1());

	/* ammo */
	if (weapon.AmmoRequired() == true) {
		draw.RText([hudSize[0] - baseIconPadding - baseIconSize - baseIconPadding, iconPos[1]], ammoValue, FONT_HUD);
	}

	if (g_ammoPic != "") {
		draw.Pic([hudSize[0] - baseIconPadding - baseIconSize, iconPos[1]], g_ammoPic, [baseIconSize, baseIconSize], [1,1,1], 1.0f);
	}

	/* health, armor icons */
	draw.RText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], healthValue, FONT_HUD);
	draw.Pic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f);

	draw.Text(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], armorValue, FONT_HUD);
	draw.Pic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f);
}

void
HUD_DrawSpectator(vector hud_mins, vector hud_size)
{

}

void
HUD_WeaponSwitched(string weaponName)
{
	g_ammoPic = entityDef.GetString(weaponName, "ammoIcon");
}
