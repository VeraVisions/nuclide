

void VGUI_BuyMenu(void)
{
	static int initialized;
	static CUIWindow winMusicPlayer;
	static CUIButton btnPlay;
	static CUIButton btnStop;

	if ( !initialized ) {
		initialized = TRUE;
		winMusicPlayer = spawn( CUIWindow );
		winMusicPlayer.SetTitle( "Music Player" );
		winMusicPlayer.SetSize( '256 180' );
		winMusicPlayer.SetIcon( "textures/ui/icons/cd" );

		btnPlay = spawn( CUIButton );
		btnPlay.SetTitle( "Play" );
		btnPlay.SetPos( '8 132' );
		//btnPlay.SetFunc( MusicPlayer_Play );

		btnStop = spawn( CUIButton );
		btnStop.SetTitle( "Stop" );
		btnStop.SetPos( '96 132' );
		//btnStop.SetFunc( MusicPlayer_Stop );

		g_uiDesktop.Add( winMusicPlayer );
		winMusicPlayer.Add( btnPlay );
		winMusicPlayer.Add( btnStop );
	}

	winMusicPlayer.Show();
	winMusicPlayer.SetPos( ( video_res / 2 ) - ( winMusicPlayer.GetSize() / 2 ) );
}
