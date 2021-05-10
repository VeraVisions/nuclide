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

/*QUAKED func_illusionary (0 .5 .8) ?
"targetname"    Name

Brush that lets light to pass through it and is non-solid.
On idTech 2 BSPs, it will change texture variants when triggered.

Trivia:
This entity was introduced in Quake (1996).
*/

class
#ifdef CLIENT
func_illusionary:CBaseEntity
#else
func_illusionary:CBaseTrigger
#endif
{
	void(void) func_illusionary;

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
/* we're overriding SendEntity so that we don't network func_illusionarys
 * without a targetname. They'll never experience gameplay changes
 * and therefore can be handled fully client-side */
float
func_illusionary::SendEntity(entity pvsent, float fl)
{
	if (targetname)
		return CBaseTrigger::SendEntity(pvsent, fl);
	else
		return (0);
}

void
func_illusionary::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		SetSkin(0);
		break;
	case TRIG_ON:
		SetSkin(1);
		break;
	default:
		SetSkin(1-skin);
	}
}

void
func_illusionary::Respawn(void)
{
	/* reset the visual parameters */
	CBaseEntity::Respawn();

	/* func_illusionary specifics */
	SetAngles([0,0,0]);
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetSkin(0);

	// TODO: Add support for (skin) -1 = Empty, -7 = Volumetric light
	if (skin < 0) {
		SetSkin(0);
	}
}
#else
float
func_illusionary::predraw(void)
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
func_illusionary::Init(void)
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
	SetAngles([0,0,0]);
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_NOT);
	drawmask = MASK_ENGINE;
}
#endif

void
func_illusionary::func_illusionary(void)
{
#ifdef CLIENT
	Init();
#else
	CBaseTrigger::CBaseTrigger();
#endif
}
