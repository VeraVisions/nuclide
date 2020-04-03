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

/* TODO: Move this into the player class. Monsters will call steps via
 * modelevents. */
.int iStep;

/* HLBSP materials.txt character id's */
#define MATID_ALIEN			'H'
#define MATID_BLOODYFLESH	'B'
#define MATID_COMPUTER		'P'
#define MATID_CONCRETE		'C'
#define MATID_DIRT			'D'
#define MATID_FLESH			'F'
#define MATID_FOLIAGE		'O'
#define MATID_GLASS			'Y'
#define MATID_GRATE			'G'
#define MATID_METAL			'M'
#define MATID_SLOSH			'S'
#define MATID_SNOW			'N'
#define MATID_TILE			'T'
#define MATID_VENT			'V'
#define MATID_WOOD			'W'

/* Valve Half-Life BSP */
void
Footsteps_HLBSP(entity target)
{
	string mat_name = "";
	string tex_name = "";

	if (!g_hlbsp_materials) {
		return;
	}

	traceline(target.origin + target.view_ofs, target.origin + [0,0,-48], FALSE, target);
	tex_name = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

	if (target.flags & FL_ONGROUND) {
		switch((float)hash_get(hashMaterials, tex_name)) { 
		case MATID_ALIEN:
			mat_name = "step_alien";
			break;
		case MATID_BLOODYFLESH:
			mat_name = "step_bloodyflesh";
			break;
		case MATID_COMPUTER:
			mat_name = "step_computer";
			break;
		case MATID_CONCRETE:
			mat_name = "step_concrete";
			break;
		case MATID_DIRT:
			mat_name = "step_dirt";
			break;
		case MATID_FLESH:
			mat_name = "step_flesh";
			break;
		case MATID_FOLIAGE:
			mat_name = "step_foliage";
			break;
		case MATID_GLASS:
			mat_name = "step_glass";
			break;
		case MATID_GRATE:
			mat_name = "step_grate";
			break;
		case MATID_METAL:
			mat_name = "step_metal";
			break;
		case MATID_SLOSH:
			mat_name = "step_slosh";
			break;
		case MATID_SNOW:
			mat_name = "step_snow";
			break;
		case MATID_TILE:
			mat_name = "step_tile";
			break;
		case MATID_VENT:
			mat_name = "step_vent";
			break;
		case MATID_WOOD:
			mat_name = "step_wood";
			break;
		default:
			mat_name = "step_default";
			break;
		}
	} else if (target.flags & FL_ONLADDER) {
		mat_name = "step_ladder";
	}

	if (target.iStep) {
		Sound_Play(target, CHAN_BODY, sprintf("%s.left", mat_name));
	} else {
		Sound_Play(target, CHAN_BODY, sprintf("%s.right", mat_name));
	}
}

/* Vera Visions BSP / Modified RFBSP */
void
Footsteps_VVBSP(entity target)
{
	string mat_name = "";

	/* WIP */
	if (target.flags & FL_ONGROUND) {
		mat_name = "step_default";
	} else if (target.flags & FL_ONLADDER) {
		mat_name = "step_ladder";
	}

	if (target.iStep) {
		Sound_Play(target, CHAN_BODY, sprintf("%s.left", mat_name));
	} else {
		Sound_Play(target, CHAN_BODY, sprintf("%s.right", mat_name));
	}
}

/*
=================
Footsteps_Update

Run every frame for each player, plays material based footsteps
=================
*/
void
Footsteps_Update(void)
{
	if (self.movetype == MOVETYPE_WALK) {
		if ((self.velocity[0] == 0 && self.velocity[1] == 0) || self.fStepTime > time) {
			return;
		}

		/* make it so we step once we land */
		if (!self.flags & FL_ONGROUND) {
			self.fStepTime = 0.0f;
			return;
		}

		/* the footsteps call might overwrite this later */
		self.fStepTime = time + 0.35;

		switch (serverkeyfloat("*bspversion")) {
		case 30:
			Footsteps_HLBSP(self);
			break;
		case 1:
			Footsteps_VVBSP(self);
			break;
		default:
		}

		/* switch between feet */
		self.iStep = 1 - self.iStep;
	}
}
