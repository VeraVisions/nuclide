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

typedef enumflags
{
	PROJ_CHANGED_ORIGIN_X,
	PROJ_CHANGED_ORIGIN_Y,
	PROJ_CHANGED_ORIGIN_Z,
	PROJ_CHANGED_ANGLES_X,
	PROJ_CHANGED_ANGLES_Y,
	PROJ_CHANGED_ANGLES_Z,
	PROJ_CHANGED_MODELINDEX,
	PROJ_CHANGED_SIZE,
	PROJ_CHANGED_FRAME,
	PROJ_CHANGED_SKIN,
	PROJ_CHANGED_EFFECTS,
	PROJ_CHANGED_BODY,
	PROJ_CHANGED_SCALE,
	PROJ_CHANGED_VELOCITY,
	PROJ_CHANGED_ANGULARVELOCITY,
	PROJ_CHANGED_RENDERCOLOR,
	PROJ_CHANGED_RENDERAMT,
	PROJ_CHANGED_RENDERMODE,
} nsprojectile_changed_t;

.void(entity, entity) m_pImpact;
.float traileffectnum;

/** This entity class represents an interactive projectile.
Objects such as rockets, grenades, bolts etc. should ideally be this. */
class NSProjectile:NSSurfacePropEntity
{
private:
	PREDICTED_FLOAT_N(traileffectnum)

#ifdef SERVER
	/* sprite animation gubbins */
	int m_iProjectileAnimEnd;
	int m_iProjectileAnimStart;
	float m_flProjectileFramerate;

	/* temp */
	float m_flDmgMultiplier;

	/* defAPI */
	string m_defDamage;
	string m_defSplashDamage;
	vector m_vecLaunchVelocity;
	float m_flThrust; /* TODO */
	float m_flThrustStart;  /* TODO */
	float m_flThrustEnd; /* TODO */
	float m_flFrictionLinear; /* TODO */
	float m_flBounce;
	float m_flMass; /* TODO */
	float m_flGravity; /* TODO */
	float m_flFuse;
	bool m_bDetonateOnFuse;
	bool m_bDetonateOnDeath;
	bool m_bDetonateOnWorld;
	bool m_bDetonateOnActor;
	bool m_bImpactEffect; /* TODO */
	bool m_bImpactGib; /* TODO */
	string m_matDetonate; /* TODO */
	float m_flDecalSize; /* TODO */
	string m_partSmokeFly;
	string m_partModelDetonate;
	string m_partSmokeDetonate;
	string m_partSmokeBounce; 
	string m_partSmokeFuse;
	int m_iDebrisCount; /* TODO */
	vector m_vecLightColor; /* TODO */
	float m_flLightRadius; /* TODO */
	float m_flLightOffset; /* TODO */
	vector m_vecExplodeLightColor; /* TODO */
	float m_fExplodelLightRadius; /* TODO */
	float m_fExplodelLightFadetime; /* TODO */
	string m_sndFly;
	string m_sndExplode;
	string m_sndBounce;

	/* ETQW-additions */
	bool m_bIsBullet;

	nonvirtual void _AnimateThink(void);
	nonvirtual void _AnimateThinkDead(void);
#endif

public:
	void NSProjectile(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
#endif

#ifdef SERVER
	/** Sets the function that'll be called upon impact of the projectile onto a surface. */
	nonvirtual void SetImpact(void(entity, entity));
	/** When called, will animated between two frame positions at a specified framerate on loop. */
	nonvirtual void Animate(int, int, float);
	/** When called, will animated between two frame positions at a specified framerate and remove itself when it has finished playing the sequence. */
	nonvirtual void AnimateOnce(int, int, float);

	/** Called upon the projectile touching another object. */
	virtual void Touch(entity);
	virtual void Spawned(void);
	virtual void Death(void);
	virtual void Pain(void);

	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);

	nonvirtual void _FuseEnded(void);
	nonvirtual void _Explode(void);

	nonvirtual void _LaunchHitscan(vector, vector, float);

	/* launch the projectile into the world */
	nonvirtual void Launch(vector, vector, float, float, float);
#endif
};


#ifdef CLIENT
void NSProjectile_ReadEntity(bool);
#endif