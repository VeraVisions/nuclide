/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

void Desktop_Init ( void )
{
	static CUIMenuButton btnNewgame;
	static CUIMenuButton btnLoadgame;
	static CUIMenuButton btnFindserver;
	static CUIMenuButton btnCreateserver;
	static CUIMenuButton btnOptions;
	static CUIMenuButton btnQuit;
	static CUIMenuButton btnMPlayer;
	static CUIMenuButton btnMViewer;
	static CUIMenuButton btnResume;
	static CUIMenuButton btnDisconnect;
	static CUIMenuButton btnMods;
	static VGUIMenuTitle title;
	
	static void Desktop_ResumeGame ( void ) {
		m_toggle( 0 );
	}
	static void Desktop_DisconnectGame ( void ) {
		localcmd( "disconnect\n" );
	}

	g_uiDesktop = spawn( CUIWidget );
	g_uiDesktop.FlagAdd( 1 );

	btnNewgame = spawn( CUIMenuButton );
	btnNewgame.SetTitle( "New Game" );
	btnNewgame.SetSize( '128 24' );
	btnNewgame.SetPosition( 1 );
	btnNewgame.SetFunc( UI_NewGame_Show );
	btnNewgame.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );
	btnNewgame.SetIcon( "gfx/icon16/new" );

	btnDisconnect = spawn( CUIMenuButton );
	btnDisconnect.SetTitle( "Disconnect" );
	btnDisconnect.SetSize( '128 24' );
	btnDisconnect.SetPosition( 1 );
	btnDisconnect.SetFunc( Desktop_DisconnectGame );
	btnDisconnect.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnDisconnect.SetIcon( "gfx/icon16/disconnect" );

	btnLoadgame = spawn( CUIMenuButton );
	btnLoadgame.SetTitle( "Load Game" );
	btnLoadgame.SetSize( '128 24' );
	btnLoadgame.SetPosition( 2 );
	btnLoadgame.SetIcon( "gfx/icon16/book_edit" );
	btnLoadgame.SetFunc( UI_LoadGame_Show );

	btnFindserver = spawn( CUIMenuButton );
	btnFindserver.SetTitle( "Find Servers" );
	btnFindserver.SetSize( '128 24' );
	btnFindserver.SetPosition(3 );
	btnFindserver.SetFunc( UI_FindServers_Show );
	btnFindserver.SetIcon( "gfx/icon16/world_go" );

	btnCreateserver = spawn( CUIMenuButton );
	btnCreateserver.SetTitle( "Create Server" );
	btnCreateserver.SetSize( '128 24' );
	btnCreateserver.SetPosition( 4 );
	btnCreateserver.SetFunc( UI_CreateServer_Show );
	btnCreateserver.SetIcon( "gfx/icon16/server_add" );

	btnMods = spawn( CUIMenuButton );
	btnMods.SetTitle( "Custom Game" );
	btnMods.SetSize( '128 24' );
	btnMods.SetPosition( 5 );
	btnMods.SetIcon( "gfx/icon16/rainbow" );
	btnMods.SetFunc( UI_CustomGame_Show );
	btnMods.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );

	btnOptions = spawn( CUIMenuButton );
	btnOptions.SetTitle( "Options" );
	btnOptions.SetSize( '128 24' );
	btnOptions.SetPosition( 6 );
	btnOptions.SetIcon( "gfx/icon16/cog" );

	btnQuit = spawn( CUIMenuButton );
	btnQuit.SetTitle( "Quit Game" );
	btnQuit.SetSize( '128 24' );
	btnQuit.SetPosition( 7 );
	btnQuit.SetFunc( UI_QuitGame_Show );
	btnQuit.SetIcon( "gfx/icon16/stop" );

	btnMPlayer = spawn( CUIMenuButton );
	btnMPlayer.SetTitle( "Music Player" );
	btnMPlayer.SetSize( '128 24' );
	btnMPlayer.SetPosition( 8 );
	btnMPlayer.SetFunc( UI_MusicPlayer_Show );
	btnMPlayer.SetIcon( "gfx/icon16/ipod" );

	btnMViewer = spawn( CUIMenuButton );
	btnMViewer.SetTitle( "Model Viewer" );
	btnMViewer.SetSize( '128 24' );
	btnMViewer.SetPosition( 9 );
	btnMViewer.SetFunc( UI_ModelViewer_Show );
	btnMViewer.SetIcon( "gfx/icon16/images" );

	btnResume = spawn( CUIMenuButton );
	btnResume.SetTitle( "Resume Game" );
	btnResume.SetSize( '128 24' );
	btnResume.SetPosition( 10 );
	btnResume.SetFunc( Desktop_ResumeGame );
	btnResume.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnResume.SetIcon( "gfx/icon16/control_play" );

	title = spawn(VGUIMenuTitle);

	g_uiDesktop.Add( title );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		g_uiDesktop.Add( btnNewgame );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		g_uiDesktop.Add( btnLoadgame );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		g_uiDesktop.Add( btnFindserver );

	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		g_uiDesktop.Add( btnCreateserver );

	g_uiDesktop.Add( btnOptions );
	g_uiDesktop.Add( btnQuit );
	g_uiDesktop.Add( btnMPlayer );
	g_uiDesktop.Add( btnMViewer );
	g_uiDesktop.Add( btnResume );
	g_uiDesktop.Add( btnDisconnect );
	g_uiDesktop.Add( btnMods );
}

void Desktop_Draw ( void )
{
	g_uiDesktop.Draw();
}

void Desktop_CanvasChanged ( void )
{
	g_uiDesktop.Reposition();
}

