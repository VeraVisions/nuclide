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
		winQuitGame.SetIcon( "gfx/icon16/stop" );
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
		lblSure.SetAlignment(AF_NONE);

		btnQuit.SetFunc( QuitGame_Yes );
		btnCancel.SetFunc( QuitGame_No );

		winQuitGame.Add( btnQuit );
		winQuitGame.Add( btnCancel );
		winQuitGame.Add( lblSure );
	}

	winQuitGame.Show();
	winQuitGame.SetPos( ( g_vidsize / 2 ) - ( winQuitGame.GetSize() / 2 ) );
}
