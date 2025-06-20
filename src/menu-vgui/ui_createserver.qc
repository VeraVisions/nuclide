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

var int autocvar_ui_maxclients = 8i;


int g_iCreateServerInitialized;

void UI_CreateServer_Show ( void )
{
	static vguiScrollBar scrlMaps;
	static vguiScrollBar scrlModes;
	static vguiWindow winCreate;
	static vguiButton btnCancel;
	static vguiButton btnStart;
	static vguiList lsbMaps;
	static vguiList lsbModes;
	static vguiLabel lblModes;
	static vguiLabel lblHostname;
	static vguiTextBox txbHostname;
	static vguiLabel lblMaxplayers;
	static vguiTextBox txbMaxplayers;
	static vguiLabel lblPassword;
	static vguiTextBox txbPassword;
	static vguiCheckbox chkLAN;

	static void CreateServer_Start ( void ) {
		int iEndMap = lsbMaps.GetSelected();
		if ( lsbMaps.GetSelected() == 0 ) {
			iEndMap = (int)( rint( random( 1, lsbMaps.GetItemCount() ) ) );
		}

		string gameType = lsbModes.GetItem( lsbModes.GetSelected() );

		if (chkLAN.GetValue() == true) {
			cvar_set("sv_public", "0");	
		} else {
			cvar_set("sv_public", "2");	
		}

		Map_SpawnServer(txbHostname.GetText(), lsbMaps.GetItem( iEndMap ), stof(txbMaxplayers.GetText()), gameType, txbPassword.GetText());
		winCreate.Hide();
	}
	static void CreateServer_Cancel ( void ) {
		winCreate.Hide();
	}
	static void CreateServer_ListUpdate ( void ) {
		lsbMaps.SetOffset( scrlMaps.GetValue(), FALSE );
	}
	static void CreateServer_ListUpdateMode ( void ) {
		lsbModes.SetOffset( scrlModes.GetValue(), FALSE );
	}
	static void CreateServer_Scrolled ( void ) {
		scrlMaps.SetValue( lsbMaps.GetOffset() );
	}
	static void CreateServer_ScrolledMode ( void ) {
		scrlModes.SetValue( lsbModes.GetOffset() );
	}

	if ( !g_iCreateServerInitialized ) {
		g_iCreateServerInitialized = TRUE;
		winCreate = spawn( vguiWindow );
		winCreate.SetTitle( "Create Server" );
		winCreate.SetSize( '338 385' );
		winCreate.SetIcon( "gfx/icon16/server_add" );

		lsbMaps = spawn( vguiList );
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

		chkLAN = spawn( vguiCheckbox );
		chkLAN.SetTitle( "LAN Game" );
		chkLAN.SetValue( TRUE );
		chkLAN.SetSize( '124 24' );
		chkLAN.SetPos( '20 186' );

		lblModes = spawn( vguiLabel );
		lblModes.SetPos( '20 218' );
		lblModes.SetTitle( "Gametype" );

		scrlMaps = spawn( vguiScrollBar );
		scrlMaps.SetLength( 306 );
		scrlMaps.SetPos( '303 32' );
		scrlMaps.SetMin( 0 );
		scrlMaps.SetStep( 1 );
		scrlMaps.SetMax( lsbMaps.GetMaxVisibleItems() );
		scrlMaps.CallOnChange( CreateServer_ListUpdate );

		lsbModes = spawn( vguiList );
		lsbModes.SetSize( '128 128' );
		lsbModes.SetPos( '20 234' );
		lsbModes.SetItemCount( ModeLibrary_GetModeCount() );
		lsbModes.CallOnScroll( CreateServer_ScrolledMode );
		lsbModes.SetSelected( 0 );

		for ( int i = 0; i < ModeLibrary_GetModeCount(); i++ ) {
			string strMode = substring(ModeLibrary_GetInfo(i, MODEINFO_NAME), 0, -5);
			lsbModes.AddItem( strMode );
			//lsbMaps.AddItem( search_getfilename( shMaps, i ) );
		}

		scrlModes = spawn( vguiScrollBar );
		scrlModes.SetLength( 128 );
		scrlModes.SetPos(  '195 234' );
		scrlModes.SetMin( 0 );
		scrlModes.SetStep( 1 );
		scrlModes.SetMax( lsbModes.GetMaxVisibleItems() );
		scrlModes.CallOnChange( CreateServer_ListUpdateMode );

		btnStart = spawn( vguiButton );
		btnStart.SetTitle( "Start" );
		btnStart.SetSize( '64 24' );
		btnStart.SetPos( winCreate.GetSize() - '152 32' );
		btnStart.SetFunc( CreateServer_Start );

		btnCancel = spawn( vguiButton );
		btnCancel.SetTitle( "Cancel" );
		btnCancel.SetSize( '64 24' );
		btnCancel.SetPos( winCreate.GetSize() - '80 32' );
		btnCancel.SetFunc( CreateServer_Cancel );

		lblHostname = spawn( vguiLabel );
		lblHostname.SetPos( '20 32' );
		lblHostname.SetTitle( "Server name" );

		txbHostname = spawn( vguiTextBox );
		txbHostname.SetPos( [ 20, 50 ] );
		txbHostname.SetSize( [ 124, 24 ] );
		txbHostname.SetText( cvar_string( "hostname" ) );

		lblMaxplayers = spawn( vguiLabel );
		lblMaxplayers.SetPos( '20 84' );
		lblMaxplayers.SetTitle( "Max players" );

		txbMaxplayers = spawn( vguiTextBox );
		txbMaxplayers.SetPos( [ 20, 102 ] );
		txbMaxplayers.SetSize( [ 124, 24 ] );
		txbMaxplayers.SetText( cvar( "ui_maxclients" ) != 0 ? cvar_string( "ui_maxclients" ) : "8" );

		lblPassword = spawn( vguiLabel );
		lblPassword.SetPos( '20 136' );
		lblPassword.SetTitle( "Password" );

		txbPassword = spawn( vguiTextBox );
		txbPassword.SetPos( [ 20, 154 ] );
		txbPassword.SetSize( [ 124, 24 ] );
		txbPassword.SetText( cvar_string( "sv_password" ) );

		g_uiDesktop.Add( winCreate );
		winCreate.Add( lsbMaps );
		winCreate.Add( lblModes );
		winCreate.Add( scrlMaps );
		winCreate.Add( lsbModes );
		winCreate.Add( scrlModes );
		winCreate.Add( btnStart );
		winCreate.Add( btnCancel );
		winCreate.Add( lblHostname );
		winCreate.Add( txbHostname );
		winCreate.Add( lblMaxplayers );
		winCreate.Add( txbMaxplayers );
		winCreate.Add( lblPassword );
		winCreate.Add( txbPassword );
		winCreate.Add( chkLAN );
	}

	winCreate.Show();
	winCreate.SetPos( ( g_vidsize / 2 ) - ( winCreate.GetSize() / 2 ) );
}
