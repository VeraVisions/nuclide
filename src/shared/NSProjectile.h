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
Objects such as rockets, grenades, bolts etc. should ideally be this.

@ingroup baseclass
*/
class NSProjectile:NSSurfacePropEntity
{
public:
	void NSProjectile(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
	virtual float predraw(void);
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
	virtual void Pain(entity, entity, int, vector, int);
	virtual void Death(entity, entity, int, vector, int);

	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string, string);

	virtual void Trigger(entity, triggermode_t);

	nonvirtual void _FuseEnded(void);
	nonvirtual void _Explode(entity);

	virtual void _LaunchHitscan(vector, vector, float);

	/* launch the projectile into the world */
	virtual void Launch(vector, vector, float, float, float);

	nonvirtual void SetLightColor(vector);
	nonvirtual void SetLightRadius(float);

	nonvirtual void EnableDetonateOnFuse(bool);
	nonvirtual void EnableDetonateOnDeath(bool);
	nonvirtual void EnableDetonateOnWorld(bool);
	nonvirtual void EnableDetonateOnActor(bool);
	nonvirtual void EnableStickToWorld(bool);
	nonvirtual void EnableStickToActor(bool);
	nonvirtual void EnableThrustHoming(bool);
	nonvirtual void EnableInheritVelocity(bool);
#endif

private:
	NETWORKED_FLOAT_N(traileffectnum)
	NETWORKED_VECTOR(m_vecLightColor)
	NETWORKED_FLOAT(m_flLightRadius)

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
	float m_flThrust;
	float m_flThrustStart;
	float m_flThrustEnd;
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
	bool m_bImpactSurfData; /* TODO */
	string m_matDetonate;
	float m_flDecalSize;
	string m_partSmokeFly;
	string m_partModelDetonate;
	string m_partSmokeDetonate;
	string m_partSmokeBounce; 
	string m_partSmokeFuse;
	string m_defProjectileDebris;
	int m_iDebrisCount;
	bool m_bDebrisStick;
	vector m_vecDebrisOffset;
	vector m_vecImpactPos;

	float m_flLightOffset; /* TODO */
	vector m_vecExplodeLightColor; /* TODO */
	float m_fExplodelLightRadius; /* TODO */
	float m_fExplodelLightFadetime; /* TODO */
	string m_sndFly;
	string m_sndExplode;
	string m_sndBounce;
	vector m_vecSpawnMins;
	vector m_vecSpawnMaxs;
	float m_flSpawnFrame;
	vector m_vecSpawnOrigin;

	/* ETQW-additions */
	bool m_bIsBullet;
	NSSurfacePropEntity m_eMultiTarget;
	int m_iMultiValue;
	int m_iMultiBody;
	int m_iShots;
	vector m_vecSpread;
	float m_flDamage;
	string m_strDecalGroup;
	float m_flRange;

	/* Nuclide additions */
	bool m_bStickToWorld;
	bool m_bStickToActor;
	bool m_bThrustHoming;
	bool m_bInheritVelocity;

	NSTimer m_thrustHandler;

	nonvirtual void _AnimateThink(void);
	nonvirtual void _ThrustThink(void);
	nonvirtual void _AnimateThinkDead(void);

	virtual void _ApplyDamage(void);
	virtual void _FireSingle(vector,vector,float,float);

	virtual void OnRemoveEntity(void);
#endif
};

#ifdef SERVER
NSProjectile NSProjectile_SpawnDef(string entityDef, NSEntity theOwner);
NSProjectile NSProjectile_SpawnDefAtPosition(string entityDef, NSEntity theOwner, vector vecOrigin, vector vecAngles);
NSProjectile NSProjectile_SpawnDefAttachment(string entityDef, NSEntity theOwner, int attachmentID);
#endif
