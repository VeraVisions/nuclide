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
	float frame_last;

	virtual float() predraw;
};

float
monster_npc::predraw(void)
{
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
	float fl;
	monster_npc pl = (monster_npc)self;

	if (new) {
		spawnfunc_monster_npc();
		pl.classname = "npc";
		pl.solid = SOLID_SLIDEBOX;
		pl.movetype = MOVETYPE_NONE;
		pl.drawmask = MASK_ENGINE;
		pl.customphysics = Empty;
		setsize(pl, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	}

	fl = readshort();

	if (fl & NPC_MODELINDEX)
		pl.modelindex = readshort();
	if (fl & NPC_ORIGIN_X)
		pl.origin[0] = readcoord();
	if (fl & NPC_ORIGIN_Y)
		pl.origin[1] = readcoord();
	if (fl & NPC_ORIGIN_Z)
		pl.origin[2] = readcoord();
	if (fl & NPC_ANGLES_X)
		pl.angles[0] = readfloat();
	if (fl & NPC_ANGLES_Y)
		pl.angles[1] = readfloat();
	if (fl & NPC_ANGLES_Z)
		pl.angles[2] = readfloat();
	if (fl & NPC_VELOCITY_X)
		pl.velocity[0] = readcoord();
	if (fl & NPC_VELOCITY_Y)
		pl.velocity[1] = readcoord();
	if (fl & NPC_VELOCITY_Z)
		pl.velocity[2] = readcoord();
	if (fl & NPC_FRAME)
		pl.frame = readbyte();
	if (fl & NPC_SKIN)
		pl.skin = readbyte();
	if (fl & NPC_BODY)
		pl.body = readbyte();

	if (new) {
		setcustomskin(pl, "", sprintf("geomset 1 %i\n", pl.body));
	}
}

