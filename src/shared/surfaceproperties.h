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

/*
	Surface Data Specs

	Scripts are formatted like our sound shaders:

	typename
	{
		key/value pairs
		...
	}

	Available keys are:
	"base"			<string>	what type to inherit
	"gamematerial"		<char>		material character, e.g. W for wood
									which are looked up in scripts/decals.txt at a later time.
	"climbable"		<bool>		???
	"thickness"		<float>		non-solid, air (?) thickness
	"density"		<int>		material density in kg / m^3

	"elasticity"		<float>		0.0 - 1.0 ; soft to hard
	"friction"		<float>		friction multiplier
	"dampening"		<float>		drag multiplier
	"jumpfactor"		<float>		bouncyness?
	"maxspeedfactor"	<float>		maxvelocity?

	"stepleft"		<string>	footstep left
	"stepright"		<string>	footstep right
	"bulletimpact"		<string>	sound shader to play on impact
	"scraperough"		<string>	sound shader to play on rough scraping
	"scrapesmooth"		<string>	sound shader to play on smooth scraping
	"impacthard"		<string>	sound shader for hard impacts
	"impactsoft"		<string>	sound shader for soft impacts

	"shake"			<string>	sound to play when object is being shaken
	"strain"		<string>	sound to play when object is being strained?
	"break"			<string>	sound to play when object breaks
	"roll/rolling"		<string>	sound to play when object rolls

	none of these are concerning us right now:
	"audioreflectivity"	<float>
	"audiohardnessfactor"	<float>
	"audioroughnessfactor"	<float>
	"scrapeRoughThreshold"	<float>
	"impactHardThreshold"	<float>
	"audioHardMinVelocity"	<float>
*/

typedef struct
{
	string m_strBase;
	float m_flMaterial;
	float m_flThickness;
	float m_flDensity;
	float m_flElasticity;
	float m_flFriction;
	float m_flDampening;
	float m_flJumpFactor;
	float m_flMaxSpeedFactor;

	string m_sndStepLeft;
	string m_sndStepRight;
	string m_sndBulletImpact;
	string m_sndScrapeRough;
	string m_sndScrapeSoft;
	string m_sndImpactHard;
	string m_sndImpactSoft;
	string m_sndShake;
	string m_sndStrain;
	string m_sndRoll;
	string m_sndBreak;

	string m_fxBulletImpact;
	float m_fxBulletImpactID;
} surfaceData_t;

/* entity will have to have a .surfdata field pointing to an id */
surfaceData_t *g_surfdata;
int g_surfdata_count;
var hashtable g_hashsurfdata;

/* querying API */
typedef enum
{
	SURFDATA_MATERIAL,
	SURFDATA_THICKNESS,
	SURFDATA_DENSITY,
	SURFDATA_ELASTICITY,
	SURFDATA_FRICTION,
	SURFDATA_DAMPENING,
	SURFDATA_JUMPFACTOR,
	SURFDATA_MAXSPEEDFACTOR,
	SURFDATA_SND_STEPLEFT,
	SURFDATA_SND_STEPRIGHT,
	SURFDATA_SND_BULLETIMPACT,
	SURFDATA_SND_SCRAPEROUGH,
	SURFDATA_SND_SCRAPESOFT,
	SURFDATA_SND_IMPACTHARD,
	SURFDATA_SND_IMPACTSOFT,
	SURFDATA_SND_SHAKE,
	SURFDATA_SND_STRAIN,
	SURFDATA_SND_ROLL,
	SURFDATA_SND_BREAK,
	SURFDATA_FX_BULLETIMPACT,
	SURFDATA_FX_BULLETIMPACTID
} surfinfo_t;

/* initialized SurfaceKit */
void SurfData_Init(void);

/* Prepares an object for SurfaceKit initialization */
void SurfData_SetStage(string type);

/* Finishes initialization, returns valid SurfaceKit id */
int SurfData_Finish(void);

int SurfData_TexToSurfData(string tex_name);

/* Call an impact effect against an entity surface */
void SurfData_Impact(entity e, vector org, vector ang);

/* Get information from a Surface */
__variant SurfData_GetInfo(int, int);

#ifdef CLIENT
void SurfData_Impact_Parse(void);
void SurfData_ImpactID_Parse(void);
#endif

void SurfData_ImpactOfType(int materialID, vector worldPosition, vector impactNormal);

void SurfData_ImpactOfNamedType(string materialName, vector worldPosition, vector impactNormal);