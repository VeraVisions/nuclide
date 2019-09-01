/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

.int iStep;

/*
=================
Footsteps_Update

Run every frame for each player, plays material based footsteps
=================
*/
void Footsteps_Update(void) {
	float fSpeed;
	float fVol;
	string sMaterial = "";
	string sTexture = "";

	if (!g_hlbsp_materials) {
		return;
	}

	if ((self.movetype == MOVETYPE_WALK) && (self.flags & FL_ONGROUND)) {
		if ((self.velocity[0] == 0 && self.velocity[1] == 0) || self.fStepTime > time) {
			return;
		}

		fSpeed = vlen(self.velocity);
		traceline(self.origin + self.view_ofs, self.origin + '0 0 -48', FALSE, self);
		sTexture = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

		if (fSpeed < 150) {
			return;
		} else if (fSpeed < 270) {
			fVol = 0.35f;
		} else {
			fVol = 0.75;
		}

		self.fStepTime = time + 0.35;

		switch((float)hash_get(hashMaterials, sTexture)) { 
			case 'M':
				sMaterial = "metal";
				break;
			case 'V':
				sMaterial = "duct";
				break;
			case 'D':
				sMaterial = "dirt";
				break;
			case 'S':
				sMaterial = "slosh";
				break;
			case 'T':
				sMaterial = "tile";
				break;
			case 'G':
				sMaterial = "grate";
				break;
			case 'W':
				sMaterial = "step";
				break;
			case 'P':
				sMaterial = "step";
				break;
			case 'Y':
				sMaterial = "step";
				break;
			case 'N':
				sMaterial = "snow";
				break;
			default:
				sMaterial = "step";
				break;
	}

		if (self.iStep) {
			if (random() < 0.5f) {
				sound(self, CHAN_BODY, sprintf("player/pl_%s1.wav", sMaterial), fVol, ATTN_STATIC);
			} else {
				sound(self, CHAN_BODY, sprintf("player/pl_%s2.wav", sMaterial), fVol, ATTN_STATIC);
			}
		} else {
			if (random() < 0.5f) {
				sound(self, CHAN_BODY, sprintf("player/pl_%s3.wav", sMaterial), fVol, ATTN_STATIC);
			} else {
				sound(self, CHAN_BODY, sprintf("player/pl_%s4.wav", sMaterial), fVol, ATTN_STATIC);
			}
		}

		self.iStep = 1 - self.iStep;
	}
}
