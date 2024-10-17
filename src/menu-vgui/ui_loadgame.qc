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

int g_iLoadGameInitialized;

void UI_LoadGame_Show ( void )
{
	static CUIWindow winLoadGame;
	static CUIList lsbSaves;
	static CUIScrollbar scrlSaves;
	static CUIButton btnLoad;

	static void LoadGame_Play ( void ) {
		string strSong;
		strSong = lsbSaves.GetItem( lsbSaves.GetSelected() );
		localcmd( sprintf( "load %s\n", strSong) );
	}

	static void LoadGame_ScrollUpdate ( void ) {
		scrlSaves.SetValue( lsbSaves.GetOffset() );
	}
	static void LoadGame_ListUpdate ( void ) {
		lsbSaves.SetOffset( scrlSaves.GetValue(), FALSE );
	}

	if ( !g_iLoadGameInitialized ) {
		g_iLoadGameInitialized = TRUE;
		winLoadGame = spawn( CUIWindow );
		winLoadGame.SetTitle( "Load Game" );
		winLoadGame.SetSize( [256,180] );
		winLoadGame.SetIcon( "gfx/icon16/music" );

		lsbSaves = spawn( CUIList );
		lsbSaves.SetSize( [192, 96] );
		lsbSaves.SetPos( [8, 32] );
		lsbSaves.SetItemCount( Saves_GetSaveCount() );
		lsbSaves.CallOnScroll( LoadGame_ScrollUpdate );

		for ( int i = 0; i < Saves_GetSaveCount(); i++ ) {
			lsbSaves.AddItem( Saves_GetInfo(i, SAVEINFO_NAME) );
		}

		scrlSaves = spawn( CUIScrollbar );
		scrlSaves.SetLength( 96 );
		scrlSaves.SetPos( [201,32] );
		scrlSaves.SetMin( 0 );
		scrlSaves.SetStep( 1 );
		scrlSaves.SetMax( lsbSaves.GetMaxVisibleItems() );
		scrlSaves.CallOnChange( LoadGame_ListUpdate );

		btnLoad = spawn( CUIButton );
		btnLoad.SetTitle( "Load" );
		btnLoad.SetIcon( "gfx/icon16/book_edit" );
		btnLoad.SetPos( [8,132] );
		btnLoad.SetSize([64,24]);
		btnLoad.SetFunc( LoadGame_Play );

		g_uiDesktop.Add( winLoadGame );
		winLoadGame.Add( lsbSaves );
		winLoadGame.Add( scrlSaves );
		winLoadGame.Add( btnLoad );
	}

	winLoadGame.Show();
	winLoadGame.SetPos( ( g_vidsize / 2 ) - ( winLoadGame.GetSize() / 2 ) );
}
