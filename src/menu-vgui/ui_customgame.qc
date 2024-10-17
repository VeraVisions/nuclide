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

int g_iCustomGameInitialized;

void UI_CustomGame_Show ( void )
{
	static CUIWindow winCustomGame;
	static CUIList lsbGames;
	static CUIScrollbar scrlGames;
	static CUIButton btnLoad;

	static void CustomGame_Play ( void ) {
		GameLibrary_Activate(lsbGames.GetSelected());
	}

	static void CustomGame_ScrollUpdate ( void ) {
		scrlGames.SetValue( lsbGames.GetOffset() );
	}
	static void CustomGame_ListUpdate ( void ) {
		lsbGames.SetOffset( scrlGames.GetValue(), FALSE );
	}

	if ( !g_iCustomGameInitialized ) {
		g_iCustomGameInitialized = TRUE;

		GameLibrary_InitCustom();

		winCustomGame = spawn( CUIWindow );
		winCustomGame.SetTitle( "Custom Game" );
		winCustomGame.SetSize( [256,180] );
		winCustomGame.SetIcon( "gfx/icon16/rainbow" );

		lsbGames = spawn( CUIList );
		lsbGames.SetSize( [192, 96] );
		lsbGames.SetPos( [8, 32] );
		lsbGames.SetItemCount( GameLibrary_GetGameCount() );
		lsbGames.CallOnScroll( CustomGame_ScrollUpdate );

		for ( int i = 0; i < GameLibrary_GetGameCount(); i++ ) {
			lsbGames.AddItem( GameLibrary_GetGameInfo(i, GAMEINFO_TITLE) );
		}

		scrlGames = spawn( CUIScrollbar );
		scrlGames.SetLength( 96 );
		scrlGames.SetPos( [201,32] );
		scrlGames.SetMin( 0 );
		scrlGames.SetStep( 1 );
		scrlGames.SetMax( lsbGames.GetMaxVisibleItems() );
		scrlGames.CallOnChange( CustomGame_ListUpdate );

		btnLoad = spawn( CUIButton );
		btnLoad.SetTitle( "Load" );
		btnLoad.SetIcon( "gfx/icon16/control_play" );
		btnLoad.SetPos( [8,132] );
		btnLoad.SetSize([64,24]);
		btnLoad.SetFunc( CustomGame_Play );

		g_uiDesktop.Add( winCustomGame );
		winCustomGame.Add( lsbGames );
		winCustomGame.Add( scrlGames );
		winCustomGame.Add( btnLoad );
	}

	winCustomGame.Show();
	winCustomGame.SetPos( ( g_vidsize / 2 ) - ( winCustomGame.GetSize() / 2 ) );
}
