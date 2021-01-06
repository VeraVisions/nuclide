/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*
=================
Footsteps_Init

Just precaching sound shaders for all the types of material oriented footsteps.
=================
*/
void
Footsteps_Init(void)
{
	Sound_Precache("step_default.left");
	Sound_Precache("step_default.right");
	Sound_Precache("step_alien.left");
	Sound_Precache("step_alien.right");
	Sound_Precache("step_bloodyflesh.left");
	Sound_Precache("step_bloodyflesh.right");
	Sound_Precache("step_computer.left");
	Sound_Precache("step_computer.right");
	Sound_Precache("step_concrete.left");
	Sound_Precache("step_concrete.right");
	Sound_Precache("step_dirt.left");
	Sound_Precache("step_dirt.right");
	Sound_Precache("step_flesh.left");
	Sound_Precache("step_flesh.right");
	Sound_Precache("step_foliage.left");
	Sound_Precache("step_foliage.right");
	Sound_Precache("step_glass.left");
	Sound_Precache("step_glass.right");
	Sound_Precache("step_grate.left");
	Sound_Precache("step_grate.right");
	Sound_Precache("step_metal.left");
	Sound_Precache("step_metal.right");
	Sound_Precache("step_slosh.left");
	Sound_Precache("step_slosh.right");
	Sound_Precache("step_snow.left");
	Sound_Precache("step_snow.right");
	Sound_Precache("step_tile.left");
	Sound_Precache("step_tile.right");
	Sound_Precache("step_vent.left");
	Sound_Precache("step_vent.right");
	Sound_Precache("step_wood.left");
	Sound_Precache("step_wood.right");
	Sound_Precache("step_ladder.left");
	Sound_Precache("step_ladder.right");
}

/*
=================
Footsteps_HLBSP

Footstep code for BSP version 30, which uses an external materials.txt
to specify materials.
=================
*/
void
Footsteps_HLBSP(base_player target)
{
	string mat_name = "";
	string tex_name = "";

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

	if (target.step) {
		Sound_Play(target, CHAN_BODY, sprintf("%s.left", mat_name));
	} else {
		Sound_Play(target, CHAN_BODY, sprintf("%s.right", mat_name));
	}
}

/*
=================
Footsteps_VVBSP

Modern BSP format which uses surfaceflags to specify materials on surfaces.
=================
*/
void
Footsteps_VVBSP(base_player target)
{
	string mat_name = "";

	/* WIP */
	if (target.flags & FL_ONGROUND) {
		target.hitcontentsmaski = CONTENTBITS_POINTSOLID;
		tracebox(target.origin, target.mins, target.maxs, (target.origin + [0,0,-16]), MOVE_NORMAL, target);
		target.hitcontentsmaski = 0;
		trace_surfaceflagsi &= ~SURF_MASK;

		switch (trace_surfaceflagsi) {
		case SURF_ALIEN:
			mat_name = "step_alien";
			break;
		case SURF_FLESH:
			mat_name = "step_flesh";
			break;
		case SURF_FOLIAGE:
			mat_name = "step_foliage";
			break;
		case SURF_COMPUTER:
			mat_name = "step_computer";
			break;
		case SURF_DIRT:
			mat_name = "step_dirt";
			break;
		case SURF_VENT:
			mat_name = "step_vent";
			break;
		case SURF_GRATE:
			mat_name = "step_grate";
			break;
		case SURF_METAL:
			mat_name = "step_metal";
			break;
		case SURF_GLASS:
			mat_name = "step_glass";
			break;
		case SURF_SAND:
			mat_name = "step_sand";
			break;
		case SURF_SLOSH:
			mat_name = "step_slosh";
			break;
		case SURF_SNOW:
			mat_name = "step_snow";
			break;
		case SURF_TILE:
			mat_name = "step_tile";
			break;
		case SURF_WOOD:
			mat_name = "step_wood";
			break;
		case SURF_CONCRETE:
			mat_name = "step_concrete";
			break;
		default:
			mat_name = "step_default";
		}
	} else if (target.flags & FL_ONLADDER) {
		mat_name = "step_ladder";
	}

	if (target.step) {
		Sound_Play(target, CHAN_BODY, sprintf("%s.left", mat_name));
	} else {
		Sound_Play(target, CHAN_BODY, sprintf("%s.right", mat_name));
	}
}

/*
=================
Footsteps_Default

Default for any map format which we don't support or don't know how to support
materials for.
=================
*/
void
Footsteps_Default(base_player target)
{
	string mat_name = "";

	/* WIP */
	if (target.flags & FL_ONGROUND) {
		mat_name = "step_default";
	} else if (target.flags & FL_ONLADDER) {
		mat_name = "step_ladder";
	}

	if (target.step) {
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
	base_player pl;

	if (self.classname != "player")
		return;

	pl = (base_player)self;

	if (pl.movetype == MOVETYPE_WALK) {
		if ((pl.velocity[0] == 0 && pl.velocity[1] == 0) || pl.step_time > time) {
			return;
		}

		/* make it so we step once we land */
		if (!(pl.flags & FL_ONGROUND) && !(pl.flags & FL_ONLADDER)) {
			pl.step_time = 0.0f;
			return;
		}

		/* the footsteps call might overwrite this later */
		pl.step_time = time + 0.35;

		switch (serverkeyfloat("*bspversion")) {
		case BSPVER_HL:
			Footsteps_HLBSP(pl);
			break;
		case BSPVER_Q3: /* Q3 */
		case BSPVER_RTCW: /* RtCW */
		case BSPVER_RBSP: /* RFVBSP */
			Footsteps_VVBSP(pl);
			break;
		default:
			Footsteps_Default(pl);
		}

		/* switch between feet */
		pl.step = 1 - pl.step;
	}
}
