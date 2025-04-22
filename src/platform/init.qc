void
Platform_Init(void)
{
	string menuMap = "";
	string videoFile = "";

	/* the HL configs make the rate this low by default. */
	if (cvar("rate") <= 2500) {
		cvar_set("rate", "30000");
	}

	Platform_RegisterCommands();
	Locale_Init();
	GameLibrary_Init();
	MapLibrary_Init();
	Saves_Init();
	Platform_RendererRestarted();

	videoFile = GameLibrary_GetInfo(GAMEINFO_INTROVIDEO);
	menuMap = GameLibrary_GetInfo(GAMEINFO_MENUMAP);

	if (STRING_SET(videoFile)) {
		localcmd(strcat("playvideo ", videoFile, "\n"));
	}

	if (STRING_SET(menuMap)) {
		localcmd(strcat("map_background ", menuMap, "\n"));
	}
}

void
Platform_Shutdown(void)
{
	FragNet_SignOff();
}

void
Platform_RendererRestarted(void)
{
	Background_RendererRestarted();
	Locale_Reload();
}

bool
Platform_Draw(vector screensize)
{
	/* set new scale whenever the resolution changes */
	if (Platform_DimensionsChanged(screensize) == true) {
		Platform_CalculateRenderingScale(screensize);
	}

	FragNet_Frame();
	g_background = cvar("_background");

	/* make sure input carries over when a map background is active */
	if (g_background) {
		if (getkeydest() != KEY_MENU) {
			setkeydest(KEY_MENU);
			setmousetarget(TARGET_MENU);
			setcursormode(TRUE, "gfx/cursor");
		}
	}

	/* clear rich presence whenever the state suddenly changes */
	if (g_gamestate != clientstate()) {
		g_gamestate = clientstate();

		if (g_gamestate == 1)
			RichPresence_Clear();
	}

	/* rich presence sanity check */
	if (RichPresence_WasSet() == false) {
		if (clientstate() == 2)
			RichPresence_Set("status", "In-game (Unknown)");
		else
			RichPresence_Set("status", "Main Menu");
	}

	/* if the menu is not visible and we're no background map... */
	if (!g_active && !g_background) {
		/* make sure we're redirecting input when the background's gone */
		if (getkeydest() != KEY_GAME) {
			setkeydest(KEY_GAME);
			setmousetarget(TARGET_CLIENT);
			setcursormode(FALSE);
		}

		/* don't draw the menu below */
		return (false);
	}

	return (g_active);
}

/* r_autoscale forces vid_conautoscale to be one of 4 integer values.
 * this is due to vid_conautoscale 0 scaling with in floating point... which
 * in turns results in skipped rows/columns and shimmering. */
var int autocvar_r_autoscale = false;
var int autocvar_r_pixelscale = FALSE;
void
Platform_AutoScale(void)
{
	if (autocvar_r_autoscale) {
		vector psize = getproperty(VF_SCREENPSIZE);
		if (psize[1] >= (480 * 4)) {
			cvar_set("vid_conautoscale", "4");
		} else if (psize[1] >= (480 * 3)) {
			cvar_set("vid_conautoscale", "3");
		} else if (psize[1] >= (480 * 2)) {
			cvar_set("vid_conautoscale", "2");
		} else {
			cvar_set("vid_conautoscale", "1");
		}

		if (autocvar_r_pixelscale) {
			float scale = bound(0.0, 480 / psize[1], 1.0);
			cvar_set("r_renderscale", sprintf("-%f", scale));
		}
	}
}

void
Platform_CalculateRenderingScale(vector screensize)
{
	g_vidsize[0] = screensize[0];
	g_vidsize[1] = screensize[1];
	g_menuofs[0] = (g_vidsize[0] / 2) - 320;
	g_menuofs[1] = (g_vidsize[1] / 2) - 240;
	Platform_AutoScale();
}

bool
Platform_DimensionsChanged(vector screensize)
{
	return ((screensize[0] != g_vidsize[0]) || (screensize[1] != g_vidsize[1])) ? (true) : (false);
}


bool
Platform_HasStartupVideos(void)
{
	if (fileExists("media/valve.avi"))
		return true;

	return false;
}

void
Platform_PlayStartupVideos(void)
{
	ncLog("Playing startup videos.\n");
	//localcmd("playvideo av:media/sierra.avi av:media/valve.avi\n");
}
