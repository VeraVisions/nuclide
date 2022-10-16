/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
}

/*
=================
Footsteps_HLBSP

Footstep code for BSP version 30, which uses an external materials.txt
to specify materials.
=================
*/
void
Footsteps_HLBSP(NSClientPlayer target)
{
	string mat_name = "";
	string tex_name = "";
	string sound = "";

	//tracebox(target.origin, PHY_HULL_MIN, PHY_HULL_MAX, target.origin + [0,0,-48], MOVE_NORMAL, target);
	traceline(target.origin + target.view_ofs, target.origin + [0,0,-48], FALSE, target);
	tex_name = getsurfacetexture(trace_ent, getsurfacenearpoint(trace_ent, trace_endpos));

	if (!(target.flags & FL_ONGROUND)) {
		return;
	} else if (target.flags & FL_ONLADDER) {
		mat_name = "step_ladder";
		
		if (target.step)
			Sound_Play(target, CHAN_BODY, sprintf("%s.left", mat_name));
		else
			Sound_Play(target, CHAN_BODY, sprintf("%s.right", mat_name));

		return;
	}

	if (target.step) {
		Sound_Play(target, CHAN_BODY, 
			SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_SND_STEPLEFT));
	} else {
		Sound_Play(target, CHAN_BODY,
			SurfData_GetInfo(SurfData_TexToSurfData(tex_name), SURFDATA_SND_STEPRIGHT));
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
	NSClientPlayer pl;

	/* mp_footsteps is only available in MP matches */
	if (Util_IsSingleplayer() == false)
		if (autocvar(mp_footsteps, 1) == 0)
			return;

	if (self.classname != "player")
		return;

	pl = (NSClientPlayer)self;

	if (pl.movetype == MOVETYPE_WALK) {
		if ((pl.velocity[0] == 0 && pl.velocity[1] == 0) || pl.step_time > time)
			return;

		if (pl.waterlevel == 1) {
			if (pl.step)
				Sound_Play(pl, CHAN_BODY, "step_slosh.left");
			else
				Sound_Play(pl, CHAN_BODY, "step_slosh.right");

			pl.step_time = time + 0.35f;
		} else if (pl.waterlevel == 2) {
			if (pl.step)
				Sound_Play(pl, CHAN_BODY, "step_wade.left");
			else
				Sound_Play(pl, CHAN_BODY, "step_wade.right");
		
			pl.step_time = time + 1.0f;
		}  else if (pl.waterlevel == 3) {
			if (pl.step)
				Sound_Play(pl, CHAN_BODY, "step_swim.left");
			else
				Sound_Play(pl, CHAN_BODY, "step_swim.right");

			pl.step_time = time + 2.0f;
		} else {
			/* make it so we step once we land */
			if (!(pl.flags & FL_ONGROUND) && !(pl.flags & FL_ONLADDER)) {
				pl.step_time = 0.0f;
				return;
			}
		}

		/* the footsteps call might overwrite this later */
		pl.step_time = time + 0.35;

		Footsteps_HLBSP(pl);

		/* switch between feet */
		pl.step = 1 - pl.step;
	}
}
