/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED func_lod (0 .5 .8) ?
Level of Detail brush entity, disappears at a set distance.
Useful for when VIS is impossible or not enough.

-------- KEYS --------
"targetname" : Name
"DisappearDist" : Distance in units for of when the func_lod will pop out of view.
"Solid" : Defines solidity. Is "0" when solid, "1" when not-solid.

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

#ifdef DEVELOPER
var int autocvar_dev_loddistance = 0;
#endif

class func_lod:NSRenderableEntity
{
	int m_iDisappearDist;
	vector m_vecTestPos;

	void(void) func_lod;
	virtual void(void) Init;
	virtual float() predraw;
	virtual void(string,string) SpawnKey;
};

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
		if (vlen(vecPlayer - m_vecTestPos) > autocvar_dev_loddistance) {
			return (PREDRAW_NEXT);
		}
	} else {
		if (vlen(vecPlayer - m_vecTestPos) > m_iDisappearDist) {
			return (PREDRAW_NEXT);
		}
	}
#else
	if (vlen(vecPlayer - m_vecTestPos) > m_iDisappearDist) {
		return (PREDRAW_NEXT);
	}
#endif

	addentity(self);
	return (PREDRAW_NEXT);
}

void
func_lod::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "DisappearDist":
		m_iDisappearDist = stoi(strKey);
		break;
	case "Solid":
	case "solid":
		solid = stoi(strKey) == 1 ? SOLID_NOT : SOLID_BSP;
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
func_lod::Init(void)
{
	super::Init();

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;

	m_vecTestPos[0] = absmin[0] + (0.5 * (absmax[0] - absmin[0]));
	m_vecTestPos[1] = absmin[1] + (0.5 * (absmax[1] - absmin[1]));
	m_vecTestPos[2] = absmin[2] + (0.5 * (absmax[2] - absmin[2]));
}

void
func_lod::func_lod(void)
{
	m_iDisappearDist = 2000;
	solid = SOLID_BSP;
	Init();
}
