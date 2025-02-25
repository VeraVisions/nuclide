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

#ifdef CLIENT
#ifdef DEVELOPER
var int autocvar_dev_loddistance = 0;
#endif
#endif

/*! \brief Shared-Entity: Level Of Detail Geometry */
/*!QUAKED func_lod (0 .5 .8) ?
# OVERVIEW
Level of Detail brush entity, disappears at a set distance.
Useful for when VIS is impossible or not enough.

# KEYS
- "targetname" : Name
- "DisappearDist" : Distance in units for of when the func_lod will pop out of view.
- "Solid" : Defines solidity. Is "0" when solid, "1" when not-solid.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup sharedentity
@ingroup brushentity
*/
class func_lod:ncRenderableEntity
{
public:
	void func_lod(void);
	virtual void SpawnKey(string,string);

#ifdef CLIENT
	virtual void Spawned(void);
	virtual float predraw(void);
	virtual bool CanSpawn(bool);
#endif

#ifdef SERVER
	virtual void Respawn(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
private:
	int m_iDisappearDist;
#endif

};

void
func_lod::func_lod(void)
{
#ifdef CLIENT
	m_iDisappearDist = 2000;
	solid = SOLID_BSP;
	isCSQC = true;
#endif
}

#ifdef CLIENT
bool
func_lod::CanSpawn(bool clientSide)
{
	return true;
}

void
func_lod::Spawned(void)
{
	super::Spawned();

	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
}

float
func_lod::predraw(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE) {
		return (PREDRAW_NEXT);
	}

#ifdef DEVELOPER
	if (autocvar_dev_loddistance != 0) {
		if (vlen(vecPlayer - WorldSpaceCenter()) > autocvar_dev_loddistance) {
			return (PREDRAW_NEXT);
		}
	} else {
		if (vlen(vecPlayer - WorldSpaceCenter()) > m_iDisappearDist) {
			return (PREDRAW_NEXT);
		}
	}
#else
	if (vlen(vecPlayer - WorldSpaceCenter()) > m_iDisappearDist) {
		return (PREDRAW_NEXT);
	}
#endif

	addentity(self);
	return (PREDRAW_NEXT);
}
#endif

void
func_lod::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "DisappearDist":
#ifdef CLIENT
		m_iDisappearDist = stoi(strKey);
#endif
		break;
	case "Solid":
	case "solid":
		solid = stoi(strKey) == 1 ? SOLID_NOT : SOLID_BSP;
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

#ifdef SERVER
void
func_lod::Respawn(void)
{
	super::Respawn();
	SetMovetype(MOVETYPE_PUSH);
}

float
func_lod::SendEntity(entity a, float b)
{
	return (0);
}
#endif
