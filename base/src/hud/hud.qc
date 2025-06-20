#pragma PROGS_DAT  "../../hud.dat"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;
var float autocvar_cg_damageFill = 0.25f;

var float g_damageAlpha;
var vector g_damageLocation;
var int g_damageFlags;

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

	if (g_damageAlpha > 0.0f) {
		if (autocvar_cg_damageFill > 0.0) {
			vector screenSize = screen.Size();
			vector finalColor = [1,1,1];
			finalColor[1] = finalColor[2] = 1.0 - (g_damageAlpha * autocvar_cg_damageFill);
			draw.Pic(hud_mins, "fade_modulate", screenSize, finalColor, 1.0, DRAWFLAG_NORMAL);
		}

		g_damageAlpha -= clframetime;
	}

	/* ammo */
	if (weapon.AmmoRequired() == true) {
		draw.RText([hudSize[0] - baseIconPadding - baseIconSize - baseIconPadding, iconPos[1]], ammoValue, FONT_HUD);
	}

	if (g_ammoPic != "") {
		draw.Pic([hudSize[0] - baseIconPadding - baseIconSize, iconPos[1]], g_ammoPic, [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
	}

	/* health, armor icons */
	draw.RText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], healthValue, FONT_HUD);
	draw.Pic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	draw.Text(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], armorValue, FONT_HUD);
	draw.Pic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
}

void
HUD_DamageReceived(vector damageLocation, int damagePoints, int damageFlags)
{
	if (damagePoints <= 0i) {
		return;
	}

	g_damageAlpha = 1.0;
	g_damageLocation = damageLocation;
	g_damageFlags = damageFlags;

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
