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

int g_iNewGameInitialized;

void UI_NewGame_Show ( void )
{
	static vguiWindow winNewGame;
	static vguiButton btnPlay;
	static vguiButton btnCancel;
	static vguiRadio radTraining;
	static vguiRadio radEasy;
	static vguiRadio radMedium;
	static vguiRadio radHard;

	static void NewGame_Play ( void ) {
		if (radTraining.GetValue())
			Map_Training();
		else
			Map_NewGame(cvar("skill"));

		winNewGame.Hide();
	}
	static void NewGame_Cancel ( void ) {
		winNewGame.Hide();
	}
	static void NewGame_Uncheck ( void ) {
		radTraining.SetValue( FALSE );
		radEasy.SetValue( FALSE );
		radMedium.SetValue( FALSE );
		radHard.SetValue( FALSE );
	}

	if ( !g_iNewGameInitialized ) {
		g_iNewGameInitialized = TRUE;
		winNewGame = spawn( vguiWindow );
		winNewGame.SetTitle( "New Game" );
		winNewGame.SetSize( '192 168' );
		winNewGame.SetIcon( "gfx/icon16/new" );
		g_uiDesktop.Add( winNewGame );

		btnPlay = spawn( vguiButton );
		btnPlay.SetTitle( "Play" );
		btnPlay.SetSize( '64 24' );
		btnPlay.SetPos( winNewGame.GetSize() - '152 32' );
		btnPlay.SetFunc( NewGame_Play );

		btnCancel = spawn( vguiButton );
		btnCancel.SetTitle( "Cancel" );
		btnCancel.SetSize( '64 24' );
		btnCancel.SetPos( winNewGame.GetSize() - '80 32' );
		btnCancel.SetFunc( NewGame_Cancel );

		radTraining = spawn( vguiRadio );
		radTraining.SetTitle( "Training" );
		radTraining.SetSize( '96 16' );
		radTraining.SetPos( '32 32' );

		radEasy = spawn( vguiRadio );
		radEasy.SetTitle( "Easy" );
		radEasy.SetSize( '96 16' );
		radEasy.SetPos( '32 56' );

		radMedium = spawn( vguiRadio );
		radMedium.SetTitle( "Medium" );
		radMedium.SetSize( '96 16' );
		radMedium.SetPos( '32 80' );
		radMedium.SetValue( TRUE );

		radHard = spawn( vguiRadio );
		radHard.SetTitle( "Hard" );
		radHard.SetSize( '96 16' );
		radHard.SetPos( '32 104' );

		radTraining.SetFunc( NewGame_Uncheck );
		radEasy.SetFunc( NewGame_Uncheck );
		radMedium.SetFunc( NewGame_Uncheck );
		radHard.SetFunc( NewGame_Uncheck );

		winNewGame.Add( btnPlay );
		winNewGame.Add( btnCancel );
		winNewGame.Add( radTraining );
		winNewGame.Add( radEasy );
		winNewGame.Add( radMedium );
		winNewGame.Add( radHard );
	}

	winNewGame.Show();
	winNewGame.SetPos( ( g_vidsize / 2 ) - ( winNewGame.GetSize() / 2 ) );
}
