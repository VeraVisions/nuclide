/*
 * Copyright (c) 2023 Vera Visions LLC.
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

void
NSRadar::NSRadar(void)
{
	m_vecOrigin = g_vec_null;
	m_flScale = 1.0f;
	m_bRotated = false;
	m_strMaterial = __NULL__;
	m_flHeight = 0.0f;
	m_flZoom = 1.0f;
	m_bShowPlayers = true;
	m_flRadarPitch = 90; /* straight down */
}

void
NSRadar::SetRadarPitch(float pitchValue)
{
	m_flRadarPitch = pitchValue;
}

void
NSRadar::SetupView(void)
{
	vector playerPos = g_view.GetCameraOrigin();

	//drawfill( atPos, ofSize, '0 0 0', 1.0f, 0 );
	setproperty(VF_DRAWENGINESBAR, (float)0);
	setproperty(VF_DRAWCROSSHAIR, (float)0);
	setproperty(VF_MIN, video_mins+ m_vecPosition);
	setproperty(VF_SIZE, m_vecSize);
	setproperty(VF_AFOV, 90);
	setproperty(VF_VIEWENTITY, 0);
	setproperty(VF_DRAWWORLD, (float)0);

	setproperty(VF_ORIGIN, [playerPos[0], playerPos[1], m_flHeight + 1024] );
	makevectors(view_angles);
	setproperty(VF_ANGLES, [m_flRadarPitch, view_angles[1], 0]);
}

void
NSRadar::RenderPlayerIcon(entity playerEnt)
{
	vector playerColor = [1,1,1];
	string teamValue = getplayerkeyvalue(playerEnt.entnum-1, "*team");
	float psize = 32.0f;

	if (playerEnt == pSeat->m_ePlayer)
		return;

	R_BeginPolygon( "gfx/playericon" );

	if (teamValue)
		playerColor = stov(serverkey(strcat("teamcolor_", teamValue)));

	vector basePos = playerEnt.origin + [0.0, 0.0, 16.0f];
	makevectors([0, playerEnt.v_angle[1], 0]);
	R_PolygonVertex( basePos + (v_forward * psize) - (v_right * psize), '0 0', playerColor, 1.0f ); 
	R_PolygonVertex( basePos + (v_forward * psize) + (v_right * psize), '1 0', playerColor, 1.0f );
	R_PolygonVertex( basePos - (v_forward * psize) + (v_right * psize), '1 1', playerColor, 1.0f );
	R_PolygonVertex( basePos - (v_forward * psize) - (v_right * psize), '0 1', playerColor, 1.0f );

	R_EndPolygon();
}

void
NSRadar::RenderOverviewPlane(void)
{
	R_BeginPolygon( m_strMaterial );
	if ( m_bRotated == true ) {
		R_PolygonVertex( [ m_vecVert4[0], m_vecVert4[1], m_flHeight ], '1 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ m_vecVert3[0], m_vecVert3[1], m_flHeight ], '1 1', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ m_vecVert1[0], m_vecVert1[1], m_flHeight ], '0 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ m_vecVert2[0], m_vecVert2[1], m_flHeight ], '0 0', '1 1 1', 1.0f ); // Bottom left
	} else {
		R_PolygonVertex( [ m_vecVert4[0], m_vecVert4[1], m_flHeight ], '0 0', '1 1 1', 1.0f ); // Top Left
		R_PolygonVertex( [ m_vecVert3[0], m_vecVert3[1], m_flHeight ], '1 0', '1 1 1', 1.0f ); // Top Right
		R_PolygonVertex( [ m_vecVert1[0], m_vecVert1[1], m_flHeight ], '1 1', '1 1 1', 1.0f ); // Bottom right
		R_PolygonVertex( [ m_vecVert2[0], m_vecVert2[1], m_flHeight ], '0 1', '1 1 1', 1.0f ); // Bottom left
	}
	R_EndPolygon();
}

void
NSRadar::RenderWireframePlane(void)
{
	vector vert1, vert2, vert3, vert4;
	vector wireColor = [0.0f, 1.0f, 0.0f];

	vert1 = [256,0];
	vert2 = [0, 0];
	vert3 = [0, 256];
	vert4 = [256, 256];

	for (int x = -4096; x < 4096; x += 256) {
		for (int y = -4096; y < 4096; y += 256) {
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

void
NSRadar::RenderView(void)
{
	if (m_strMaterial != __NULL__) {
		RenderOverviewPlane();
	} else if (m_strMaterial == "wireframe") {
		RenderWireframePlane();
	}

	if (m_bShowPlayers)
	for ( entity eFind = world; ( eFind = find( eFind, ::classname, "player" ) ); ) {
		RenderPlayerIcon(eFind);
	}
	
	renderscene();
}

NSRadar
NSRadar::InitEmpty(void)
{
	NSRadar newRadar = spawn(NSRadar);
	newRadar.m_bDrawEntities = false;
	newRadar.CalculateVertices();
	newRadar.m_strMaterial = __NULL__;
	return newRadar;
}

NSRadar
NSRadar::InitWireframe(void)
{
	NSRadar newRadar = spawn(NSRadar);
	newRadar.m_bDrawEntities = false;
	newRadar.CalculateVertices();
	newRadar.m_strMaterial = "wireframe";
	return newRadar;
}

NSRadar
NSRadar::InitForCurrentMap(void)
{
	return InitWithMapname(mapname);
}

NSRadar
NSRadar::InitWithMapname(string mapName)
{
	string sourceFile = strcat("resource/overviews/", mapName, ".txt");
	string hlFile = strcat("overviews/", mapName, ".txt");

	/* try Source first, then GoldSrc */
	if (fileExists(sourceFile)) {
		return InitFromSourceHLTVScript(sourceFile);
	} else if (fileExists(hlFile)) {
		return InitFromHLTVScript(hlFile);
	}

	/* empty */
	return InitWireframe();
}

void
NSRadar::CalculateVertices(void)
{
	if ( m_bRotated == true ) {
		m_vecVert1 = m_vecOrigin -( ( 4096/m_flZoom )  * '1 0.75 0' );
		m_vecVert4 = m_vecOrigin + ( 4096/m_flZoom )  * '1 0.75 0';
		m_vecVert2 = [ m_vecVert1[0], m_vecVert4[1] ] ;
		m_vecVert3 = [ m_vecVert4[0], m_vecVert1[1] ] ; 
	} else {
		m_vecVert1 = m_vecOrigin -( ( 4096/m_flZoom )  * '0.75 1 0' );
		m_vecVert4 = m_vecOrigin + ( 4096/m_flZoom )  * '0.75 1 0';
		m_vecVert2 = [ m_vecVert1[0], m_vecVert4[1] ] ;
		m_vecVert3 = [ m_vecVert4[0], m_vecVert1[1] ] ;
	}
}

void
NSRadar::CalculateVerticesSource(float width, float height)
{
	m_vecVert2 = m_vecOrigin;
	m_vecVert1 = m_vecOrigin + [(width), 0.0f];
	m_vecVert3 = m_vecOrigin + [(width), (height)];
	m_vecVert4 = m_vecOrigin + [0.0f, (height)];

	m_vecVert1 -= [0.0, height];
	m_vecVert2 -= [0.0, height];
	m_vecVert3 -= [0.0, height];
	m_vecVert4 -= [0.0, height];
}

NSRadar
NSRadar::InitFromHLTVScript(string fileName)
{
	filestream overviewFile;
	NSRadar newRadar = spawn(NSRadar);
	string temp;
	int c;

	overviewFile = fopen(fileName, FILE_READ);

	/* sane switch */
	newRadar.m_bDrawEntities = false;

	if (overviewFile < 0) {
		error("Fatal: Unable to load HL file that exists on disk.");
		return newRadar;
	}

	/* the most primitive parser possible, technically the format
	   is supposed to support layers - but that was never utilized
	   and may not even be implemented. didn't check though. */
	while ((temp = fgets(overviewFile))) {
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "ZOOM":
			NSAssert((c >= 2i), "Too few parameters on ZOOM");
			newRadar.m_flZoom = stof(argv(1));
			break;
		case "ORIGIN":
			NSAssert((c >= 4i), "Too few parameters on ORIGIN");
			newRadar.m_vecOrigin[0] = stof(argv(1));
			newRadar.m_vecOrigin[1] = stof(argv(2));
			newRadar.m_vecOrigin[2] = stof(argv(3));
			break;
		case "ROTATED":
			NSAssert((c >= 2i), "Too few parameters on ROTATED");
			newRadar.m_bRotated = stof(argv(1)) == 0 ? false : true;
			break;
		case "IMAGE":
			NSAssert((c >= 2i), "Too few parameters on IMAGE");
			newRadar.m_strMaterial = argv(1);
			break;
		case "HEIGHT":
			NSAssert((c >= 2i), "Too few parameters on HEIGHT");
			newRadar.m_flHeight = stof(argv(1));
			break;
		default:
			break;
		}
	}

	newRadar.CalculateVertices();

	/* load the (presumably) .bmp file */
	int width, height, format;
	int *imgData = r_readimage(newRadar.m_strMaterial, width, height, format);

	NSAssert((imgData != __NULL__), "Cannot read overview image.");

	/* blank out the areas that are supposed to be transparent */
	for (int i = 0i; i < (width * height); i += 1i) {
		int r = (imgData[i] & 0xFF);
		int g = ((imgData[i] >> 8) & 0xFF);
		int b = ((imgData[i] >> 16) & 0xFF);

		/* check for purple, blue color */
		if (r == 255 && g == 0 && b == 255) {
			imgData[i] = 0i;
		} else if (r == 0 && g == 0 && b == 255) {
			imgData[i] = 0i;
		} else if (r == 0 && g == 255 && b == 0) {
			imgData[i] = 0i;
		}
	}

	shaderforname("overview", "{\n{\nmap $rt:overview\nblendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA\n}\n}\n");
	r_uploadimage("overview", width, height, (void *)imgData);
	memfree(imgData);
	newRadar.m_strMaterial = "overview";
	NSLog("Map overview available.");
	return newRadar;
}

NSRadar
NSRadar::InitFromSourceHLTVScript(string fileName)
{
	filestream overviewFile;
	NSRadar newRadar = spawn(NSRadar);
	string temp;
	int c;

	overviewFile = fopen(fileName, FILE_READ);

	/* sane switch */
	newRadar.m_bDrawEntities = false;

	if (overviewFile < 0) {
		error("Fatal: Unable to load file that exists on disk.");
		return newRadar;
	}

	/* the most primitive parser possible, technically the format
	   is supposed to support layers - but that was never utilized
	   and may not even be implemented. didn't check though. */
	while ((temp = fgets(overviewFile))) {
		c = tokenize_console(temp);

		switch(argv(0)) {
		case "zoom":
			NSAssert((c >= 2i), "Too few parameters on 'zoom'");
			newRadar.m_flZoom = stof(argv(1));
			break;
		case "scale":
			NSAssert((c >= 2i), "Too few parameters on 'scale'");
			newRadar.m_flScale = stof(argv(1));
			break;
		case "pos_x":
			NSAssert((c >= 2i), "Too few parameters on 'pos_x'");
			newRadar.m_vecOrigin[0] = stof(argv(1));
			break;
		case "pos_y":
			NSAssert((c >= 2i), "Too few parameters on 'pos_y'");
			newRadar.m_vecOrigin[1] = stof(argv(1));
			break;
		case "rotate":
			NSAssert((c >= 2i), "Too few parameters on 'rotate'");
			/* this seems to be ignored? whatever */
			//newRadar.m_bRotated = stof(argv(1)) == 0 ? false : true;
			break;
		case "material":
			NSAssert((c >= 2i), "Too few parameters on 'material'");
			newRadar.m_strMaterial = strcat("materials/", argv(1));
			break;
		case "height":
			NSAssert((c >= 2i), "Too few parameters on 'height'");
			newRadar.m_flHeight = stof(argv(1));
			break;
		default:
			break;
		}
	}

	vector imageSize = drawgetimagesize(newRadar.m_strMaterial);
	imageSize *= newRadar.m_flScale;
	newRadar.CalculateVerticesSource(imageSize[0], imageSize[1]);
	NSLog("Map overview available.");
	return newRadar;
}