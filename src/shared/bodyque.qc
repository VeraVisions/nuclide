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
entity g_bodiesRagdoll;

void
BodyQue_Init(void)
{
	entity next;

	g_bodies = next = spawn(ncRenderableEntity);

	for (int i = 0i; i <= CORPSES_MAX; i++) {
		if (i == CORPSES_MAX) {
			next.owner = g_bodies;
		} else {
			next = next.owner = spawn(ncRenderableEntity);
		}
	}

	g_bodiesRagdoll = next = spawn(ncRagdoll);

	for (int i = 0i; i <= RAGDOLLS_MAX; i++) {
		if (i == RAGDOLLS_MAX) {
			next.owner = g_bodiesRagdoll;
		} else {
			next = next.owner = spawn(ncRagdoll);
		}
	}
}

static ncRenderableEntity
BodyQue_Next(void)
{
	entity r = g_bodies;
	g_bodies = g_bodies.owner;
	return r;
}

static ncRagdoll
BodyQue_NextRagdoll(void)
{
	entity r = g_bodiesRagdoll;
	g_bodiesRagdoll = g_bodiesRagdoll.owner;
	return r;
}

static void
BodyQue_Update(void)
{
	ncEntity meSelf = (ncEntity)self;

	meSelf.frame1time += frametime;
	meSelf.AddVelocity([0,0,128] * lerp(1.0f, 0.0f, meSelf.GetSpawnAge() * 0.1f));

	if (meSelf.frame1time < 10.0) {
		meSelf.ScheduleThink(BodyQue_Update, 0.0f);
	}
}

ncRenderableEntity
BodyQue_Spawn(ncActor pl, float anim)
{
	ncRenderableEntity nextBody = BodyQue_Next();

	nextBody.Spawn();
	nextBody.SetMovetype(MOVETYPE_BOUNCE);
	nextBody.SetSolid(SOLID_CORPSE);
	nextBody.SetModelindex(pl.GetModelindex());

	if (pl.IsCrouching()) {
		nextBody.SetOrigin(pl.GetOrigin() + [0,0,32]);
	} else {
		nextBody.SetOrigin(pl.GetOrigin());
	}

	nextBody.SetSize(pl.GetMins(), pl.GetMaxs());
	nextBody.SetAngles(pl.GetAngles());
	nextBody.SetVelocity(pl.GetVelocity() + [0,0,120]);
	nextBody.SetFrame(anim);
	nextBody.m_geomsetField = pl.m_geomsetField;
	nextBody.ScheduleThink(BodyQue_Update, 0.0f);
	nextBody.colormap = pl.colormap;
	nextBody.frame1time = 0.0f;

	return (nextBody);
}

ncRagdoll
BodyQue_SpawnRagdoll(ncActor pl, float anim)
{
	ncRagdoll nextRagdoll = (ncRagdoll)BodyQue_NextRagdoll();

	nextRagdoll.Spawn();
	/* don't run physics on server side */
	nextRagdoll.SetMovetype(MOVETYPE_NONE);
	nextRagdoll.SetSolid(SOLID_NOT);
	nextRagdoll.SetModelindex(pl.GetModelindex());

	if (pl.IsCrouching()) {
		nextRagdoll.SetOrigin(pl.GetOrigin() + [0,0,32]);
	} else {
		nextRagdoll.SetOrigin(pl.GetOrigin());
	}

	nextRagdoll.SetSize(pl.GetMins(), pl.GetMaxs());
	nextRagdoll.SetAngles(pl.GetAngles());
	nextRagdoll.SetVelocity(pl.GetVelocity() + [0,0,120]);
	nextRagdoll.SetFrame(anim);
	nextRagdoll.m_geomsetField = pl.m_geomsetField;
	nextRagdoll.ScheduleThink(BodyQue_Update, 0.0f);
	nextRagdoll.colormap = pl.colormap;
	nextRagdoll.frame1time = 0.0f;

	return (nextRagdoll);
}
#endif
