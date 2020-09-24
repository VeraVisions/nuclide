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
	Menu_AutoScale();
}

void
Menu_RendererRestarted(void)
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

	if ( !g_iMenuActive ) {
		return;
	}

	frametime = time - lasttime;
	lasttime = time;

	video_res = vecScreensize;
	Background_Draw( vecScreensize );
	Desktop_Draw();
}

float Menu_InputEvent ( float flEvType, float flScanX, float flCharY, float flDevID )
{
	g_uiDesktop.Input( flEvType, flScanX, flCharY, flDevID );
	return (float)g_iMenuActive;
}

void m_toggle ( float flWantMode )
{
	dprint( sprintf( "[MENU] m_toggle: %d\n", flWantMode ) );

	if ( flWantMode == 0 ) {
		g_iMenuActive = FALSE;
		setkeydest( KEY_GAME );
		setmousetarget( TARGET_CLIENT );
		setcursormode( FALSE );
	} else {
		g_iMenuActive = TRUE;
		setkeydest( KEY_MENU );
		setmousetarget( TARGET_MENU );
		setcursormode( TRUE, "gfx/cursor" );
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
		default:
			return FALSE;
	}

	return TRUE;
}
