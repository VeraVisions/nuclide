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

int g_iModelViewerInitialized;

// menuqc doesn't have access to makevectors... screw you, guys
vector v_forward;
vector v_up;
vector v_right;
void AngleVectors ( vector angles )
{
	float angle;
	float sr, sp, sy, cr, cp, cy;
	
	angle = angles[1] * (M_PI*2 / 360);
	sy = sin(angle);
	cy = cos(angle);
	angle = angles[0] * (M_PI*2 / 360);
	sp = sin(angle);
	cp = cos(angle);
	angle = angles[2] * (M_PI*2 / 360);
	sr = sin(angle);
	cr = cos(angle);

	v_forward[0] = cp*cy;
	v_forward[1] = cp*sy;
	v_forward[2] = -sp;

	v_right[0] = (-1*sr*sp*cy+-1*cr*-sy);
	v_right[1] = (-1*sr*sp*sy+-1*cr*cy);
	v_right[2] = -1*sr*cp;

	v_up[0] = (cr*sp*cy+-sr*-sy);
	v_up[1] = (cr*sp*sy+-sr*cy);
	v_up[2] = cr*cp;
}

string(float modidx, float framenum) frametoname = #0;
.float modelindex;

void UI_ModelViewer_Show ( void )
{
	static entity eModel;
	static vector vecDistance = [ 90, 0, 0 ];
	static CUIWindow winViewer;
	static CUI3DView viewModel;
	static CUIPic picBackground;
	static CUIButton btnTabRenderer;
	static CUIButton btnTabSequence;
	static CUIButton btnTabBody;
	static CUIButton btnTabTexture;
	static CUIList lstModels;
	static CUIScrollbar scrlModels;
	static CUIButton btnLoadModel;
	
	// Renderer
	static CUICheckbox chkBackground;
	static CUICheckbox chkGround;
	static CUICheckbox chkMirror;
	static CUIButton btnFirstperson;
	
	// Sequences
	static CUILabel lblSeqFrame;
	static CUIButton btnSeqNext;
	static CUIButton btnSeqPrev;
	
	static void UI_ModelViewer_Firstperson( void ) {
		vecDistance = [ 0, 0, 0 ];
		viewModel.Set3DAngles( [0,0,0] );
		viewModel.Set3DPos( [0,0,0] );
	}
	static void UI_ModelViewer_SetFrame( int iFrame ) {
		float maxFrame = modelframecount(eModel.modelindex) - 1;
		eModel.frame = (float)iFrame;

		if (eModel.frame > maxFrame) {
			eModel.frame = (maxFrame);
		}

		if (eModel.frame < 0) {
			eModel.frame = 0;
		}

		lblSeqFrame.SetTitle( sprintf( "Frame %d: %s", eModel.frame, frametoname(eModel.modelindex, eModel.frame) ) );
		eModel.frame1time = 0;
	}
	static void UI_ModelViewer_SetFrameP( void ) {
		UI_ModelViewer_SetFrame( eModel.frame + 1 );
	}
	static void UI_ModelViewer_SetFrameM( void ) {
		UI_ModelViewer_SetFrame( eModel.frame - 1 );
	}
	static void UI_ModelViewer_SetModel( string strModel ) {
		setmodel( eModel, strModel );
		winViewer.SetTitle( sprintf( "Model Viewer (%s)", strModel ) );
		UI_ModelViewer_SetFrame( 0 );
	}
	static void UI_ModelViewer_Draw ( void ) {
		static int initialized = FALSE;
		if ( !initialized ) {
			initialized = TRUE;
			eModel = spawn();
			UI_ModelViewer_SetModel( "models/error.vvm" );
			AngleVectors( viewModel.Get3DAngles() );
			viewModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
		}
		addentity( eModel );
		eModel.frame1time += frametime;
		
		if ( chkGround.GetValue() == TRUE ) {
			R_BeginPolygon( "", 0, FALSE );
			R_PolygonVertex( [ 64, -64, 0 ], [1,0], [1,1,1], 1.0f ); // Top Right
			R_PolygonVertex( [ -64, -64, 0 ], [0,0], [1,1,1], 1.0f ); // Top left
			R_PolygonVertex( [ -64, 64, 0 ], [0,1], [1,1,1], 1.0f ); // Bottom left
			R_PolygonVertex( [ 64, 64, 0 ], [1,1], [1,1,1], 1.0f ); // Bottom right
			R_EndPolygon();
		}
	
		if ( chkBackground.GetValue() == TRUE ) {
			picBackground.Show();
		} else {
			picBackground.Hide();
		}
	}
	static float UI_ModelViewer_Input ( float flEVType, float flKey, float flChar, float flDevID ) {
		static int iMouseDrag = FALSE;
		static int iShiftDrag = FALSE;
		static vector vecDragOfs;
		vector vecDifference;

		int iMouseOver =  Util_MouseAbove( getmousepos(), viewModel.m_parent.GetPos() + viewModel.GetPos(), viewModel.GetSize() );
		if ( flEVType == IE_KEYDOWN ) {
			if ( flKey == K_MOUSE1 && iMouseOver == TRUE ) {
				iMouseDrag = TRUE;
				vecDragOfs = getmousepos();
				return true;
			} else if ( flKey == K_MWHEELUP && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, --vecDistance[0], 512 );
				AngleVectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				return true;
			} else if ( flKey == K_MWHEELDOWN && iMouseOver == TRUE ) {
				vecDistance[0] = bound( 0, ++vecDistance[0], 512 );
				AngleVectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				return true;
			} else if ( flKey == K_LSHIFT && iMouseOver == TRUE ) {
				iShiftDrag = TRUE;
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
				AngleVectors( viewModel.Get3DAngles() );
				viewModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				vecDragOfs = getmousepos();
				return true;
			}
		} else if ( iMouseDrag == TRUE && iShiftDrag == TRUE ) {
			if ( flEVType == IE_MOUSEABS ) {
				vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
				vecDistance[1] -= vecDifference[1];
				vecDistance[2] += vecDifference[0];
				viewModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				vecDragOfs = getmousepos();
				return true;
			}
		}
		return false;
	}
	static void UI_ModelViewer_Resize ( void ) {
		// Resize the background and viewer
		vector vWinSize = winViewer.GetSize();
		picBackground.SetSize( [vWinSize[0] - 12 - 192, vWinSize[1] - 128 ] );
		viewModel.SetSize( picBackground.GetSize() );

		btnTabRenderer.SetPos( [ 6, vWinSize[1] - 92 ] );
		btnTabSequence.SetPos( btnTabRenderer.GetPos() + [ btnTabRenderer.GetSizeWidth() + 1, 0 ] );
		btnTabBody.SetPos( btnTabSequence.GetPos() + [ btnTabSequence.GetSizeWidth() + 1, 0 ] );
		btnTabTexture.SetPos( btnTabBody.GetPos() + [ btnTabBody.GetSizeWidth() + 1, 0 ] );
		
		chkBackground.SetPos( btnTabRenderer.GetPos() + [ 0, 30 ] );
		chkGround.SetPos( btnTabRenderer.GetPos() + [ 0, 50 ] );
		chkMirror.SetPos( btnTabRenderer.GetPos() + [ 0, 70 ] );
		lstModels.SetPos( viewModel.GetPos() + [ viewModel.GetSize()[0], 0 ] );
		lstModels.SetSize( [ 172, viewModel.GetSize()[1] ] );
		scrlModels.SetPos( lstModels.GetPos() + [ 172, 0 ] );
		scrlModels.SetLength( viewModel.GetSize()[1] );
		scrlModels.SetMax( lstModels.GetMaxVisibleItems() );
		btnLoadModel.SetPos( lstModels.GetPos() + [ 0, lstModels.GetSize()[1] + 1 ] );
		btnFirstperson.SetPos( btnTabRenderer.GetPos() + [ 128, 30 ] );
		
		lblSeqFrame.SetPos( btnTabRenderer.GetPos() + [ 0, 30 ] );
		btnSeqPrev.SetPos( btnTabRenderer.GetPos() + [ 0, 50 ] );
		btnSeqNext.SetPos( btnTabRenderer.GetPos() + [ 64, 50 ] );
	}
	static void UI_ModelViewer_HideAll( void ) {
		chkBackground.Hide();
		chkGround.Hide();
		chkMirror.Hide();
		lblSeqFrame.Hide();
		btnSeqPrev.Hide();
		btnSeqNext.Hide();
		btnFirstperson.Hide();
	}
	static void UI_ModelViewer_ShowRenderer( void ) {
		UI_ModelViewer_HideAll();
		chkBackground.Show();
		chkGround.Show();
		chkMirror.Show();
		btnFirstperson.Show();
	}
	static void UI_ModelViewer_ShowSequence( void ) {
		UI_ModelViewer_HideAll();
		lblSeqFrame.Show();
		btnSeqPrev.Show();
		btnSeqNext.Show();
	}
	static void UI_ModelViewer_ShowBody( void ) {
		UI_ModelViewer_HideAll();
	}
	static void UI_ModelViewer_ShowTexture( void ) {
		UI_ModelViewer_HideAll();
	}
	
	static void ModelViewer_ScrollUpdate ( void ) {
		scrlModels.SetValue( lstModels.GetOffset() );
	}
	static void ModelViewer_ListUpdate ( void ) {
		lstModels.SetOffset( scrlModels.GetValue(), FALSE );
	}

	if ( !g_iModelViewerInitialized ) {
		g_iModelViewerInitialized = TRUE;
		winViewer = spawn( CUIWindow );
		winViewer.SetTitle( "Model Viewer" );
		winViewer.SetSize( [ 550, 390 ] );
		winViewer.SetMinSize( [ 430, 256 ] );
		winViewer.SetMaxSize( [ 9999, 9999 ] );
		winViewer.SetStyleMask( VGUIWindowStyleDefault | VGUIWindowResizeable );
		winViewer.SetPos( [ 172, 64 ] );
		winViewer.SetIcon( "gfx/icon16/images" );
		winViewer.CallOnResize( UI_ModelViewer_Resize );

		picBackground = spawn( CUIPic );
		picBackground.SetImage( "gfx/background" );
		picBackground.SetPos( [ 6, 32 ] );

		viewModel = spawn( CUI3DView );
		viewModel.SetDrawFunc( UI_ModelViewer_Draw );
		viewModel.SetInputFunc( UI_ModelViewer_Input );
		viewModel.SetPos( [ 6, 32 ] );

		btnTabRenderer = spawn( CUIButton );
		btnTabRenderer.SetTitle( "Renderer" );
		btnTabRenderer.SetFunc( UI_ModelViewer_ShowRenderer );
		btnTabSequence = spawn( CUIButton );
		btnTabSequence.SetTitle( "Sequence" );
		btnTabSequence.SetFunc( UI_ModelViewer_ShowSequence );
		btnTabBody = spawn( CUIButton );
		btnTabBody.SetTitle( "Body" );
		btnTabBody.SetFunc( UI_ModelViewer_ShowBody );
		btnTabTexture = spawn( CUIButton );
		btnTabTexture.SetTitle( "Texture" );
		btnTabTexture.SetFunc( UI_ModelViewer_ShowTexture );
		
		chkBackground = spawn( CUICheckbox );
		chkBackground.SetTitle( "Background" );
		chkBackground.SetValue( TRUE );
		chkGround = spawn( CUICheckbox );
		chkGround.SetTitle( "Ground" );
		chkMirror = spawn( CUICheckbox );
		chkMirror.SetTitle( "Mirror on Ground" );
		btnFirstperson = spawn( CUIButton );
		btnFirstperson.SetTitle( "FPS-CAM" );
		btnFirstperson.SetFunc( UI_ModelViewer_Firstperson );
		
		lblSeqFrame = spawn( CUILabel );
		lblSeqFrame.SetTitle( "Frame: 0" );
		lblSeqFrame.SetSize([550,16]);
		btnSeqNext = spawn( CUIButton );
		btnSeqNext.SetTitle( ">>" );
		btnSeqNext.SetSize([48,24]);
		btnSeqNext.SetFunc( UI_ModelViewer_SetFrameP );
		btnSeqPrev = spawn( CUIButton );
		btnSeqPrev.SetTitle( "<<" );
		btnSeqPrev.SetSize([48,24]);
		btnSeqPrev.SetFunc( UI_ModelViewer_SetFrameM );
		
		searchhandle shModels = search_begin( "models/*.mdl:models/*.vvm:models/*/*.mdl:models/*/*.vvm:models/*/*/*.mdl:models/*/*/*.vvm:models/*/*/*/*.mdl:models/*/*/*/*.vvm", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
		lstModels = spawn( CUIList );
		lstModels.SetItemCount( search_getsize( shModels ) );
		lstModels.CallOnScroll( ModelViewer_ScrollUpdate );

		for ( int i = 0; i < search_getsize( shModels ); i++ ) {
			string strAdd = search_getfilename( shModels, i );
			lstModels.AddItem( substring( strAdd , 7, -1 ) );
		}
		search_end( shModels );
		
		scrlModels = spawn( CUIScrollbar );
		scrlModels.SetMin( 0 );
		scrlModels.SetStep( 1 );
		scrlModels.CallOnChange( ModelViewer_ListUpdate );

		static void UI_ModelViewer_LoadSelected ( void ) {
			UI_ModelViewer_SetModel( sprintf( "models/%s", lstModels.GetItem( lstModels.GetSelected() ) ) );
		}
		btnLoadModel = spawn( CUIButton );
		btnLoadModel.SetTitle( "Load Selected" );
		btnLoadModel.SetFunc( UI_ModelViewer_LoadSelected );
		btnLoadModel.SetSize( [192,24] );

		UI_ModelViewer_Resize();
		UI_ModelViewer_ShowRenderer();

		g_uiDesktop.Add( winViewer );
		winViewer.Add( picBackground );
		winViewer.Add( viewModel );
		winViewer.Add( btnTabRenderer );
		winViewer.Add( btnTabSequence );
		//winViewer.Add( btnTabBody );
		//winViewer.Add( btnTabTexture );
		winViewer.Add( chkBackground );
		winViewer.Add( chkGround );
		winViewer.Add( chkMirror );
		winViewer.Add( lstModels );
		winViewer.Add( lblSeqFrame );
		winViewer.Add( btnSeqNext );
		winViewer.Add( btnSeqPrev );
		winViewer.Add( btnFirstperson );
		winViewer.Add( btnLoadModel );
		winViewer.Add( scrlModels );
	}

	winViewer.Show();
}
