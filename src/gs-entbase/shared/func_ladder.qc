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

/*QUAKED func_ladder (0 .5 .8) ?
Ladder volume. Climb up ladders with this one simple brush.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class
#ifdef CLIENT
func_ladder:CBaseEntity
#else
func_ladder:CBaseTrigger
#endif
{
	void(void) func_ladder;

#ifdef SERVER
	virtual void(void) Respawn;
	virtual float(entity, float) SendEntity;
	virtual void(entity, int) Trigger;
#else
	virtual float() predraw;
	virtual void(void) Init;
#endif
};

#ifdef SERVER
/* we're overriding SendEntity so that we don't network func_walls
 * without a targetname. They'll never experience gameplay changes
 * and therefore can be handled fully client-side */
float
func_ladder::SendEntity(entity pvsent, float fl)
{
	if (targetname)
		return CBaseTrigger::SendEntity(pvsent, fl);
	else
		return (0);
}

void
func_ladder::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		SetFrame(0);
		break;
	case TRIG_ON:
		SetFrame(1);
		break;
	default:
		SetFrame(1 - frame);
	}
}

void
func_ladder::Respawn(void)
{
	/* reset the visual parameters */
	CBaseEntity::Respawn();

	/* func_ladder specifics */
	SetAngles([0,0,0]);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSP);
	SetSkin(CONTENT_LADDER);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetFrame(0);
#ifdef GS_RENDERFX
	SetRenderMode(RM_TRIGGER);
#endif
}
#else
float
func_ladder::predraw(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE) {
		return (PREDRAW_NEXT);
	}

	CBaseEntity::predraw();
	addentity(self);
	return (PREDRAW_NEXT);
}

void
func_ladder::Init(void)
{
	CBaseEntity::Init();

	/* this entity is being controlled by the server, remove it */
	if (targetname) {
		think = Util_Destroy;
		nextthink = time + 0.01f; /* time may be 0.0 */
		return;
	}

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	solid = SOLID_BSP;
	skin = CONTENT_LADDER;
}
#endif

void
func_ladder::func_ladder(void)
{
#ifdef CLIENT
	Init();
#else
	CBaseTrigger::CBaseTrigger();
#endif
}
