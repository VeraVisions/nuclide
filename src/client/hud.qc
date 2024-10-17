
var float g_flHUDProgs;
var void(void) g_hudInit;
var void(void) g_hudDraw;
var void(void) g_hudDrawSpectator;
var void(string, string) g_hudSendStat;
var void(string) g_hudSwitchedWeapon;
var float(float) g_hudInputFrame;
var bool(string) g_hudConsoleCommand;
var void(void) g_hudRendererRestarted;

void
HUDProgs_Init(void)
{
	g_flHUDProgs = addprogs("hud.dat");

	if (g_flHUDProgs > 0) {
		g_hudInit = externvalue(g_flHUDProgs, "main");
		g_hudDraw = externvalue(g_flHUDProgs, "HUD_Draw");
		g_hudDrawSpectator = externvalue(g_flHUDProgs, "HUD_DrawSpectator");
		g_hudSendStat = externvalue(g_flHUDProgs, "HUD_SendStat");
		g_hudSwitchedWeapon = externvalue(g_flHUDProgs, "HUD_WeaponSwitched");
		g_hudInputFrame = externvalue(g_flHUDProgs, "HUD_InputFrame");
		g_hudConsoleCommand = externvalue(g_flHUDProgs, "HUD_ConsoleCommand");
		g_hudRendererRestarted = externvalue(g_flHUDProgs, "HUD_RendererRestarted");

		if (g_hudInit) {
			g_hudInit();
		} else {
			NSError("HUD progs does not have a main function.");
		}
	}
}

void
HUDProgs_RendererRestarted(void)
{
	if (g_flHUDProgs > 0) {
		if (g_hudRendererRestarted) {
			g_hudRendererRestarted();
		}
	}
}

void
HUDProgs_Draw(void)
{
	if (g_flHUDProgs > 0) {
		if (g_hudDraw) {
			externset(g_flHUDProgs, clframetime, "clframetime");
			g_hudDraw();
		}
	}
}

 void
HUDProgs_DrawSpectator(void)
{
	if (g_flHUDProgs > 0) {
		if (g_hudDrawSpectator) {
			g_hudDrawSpectator();
		}
	}
}

void
HUDProgs_SendStat(string statName, string statValue)
{
	if (g_flHUDProgs > 0) {
		if (g_hudSendStat) {
			g_hudSendStat(statName, statValue);
		}
	}
}

void
HUDProgs_SwitchedToWeapon(string weaponName)
{
	if (g_flHUDProgs > 0) {
		if (g_hudSwitchedWeapon) {
			g_hudSwitchedWeapon(weaponName);
		}
	}
}

float
HUDProgs_ClientInputFrame(float inputFrame)
{
	if (g_flHUDProgs > 0) {
		if (g_hudInputFrame) {
			return g_hudInputFrame(inputFrame);
		}
	}

	return (0.0f);
}

bool
HUDProgs_ConsoleCommand(string commandString)
{
	if (g_flHUDProgs > 0) {
		if (g_hudConsoleCommand) {
			return g_hudConsoleCommand(commandString);
		}
	}

	return (false);
}

__weak void
HUD_Init(void)
{
	HUDProgs_Init();
}

__weak void
HUD_RendererRestarted(void)
{
	HUDProgs_RendererRestarted();
}

__weak void
HUD_Draw(void)
{
	HUDProgs_Draw();
}

__weak void
HUD_DrawSpectator(void)
{
	HUDProgs_DrawSpectator();
}

__weak void
HUD_SendStat(string statName, string statValue)
{
	HUDProgs_SendStat(statName, statValue);
}

__weak void
HUD_SwitchedToWeapon(string weaponName)
{
	HUDProgs_SwitchedToWeapon(weaponName);
}

__weak float
HUD_ClientInputFrame(float inputButtons)
{
	return HUDProgs_ClientInputFrame(inputButtons);
}

__weak bool
HUD_ConsoleCommand(string commandString)
{
	return HUDProgs_ConsoleCommand(commandString);
}
