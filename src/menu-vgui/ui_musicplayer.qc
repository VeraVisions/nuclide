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

int g_iMusicPlayerInitialized;

void UI_MusicPlayer_Show ( void )
{
	static CUIWindow winMusicPlayer;
	static CUIList lsbSongs;
	static CUIScrollbar scrlSong;
	static CUIButton btnPlay;
	static CUIButton btnStop;

	static void MusicPlayer_Play ( void ) {
		string strSong;
		strSong = lsbSongs.GetItem( lsbSongs.GetSelected() );
		localcmd( sprintf( "play %S\n", strSong ) );
	}
	static void MusicPlayer_Stop ( void ) {
		localcmd( "stopsound\n" );
	}
	static void MusicPlayer_ScrollUpdate ( void ) {
		scrlSong.SetValue( lsbSongs.GetOffset(), FALSE );
	}
	static void MusicPlayer_ListUpdate ( void ) {
		lsbSongs.SetOffset( scrlSong.GetValue(), FALSE );
	}

	if ( !g_iMusicPlayerInitialized ) {
		g_iMusicPlayerInitialized = TRUE;
		winMusicPlayer = spawn( CUIWindow );
		winMusicPlayer.SetTitle( "Music Player" );
		winMusicPlayer.SetSize( [256,180] );
		winMusicPlayer.SetIcon( "gfx/icon16/ipod" );

		searchhandle shSongs = search_begin( "music/*.flac:music/*.wav:music/*.ogg:media/*.mp3:sound/music/*.mp3", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
		lsbSongs = spawn( CUIList );
		lsbSongs.SetSize( [192, 96] );
		lsbSongs.SetPos( [8, 32] );
		lsbSongs.SetItemCount( search_getsize( shSongs ) );
		lsbSongs.CallOnScroll( MusicPlayer_ScrollUpdate );

		for ( int i = 0; i < search_getsize( shSongs ); i++ ) {
			lsbSongs.AddItem( search_getfilename( shSongs, i ) );
		}

		scrlSong = spawn( CUIScrollbar );
		scrlSong.SetLength( 96 );
		scrlSong.SetPos( [201,32] );
		scrlSong.SetMin( 0 );
		scrlSong.SetStep( 1 );
		scrlSong.SetMax( lsbSongs.GetMaxVisibleItems() );
		scrlSong.CallOnChange( MusicPlayer_ListUpdate );

		btnPlay = spawn( CUIButton );
		btnPlay.SetTitle( "Play" );
		btnPlay.SetIcon( "gfx/icon16/control_play" );
		btnPlay.SetPos( [8,132] );
		btnPlay.SetSize([64,24]);
		btnPlay.SetFunc( MusicPlayer_Play );

		btnStop = spawn( CUIButton );
		btnStop.SetTitle( "Stop" );
		btnStop.SetIcon( "gfx/icon16/control_stop" );
		btnStop.SetPos( [96,132] );
		btnStop.SetSize([64,24]);
		btnStop.SetFunc( MusicPlayer_Stop );

		g_uiDesktop.Add( winMusicPlayer );
		winMusicPlayer.Add( lsbSongs );
		winMusicPlayer.Add( scrlSong );
		winMusicPlayer.Add( btnPlay );
		winMusicPlayer.Add( btnStop );
		search_end( shSongs );
	}

	winMusicPlayer.Show();
	winMusicPlayer.SetPos( ( g_vidsize / 2 ) - ( winMusicPlayer.GetSize() / 2 ) );
}
