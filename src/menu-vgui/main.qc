/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

var int autocvar_r_autoscale = TRUE;
void
Menu_AutoScale(void)
{
	if (autocvar_r_autoscale) {
		/* override for vid_conautoscales */
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
	}
}

void m_init ( void )
{
	UISystem_Init();
	Background_Init();
	Desktop_Init();
	
	registercommand( "menu_quit" );
	registercommand( "menu_music" );
	registercommand( "map_background" );
	Menu_AutoScale();
}

void
Menu_RendererRestarted(string renderer)
{
	localcmd("menu_restart\n");
	Menu_AutoScale();
}

void m_shutdown ( void )
{
	
}

void m_draw ( vector vecScreensize )
{
	if (vecScreensize != video_res) {
		Menu_AutoScale();
	}

	g_background = cvar("_background");

	/* make sure input carries over when a map background is active */
	if (g_background) {
		if (getkeydest() != KEY_MENU) {
			setkeydest(KEY_MENU);
			setmousetarget(TARGET_MENU);
			setcursormode(TRUE, "gfx/cursor");
		}
	}

	if (!g_iMenuActive && !g_background) {
		/* make sure we're redirecting input when the background's gone */
		if (getkeydest() != KEY_GAME) {
			setkeydest(KEY_GAME);
			setmousetarget(TARGET_CLIENT);
			setcursormode(FALSE);
		}
		return;
	}

	frametime = time - lasttime;
	lasttime = time;

	video_res = vecScreensize;
	Background_Draw( vecScreensize );
	Desktop_Draw();
}

float Menu_InputEvent ( float evtype, float scanx, float chary, float devid )
{
	switch (evtype) {
		case IE_KEYDOWN:
			if (chary == K_ESCAPE) {
				if (clientstate() == 2 && !g_background) {
					m_toggle(0);
				}
			}
			break;
	}

	g_uiDesktop.Input( evtype, scanx, chary, devid );
	return (float)g_iMenuActive;
}

void
m_display(void)
{
	g_iMenuActive = TRUE;
	setkeydest(KEY_MENU);
	setmousetarget(TARGET_MENU);
	setcursormode(TRUE, "gfx/cursor");
}

/*
=================
m_hide
=================
*/
void
m_hide(void)
{
	g_iMenuActive = FALSE;
	setkeydest(KEY_GAME);
	setmousetarget(TARGET_CLIENT);
	setcursormode(FALSE);
}

/*
=================
m_toggle
=================
*/
void
m_toggle(float fMode)
{
	if (fMode == FALSE) {
		m_hide();
	} else {
		m_display();
	}
}

float m_consolecommand ( string strCommand )
{
	dprint( sprintf( "[MENU] m_consolecommand: %s\n", strCommand ) );
	tokenize( strCommand );

	switch ( argv( 0 ) ) {
	case "menu_quit":
		UI_QuitGame_Show();
		break;
	case "menu_music":
		UI_MusicPlayer_Show();
		break;
	case "showconsole":
		UI_Console_Show();
		break;
	case "map_background":
		localcmd(sprintf("maxplayers 2\nset coop 1\nset sv_background 1\nmap %s\n",
			argv(1)));
		break;
	default:
		return (0);
	}

	return (1);
}
