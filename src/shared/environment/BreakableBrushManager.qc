/*
 * Copyright (c) 2024-2025 Vera Visions LLC.
 * Copyright (c) 2017 David Walton
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

#ifdef SERVER
brushface_t g_stageBreakFaces[6];
brushface_t g_tmpBreakFaces[128];
int g_breakBrushList[128];
int g_stagePlaneCount;
int g_tmpBreakContents;
vector g_tmpBreakFacePoints[128];

void
ncBreakableBrushManager::ResetBrushFaceUVCoords(brushface_t *fa)
{	
	float a = fabs(fa->planenormal[0]);
	float b = fabs(fa->planenormal[1]);
	float c = fabs(fa->planenormal[2]);

	fa->sdir = g_vec_null;
	fa->sbias = 0;
	fa->tdir = g_vec_null;
	fa->tbias = 0;

	if (a>=b && a>=c) {
		fa->sdir[1] = 1;
	} else {
		fa->sdir[0] = 1;
	}

	if (c>a && c>b) {
		fa->tdir[1] = -1;
	} else {
		fa->tdir[2] = -1;
	}
}

void
ncBreakableBrushManager::CarveRadiusIntoBrush(vector atPos, float withDamage)
{
	_StageCarvedBrush(atPos, withDamage, "gfx/conback");
	_SubtractStagedFromModelindex(world.modelindex);
}

void
ncBreakableBrushManager::CreateBrush(vector absMin, vector absMax, string shaderName)
{
	_StageBoundingBoxBrush(absMin, absMax, shaderName);
	brush_create(world.modelindex, g_stageBreakFaces, g_stagePlaneCount, CONTENTBIT_SOLID);
}

void
ncBreakableBrushManager::_StageBoundingBoxBrush(vector min, vector max, string shadername)
{
	g_stagePlaneCount = 6;
	
	g_stageBreakFaces[0].planenormal = [1,0,0];
	g_stageBreakFaces[0].planedist = max[0];
	g_stageBreakFaces[1].planenormal = [0,1,0];
	g_stageBreakFaces[1].planedist = max[1];
	g_stageBreakFaces[2].planenormal = [0,0,1];
	g_stageBreakFaces[2].planedist = max[2];
	
	g_stageBreakFaces[3].planenormal = [-1,0,0];
	g_stageBreakFaces[3].planedist = -min[0];
	g_stageBreakFaces[4].planenormal = [0,-1,0];
	g_stageBreakFaces[4].planedist = -min[1];
	g_stageBreakFaces[5].planenormal = [0,0,-1];
	g_stageBreakFaces[5].planedist = -min[2];

	for (int i = 0; i < g_stagePlaneCount; i++) {
		g_stageBreakFaces[i].shadername = shadername;
		ResetBrushFaceUVCoords(&g_stageBreakFaces[i]);
	}
}

void
ncBreakableBrushManager::_StageCarvedBrush(vector centerPos, float withRadius, string materialName)
{
	g_stagePlaneCount = 6;

	g_stageBreakFaces[0].planenormal = [1,0,0];
	g_stageBreakFaces[1].planenormal = [0,1,0];
	g_stageBreakFaces[2].planenormal = [0,0,1];
	g_stageBreakFaces[3].planenormal = [-1,0,0];
	g_stageBreakFaces[4].planenormal = [0,-1,0];
	g_stageBreakFaces[5].planenormal = [0,0,-1];

	for (int i = 0; i < g_stagePlaneCount; i++) {
		g_stageBreakFaces[i].planenormal = normalize(g_stageBreakFaces[i].planenormal + [random(-0.25, 0.25), random(-0.25, 0.25), random(-0.25, 0.25)]);
		g_stageBreakFaces[i].planedist = g_stageBreakFaces[i].planenormal * (g_stageBreakFaces[i].planenormal * withRadius + centerPos);
		g_stageBreakFaces[i].shadername = materialName;
		ResetBrushFaceUVCoords(&g_stageBreakFaces[i]);
	}
}

void
ncBreakableBrushManager::_SubtractStageFromIntersecting(float targetModelindex, int brushIndex)
{
	int v = 0;
	int faceCount = brush_get(targetModelindex, brushIndex, g_tmpBreakFaces, g_tmpBreakFaces.length, &g_tmpBreakContents);
	int newCount = faceCount + g_stagePlaneCount;

	if (newCount > g_tmpBreakFaces.length) {
		return;
	}

	memcpy(&g_tmpBreakFaces[faceCount], g_stageBreakFaces, sizeof(g_stageBreakFaces[0]) * g_stagePlaneCount);

	for (v = 0, int i = 1; i <= newCount; i++) {
		if (brush_calcfacepoints(i, g_tmpBreakFaces, newCount, g_tmpBreakFacePoints, g_tmpBreakFacePoints.length)) {
			v++;
		}
	}

	/* too many planes clipped away, they can't really intersect */
	if (!v) {
		return;
	}

	brush_delete(targetModelindex, brushIndex);

	while (newCount --> faceCount) {
		/* only consider the resulting brush if the new face actually contributed anything. this reduces dupes. -- Spoike */
		if (brush_calcfacepoints(1 + newCount, g_tmpBreakFaces, newCount + 1, g_tmpBreakFacePoints, g_tmpBreakFacePoints.length)) {
			g_tmpBreakFaces[newCount].planenormal *= -1;
			g_tmpBreakFaces[newCount].planedist *= -1;
			brush_create(targetModelindex, g_tmpBreakFaces, newCount + 1, g_tmpBreakContents);
		}
	}
}

float
ncBreakableBrushManager::_SubtractStagedFromModelindex(float targetModelindex)
{
	int numBrushes = 0;
	static vector stagedNormals[g_stageBreakFaces.length];
	static float stagedDists[g_stageBreakFaces.length];

	for (int i = 0; i < g_stagePlaneCount; i++) {
		stagedNormals[i] = g_stageBreakFaces[i].planenormal;
		stagedDists[i] = g_stageBreakFaces[i].planedist;
	}

	numBrushes = brush_findinvolume(targetModelindex, stagedNormals, stagedDists, g_stagePlaneCount, g_breakBrushList, __NULL__, g_breakBrushList.length);

	if (!numBrushes) {
		return (false);
	}

	while (numBrushes --> 0) {
		_SubtractStageFromIntersecting(targetModelindex, g_breakBrushList[numBrushes]);
	}

	return (true);
}
#endif
