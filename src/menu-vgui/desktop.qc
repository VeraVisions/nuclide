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
	btnNewgame.SetPos( '32 64' );
	btnNewgame.SetFunc( UI_NewGame_Show );
	btnNewgame.FlagRemove( MBUTTON_SHOWSP | MBUTTON_SHOWMP );
	btnNewgame.SetIcon( "textures/ui/icons/desktop" );

	btnDisconnect = spawn( CUIMenuButton );
	btnDisconnect.SetTitle( "Disconnect" );
	btnDisconnect.SetSize( '128 24' );
	btnDisconnect.SetPos( '32 64' );
	btnDisconnect.SetFunc( Desktop_DisconnectGame );
	btnDisconnect.FlagRemove( MBUTTON_SHOWOFFLINE );
	btnDisconnect.SetIcon( "textures/ui/icons/disconnect" );

	btnLoadgame = spawn( CUIMenuButton );
	btnLoadgame.SetTitle( "Load Game" );
	btnLoadgame.SetSize( '128 24' );
	btnLoadgame.SetPos( '32 96' );
	btnLoadgame.SetIcon( "textures/ui/icons/folder" );

	btnFindserver = spawn( CUIMenuButton );
	btnFindserver.SetTitle( "Find Servers" );
	btnFindserver.SetSize( '128 24' );
	btnFindserver.SetPos( '32 128' );
	btnFindserver.SetFunc( UI_FindServers_Show );
	btnFindserver.SetIcon( "textures/ui/icons/servers" );

	btnCreateserver = spawn( CUIMenuButton );
	btnCreateserver.SetTitle( "Create Server" );
	btnCreateserver.SetSize( '128 24' );
	btnCreateserver.SetPos( '32 160' );
	btnCreateserver.SetFunc( UI_CreateServer_Show );
	btnCreateserver.SetIcon( "textures/ui/icons/server-new" );

	btnOptions = spawn( CUIMenuButton );
	btnOptions.SetTitle( "Options" );
	btnOptions.SetSize( '128 24' );
	btnOptions.SetPos( '32 192' );
	btnOptions.SetIcon( "textures/ui/icons/gear" );

	btnQuit = spawn( CUIMenuButton );
	btnQuit.SetTitle( "Quit Game" );
	btnQuit.SetSize( '128 24' );
	btnQuit.SetPos( '32 224' );
	btnQuit.SetFunc( UI_QuitGame_Show );
	btnQuit.SetIcon( "textures/ui/icons/cancel" );

	btnMPlayer = spawn( CUIMenuButton );
	btnMPlayer.SetTitle( "Music Player" );
	btnMPlayer.SetSize( '128 24' );
	btnMPlayer.SetPos( '32 288' );
	btnMPlayer.SetFunc( UI_MusicPlayer_Show );
	btnMPlayer.SetIcon( "textures/ui/icons/cd" );

	btnMViewer = spawn( CUIMenuButton );
	btnMViewer.SetTitle( "Model Viewer" );
	btnMViewer.SetSize( '128 24' );
	btnMViewer.SetPos( '32 320' );
	btnMViewer.SetFunc( UI_ModelViewer_Show );
	btnMViewer.SetIcon( "textures/ui/icons/hdd" );

	btnResume = spawn( CUIMenuButton );
	btnResume.SetTitle( "Resume Game" );
	btnResume.SetSize( '128 24' );
	btnResume.SetPos( '32 384' );
	btnResume.SetFunc( Desktop_ResumeGame );
	btnResume.FlagRemove( MBUTTON_SHOWOFFLINE );

	g_uiDesktop.Add( btnNewgame );
	g_uiDesktop.Add( btnLoadgame );
	g_uiDesktop.Add( btnFindserver );
	g_uiDesktop.Add( btnCreateserver );
	g_uiDesktop.Add( btnOptions );
	g_uiDesktop.Add( btnQuit );
	g_uiDesktop.Add( btnMPlayer );
	g_uiDesktop.Add( btnMViewer );
	g_uiDesktop.Add( btnResume );
	g_uiDesktop.Add( btnDisconnect );
}

void Desktop_Draw ( void )
{
	g_uiDesktop.Draw();
}
