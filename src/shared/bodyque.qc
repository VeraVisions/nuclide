/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
entity g_bodies;

var bool autocvar_bodyque_ragdolls = true;
var int autocvar_bodyque_maxBodies = 4i;

#define CORPSES_MAX autocvar_bodyque_maxBodies

void
BodyQue_Init(void)
{
	entity next;

	if (autocvar_bodyque_ragdolls)
		next = spawn(ncRagdoll);
	else
		next = spawn(ncRenderableEntity);

	g_bodies = next;

	for ( int i = 0; i <= CORPSES_MAX; i++ ) {
		next.classname = "corpse";

		if (autocvar_bodyque_ragdolls)
			next.owner = spawn(ncRagdoll);
		else
			next.owner = spawn(ncRenderableEntity);
		
		if ( i == CORPSES_MAX ) {
			next.owner = g_bodies;
		} else {
			next = next.owner;
		}
	}
}

static entity
BodyQue_Next(void)
{
	entity r = g_bodies;
	g_bodies = g_bodies.owner;
	return r;
}

static void
BodyQue_Update(void)
{
	ncEntity meSelf = (ncEntity)self;
	meSelf.frame1time += frametime;

	if (meSelf.frame1time < 10.0) {
		meSelf.ScheduleThink(BodyQue_Update, 0.0f);
	}
}

entity
BodyQue_Spawn(ncActor pl, float anim)
{
	ncRagdoll body_next = (ncRagdoll)BodyQue_Next();

	if (autocvar_bodyque_ragdolls) {
		/* don't run physics on server side */
		body_next.SetMovetype(MOVETYPE_NONE);
		body_next.SetSolid(SOLID_NOT);
	} else {
		body_next.SetMovetype(MOVETYPE_BOUNCE);
		body_next.SetSolid(SOLID_CORPSE);
	}

	body_next.SetModelindex(pl.GetModelindex());

	if (pl.IsCrouching()) {
		body_next.SetOrigin(pl.GetOrigin() + [0,0,32]);
	} else {
		body_next.SetOrigin(pl.GetOrigin());
	}

	body_next.SetSize(pl.GetMins(), pl.GetMaxs());
	body_next.SetAngles(pl.GetAngles());
	body_next.SetVelocity(pl.GetVelocity() + [0,0,120]);
	body_next.SetFrame(anim);
	body_next.m_iBody = pl.m_iBody;
	body_next.ScheduleThink(BodyQue_Update, 0.0f);
	body_next.colormap = pl.colormap;
	body_next.frame1time = 0.0f;

	return (entity)body_next;
}
#endif
