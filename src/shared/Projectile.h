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

# OVERVIEW

Objects such as rockets, grenades, bolts etc. should ideally be this class.
Weapons are the primary source of firing this projectile, but any actor and other
entity can launch these as well.

ncEntity can use its inputs `SpawnProjectileDef` and `SpawnProjectileOffset` anywhere
in the game to spawn a projectile. Refer to ncEntity its own documentation for details.


# KEYS
- "model" : Model of the projectile.
- "mins" : Mins of the projectile bounding box.
- "maxs" : Maxs of the projectile bounding box.
- "def_damage" : direct damage, upon touch 
- "def_splash_damage" : splash damage damage def 
- "velocity" : Start velocity. Main speed control when thrust isn't on. Relative to view (forward, right, up).
- "health" : amount of dmg the projectile can take 
- "angular_velocity" : Specifies the angular velocity. Pitch/yaw/roll per second.
- "thrust" : Rate of acceeleration.
- "thrust_start" : When to begin accel, in seconds.
- "thrust_end" : When to stop accel, in seconds.
- "linear_friction" : Air friction.
- "bounce" : Bounce to speed multiplier.
- "gravity" : 0 means no gravity.
- "fuse" : Fuse time in seconds.
- "detonate_on_fuse" : When 1, will detonate when fuse runs out. 
- "detonate_on_death" : When 1, makes it it detonate when it gets damaged enough.
- "detonate_on_world" : When 1, detonates when touching world.
- "detonate_on_actor" : When 1 touching a monster/player will detonate it. 
- "decal_detonate" : Name of the decal group to place.
- "smoke_fly" : Particle effect to use when flying.
- "fx_path" : Particle trail to use when flying.
- "model_detonate" : Particle effect to play when the projectile explodes.
- "smoke_bounce" : Smoke effect to play when bouncing around.
- "smoke_fuse" : Particle effect to play when the fuse timer runs out.
- "projectile_debris" : Another projectile to spawn when this one detonates.
- "debris_count" : Number of projectiles to spawn upon detonation.
- "debris_stick" : When 1, projectiles will stick to walls.
- "debris_offset" : Offset at which debris is spawned from the impact position, aiming away from the impact normal. In units, forward/right/up vector.
- "detonate_offset" : Offset at which the particles and lights occur during explosion.
- "damage_offset" : The offset at which explosion damage will be calculated from. In units, forward/right/up vector.
- "light_color" : Flying dynamic light color.
- "light_radius" : Flying dynamic light radius.
- "light_offset" : Flying dynamic light offset.
- "explode_light_color" : Explosion dynamic light color.
- "explode_light_radius" : Explosion dynamic light radius.
- "explode_light_fadetime" : Explosion dynamic light fade time.
- "snd_fly" : Sound to play when flying.
- "snd_explode" : Sound to play when exploding.
- "snd_bounce" : Sound to play when bouncing around, not exploding.
- "decal_impact" : Decal group to spawn upon impact.
- "stick_to_world" : When 1, will stick to world.
- "stick_to_actor" : When 1, will stick to actors.
- "thrust_homing" : When 1, will change the thrust to act as a homing missile.
- "frame" : Animation sequence to use when flying.
- "inherit_velocity" : When 1, will inherit the velocity from the owner.
- "offset" : Offset position from the owner. In units from face. Vector axis are [forward] [right] [up].
- "damage" : Damage upon direct impact, respected when "def_damage" is not set.
- "thrown" : Will not fly like a rocket, but be thrown like a grenade. Hold-time will be passed as a fuse.
- "reflects" : When 1, will reflect off surfaces.
- "trackEnemy" : When 1, will track the nearest enemy.
- "trackJitter" : Will jitter movement when tracking by this many units per second.
- "trackDelay" : Delay between tracking position updates.
- "def_planeImpact" : When set, will spawn an entity at the position of impact aligned towards the impact surface's normal.
- "noFX" : Disable impact effects.

# UNUSED
- "mass" : Reserved.
- "impact_damage_effect" : Reserved. May affect blood splats? 
- "impact_gib" : impact gibs? Reserved.
- "decal_size" : Reserved.
- "smoke_detonate" : Reserved.

# HITSCAN KEYS
- "is_bullet": When 1, will act as a traceline/hitscan bullet instead of a projectile.
- "hitscans": Number of hitscans cast when "is_bullet" is 1.
- "spread": Spread of the projectile flying direction (e.g. "0.1 0.1")
- "range": Hitscan maximum range.

# SPRITE KEYS
- "animStartFrame" : Animation start frame.
- "animEndFrame" : Animation end frame.
- "animFrameRate" : Animation frame rate.
- "animEndRemoves" : Removes projectile once animation finishes when "1".

# EXAMPLES

A projectile for a shotgun may look like this:

```
entityDef projectile_shotgun
{
	"spawnclass"			"ncProjectile"
	"is_bullet"				"1"
	"detonate_on_world" 	"1"
	"damage"				"10"
	"hitscans"				"6"
	"spread"				"0.1 0.1"
}
```

Here's one for a rocket, fired from a rocket launcher. The `//` comments indicate where you'd have to define the extra effects:

```
entityDef damage_rocketDirect
{
	"damage"		"80"
	"damage_random"	"25" // adds up to 25 units of damage on top
}

entityDef damage_rocketSplash
{
	"damage"	"200"
	"radius"	"250"
	"push"		"10000"
}

entityDef projectile_rocket
{
	"spawnclass"				"ncProjectile"
	"model"						"models/rocket.vvm"

	"def_damage"				"damage_rocketDirect"
	"def_splash_damage"			"damage_rocketSplash"

	"velocity"					"250"
	"angular_velocity"			"0 0 200"
	"fuse"						"10"
	"detonate_on_fuse"			"0"
	"detonate_on_death"			"1"
	"detonate_on_world"			"1"
	"detonate_on_actor"			"1"
	"impact_damage_effect"		"1"
	"impact_gib"				"1"

	"thrust"					"2000"
	"thrust_start"				"0.1"
	"thrust_end"				"2"

	"smoke_fly"					"weapon_rocketlauncher.smoke_trail" // define `smoke_trail` in particles/weapon_rocketlauncher.cfg
	"model_detonate"			"weapon_rocketlauncher.explosion" // define `explosion` in particles/weapon_rocketlauncher.cfg
	"decal_detonate"			"ExplosionDecal" // define `ExplosionDecal` in scripts/decals.txt
	"light_color"				"1 1 1"
	"light_radius"				"160"
	"light_offset"				"0 0 0"
	"detonate_offset"			"24"

	"explode_light_color"		"2 1.6 0.8"
	"explode_light_radius"		"320"
	"explode_light_fadetime"	"0.5"

	"snd_explode"				"Weapon_RocketLauncher.Explosion" // define it in decls/sound/weapons.sndshd
	"offset"					"0 7 -3"
}
```

@ingroup baseclass
*/
class ncProjectile:ncAttack
{
public:
	void ncProjectile(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
	virtual float predraw(void);
	virtual void postdraw(void);
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
	virtual void Pain(entity, entity, int, vector, vector, int);
	virtual void Death(entity, entity, int, vector, vector, int);

	virtual void SpawnKey(string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string, string);

	virtual void Trigger(entity, triggermode_t);

	nonvirtual void _FuseEnded(void);
	nonvirtual void _Explode(entity);
	virtual void HasExploded(void);

	virtual void _LaunchHitscan(vector, vector, float);

	/* launch the projectile into the world */
	virtual void Launch(vector, vector, float, float, float);

	nonvirtual void SetLightColor(vector);
	nonvirtual void SetLightRadius(float);

	nonvirtual void SetWeaponOwner(ncWeapon);
	nonvirtual ncWeapon GetWeaponOwner(void);

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
	/* I/O system */
	string m_outputOnDetonate;

	/* sprite animation gubbins */
	int m_iProjectileAnimEnd;
	int m_iProjectileAnimStart;
	float m_flProjectileFramerate;

	/* temp */
	float m_flDmgMultiplier;
	float m_trackDelayTime;

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
	string m_partFXPath;
	string m_partModelDetonate;
	string m_partSmokeDetonate;
	string m_partSmokeBounce; 
	string m_partSmokeFuse;
	string m_defProjectileDebris;
	int m_iDebrisCount;
	bool m_bDebrisStick;
	vector m_vecDebrisOffset;
	vector m_vecDetonateOffset;
	vector m_vecDamageOffset;
	vector m_vecImpactPos;
	bool m_bThrown;

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
	ncWeapon m_weaponOwner;

	/* ETQW-additions */
	bool m_bIsBullet;
	ncSurfacePropEntity m_eMultiTarget;
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
	bool m_bReflect;
	bool m_bTrackEnemy;
	vector m_trackJitter;
	float m_trackDelay;
	string m_defPlaneImpact;

	ncTimer m_thrustHandler;
	vector m_hitLocation;
	bool m_noFX;
	vector m_lastPlaneNormal;

	nonvirtual void _AnimateThink(void);
	nonvirtual void _ThrustThink(void);
	nonvirtual void _AnimateThinkDead(void);

	virtual void _ApplyDamage(void);
	virtual void _FireSingle(vector,vector,float,float);

	virtual void OnRemoveEntity(void);
#endif
};

#ifdef SERVER
ncProjectile ncProjectile_SpawnDef(string entityDef, ncActor theOwner);
ncProjectile ncProjectile_SpawnDefAtPosition(string entityDef, ncActor theOwner, vector vecOrigin, vector vecAngles);
ncProjectile ncProjectile_SpawnDefAttachment(string entityDef, ncActor theOwner, int attachmentID);
#endif
