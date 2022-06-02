/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED func_dustcloud (0 .5 .8) ?
Dust cloud emitting brush volume.

-------- KEYS --------
"count" :  Number of cloud particles that will float around on average.
"Alpha" :  Transparency of the clouds. Value from 0 to 255.
"SizeMin" : Minimum size of each cloud. In Quake units.
"SizeMax" : Maximum size of each cloud. In Quake units.

-------- TRIVIA --------
This entity was introduced in Half-Life 2 (2004).
*/

class func_dustcloud:NSEntity
{
	int m_iCount;
	int m_iPart;
	float m_flNexTime;

	float m_flSizeMin;
	float m_flSizeMax;
	float m_flAlpha;
	vector m_vecColor;
	float m_flLifetimeMin;
	float m_flLifetimeMax;

	void(void) func_dustcloud;
	virtual void(void) Spawned;
	virtual float() predraw;
	virtual void(string, string) SpawnKey;
};

#if 1
class func_dustcloud_cloud
{
	vector cloudsize;
	float lifetime;

	/* attributes */
	float m_flMaxAlpha;
	vector m_vecColor;
	float m_flLifeTime;

	void(void) func_dustcloud_cloud;

	virtual float(void) predraw;
};

float
func_dustcloud_cloud::predraw(void)
{
	float alpha;
	makevectors(view_angles);

	if (lifetime < (m_flLifeTime / 2)) {
		alpha = bound(0.0, lifetime / (m_flLifeTime / 2), 1.0);
	} else {
		alpha = 1.0 - bound(0.0, ((lifetime-(m_flLifeTime / 2)) / (m_flLifeTime / 2)), 1.0);
	}

	alpha *= m_flMaxAlpha;

	R_BeginPolygon("textures/sfx/dustcloud", 0, 0);
	R_PolygonVertex(origin + v_right * cloudsize[0] - v_up * cloudsize[1], [1,1], m_vecColor, alpha);
	R_PolygonVertex(origin - v_right * cloudsize[0] - v_up * cloudsize[1], [0,1], m_vecColor, alpha);
	R_PolygonVertex(origin - v_right * cloudsize[0] + v_up * cloudsize[1], [0,0], m_vecColor, alpha);
	R_PolygonVertex(origin + v_right * cloudsize[0] + v_up * cloudsize[1], [1,0], m_vecColor, alpha);
	R_EndPolygon();

	if (lifetime >= 10.0f) {
		think = Util_Destroy;
		nextthink = time;
	}

	lifetime += frametime;

	return PREDRAW_NEXT;
}

void
func_dustcloud_cloud::func_dustcloud_cloud(void)
{
	setsize(this, [0,0,0], [0,0,0]);
	drawmask = MASK_ENGINE;
	lifetime = 0.0f;
}
#endif

float
func_dustcloud::predraw(void)
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

		func_dustcloud_cloud cloud = spawn(func_dustcloud_cloud);
		setorigin(cloud, vecPos);
		cloud.m_vecColor = m_vecColor;
		cloud.m_flMaxAlpha = m_flAlpha;
		cloud.cloudsize[0] = random(m_flSizeMin, m_flSizeMax);
		cloud.cloudsize[1] = random(m_flSizeMin, m_flSizeMax);
		cloud.m_flLifeTime = random(m_flLifetimeMin, m_flLifetimeMax);
	}

	m_flNexTime = cltime + 1.0f;

	addentity(self);
	return (PREDRAW_NEXT);
}

void
func_dustcloud::Spawned(void)
{
	super::Spawned();

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
	/*m_strParticle = strcat("dustcloud_", ftos(entnum));
	localcmd(sprintf(g_dustcloud_cfg, m_strParticle));*/
}

void
func_dustcloud::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "count":
	case "SpawnRate":
		m_iCount = stoi(strKey);
		break;
	case "LifetimeMin":
		m_flLifetimeMin = stof(strKey);
		break;
	case "LifetimeMax":
		m_flLifetimeMax = stof(strKey);
		break;
	case "SizeMin":
		m_flSizeMin = stof(strKey);
		break;
	case "SizeMax":
		m_flSizeMax = stof(strKey);
		break;
	case "Alpha":
		m_flAlpha = stof(strKey) / 255;
		break;
	case "Color":
		m_vecColor = stov(strKey) / 255;
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
func_dustcloud::func_dustcloud(void)
{
/*
	m_iCount = vlen(size) / 100;
	m_flSizeMin = 200;
	m_flSizeMax = 250;
	m_flAlpha = 1.0f;
	m_vecColor = [1,1,1];
*/
	solid = SOLID_NOT;
}
