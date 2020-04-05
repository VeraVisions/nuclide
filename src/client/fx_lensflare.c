/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

int trace_surfaceflagsi;
var vector g_vecLensPos;
var float g_flLensAlpha;

int Util_IsSky(vector pos)
{
	if (serverkeyfloat("*bspversion") == 30)
	if (getsurfacetexture(world, getsurfacenearpoint(world, pos)) == "sky") {
		return TRUE;
	}
	
	/* trace_surfaceflagsi & SURF_SKY */
	return FALSE;
}

#define FLARE_SIZE [128,128]
void FX_LensFlare(void)
{
	if (!g_vecLensPos) {
		return;
	}

	makevectors(g_vecLensPos);
	vector lens_pos = getproperty(VF_ORIGIN) + (v_forward * 16384);
	vector lens_1 = project(lens_pos) - (FLARE_SIZE / 2);

	makevectors(getproperty(VF_ANGLES));
	vector v = normalize (lens_pos - getproperty(VF_ORIGIN));
	float flDot = v * v_forward;

	if (flDot < 0.15) {
		return;
	} else {
		traceline(getproperty(VF_ORIGIN), lens_pos, TRUE, self);

		if (Util_IsSky(trace_endpos) && flDot > 0.8) {
			/* this never happens because the above trace fails. */
			g_flLensAlpha = bound(0.0, g_flLensAlpha + (clframetime * 2), 1.0);
		} else {
			g_flLensAlpha = bound(0.0, g_flLensAlpha - (clframetime * 2), 1.0);
		}
	}

	if (g_flLensAlpha <= 0.0f) {
		return;
	}

	makevectors(getproperty(VF_CL_VIEWANGLES));
	vector lens_m = project(getproperty(VF_ORIGIN) + (v_forward * 16384));
	vector c = (lens_1 - lens_m) * 1.5;
	drawpic(lens_1, "textures/fx/flare1", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.1, "textures/fx/flare2", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.2, "textures/fx/flare3", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.3, "textures/fx/flare4", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 + c * 0.4, "textures/fx/flare2", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
	drawpic(lens_1 - c * 0.5, "textures/fx/flare3", FLARE_SIZE, [1,1,1] * g_flLensAlpha, 1.0f, DRAWFLAG_ADDITIVE);
}
