#pragma PROGS_DAT  "../../hud.dat"

const float baseIconSize = 32.0;
const float baseIconPadding = 16.0;
var float autocvar_cg_damageFill = 0.25f;

var float g_damageAlpha;
var vector g_damageLocation;
var int g_damageFlags;

font_s FONT_HUD;
var string g_ammoPic;

#define KILLMESSAGE_LIMIT 5i
#define KILLMESSAGE_TIME 4.0f

int g_killMsgCount;
float g_killMsgTime;
string g_killMsgRecord[KILLMESSAGE_LIMIT];


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
	vector hudSize = screen.HUDSize();
	vector iconPos = hud_mins + (hudSize / 2);
	iconPos[1] = (hudSize[1] - baseIconSize) - baseIconPadding;

	string healthValue = ftos(player.GetHealth());
	string armorValue = ftos(player.GetArmor());
	string ammoValue = ftos(weapon.GetAmmo1());

	if (g_damageAlpha > 0.0f) {
		if (autocvar_cg_damageFill > 0.0) {
			vector screenSize = screen.Size();
			vector screenMins = screen.Mins();
			vector finalColor = [1,1,1];
			finalColor[1] = finalColor[2] = 1.0 - (g_damageAlpha * autocvar_cg_damageFill);
			draw.Pic(screenMins, "fade_modulate", screenSize, finalColor, 1.0, DRAWFLAG_NORMAL);
		}

		g_damageAlpha -= clframetime;
	}

	/* health, armor icons */
	draw.RText(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)) - baseIconPadding, 0], healthValue, FONT_HUD);
	draw.Pic(iconPos + [-((baseIconSize/2) + (baseIconPadding/2)), 0], "gfx/hud/health", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	draw.Text(iconPos + [(baseIconSize/2) + (baseIconPadding/2) + baseIconSize + baseIconPadding, 0], armorValue, FONT_HUD);
	draw.Pic(iconPos + [(baseIconSize/2) + (baseIconPadding/2), 0], "gfx/hud/armor", [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	draw.RadarRect(hud_mins + [hudSize[0] - 127 - 16, 17], [126,126]);
	draw.RectOutline(hud_mins + [hudSize[0] - 128 - 16, 16], [128,128], 1.0f, [0.5,0.5,0.5], 1.0f);

	/* ammo */
	if (weapon.AmmoRequired() == true) {
		iconPos[0] = hud_mins[0] + (hudSize[0] - baseIconSize) - baseIconPadding;
		iconPos[1] = hud_mins[1] + (hudSize[1] - baseIconSize) - baseIconPadding;
		draw.Pic(iconPos, g_ammoPic, [baseIconSize, baseIconSize], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
		iconPos[0] -= baseIconPadding;
		draw.RText(iconPos, ammoValue, FONT_HUD);
		iconPos[1] += font.GetHeight(FONT_HUD);
		draw.RText(iconPos, weapon.GetTitle(), FONT_HUD);
	} else {
		iconPos[0] = hud_mins[0] + hudSize[0] - baseIconPadding;
		iconPos[1] = hud_mins[1] + (hudSize[1] - baseIconSize) - baseIconPadding;
		iconPos[1] += font.GetHeight(FONT_HUD);
		draw.RText(iconPos, weapon.GetTitle(), FONT_HUD);
	}

	if (g_killMsgTime < time && g_killMsgCount > 0i) {
		for (int i = 0i; i < (KILLMESSAGE_LIMIT-1i); i++) {
			g_killMsgRecord[i] = g_killMsgRecord[i+1];
		}

		g_killMsgRecord[KILLMESSAGE_LIMIT-1] = "";
		g_killMsgTime = time + KILLMESSAGE_TIME;
		g_killMsgCount--;
	}

	if (g_killMsgCount <= 0i) {
		return;
	}

	iconPos = hud_mins + [16, 16];

	for (int i = 0i; i < g_killMsgCount; i++) {
		draw.Text(iconPos, g_killMsgRecord[i], FONT_HUD);
		iconPos[1] += font.GetHeight(FONT_HUD);
	}
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
HUD_DrawSpectator(void)
{
	float palpha = 1.0f;
	string strText;

	vector hud_mins = screen.HUDMins();
	vector hud_size = screen.HUDSize();
	vector vecPos = g_vec_null;

	if (spectating.Mode() == SPECMODE_FREE) {
		palpha = 0.5f;
	}

	strText = sprintf("Tracking: %s", spectating.Name());
	vecPos[0] = hud_mins[0] + (hud_size[0] / 2) - (font.StringWidth(strText, true, FONT_HUD) / 2);
	vecPos[1] = hud_mins[1] + hud_size[1] - 60;
	draw.Text_A(vecPos, strText, palpha, FONT_HUD);

	strText = sprintf("Mode: %s", spectating.LocalizedMode());
	vecPos[0] = hud_mins[0] + (hud_size[0] / 2) - (font.StringWidth(strText, true, FONT_HUD) / 2);
	vecPos[1] = hud_mins[1] + hud_size[1] - 40;
	draw.Text_A(vecPos, strText, palpha, FONT_HUD);
}

void
HUD_WeaponSwitched(string weaponName)
{
	/* Here you could change the ammo icon based on the weapon you switched to */
	g_ammoPic = "gfx/hud/armor";
}


void
HUD_Obituary(string targetName, string attackerName, string weaponDef, string meansOfDeath)
{
	static void HUD_Obituary_Add(int id, string targetName, string attackerName, string weaponDef, string meansOfDeath) {
		string killMsg = entityDef.GetString(weaponDef, "msg_obituary");
		string killMsgGib = entityDef.GetString(weaponDef, "msg_gib");
		string killMsgSelf = entityDef.GetString(weaponDef, "msg_suicide");

		if (STRING_SET(killMsg)) {
			g_killMsgRecord[id] = sprintf(killMsg, targetName, attackerName);
		} else {
			g_killMsgRecord[id] = sprintf("%s killed %s", attackerName, targetName);
		}

		if (wordInString(meansOfDeath, "self")) {
			if (STRING_SET(killMsgSelf)) {
				g_killMsgRecord[id] = sprintf(killMsgSelf, targetName, attackerName);
			} else {
				g_killMsgRecord[id] = sprintf("%s ended their own life.", targetName);
			}
		} else if (wordInString(meansOfDeath, "gib")) {
			if (STRING_SET(killMsgGib)) {
				g_killMsgRecord[id] = sprintf(killMsgGib, targetName, attackerName);
			} else {
				g_killMsgRecord[id] = sprintf("%s gibbed %s.", attackerName , targetName);
			}
		}
	}

	if (g_killMsgCount < KILLMESSAGE_LIMIT) {
		HUD_Obituary_Add(g_killMsgCount, targetName, attackerName, weaponDef, meansOfDeath);
		g_killMsgCount++;
	} else {
		for (int i = 0i; i < (KILLMESSAGE_LIMIT-1); i++) {
			g_killMsgRecord[i] = g_killMsgRecord[i+1];
		}

		HUD_Obituary_Add(KILLMESSAGE_LIMIT-1, targetName, attackerName, weaponDef, meansOfDeath);
	}

	g_killMsgTime = time + KILLMESSAGE_TIME;
}
