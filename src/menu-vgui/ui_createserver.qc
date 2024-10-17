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

int g_iCreateServerInitialized;

void UI_CreateServer_Show ( void )
{
	static CUIScrollbar scrlMaps;
	static CUIWindow winCreate;
	static CUIButton btnCancel;
	static CUIButton btnStart;
	static CUIList lsbMaps;
	static CUILabel lblHostname;
	static CUITextBox txbHostname;
	static CUILabel lblMaxplayers;
	static CUITextBox txbMaxplayers;
	static CUILabel lblPassword;
	static CUITextBox txbPassword;

	static void CreateServer_Start ( void ) {
		int iEndMap = lsbMaps.GetSelected();
		if ( lsbMaps.GetSelected() == 0 ) {
			iEndMap = (int)( rint( random( 1, lsbMaps.GetItemCount() ) ) );
		}
		localcmd( sprintf( "hostname %s\n", txbHostname.GetText() ) );
		localcmd( sprintf( "maxplayers %s\n", txbMaxplayers.GetText() ) );
		localcmd( sprintf( "sv_password %s\n", txbPassword.GetText() ) );
		localcmd( sprintf( "map %s\n", lsbMaps.GetItem( iEndMap ) ) );
		winCreate.Hide();
	}
	static void CreateServer_Cancel ( void ) {
		winCreate.Hide();
	}
	static void CreateServer_ListUpdate ( void ) {
		lsbMaps.SetOffset( scrlMaps.GetValue(), FALSE );
	}
	static void CreateServer_Scrolled ( void ) {
		scrlMaps.SetValue( lsbMaps.GetOffset() );
	}

	if ( !g_iCreateServerInitialized ) {
		g_iCreateServerInitialized = TRUE;
		winCreate = spawn( CUIWindow );
		winCreate.SetTitle( "Create Server" );
		winCreate.SetSize( '338 385' );
		winCreate.SetIcon( "gfx/icon16/server_add" );

		lsbMaps = spawn( CUIList );
		lsbMaps.SetSize( '128 306' );
		lsbMaps.SetPos( '175 32 ' );
		lsbMaps.SetItemCount( MapLibrary_GetMapCount() );
		lsbMaps.CallOnScroll( CreateServer_Scrolled );
		lsbMaps.SetSelected( 0 );

		lsbMaps.AddItem( "< Random Map >" );
		for ( int i = 0; i < MapLibrary_GetMapCount(); i++ ) {
			string strMap = MapLibrary_GetInfo(i, MAPINFO_NAME);
			lsbMaps.AddItem( strMap );
			//lsbMaps.AddItem( search_getfilename( shMaps, i ) );
		}

		scrlMaps = spawn( CUIScrollbar );
		scrlMaps.SetLength( 306 );
		scrlMaps.SetPos( '303 32' );
		scrlMaps.SetMin( 0 );
		scrlMaps.SetStep( 1 );
		scrlMaps.SetMax( lsbMaps.GetMaxVisibleItems() );
		scrlMaps.CallOnChange( CreateServer_ListUpdate );

		btnStart = spawn( CUIButton );
		btnStart.SetTitle( "Start" );
		btnStart.SetSize( '64 24' );
		btnStart.SetPos( winCreate.GetSize() - '152 32' );
		btnStart.SetFunc( CreateServer_Start );

		btnCancel = spawn( CUIButton );
		btnCancel.SetTitle( "Cancel" );
		btnCancel.SetSize( '64 24' );
		btnCancel.SetPos( winCreate.GetSize() - '80 32' );
		btnCancel.SetFunc( CreateServer_Cancel );

		lblHostname = spawn( CUILabel );
		lblHostname.SetPos( '20 32' );
		lblHostname.SetTitle( "Server name" );

		txbHostname = spawn( CUITextBox );
		txbHostname.SetPos( [ 20, 50 ] );
		txbHostname.SetSize( [ 124, 24 ] );
		txbHostname.SetText( cvar_string( "hostname" ) );

		lblMaxplayers = spawn( CUILabel );
		lblMaxplayers.SetPos( '20 84' );
		lblMaxplayers.SetTitle( "Max players" );

		txbMaxplayers = spawn( CUITextBox );
		txbMaxplayers.SetPos( [ 20, 102 ] );
		txbMaxplayers.SetSize( [ 124, 24 ] );
		txbMaxplayers.SetText( cvar_string( "sv_playerslots" ) != "1" ? cvar_string( "sv_playerslots" ) : "8" );

		lblPassword = spawn( CUILabel );
		lblPassword.SetPos( '20 136' );
		lblPassword.SetTitle( "Password" );

		txbPassword = spawn( CUITextBox );
		txbPassword.SetPos( [ 20, 154 ] );
		txbPassword.SetSize( [ 124, 24 ] );
		txbPassword.SetText( cvar_string( "sv_password" ) );

		g_uiDesktop.Add( winCreate );
		winCreate.Add( lsbMaps );
		winCreate.Add( scrlMaps );
		winCreate.Add( btnStart );
		winCreate.Add( btnCancel );
		winCreate.Add( lblHostname );
		winCreate.Add( txbHostname );
		winCreate.Add( lblMaxplayers );
		winCreate.Add( txbMaxplayers );
		winCreate.Add( lblPassword );
		winCreate.Add( txbPassword );
	}

	winCreate.Show();
	winCreate.SetPos( ( g_vidsize / 2 ) - ( winCreate.GetSize() / 2 ) );
}
