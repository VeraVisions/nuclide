

void VGUI_MessageOfTheDay(void)
{
	static int initialized;
	static CUIWindow winMOTD;
	static CUIButton btnOK;

	if ( !initialized ) {
		initialized = TRUE;
		winMOTD = spawn( CUIWindow );
		winMOTD.SetTitle( "Message Of The Day" );
		winMOTD.SetSize( '420 320' );
		winMOTD.SetIcon( "textures/ui/icons/cd" );

		btnOK = spawn( CUIButton );
		btnOK.SetTitle( "Play" );
		btnOK.SetPos( '8 132' );
		//btnPlay.SetFunc( MusicPlayer_Play );

		g_uiDesktop.Add( winMOTD );
		winMOTD.Add( btnOK );
	}

	winMOTD.Show();
	winMOTD.SetPos( ( video_res / 2 ) - ( winMOTD.GetSize() / 2 ) );
}
