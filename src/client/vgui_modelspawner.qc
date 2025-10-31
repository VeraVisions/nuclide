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

bool g_iModelSpawnerInitialized;

void VGUI_ModelSpawner ( void )
{
	static entity eModel;
	static vector vecDistance = [ 90, 0, 0 ];
	static vguiWindow winViewer;
	static vgui3DView viewModel;
	static vguiRect picBackground;
	static vguiButton btnTabRenderer;
	static vguiButton btnTabSequence;
	static vguiButton btnTabBody;
	static vguiButton btnTabTexture;
	static vguiList lstModels;
	static vguiScrollBar scrlModels;
	static vguiButton btnLoadModel;
	
	// Renderer
	static vguiCheckbox chkBackground;
	static vguiCheckbox chkGround;
	static vguiCheckbox chkMirror;
	static vguiButton btnSpawnProp;
	static vguiButton btnSpawnDoll;
	static vguiButton btnFirstperson;
	static vguiButton btnResetCam;
	static vguiButton btnSetViewModel;
	
	// Sequences
	static vguiLabel lblSeqFrame;
	static vguiButton btnSeqNext;
	static vguiButton btnSeqPrev;
	
	static void VGUI_ModelViewer_SetViewModel( void ) {
		if (pSeat == __NULL__) {
			return;
		}
		ncRenderableEntity theModel = (ncRenderableEntity)pSeat->m_eViewModel;
		ncRenderableEntity theModel2 = (ncRenderableEntity)pSeat->m_eViewModelL;

		if (theModel && theModel.classname == "vm") {
			theModel.modelindex = getmodelindex(eModel.model);
			theModel2.modelindex = 
			theModel2.modelindex2 = 
			theModel2.modelindex3 = 
			theModel2.modelindex4 =
			theModel.modelindex2 = 
			theModel.modelindex3 = 
			theModel.modelindex4 = 0;
			

			if (theModel) {
				theModel._UpdateBoneCount();
			}

			if (theModel2) {
				theModel2._UpdateBoneCount();
			}
		}
	}
	static void VGUI_ModelViewer_Firstperson( void ) {
		vecDistance = [ 0, 0, 0 ];
		viewModel.Set3DAngles( [0,0,0] );
		viewModel.Set3DPos( [0,0,0] );
	}
	static void VGUI_ModelViewer_ResetCam( void ) {
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));
		vecDistance = [ 90, 0, 0 ];
		viewModel.Set3DAngles( [0,180,0] );
		viewModel.Set3DPos( modelPos );

		makevectors( viewModel.Get3DAngles() );
		viewModel.Set3DPos( modelPos + (v_forward * -vecDistance[0]) + (v_right * vecDistance[1]) + (v_up * vecDistance[2]) );
	}
	static void VGUI_ModelViewer_SpawnProp( void ) {
		localcmd(sprintf("propSpawn %S\n", eModel.model));
	}
	static void VGUI_ModelViewer_SpawnDoll( void ) {
		localcmd(sprintf("ragdollCreate %S\n", eModel.model));
	}
	static void VGUI_ModelViewer_SetFrame( int iFrame ) {
		float maxFrame = modelframecount(eModel.modelindex) - 1;
		eModel.frame = (float)iFrame;

		if (eModel.frame < 0) {
			eModel.frame = 0;
		}

		lblSeqFrame.SetTitle( sprintf( "Frame %d: %s", eModel.frame, frametoname(eModel.modelindex, eModel.frame) ) );
		eModel.frame1time = 0;
	}
	static void VGUI_ModelViewer_SetFrameP( void ) {
		VGUI_ModelViewer_SetFrame( eModel.frame + 1 );
	}
	static void VGUI_ModelViewer_SetFrameM( void ) {
		VGUI_ModelViewer_SetFrame( eModel.frame - 1 );
	}
	static void VGUI_ModelViewer_SetModel( string strModel ) {
		setmodel( eModel, strModel );
		winViewer.SetTitle( sprintf( "Model Viewer (%s)", strModel ) );
		VGUI_ModelViewer_SetFrame( 0 );
		VGUI_ModelViewer_ResetCam();
	}
	static void VGUI_ModelViewer_Draw ( void ) {
		static int initialized = FALSE;
		if ( !initialized ) {
			initialized = TRUE;
			eModel = spawn();
			VGUI_ModelViewer_SetModel( "models/error.vvm" );
		}
		addentity( eModel );
		eModel.frame1time += frametime;
		
		if ( chkGround.GetValue() == TRUE ) {
			vector vert1, vert2, vert3, vert4;
			vector wireColor = [0.8f, 0.8f, 0.9f];

			vert1 = [16,0];
			vert2 = [0, 0];
			vert3 = [0, 16];
			vert4 = [16, 16];

			for (int x = -256; x < 256; x += 16) {
				for (int y = -256; y < 256; y += 16) {
					R_BeginPolygon( "" );
					R_PolygonVertex( [ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f );
					R_PolygonVertex( [ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f );
					R_EndPolygon();

					R_BeginPolygon( "" );
					R_PolygonVertex( [ x + vert2[0], y + vert2[1] ], '1 0', wireColor, 1.0f );
					R_PolygonVertex( [ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f );
					R_EndPolygon();

					R_BeginPolygon( "" );
					R_PolygonVertex( [ x + vert3[0], y + vert3[1] ], '1 1', wireColor, 1.0f );
					R_PolygonVertex( [ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f );
					R_EndPolygon();

					R_BeginPolygon( "" );
					R_PolygonVertex( [ x + vert4[0], y + vert4[1] ], '0 1', wireColor, 1.0f );
					R_PolygonVertex( [ x + vert1[0], y + vert1[1] ], '0 0', wireColor, 1.0f );
					R_EndPolygon();
				}
			}
		}
	
		if ( chkBackground.GetValue() == TRUE ) {
			picBackground.Show();
		} else {
			picBackground.Hide();
		}
	}
	static float VGUI_ModelViewer_Input ( float flEVType, float flKey, float flChar, float flDevID ) {
		static int iMouseDrag = FALSE;
		static int iShiftDrag = FALSE;
		static vector vecDragOfs;
		vector vecDifference;
		vector modelPos = (eModel.absmin + (0.5 * (eModel.absmax - eModel.absmin)));

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
	static void VGUI_ModelViewer_Resize ( void ) {
		// Resize the background and viewer
		vector vWinSize = winViewer.GetSize();
		picBackground.SetSize( [vWinSize[0] - 12 - 192, vWinSize[1] - 128 ] );
		viewModel.SetSize( picBackground.GetSize() );

		btnTabRenderer.SetPos( [ 6, vWinSize[1] - 92 ] );
		btnTabSequence.SetPos( btnTabRenderer.GetPos() + [ btnTabRenderer.GetWidth() + 1, 0 ] );
		btnTabBody.SetPos( btnTabSequence.GetPos() + [ btnTabSequence.GetWidth() + 1, 0 ] );
		btnTabTexture.SetPos( btnTabBody.GetPos() + [ btnTabBody.GetWidth() + 1, 0 ] );
		
		chkBackground.SetPos( btnTabRenderer.GetPos() + [ 0, 30 ] );
		chkGround.SetPos( btnTabRenderer.GetPos() + [ 0, 50 ] );
		chkMirror.SetPos( btnTabRenderer.GetPos() + [ 0, 70 ] );
		lstModels.SetPos( viewModel.GetPos() + [ viewModel.GetSize()[0], 0 ] );
		lstModels.SetSize( [ 172, viewModel.GetSize()[1] ] );
		scrlModels.SetPos( lstModels.GetPos() + [ 172, 0 ] );
		scrlModels.SetLength( viewModel.GetSize()[1] );
		scrlModels.SetMax( lstModels.GetMaxVisibleItems() );
		btnLoadModel.SetPos( lstModels.GetPos() + [ 0, lstModels.GetSize()[1] + 1 ] );
		btnSpawnProp.SetPos( btnLoadModel.GetPos() + [ 0, 30 ] );
		btnSpawnDoll.SetPos( btnSpawnProp.GetPos() + [ 0, 30 ] );
		btnSetViewModel.SetPos( btnSpawnDoll.GetPos() + [ 0, 30 ] );
		btnFirstperson.SetPos( btnTabRenderer.GetPos() + [ 128, 30 ] );
		btnResetCam.SetPos( btnFirstperson.GetPos() + [ 0, 30 ] );
		
		lblSeqFrame.SetPos( btnTabRenderer.GetPos() + [ 0, 30 ] );
		btnSeqPrev.SetPos( btnTabRenderer.GetPos() + [ 0, 50 ] );
		btnSeqNext.SetPos( btnTabRenderer.GetPos() + [ 64, 50 ] );
	}
	static void VGUI_ModelViewer_HideAll( void ) {
		chkBackground.Hide();
		chkGround.Hide();
		chkMirror.Hide();
		lblSeqFrame.Hide();
		btnSeqPrev.Hide();
		btnSeqNext.Hide();
		btnFirstperson.Hide();
		btnResetCam.Hide();
	}
	static void VGUI_ModelViewer_ShowRenderer( void ) {
		VGUI_ModelViewer_HideAll();
		chkBackground.Show();
		chkGround.Show();
		chkMirror.Show();
		btnFirstperson.Show();
		btnResetCam.Show();
	}
	static void VGUI_ModelViewer_ShowSequence( void ) {
		VGUI_ModelViewer_HideAll();
		lblSeqFrame.Show();
		btnSeqPrev.Show();
		btnSeqNext.Show();
	}
	static void VGUI_ModelViewer_ShowBody( void ) {
		VGUI_ModelViewer_HideAll();
	}
	static void VGUI_ModelViewer_ShowTexture( void ) {
		VGUI_ModelViewer_HideAll();
	}
	
	static void VGUI_ModelViewer_ScrollUpdate ( void ) {
		scrlModels.SetValue( lstModels.GetOffset() );
	}
	static void VGUI_ModelViewer_ListUpdate ( void ) {
		lstModels.SetOffset( scrlModels.GetValue(), FALSE );
	}

	if ( !g_iModelSpawnerInitialized ) {
		g_iModelSpawnerInitialized = true;
		winViewer = spawn( vguiWindow );
		winViewer.SetTitle( "Model Viewer" );
		winViewer.SetSize( [ 550, 390 ] );
		winViewer.SetMinSize( [ 430, 256 ] );
		winViewer.SetMaxSize( [ 9999, 9999 ] );
		winViewer.SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
		winViewer.SetPos( [ 172, 64 ] );
		winViewer.SetIcon( "gfx/icon16/images" );
		winViewer.CallOnResize( VGUI_ModelViewer_Resize );

		picBackground = spawn( vguiRect );
		picBackground.SetPos( [ 6, 32 ] );

		viewModel = spawn( vgui3DView );
		viewModel.SetDrawFunc( VGUI_ModelViewer_Draw );
		viewModel.SetInputFunc( VGUI_ModelViewer_Input );
		viewModel.SetPos( [ 6, 32 ] );

		btnTabRenderer = spawn( vguiButton );
		btnTabRenderer.SetTitle( "Renderer" );
		btnTabRenderer.SetFunc( VGUI_ModelViewer_ShowRenderer );
		btnTabSequence = spawn( vguiButton );
		btnTabSequence.SetTitle( "Sequence" );
		btnTabSequence.SetFunc( VGUI_ModelViewer_ShowSequence );
		btnTabBody = spawn( vguiButton );
		btnTabBody.SetTitle( "Body" );
		btnTabBody.SetFunc( VGUI_ModelViewer_ShowBody );
		btnTabTexture = spawn( vguiButton );
		btnTabTexture.SetTitle( "Texture" );
		btnTabTexture.SetFunc( VGUI_ModelViewer_ShowTexture );
		
		chkBackground = spawn( vguiCheckbox );
		chkBackground.SetTitle( "Background" );
		chkBackground.SetValue( TRUE );
		chkGround = spawn( vguiCheckbox );
		chkGround.SetTitle( "Ground" );
		chkGround.SetValue( true );
		chkMirror = spawn( vguiCheckbox );
		chkMirror.SetTitle( "Mirror on Ground" );
		btnSpawnProp = spawn( vguiButton );
		btnSpawnProp.SetTitle( "Spawn Prop" );
		btnSpawnProp.SetFunc( VGUI_ModelViewer_SpawnProp );
		btnSpawnProp.SetSize( [192,24] );
		
		btnSpawnDoll = spawn( vguiButton );
		btnSpawnDoll.SetTitle( "Spawn Doll" );
		btnSpawnDoll.SetFunc( VGUI_ModelViewer_SpawnDoll );
		btnSpawnDoll.SetSize( [192,24] );
		
		btnFirstperson = spawn( vguiButton );
		btnFirstperson.SetTitle( "FPS Cam" );
		btnFirstperson.SetFunc( VGUI_ModelViewer_Firstperson );
		btnResetCam = spawn( vguiButton );
		btnResetCam.SetTitle( "Reset Cam" );
		btnResetCam.SetFunc( VGUI_ModelViewer_ResetCam );
		btnSetViewModel = spawn( vguiButton );
		btnSetViewModel.SetTitle( "Set ViewModel" );
		btnSetViewModel.SetFunc( VGUI_ModelViewer_SetViewModel );
		btnSetViewModel.SetSize( [192,24] );
		
		lblSeqFrame = spawn( vguiLabel );
		lblSeqFrame.SetTitle( "Frame: 0" );
		lblSeqFrame.SetSize([550,16]);
		btnSeqNext = spawn( vguiButton );
		btnSeqNext.SetTitle( ">>" );
		btnSeqNext.SetSize([48,24]);
		btnSeqNext.SetFunc( VGUI_ModelViewer_SetFrameP );
		btnSeqPrev = spawn( vguiButton );
		btnSeqPrev.SetTitle( "<<" );
		btnSeqPrev.SetSize([48,24]);
		btnSeqPrev.SetFunc( VGUI_ModelViewer_SetFrameM );
		
		searchhandle shModels = search_begin( "models/*.mdl:models/*.md2:models/*.vvm:models/*/*.mdl:models/*/*.md2:models/*/*.vvm:models/*/*/*.mdl:models/*/*/*.md2:models/*/*/*.vvm:models/*/*/*/*.mdl:models/*/*/*/*.md2:models/*/*/*/*.vvm", SEARCH_NAMESORT | SEARCH_MULTISEARCH, TRUE );
		lstModels = spawn( vguiList );
		lstModels.SetItemCount( search_getsize( shModels ) );
		lstModels.CallOnScroll( VGUI_ModelViewer_ScrollUpdate );

		for ( int i = 0; i < search_getsize( shModels ); i++ ) {
			string strAdd = search_getfilename( shModels, i );
			lstModels.AddItem( substring( strAdd , 7, -1 ) );
		}
		search_end( shModels );
		
		scrlModels = spawn( vguiScrollBar );
		scrlModels.SetMin( 0 );
		scrlModels.SetStep( 1 );
		scrlModels.CallOnChange( VGUI_ModelViewer_ListUpdate );

		static void VGUI_ModelViewer_LoadSelected ( void ) {
			VGUI_ModelViewer_SetModel( sprintf( "models/%s", lstModels.GetItem( lstModels.GetSelected() ) ) );
		}
		btnLoadModel = spawn( vguiButton );
		btnLoadModel.SetTitle( "Load Selected" );
		btnLoadModel.SetFunc( VGUI_ModelViewer_LoadSelected );
		btnLoadModel.SetSize( [192,24] );

		VGUI_ModelViewer_Resize();
		VGUI_ModelViewer_ShowRenderer();

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
		winViewer.Add( btnSpawnProp );
		winViewer.Add( btnSpawnDoll );
		winViewer.Add( btnFirstperson );
		winViewer.Add( btnSetViewModel );
		winViewer.Add( btnResetCam );
		winViewer.Add( btnLoadModel );
		winViewer.Add( scrlModels );
	}

	winViewer.Show();
}
