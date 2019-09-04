/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

int g_iQuitGameInitialized;

void UI_QuitGame_Show ( void )
{
	static CUIWindow winQuitGame;
	static CUILabel lblSure;
	static CUIButton btnQuit;
	static CUIButton btnCancel;

	static void QuitGame_Yes ( void ) {
		winQuitGame.Hide();
		localcmd( "quit\n" );
	}
	static void QuitGame_No ( void ) {
		winQuitGame.Hide();
	}
	if ( !g_iQuitGameInitialized ) {
		g_iQuitGameInitialized = TRUE;
		winQuitGame = spawn( CUIWindow );
		winQuitGame.SetTitle( "Quit Game" );
		winQuitGame.SetSize( '256 128' );
		winQuitGame.SetIcon( "textures/ui/icons/cancel" );
		g_uiDesktop.Add( winQuitGame );

		btnQuit = spawn( CUIButton );
		btnQuit.SetTitle( "Quit" );
		btnQuit.SetSize( '64 24' );
		btnQuit.SetPos( winQuitGame.GetSize() - '152 32' );
		
		btnCancel = spawn( CUIButton );
		btnCancel.SetTitle( "Cancel" );
		btnCancel.SetSize( '64 24' );
		btnCancel.SetPos( winQuitGame.GetSize() - '80 32' );

		lblSure = spawn( CUILabel );
		lblSure.SetTitle( "Do you wish to stop playing now?" );
		lblSure.SetSize( '256 16' );
		lblSure.SetPos( '0 48' );

		btnQuit.SetFunc( QuitGame_Yes );
		btnCancel.SetFunc( QuitGame_No );

		winQuitGame.Add( btnQuit );
		winQuitGame.Add( btnCancel );
		winQuitGame.Add( lblSure );
	}

	winQuitGame.Show();
	winQuitGame.SetPos( ( video_res / 2 ) - ( winQuitGame.GetSize() / 2 ) );
}
