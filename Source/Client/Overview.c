/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
The overview system was meant to support
more layers and so on. Never actually used.
Probably seemed impractical, feel free to make this
parse layers etc. properly though.
*/

typedef struct {
	float fZoom;
	vector vOrigin;
	int iRotated;
	float fHeight;
	string sImagePath;
	float fCameraHeight;
	vector vVert1;
	vector vVert2;
	vector vVert3;
	vector vVert4;
} overview_t;

overview_t ovMap;

/*
=================
Overview_Init

Initializes the globals and whatnot
=================
*/
void Overview_Init( void ) {
	int *iImageSrc;
	int iImageWidth = 0;
	int iImageHeight = 0;
	int iImageCount = 0;
	string sTemp;
	
	ovMap.fZoom = 1.0f;
	ovMap.vOrigin = '0 0 0';
	ovMap.iRotated = FALSE;
	
	filestream fOverview = fopen( sprintf( "overviews/%s.txt", mapname ), FILE_READ );
	if ( fOverview != -1 ) {
		for ( int i = 0;; i++ ) {
			sTemp = fgets( fOverview );
			if not ( sTemp ) {
				break;
			} 
			
			tokenize( sTemp );
			if ( strtolower( argv( 0 ) ) == "zoom" ) {
				ovMap.fZoom = stof( argv( 1 ) );
			} else if ( strtolower( argv( 0 ) ) == "origin" ) {
				ovMap.vOrigin = [ stof( argv( 1 ) ), stof( argv( 2 ) ), stof( argv( 3 ) ) ];
			} else if ( strtolower( argv( 0 ) ) == "rotated" ) {
				ovMap.iRotated = (int)stof( argv( 1 ) );
			} else if ( strtolower( argv( 0 ) ) == "height" ) {
				ovMap.fHeight = stof( argv( 1 ) );
			}
		}
		fclose( fOverview );
	} else {
		print( sprintf( "[OVERVIEW] Couldn't load overviews/%s.txt\n", mapname ) );
		ovMap.sImagePath = __NULL__;
		return;
	}
	
	if ( ovMap.iRotated == TRUE ) {
		ovMap.vVert1 = ovMap.vOrigin -( ( 4096/ovMap.fZoom )  * '1 0.75 0' );
		ovMap.vVert4 = ovMap.vOrigin + ( 4096/ovMap.fZoom )  * '1 0.75 0';
		ovMap.vVert2 = [ ovMap.vVert1[0], ovMap.vVert4[1] ] ;
		ovMap.vVert3 = [ ovMap.vVert4[0], ovMap.vVert1[1] ] ; 
	} else {
		ovMap.vVert1 = ovMap.vOrigin -( ( 4096/ovMap.fZoom )  * '0.75 1 0' );
		ovMap.vVert4 = ovMap.vOrigin + ( 4096/ovMap.fZoom )  * '0.75 1 0';
		ovMap.vVert2 = [ ovMap.vVert1[0], ovMap.vVert4[1] ] ;
		ovMap.vVert3 = [ ovMap.vVert4[0], ovMap.vVert1[1] ] ;
	}
	
	ovMap.fCameraHeight = fabs( 4096/ovMap.fZoom );
	
	ovMap.sImagePath = "overview";
	shaderforname( ovMap.sImagePath, sprintf("{\n{\nprogram default2d\nmap $rt:%s\n}\n}\n", ovMap.sImagePath ) );
	
	// Read the image and get rid of the burning green
	iImageSrc = r_readimage( sprintf( "overviews/%s.bmp", mapname ), iImageWidth, iImageHeight );
	if ( iImageSrc != __NULL__ ) {
		for ( int i = 0; i < ( iImageWidth * iImageHeight ); i++ ) {
			if ( iImageSrc[ i ] == 0xff00ff00i ) {
				iImageSrc[ i ] = 0x00000000i;
			}
		}	
		r_uploadimage( ovMap.sImagePath, iImageWidth, iImageHeight, iImageSrc );
		memfree( iImageSrc );
	}
}

void Overview_DrawLayer( void ) {
	setproperty( VF_AFOV, 90 );
	if ( ovMap.iRotated == TRUE ) {
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ ovMap.vVert4[0], ovMap.vVert4[1], ovMap.fHeight ], '1 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ ovMap.vVert3[0], ovMap.vVert3[1], ovMap.fHeight ], '1 1', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ ovMap.vVert1[0], ovMap.vVert1[1], ovMap.fHeight ], '0 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ ovMap.vVert2[0], ovMap.vVert2[1], ovMap.fHeight ], '0 0', '1 1 1', 1.0f ); // Bottom left
		R_EndPolygon();
	} else {
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ ovMap.vVert4[0], ovMap.vVert4[1], ovMap.fHeight ], '0 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ ovMap.vVert3[0], ovMap.vVert3[1], ovMap.fHeight ], '1 0', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ ovMap.vVert1[0], ovMap.vVert1[1], ovMap.fHeight ], '1 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ ovMap.vVert2[0], ovMap.vVert2[1], ovMap.fHeight ], '0 1', '1 1 1', 1.0f ); // Bottom left
		R_EndPolygon();
	}
	
	for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
		if ( getplayerkeyvalue( eFind.entnum - 1, "*team" ) == "1" ) {
			R_BeginPolygon( "sprites/iplayerred.spr_0.tga" );
		} else {
			if ( getplayerkeyvalue( eFind.entnum - 1, "*dead" ) == "2" ) {
				R_BeginPolygon( "sprites/iplayervip.spr_0.tga" );
			} else { 
				R_BeginPolygon( "sprites/iplayerblue.spr_0.tga" );
			}
		}
		R_PolygonVertex( [ eFind.absmax_x + 16, eFind.absmin_y - 16, ovMap.fHeight + 16 ], '1 0', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ eFind.absmin_x - 16, eFind.absmin_y - 16, ovMap.fHeight + 16 ], '0 0', '1 1 1', 1.0f ); // Top left
		R_PolygonVertex( [ eFind.absmin_x - 16, eFind.absmax_y + 16, ovMap.fHeight + 16 ], '0 1', '1 1 1', 1.0f ); // Bottom left
		R_PolygonVertex( [ eFind.absmax_x + 16, eFind.absmax_y + 16, ovMap.fHeight + 16 ], '1 1', '1 1 1', 1.0f ); // Bottom right
		R_EndPolygon();
	}

}

/*
=================
Overview_Draw

Draw one of two types of overviews.
This is for spectators.
=================
*/
void Overview_Draw( void ) {
	if ( ovMap.sImagePath == __NULL__ ) {
		return;
	}
	
	drawfill( vVideoMins, vVideoResolution, '0 0 0', 1.0f, 0 );
	
	Overview_DrawLayer();
	
	makevectors( view_angles );
	setproperty( VF_ORIGIN, ovMap.vOrigin + ( v_forward * -ovMap.fCameraHeight ) ) ;
}
