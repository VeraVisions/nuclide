/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED func_dustmotes (0 .5 .8) ?
Dustmote emitting brush volume.

-------- KEYS --------
"count" :  Number of dustmote particles that will float around on average.

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

class func_dustmotes:NSEntity
{
	int m_iCount;
	int m_iPart;
	float m_flNexTime;

	void(void) func_dustmotes;

	virtual void(void) Spawned;
	virtual float() predraw;
	virtual void(string, string) SpawnKey;
};

float
func_dustmotes::predraw(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE)
		return (PREDRAW_NEXT);

	if (m_flNexTime > cltime)
		return (PREDRAW_NEXT);

	for (int i = 0; i < m_iCount; i++) {
		vector vecPos;
		vecPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
		vecPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
		vecPos[2] = mins[2] + (random() * (maxs[2] - mins[2]));
		pointparticles(PART_DUSTMOTE, vecPos, [0,0,0], 1);
	}

	m_flNexTime = cltime + 3.0f;

	addentity(self);
	return (PREDRAW_NEXT);
}

void
func_dustmotes::Spawned(void)
{
	super::Spawned();

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	m_iCount = vlen(size) / 10;
}

void
func_dustmotes::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "count":
	case "SpawnRate":
		m_iCount = stoi(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
func_dustmotes::func_dustmotes(void)
{
	solid = SOLID_NOT;
}
