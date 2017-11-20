/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

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
} overview_t;

overview_t ovMap;

/*
=================
Overview_Init

Initializes the globals and whatnot
=================
*/
void Overview_Init( void ) {
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
		ovMap.sImagePath = sprintf( "overviews/%s.bmp", mapname );
	} else {
		error( sprintf( "[OVERVIEW] Couldn't load overviews/%s.txt", mapname ) );
		ovMap.sImagePath = __NULL__;
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
	float fCameraHeight;
	vector vVert1, vVert2, vVert3, vVert4;
	
	if ( ovMap.sImagePath == __NULL__ ) {
		return;
	}
	
	drawfill( vVideoMins, vVideoResolution, '0 0 0', 1.0f, 0 );
	if ( ovMap.iRotated == TRUE ) {
		
		vVert1 = ovMap.vOrigin -( ( 4096/ovMap.fZoom )  * '1 0.75 0' );
		vVert4 = ovMap.vOrigin + ( 4096/ovMap.fZoom )  * '1 0.75 0';
				
		vVert2 = [ vVert1_x, vVert4_y ] ;
		vVert3 = [ vVert4_x, vVert1_y ] ; 
	
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ vVert4_x, vVert4_y, ovMap.fHeight ], '1 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ vVert3_x, vVert3_y, ovMap.fHeight ], '1 1', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ vVert2_x, vVert2_y, ovMap.fHeight ], '0 0', '1 1 1', 1.0f ); // Bottom left
		R_EndPolygon();
				
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ vVert1_x, vVert1_y, ovMap.fHeight ], '0 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ vVert2_x, vVert2_y, ovMap.fHeight ], '0 0', '1 1 1', 1.0f ); // Bottom left
		R_PolygonVertex( [ vVert3_x, vVert3_y, ovMap.fHeight ], '1 1', '1 1 1', 1.0f ); // Top Right
		R_EndPolygon();
		
		fCameraHeight = fabs( 4096/ovMap.fZoom );
	} else {
		
		vVert1 = ovMap.vOrigin -( ( 4096/ovMap.fZoom )  * '0.75 1 0' );
		vVert4 = ovMap.vOrigin + ( 4096/ovMap.fZoom )  * '0.75 1 0';
				
		vVert2 = [ vVert1_x, vVert4_y ] ;
		vVert3 = [ vVert4_x, vVert1_y ] ;
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ vVert4_x, vVert4_y, ovMap.fHeight ], '0 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ vVert3_x, vVert3_y, ovMap.fHeight ], '1 0', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ vVert2_x, vVert2_y, ovMap.fHeight ], '0 1', '1 1 1', 1.0f ); // Bottom left
		R_EndPolygon();
				
		R_BeginPolygon( ovMap.sImagePath );
		R_PolygonVertex( [ vVert1_x, vVert1_y, ovMap.fHeight ], '1 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ vVert2_x, vVert2_y, ovMap.fHeight ], '0 1', '1 1 1', 1.0f ); // Bottom left
		R_PolygonVertex( [ vVert3_x, vVert3_y, ovMap.fHeight ], '1 0', '1 1 1', 1.0f ); // Top Right
		R_EndPolygon();
		
		fCameraHeight = fabs( 4096/ovMap.fZoom );
	}
	
	makevectors( view_angles );
	setproperty( VF_ORIGIN, ovMap.vOrigin + ( v_forward * -fCameraHeight ) ) ;
}