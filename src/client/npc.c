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

class monster_npc
{
	int body;
	int inited;
	float frame_last;

	virtual float() predraw;
};

float
monster_npc::predraw(void)
{
	/* Only do this once whenever the ent pops into view */
	if (!inited) {
		setcustomskin(this, "", sprintf("geomset 1 %i\n", body));
		inited = TRUE;
	}

	if (lerpfrac > 0) {
		lerpfrac -= frametime * 5;
		if (lerpfrac < 0) {
			lerpfrac = 0;
		}
	}

	if (frame != frame_last) {
		frame2time = frame1time;
		frame2 = frame_last;
		frame_last = frame;
		lerpfrac = 1.0f;
		frame1time = 0.0f;
	}

	frame2time += clframetime;
	frame1time += clframetime;
	bonecontrol5 = getchannellevel(this, CHAN_VOICE) * 20;

	addentity(this);
	return PREDRAW_NEXT;
}

void
NPC_ReadEntity(float new)
{
	monster_npc pl = (monster_npc)self;
	if (new == TRUE) {
		spawnfunc_monster_npc();
		pl.classname = "npc";
		pl.solid = SOLID_SLIDEBOX;
		pl.drawmask = MASK_ENGINE;
		pl.customphysics = Empty;
		setsize( pl, VEC_HULL_MIN, VEC_HULL_MAX );
	}

	/* TODO: make these conditional */
	pl.modelindex = readshort();
	pl.origin[0] = readcoord();
	pl.origin[1] = readcoord();
	pl.origin[2] = readcoord();
	pl.angles[1] = readfloat();
	pl.angles[2] = readfloat();
	pl.velocity[0] = readcoord();
	pl.velocity[1] = readcoord();
	pl.velocity[2] = readcoord();
	pl.frame = readbyte();
	pl.skin = readbyte();
	pl.body = readbyte();
}

