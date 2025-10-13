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

bool g_iPlayerListInitialized;

void VGUI_PlayerList ( void )
{
	static entity eModel;
	static vector vecDistance = [ 90, 0, 0 ];
	static vguiWindow winPlayerList;
	static vgui3DView viewModel;
	static vguiPic picBackground;
	
	
	static vguiPic picAvatar;
	static vguiLabel lblPlayerName;
	static vguiPic picFlag;
	static vguiPic picGradient;
	static vguiPic picHGradient;
	static vguiLabel lblContact;
	static vguiLabel lblOnlineStatus;
	static vguiLabel lblInfoText;

	static vguiList lstPlayers;
	static vguiScrollBar scrlPlayers;

	static void VGUI_PlayerList_ResetCam( void ) {
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));
		modelPos[2] = (eModel.absmin[2] + (0.75 * (eModel.absmax[2] - eModel.absmin[2])));
		
		vecDistance = [ 90, 0, 0 ];
		viewModel.Set3DAngles( [0,180,0] );
		viewModel.Set3DPos( modelPos );

		makevectors( viewModel.Get3DAngles() );
		viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
	}

	static void VGUI_PlayerList_SetFrame( int iFrame ) {
		if (!eModel) {
			return;
		}
	
		float maxFrame = modelframecount(eModel.modelindex) - 1;
		eModel.frame = (float)iFrame;

		if (eModel.frame < 0) {
			eModel.frame = 0;
		}

		eModel.frame1time = 0;
	}
	static void VGUI_PlayerList_SetModel( string strModel ) {
		if (!eModel) {
			return;
		}

		setmodel( eModel, strModel );
		VGUI_PlayerList_SetFrame( 0 );
		VGUI_PlayerList_ResetCam();
	}
	static void VGUI_PlayerList_Draw ( void ) {
		static int initialized = FALSE;
		if ( !initialized ) {
			initialized = TRUE;
			eModel = spawn();
		}
		addentity( eModel );
		eModel.frame1time += frametime;
	}
	static float VGUI_PlayerList_Input ( float flEVType, float flKey, float flChar, float flDevID ) {
		static int iMouseDrag = FALSE;
		static int iShiftDrag = FALSE;
		static vector vecDragOfs;
		vector vecDifference;
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));
		modelPos[2] = (eModel.absmin[2] + (0.75 * (eModel.absmax[2] - eModel.absmin[2])));

		int iMouseOver =  Util_MouseAbove( getmousepos(), viewModel.m_parent.GetPos() + viewModel.GetPos(), viewModel.GetSize() );
		if ( flEVType == IE_KEYDOWN ) {
			if ( flKey == K_MOUSE1 && iMouseOver == TRUE ) {
				iMouseDrag = TRUE;
				vecDragOfs = getmousepos();
				return true;
			} else if ( flKey == K_MWHEELUP && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, --vecDistance[0], 512 );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				return true;
			} else if ( flKey == K_MWHEELDOWN && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, ++vecDistance[0], 512 );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				return true;
			}
		} else if ( flEVType == IE_KEYUP ) {
			if ( flKey == K_MOUSE1 ) {
				iMouseDrag = FALSE;
			} else if ( flKey == K_LSHIFT ) {
				iShiftDrag = FALSE;
			}
		}

		if ( iMouseDrag == TRUE && iShiftDrag == FALSE ) {
			if ( flEVType == IE_MOUSEABS ) {
				vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
				viewModel.Set3DAngles( viewModel.Get3DAngles() + vecDifference );
				makevectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				vecDragOfs = getmousepos();
				return true;
			}
		} else if ( iMouseDrag == TRUE && iShiftDrag == TRUE ) {
			if ( flEVType == IE_MOUSEABS ) {
				vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
				vecDistance[1] -= vecDifference[1];
				vecDistance[2] += vecDifference[0];
				viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
				vecDragOfs = getmousepos();
				return true;
			}
		}
		return false;
	}
	static void VGUI_PlayerList_Resize ( void ) {
		// Resize the background and viewer
		vector vWinSize = winPlayerList.GetSize();
		picBackground.SetSize( [vWinSize[0] - 12 - 192 - 4, vWinSize[1] - 52 ] );
		picBackground.SetBorder(1);
		picGradient.SetSize( picBackground.GetSize() );
		picHGradient.SetSize( [vWinSize[0] - 12 - 192 - 4, 96 ]);
		viewModel.SetSize( picBackground.GetSize() );
		
		lstPlayers.SetPos( viewModel.GetPos() + [ viewModel.GetSize()[0] + 4, 0 ] );
		lstPlayers.SetSize( [ 172, viewModel.GetSize()[1] ] );
		scrlPlayers.SetPos( lstPlayers.GetPos() + [ 172, 0 ] );
		scrlPlayers.SetLength( viewModel.GetSize()[1] );
		scrlPlayers.SetMax( lstPlayers.GetMaxVisibleItems() );

		picAvatar.SetPos(viewModel.GetPos() + [16, 16]);
		lblPlayerName.SetPos(picAvatar.GetPos() + [picAvatar.GetWidth() + 16, 7]);
		lblOnlineStatus.SetPos(lblPlayerName.GetPos() + [0, 20]);
		picFlag.SetPos(lblOnlineStatus.GetPos() + [64, 0]);
		lblContact.SetPos(lblOnlineStatus.GetPos() + [0, 20]);
		
		lblPlayerName.SetSize([ (lstPlayers.GetPos()[0] + 4) - lblPlayerName.GetPos()[0], 16]);
		lblOnlineStatus.SetSize(lblPlayerName.GetSize());
		lblContact.SetSize(lblPlayerName.GetSize());
		
		lblInfoText.SetPos(picAvatar.GetPos());
		lblInfoText.SetSize([vWinSize[0] - 48 - 192 - 4, vWinSize[1] - 52 ]);
	}

	static void VGUI_PlayerList_ScrollUpdate ( void ) {
		scrlPlayers.SetValue( lstPlayers.GetOffset() );
	}

	static void VGUI_PlayerList_ListUpdate ( void ) {
		lstPlayers.SetOffset( scrlPlayers.GetValue(), FALSE );
	}

	static void VGUI_PlayerList_UpdateDetails ( void ) {
		int selectedEntry = lstPlayers.GetSelected();
		string playerName = "";
		string playerModel = "";
		string playerFedi = "";
		string playerFlag = "";
		string playerAvatar = "";
		string modelIndex = "";
		string playerBG = "";
		
		/* TODO: these should be cached elsewhere, with an API making these accessible */
		if (selectedEntry != -1) {
			ncUserInfo playerInfo = g_userInfo.InfoByIndex(selectedEntry);
			playerName =  playerInfo.Name();
			playerModel =  playerInfo.Model();
			playerFedi =  playerInfo.Contact();
			playerFlag =  playerInfo.Flag();
			playerAvatar =  playerInfo.Avatar();
			modelIndex =  modelnameforindex(getplayerkeyfloat(selectedEntry, "*mi"));
			playerBG =  playerInfo.Banner();
		}

		
		if (!STRING_SET(playerBG)) {
			picBackground.Hide();
			picGradient.Hide();
			picHGradient.Hide();
		} else {
			picBackground.SetImage(playerBG);
			picBackground.Show();
			picGradient.Show();
			picHGradient.Show();
		}

		if (!STRING_SET(playerName)) {
			playerName = "Unconnected";
			playerAvatar = "";
			playerFlag = "";
			playerFedi = "";
			winPlayerList.SetTitle( "User Info - none");
			VGUI_PlayerList_SetModel("");
			picAvatar.Hide();
			picFlag.Hide();
			lblOnlineStatus.Hide();
			lblInfoText.Show();
			lblPlayerName.Hide();
		} else {
			winPlayerList.SetTitle( sprintf( "User Info (%s, id: %i)", strdecolorize(playerName), selectedEntry + 1i) );
			VGUI_PlayerList_SetModel(modelIndex);
			picAvatar.Show();
			picFlag.Show();
			lblOnlineStatus.Show();
			lblInfoText.Hide();
			lblPlayerName.Show();
		}
		
		picAvatar.SetImage(playerAvatar);
		lblPlayerName.SetTitle(playerName);
		lblOnlineStatus.SetTitle("^2ONLINE");
		picFlag.SetImage(playerFlag);
		lblContact.SetTitle(strcat("^7", playerFedi));
	}
	
	if ( !g_iPlayerListInitialized ) {
		g_iPlayerListInitialized = true;
		winPlayerList = spawn( vguiWindow );
		winPlayerList.SetTitle( "User Info" );
		winPlayerList.SetSize( [ 550, 390 ] );
		winPlayerList.SetMinSize( [ 430, 256 ] );
		winPlayerList.SetMaxSize( [ 9999, 9999 ] );
		winPlayerList.SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
		winPlayerList.SetPos( [ 172, 64 ] );
		winPlayerList.SetIcon( "gfx/icon16/user" );
		winPlayerList.CallOnResize( VGUI_PlayerList_Resize );

		picBackground = spawn( vguiPic );
		picBackground.SetPos( [ 6, 32 ] );
		picBackground.SetBorder(1);
		picBackground.Hide();

		picGradient = spawn( vguiPic );
		picGradient.SetPos( [ 6, 32 ] );
		picGradient.Hide();
		picGradient.SetImage("gfx/ui/user_bg_gradient");
		picGradient.SetColor( UI_MAINCOLOR );

		picHGradient = spawn( vguiPic );
		picHGradient.SetPos( [ 6, 32 ] );
		picHGradient.Hide();
		picHGradient.SetImage("gfx/ui/user_header_gradient");
		picHGradient.SetColor( UI_MAINCOLOR );

		viewModel = spawn( vgui3DView );
		viewModel.SetDrawFunc( VGUI_PlayerList_Draw );
		viewModel.SetInputFunc( VGUI_PlayerList_Input );
		viewModel.SetPos( picBackground.GetPos() );

		lstPlayers = spawn( vguiList );
		lstPlayers.SetItemCount( serverinfo.GetInteger("sv_playerslots") );
		lstPlayers.CallOnScroll( VGUI_PlayerList_ScrollUpdate );
		lstPlayers.CallOnSelectionChanged(VGUI_PlayerList_UpdateDetails);

		for ( int i = 0; i < serverinfo.GetInteger("sv_playerslots"); i++ ) {
			lstPlayers.AddItem( getplayerkeyvalue(i, "name") );
		}
		scrlPlayers = spawn( vguiScrollBar );
		scrlPlayers.SetMin( 0 );
		scrlPlayers.SetStep( 1 );
		scrlPlayers.CallOnChange( VGUI_PlayerList_ListUpdate );

		picAvatar = spawn(vguiPic);
		picAvatar.SetSize( [64, 64] );
		picAvatar.SetBorder(1);
		
		lblPlayerName = spawn(vguiLabel);
		lblPlayerName.SetSize( [232, 16] );

		picFlag = spawn(vguiPic);
		picFlag.SetSize( [16, 8] );

		lblOnlineStatus = spawn(vguiLabel);
		lblOnlineStatus.SetSize( [232, 16] );

		lblInfoText = spawn(vguiLabel);
		lblInfoText.SetSize( [232, 16] );
		lblInfoText.SetTitle(localize("#USERINFO_HELP"));

		lblContact = spawn(vguiLabel);
		lblContact.SetSize( [232, 16] );

		VGUI_PlayerList_Resize();
		VGUI_PlayerList_UpdateDetails();

		g_uiDesktop.Add( winPlayerList );
		winPlayerList.Add( picBackground );
		winPlayerList.Add( picGradient );
		winPlayerList.Add( picHGradient );
		winPlayerList.Add( viewModel );

		winPlayerList.Add( lstPlayers );
		winPlayerList.Add( scrlPlayers );
		
		winPlayerList.Add( picAvatar );
		winPlayerList.Add( lblPlayerName );
		winPlayerList.Add( lblOnlineStatus );
		winPlayerList.Add( lblInfoText );
		winPlayerList.Add( picFlag );
		winPlayerList.Add( lblContact );
	}

	for (int i = 0i; i < serverinfo.GetInteger("sv_playerslots"); i++) {
		lstPlayers.m_strItems[i] = strdecolorize(getplayerkeyvalue(i, "name"));
		
		if (!STRING_SET(lstPlayers.m_strItems[i])) {
			lstPlayers.m_strItems[i] = strcat("^8", localize("#EMPTY_PLAYERSLOT"));
		}
	}

	winPlayerList.Show();
}
