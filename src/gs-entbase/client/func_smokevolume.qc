/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/*!QUAKED func_smokevolume (0 .5 .8) ? FULLBRIGHT
# OVERVIEW
Smoke cloud emitting brush volume.

# KEYS
- "ParticleDrawWidth" : Size of the particles in Quake units.
- "SizeMax" : Maximum size of each cloud. In Quake units.
- "Color1" : Primary color
- "Color2" : Secondary color
- "MaxDrawDistance" : Maximum draw distance. Set to 0 if infinite.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class func_smokevolume:NSEntity
{
public:
	void func_smokevolume(void);

	virtual void Spawned(void);
	virtual float predraw(void);
	virtual void SpawnKey(string, string);
	virtual bool CanSpawn(bool);

private:
	int m_iCount;
	int m_iPart;
	float m_flNexTime;

	float m_flSizeMin;
	float m_flSizeMax;
	float m_flAlpha;
	vector m_vecColor1;
	vector m_vecColor2;
	float m_flLifetimeMin;
	float m_flLifetimeMax;
	string m_strMaterial;
	float m_flMaxDrawDistance;
};

#if 1
class func_smokevolume_cloud
{
public:
	void func_smokevolume_cloud(void);
	
	virtual float predraw(void);

private:
	vector cloudsize;
	float lifetime;

	/* attributes */
	float m_flMaxAlpha;
	vector m_vecColor;
	float m_flLifeTime;
	string m_strMaterial;
};

float
func_smokevolume_cloud::predraw(void)
{
	float alpha;
	makevectors(view_angles);

	if (lifetime < (m_flLifeTime / 2)) {
		alpha = bound(0.0, lifetime / (m_flLifeTime / 2), 1.0);
	} else {
		alpha = 1.0 - bound(0.0, ((lifetime-(m_flLifeTime / 2)) / (m_flLifeTime / 2)), 1.0);
	}

	alpha *= m_flMaxAlpha;

	if (!(spawnflags & 1)) {
		m_vecColor *= (getlight(origin) / 255);
	}

	R_BeginPolygon(m_strMaterial, 0, 0);
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
func_smokevolume_cloud::func_smokevolume_cloud(void)
{
	setsize(this, [0,0,0], [0,0,0]);
	drawmask = MASK_ENGINE;
	lifetime = 0.0f;
}
#endif

float
func_smokevolume::predraw(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	if (checkpvs(vecPlayer, this) == FALSE)
		return (PREDRAW_NEXT);

	if (m_flMaxDrawDistance > 0.0)
		if (vlen(vecPlayer - origin) > m_flMaxDrawDistance)
			return (PREDRAW_NEXT);

	if (m_flNexTime > cltime)
		return (PREDRAW_NEXT);

	for (int i = 0; i < m_iCount; i++) {
		vector vecPos;
		vecPos[0] = mins[0] + (random() * (maxs[0] - mins[0]));
		vecPos[1] = mins[1] + (random() * (maxs[1] - mins[1]));
		vecPos[2] = mins[2] + (random() * (maxs[2] - mins[2]));

		func_smokevolume_cloud cloud = spawn(func_smokevolume_cloud);
		setorigin(cloud, vecPos);
		float r = random();
		cloud.m_vecColor[0] = Math_Lerp(m_vecColor1[0], m_vecColor2[0], r);
		cloud.m_vecColor[1] = Math_Lerp(m_vecColor1[1], m_vecColor2[1], r);
		cloud.m_vecColor[2] = Math_Lerp(m_vecColor1[2], m_vecColor2[2], r);
		cloud.m_flMaxAlpha = m_flAlpha;
		cloud.cloudsize[0] = random(m_flSizeMin, m_flSizeMax);
		cloud.cloudsize[1] = random(m_flSizeMin, m_flSizeMax);
		cloud.m_flLifeTime = random(m_flLifetimeMin, m_flLifetimeMax);
		cloud.spawnflags = spawnflags;
		cloud.m_strMaterial = m_strMaterial;
	}

	m_flNexTime = cltime + 1.0f;

	addentity(self);
	return (PREDRAW_NEXT);
}

void
func_smokevolume::Spawned(void)
{
	super::Spawned();

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;

	if (m_iCount == -1)
		m_iCount = (int)(vlen(size) / 100);
	/*m_strParticle = strcat("dustcloud_", ftos(entnum));
	localcmd(sprintf(g_dustcloud_cfg, m_strParticle));*/
}

bool
func_smokevolume::CanSpawn(bool clientSide)
{
	return true;
}

void
func_smokevolume::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "ParticleDrawWidth":
		m_flSizeMin = stof(strKey);
		m_flSizeMax = stof(strKey);
		break;
	case "Color1":
		m_vecColor1 = stov(strKey) / 255;
		break;
	case "Color2":
		m_vecColor2 = stov(strKey) / 255;
		break;
	case "material":
		m_strMaterial = strKey;
		break;
	case "MaxDrawDistance":
		m_flMaxDrawDistance = stof(strKey);
		break;
	default:
		super::SpawnKey(strField, strKey);
	}
}

void
func_smokevolume::func_smokevolume(void)
{
	m_strMaterial = "textures/sfx/smokevolume";
	m_iCount = -1;
	m_flSizeMin = 200;
	m_flSizeMax = 250;
	m_flLifetimeMin = 3;
	m_flLifetimeMax = 5;
	m_flAlpha = 1.0f;
	m_vecColor1 = m_vecColor2 = [0,0,0];

	solid = SOLID_NOT;
	isCSQC = true;
}
