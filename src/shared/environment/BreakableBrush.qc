
#ifdef SERVER

#define BRUSHCONTENTS CONTENTBIT_SOLID
#define BREAKABLE_MAX_SPAWNFACES 32
#define BREAKABLE_CARVE_PLANES 6

brushface_t faces[BREAKABLE_CARVE_PLANES];
brushface_t tmp_faces[128];
float seldists[BREAKABLE_CARVE_PLANES];
int brushlist[128];
int tmp_contents;
vector facepoints[128];
vector selnormals[BREAKABLE_CARVE_PLANES];

#endif

class
ncBreakableBrush:ncSurfacePropEntity
{
public:
	void ncBreakableBrush(void);

#ifdef SERVER
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void OnRemoveEntity(void);
	virtual void Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody);

	nonvirtual void ResetFaceTextureCoordinates(brushface_t *fa);
	nonvirtual void SubtractFacesFromBrush(int br);
	nonvirtual void CarveRadiusIntoBrush(vector atPoint, float radiusValue);

private:

	string m_insideTexture;
	int m_originalContents;
	brushface_t *m_originalFaces;
	int m_originalFaceCount;
#endif
};

void
ncBreakableBrush::ncBreakableBrush(void)
{
#ifdef SERVER
	m_insideTexture = __NULL__;
	m_originalFaces = __NULL__;
	m_originalFaceCount = 0i;
#endif
}

#ifdef SERVER



void
ncBreakableBrush::OnRemoveEntity(void)
{
	if (m_originalFaces) {
		memfree(m_originalFaces);
		m_originalFaces = __NULL__;
		m_originalFaceCount = 0i;
	}
}

void
ncBreakableBrush::ResetFaceTextureCoordinates(brushface_t *fa)
{
	//figure out some default texture coords	
	fa->sdir = '0 0 0';
	fa->sbias = 0;
	fa->tdir = '0 0 0';
	fa->tbias = 0;
	float a=fabs(fa->planenormal[0]),b=fabs(fa->planenormal[1]),c=fabs(fa->planenormal[2]);
	if (a>=b&&a>=c)
		fa->sdir[1] = 1;
	else
		fa->sdir[0] = 1;
	if (c>a&&c>b)
		fa->tdir[1] = -1;
	else
		fa->tdir[2] = -1;
};

void
ncBreakableBrush::SubtractFacesFromBrush(int br)
{
	//generate the new brush with the old brush's planes
	int counto = brush_get(world.modelindex, br, tmp_faces, tmp_faces.length, &tmp_contents);

	//FIXME: chop the brushes on some grid up if their extents are big, so as to constrain carving damage

	//append the planes that we're subtracting...
	int counts = counto + BREAKABLE_CARVE_PLANES;
	if (counts > tmp_faces.length)
		return;	//zomg! panic! flee in terror!
	memcpy(&tmp_faces[counto], faces, sizeof(faces[0])*BREAKABLE_CARVE_PLANES);
	
	int v;
	for (v = 0, int i = 1; i <= counts; i++)
	{
		if (brush_calcfacepoints(i, tmp_faces, counts, facepoints, facepoints.length))
			v++;
	}
	if (!v) {
		return;	//too many planes clipped away, they can't really intersect.
	}

	//nuke the old brush
	brush_delete(world.modelindex, br);
	while(counts --> counto)
	{
		//only consider the resulting brush if the new face actually contributed anything.
		//this reduces dupes.
		if (brush_calcfacepoints(1+counts, tmp_faces, counts+1, facepoints, facepoints.length))
		{
			//determine the brush defined by this plane
			tmp_faces[counts].planenormal *= -1;
			tmp_faces[counts].planedist *= -1;
			brush_create(world.modelindex, tmp_faces, counts+1, tmp_contents);
		}
	}
};


void
ncBreakableBrush::CarveRadiusIntoBrush(vector atPoint, float radiusValue)
{

	faces[0].planenormal = '1 0 0';
	faces[1].planenormal = '0 1 0';
	faces[2].planenormal = '0 0 1';
	
	faces[3].planenormal = '-1 0 0';
	faces[4].planenormal = '0 -1 0';
	faces[5].planenormal = '0 0 -1';

	for (int i = 0; i < BREAKABLE_CARVE_PLANES; i++) {
		faces[i].planenormal = normalize(faces[i].planenormal + [random(-0.25,0.25),random(-0.25,0.25),random(-0.25,0.25)]);
		faces[i].planedist = faces[i].planenormal * (faces[i].planenormal*radiusValue+atPoint);
		faces[i].shadername = m_insideTexture;
		ResetFaceTextureCoordinates(&faces[i]);

		selnormals[i] = faces[i].planenormal;
		seldists[i] = faces[i].planedist;
	}

	int numbrushes = brush_findinvolume(world.modelindex, selnormals, seldists, BREAKABLE_CARVE_PLANES, brushlist, __NULL__, brushlist.length);

	if (!numbrushes) {
		return;
	}

	while (numbrushes --> 0) {
		SubtractFacesFromBrush((int)brushlist[numbrushes]);
	}
}

void
ncBreakableBrush::generatebboxbrush(vector min, vector max, string shadername)
{
	faces[0].planenormal = '1 0 0';
	faces[0].planedist = max[0];
	faces[1].planenormal = '0 1 0';
	faces[1].planedist = max[1];
	faces[2].planenormal = '0 0 1';
	faces[2].planedist = max[2];
	
	faces[3].planenormal = '-1 0 0';
	faces[3].planedist = -min[0];
	faces[4].planenormal = '0 -1 0';
	faces[4].planedist = -min[1];
	faces[5].planenormal = '0 0 -1';
	faces[5].planedist = -min[2];

	for (int i = 0; i < 6; i++)
	{
		faces[i].shadername = shadername;
		ResetFaceTextureCoordinates(&faces[i]);
	}
};

void
ncBreakableBrush::Spawned(void)
{
	super::Spawned();

#if 0
	float targetModel = getmodelindex(GetSpawnString("model"), false);
#else
	SetModel(GetSpawnString("model"));
	generatebboxbrush(absmin, absmax, "outside");
	brush_create(world.modelindex, faces, 6, BRUSHCONTENTS);
#endif

	int numBrushes = brush_findinvolume(world.modelindex, selnormals, seldists, BREAKABLE_MAX_SPAWNFACES, brushlist, __NULL__, brushlist.length);

	if (numBrushes == 0i) {
		EntError("failed to get brush info for modelindex %d", modelindex);
		//Destroy();
		return;
	}

	/* store a copy of our original brush data, so we can restore it */
	if (!m_originalFaces) {
		m_originalFaces = memalloc(sizeof(brushface_t) * BREAKABLE_MAX_SPAWNFACES);
	}

	m_originalFaceCount = brush_get(world.modelindex, brushlist[0], &m_originalFaces, BREAKABLE_MAX_SPAWNFACES, &m_originalContents);

	if (m_originalFaceCount == 0i) {
		EntError("failed to get face info for brush %i", brushlist[0]);
		return;
	}
}

void
ncBreakableBrush::Pain(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	CarveRadiusIntoBrush(absImpactPos, (float)damage);
	SetHealth(99999);
	SetMovetype(MOVETYPE_PUSH);
	EntError("Ow! %i", damage);
}

void
ncBreakableBrush::Respawn(void)
{
	super::Respawn();

	MakeVulnerable();
	Hide();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetHealth(99999);

}

#endif
