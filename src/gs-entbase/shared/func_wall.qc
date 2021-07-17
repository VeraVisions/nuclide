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

/*QUAKED func_wall (0 .5 .8) ?
Brush that lets light to pass through it.

-------- KEYS --------
"targetname" : Name

-------- NOTES --------
On idTech 2 BSPs, it will change texture variants when triggered.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

class
#ifdef CLIENT
func_wall:CBaseEntity
#else
func_wall:CBaseTrigger
#endif
{
	void(void) func_wall;

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
func_wall::SendEntity(entity pvsent, float fl)
{
	if (targetname)
		return CBaseTrigger::SendEntity(pvsent, fl);
	else
		return (0);
}

void
func_wall::Trigger(entity act, int state)
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
func_wall::Respawn(void)
{
	/* reset the visual parameters */
	CBaseEntity::Respawn();

	/* func_wall specifics */
	SetAngles([0,0,0]);
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetFrame(0);
}
#else
float
func_wall::predraw(void)
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
func_wall::Init(void)
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
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;
	MakeStatic();
}
#endif

void
func_wall::func_wall(void)
{
#ifdef CLIENT
	Init();
#else
	CBaseTrigger::CBaseTrigger();
#endif
}
