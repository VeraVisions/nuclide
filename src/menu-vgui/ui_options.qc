/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

int g_iServerBrowserInitialized;

var string autocvar_ui_name = "Player";

void UI_Options_Show ( void )
{
	static vguiWindow winServers;
	static vguiButton btnCancel;
	static vguiButton btnApply;
	static vguiButton btnOK;

	static vguiButton tabMultiplayer;
	static vguiButton tabMouse;
	static vguiButton tabKeyboard;
	static vguiButton tabAudio;
	static vguiButton tabVideo;
	static vguiButton tabVoice;

	static vguiPic picPlayerModel;
	static vguiLabel lblPlayerName;
	static vguiTextBox txbPlayerName;

	static vguiLabel lblResolution;
	static vguiListBox lbxResolution;
	static vguiLabel lblDisplayModes;
	static vguiListBox lbxDisplayModes;
	static vguiLabel lblAspectRatio;
	static vguiListBox lbxAspectRatio;

	static void Multiplayer_Hide ( void ) {
		picPlayerModel.Hide();
		lblPlayerName.Hide();
		txbPlayerName.Hide();
	}
	static void Mouse_Hide ( void ) {
	}
	static void Keyboard_Hide ( void ) {
	}
	static void Audio_Hide ( void ) {
	}
	static void Video_Hide ( void ) {
		lblResolution.Hide();
		lblDisplayModes.Hide();
		lblAspectRatio.Hide();
		lbxResolution.Hide();
		lbxDisplayModes.Hide();
		lbxAspectRatio.Hide();
	}
	static void Voice_Hide ( void ) {
	}

	static void Multiplayer_Show ( void ) {
		picPlayerModel.Show();
		lblPlayerName.Show();
		txbPlayerName.Show();

		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();
	}
	static void Mouse_Show ( void ) {
		Multiplayer_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();
	}
	static void Keyboard_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Audio_Hide();
		Video_Hide();
		Voice_Hide();
	}
	static void Audio_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Video_Hide();
		Voice_Hide();
	}
	static void Video_Show ( void ) {
		lblResolution.Show();
		lblDisplayModes.Show();
		lblAspectRatio.Show();
		lbxResolution.Show();
		lbxDisplayModes.Show();
		lbxAspectRatio.Show();

		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Voice_Hide();
	}
	static void Voice_Show ( void ) {
		Multiplayer_Hide();
		Mouse_Hide();
		Keyboard_Hide();
		Audio_Hide();
		Video_Hide();
	}

	static void Options_Cancel ( void ) {
		winServers.Hide();
	}
	static void Options_Apply ( void ) {
		string playerName = txbPlayerName.GetText();
		cvar_set("name", playerName);
		cvar_set("ui_name", playerName);
	}
	static void Options_OK ( void ) {
		Options_Apply();
		Options_Cancel();
	}

	if ( !g_iServerBrowserInitialized ) {
		g_iServerBrowserInitialized = TRUE;
		winServers = spawn( vguiWindow );
		winServers.SetTitle( "Options" );
		winServers.SetSize( '512 406' );
		winServers.SetIcon( "gfx/icon16/cog" );

		tabMultiplayer = spawn( vguiButton );
		tabMultiplayer.SetTitle( "Multiplayer" );
		tabMultiplayer.SetIcon( "gfx/icon16/vcard" );
		tabMultiplayer.SetPos( [8,32] );
		tabMultiplayer.SetFunc( Multiplayer_Show );

		tabKeyboard = spawn( vguiButton );
		tabKeyboard.SetTitle( "Keyboard" );
		tabKeyboard.SetIcon( "gfx/icon16/keyboard" );
		tabKeyboard.SetPos( tabMultiplayer.GetPos() + [tabMultiplayer.GetWidth() + 8, 0] );
		tabKeyboard.SetFunc( Keyboard_Show );

		tabMouse = spawn( vguiButton );
		tabMouse.SetTitle( "Mouse" );
		tabMouse.SetIcon( "gfx/icon16/mouse" );
		tabMouse.SetPos( tabKeyboard.GetPos() + [tabKeyboard.GetWidth() + 8, 0] );
		tabMouse.SetFunc( Mouse_Show );

		tabAudio = spawn( vguiButton );
		tabAudio.SetTitle( "Audio" );
		tabAudio.SetIcon( "gfx/icon16/sound" );
		tabAudio.SetPos( tabMouse.GetPos() + [tabMouse.GetWidth() + 8, 0] );
		tabAudio.SetFunc( Audio_Show );

		tabVideo = spawn( vguiButton );
		tabVideo.SetTitle( "Video" );
		tabVideo.SetIcon( "gfx/icon16/monitor" );
		tabVideo.SetPos( tabAudio.GetPos() + [tabAudio.GetWidth() + 8, 0] );
		tabVideo.SetFunc( Video_Show );

		tabVoice = spawn( vguiButton );
		tabVoice.SetTitle( "Voice" );
		tabVoice.SetIcon( "gfx/icon16/telephone" );
		tabVoice.SetPos( tabVideo.GetPos() + [tabVideo.GetWidth() + 8, 0] );
		tabVoice.SetFunc( Voice_Show );

		btnOK = spawn( vguiButton );
		btnOK.SetTitle("OK");
		btnOK.SetPos([267,373]);
		btnOK.SetSize([72,24]);
		btnOK.SetFunc( Options_OK );

		btnCancel = spawn( vguiButton );
		btnCancel.SetTitle("Cancel");
		btnCancel.SetPos(  btnOK.GetPos() + [btnOK.GetWidth() + 8, 0] );
		btnCancel.SetSize([72,24]);
		btnCancel.SetFunc( Options_Cancel );

		btnApply = spawn( vguiButton );
		btnApply.SetTitle( "Apply" );
		btnApply.SetPos(  btnCancel.GetPos() + [btnCancel.GetWidth() + 8, 0] );
		btnApply.SetSize([72,24]);
		btnApply.SetFunc( Options_Apply );

		/* multiplayer tab */
		picPlayerModel = spawn(vguiPic);
		picPlayerModel.SetPos( [265, 87] );
		picPlayerModel.SetSize( [190, 203] );
		picPlayerModel.SetBorder(4);

		lblPlayerName = spawn(vguiLabel);
		lblPlayerName.SetTitle( "Player name" );
		lblPlayerName.SetPos('20 87' );
		lblPlayerName.SetSize( [232, 24] );

		txbPlayerName = spawn( vguiTextBox );
		txbPlayerName.SetPos( lblPlayerName.GetPos() + [0, lblPlayerName.GetHeight() + 8] );
		txbPlayerName.SetSize( [ 124, 24 ] );
		txbPlayerName.SetText( STRING_SET(cvar_string( "ui_name" )) ?  cvar_string( "ui_name" ) : cvar_string( "name" ) );

		winServers.Add( picPlayerModel );
		winServers.Add( lblPlayerName );
		winServers.Add( txbPlayerName );

		/* keyboard tab */

		/* mouse tab */

		/* video tab */
		lblResolution = spawn(vguiLabel);
		lblResolution.SetTitle( "Resolution" );
		lblResolution.SetPos('20 87' );
		lblResolution.SetSize( [232, 24] );

		lbxResolution = spawn(vguiListBox);
		lbxResolution.SetPos(lblResolution.GetPos() + [0, lblResolution.GetHeight() + 8]);
		lbxResolution.SetSize( [232, 24] );
		lbxResolution.SetItemCount(1);
		lbxResolution.AddItem( "640x480" );

		lblDisplayModes = spawn(vguiLabel);
		lblDisplayModes.SetTitle( "Display Mode" );
		lblDisplayModes.SetPos('262 87' );
		lblDisplayModes.SetSize( [232, 24] );

		lbxDisplayModes = spawn(vguiListBox);
		lbxDisplayModes.SetPos(lblDisplayModes.GetPos() + [0, lblDisplayModes.GetHeight() + 8]);
		lbxDisplayModes.SetSize( [232, 24] );
		lbxDisplayModes.SetItemCount(1);
		lbxDisplayModes.AddItem( "Windowed" );

		lblAspectRatio = spawn(vguiLabel);
		lblAspectRatio.SetTitle( "Aspect Ratio" );
		lblAspectRatio.SetPos('20 164' );
		lblAspectRatio.SetSize( [232, 24] );

		lbxAspectRatio = spawn(vguiListBox);
		lbxAspectRatio.SetPos(lblAspectRatio.GetPos() + [0, lblAspectRatio.GetHeight() + 8]);
		lbxAspectRatio.SetSize( [232, 24] );
		lbxAspectRatio.SetItemCount(1);
		lbxAspectRatio.AddItem( "4:3" );

		winServers.Add( lblResolution );
		winServers.Add( lblDisplayModes );
		winServers.Add( lblAspectRatio );
		winServers.Add( lbxResolution );
		winServers.Add( lbxDisplayModes );
		winServers.Add( lbxAspectRatio );

		/* audio tab */

		/* voice tab */


		g_uiDesktop.Add( winServers );
		winServers.Add( btnOK );
		winServers.Add( btnCancel );
		winServers.Add( btnApply );
		winServers.Add( tabMultiplayer );
		winServers.Add( tabKeyboard );
		winServers.Add( tabMouse );
		winServers.Add( tabVideo );
		winServers.Add( tabAudio );
		winServers.Add( tabVoice );

		Multiplayer_Show();
	}

	winServers.Show();
	winServers.SetPos( ( g_vidsize / 2 ) - ( winServers.GetSize() / 2 ) );
}
