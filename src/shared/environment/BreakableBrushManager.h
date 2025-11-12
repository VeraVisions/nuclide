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

class
ncBreakableBrushManager
{
#ifdef SERVER
public:
	nonvirtual void CarveRadiusIntoBrush(vector atPos, float withDamage);
	nonvirtual void CreateBrush(vector absMin, vector absMax, string shaderName);
	nonvirtual void ResetBrushFaceUVCoords(brushface_t *fa);
private:
	nonvirtual void _StageCarvedBrush(vector centre, float radius, string shadername);
	nonvirtual void _SubtractStageFromIntersecting(float modelindex, int br);
	nonvirtual void _StageBoundingBoxBrush(vector min, vector max, string shadername);
	nonvirtual float _SubtractStagedFromModelindex(float mod);
#endif
};
