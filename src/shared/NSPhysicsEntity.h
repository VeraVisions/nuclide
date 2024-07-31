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

var bool autocvar_phys_developer = false;
void
_NSPhysics_Log(string msg)
{
	if (autocvar_phys_developer == true)
		print(sprintf("%f %s\n", time, msg));
}
#define NSPhysics_Log(...) _NSPhysics_Log(sprintf(__VA_ARGS__))


var float autocvar_phys_pushscale = 1.0f;
var float autocvar_phys_impactforcescale = 100.0f;

#ifdef CLIENT
var bool autocvar_r_showPhysicsInfo = false;
#endif

.float damp_linear;
.float damp_angular;
.float jointgroup;

enum
{
	PHYSM_BOX,
	PHYSM_SPHERE,
	PHYSM_CAPSULE,
	PHYSM_TRIMESH,
	PHYSM_CYLINDER
};

enumflags
{
	BPHY_NODMGPUSH,
	BPHY_SHARP
};


typedef enumflags
{
	PHYENT_CHANGED_ORIGIN_X,
	PHYENT_CHANGED_ORIGIN_Y,
	PHYENT_CHANGED_ORIGIN_Z,
	PHYENT_CHANGED_ANGLES_X,
	PHYENT_CHANGED_ANGLES_Y,
	PHYENT_CHANGED_ANGLES_Z,
	PHYENT_CHANGED_MODELINDEX,
	PHYENT_CHANGED_SIZE,
	PHYENT_CHANGED_FLAGS,
	PHYENT_CHANGED_SOLID,
	PHYENT_CHANGED_FRAME,
	PHYENT_CHANGED_SKIN,
	PHYENT_CHANGED_MOVETYPE,
	PHYENT_CHANGED_EFFECTS,
	PHYENT_CHANGED_BODY,
	PHYENT_CHANGED_SCALE,
	PHYENT_CHANGED_VELOCITY,
	PHYENT_CHANGED_RENDERCOLOR,
	PHYENT_CHANGED_RENDERAMT,
	PHYENT_CHANGED_RENDERMODE,
} nsphyricsentity_changed_t;

/** This entity class represents physically-simulated entities. 

The physics simulator used is controlled by the engine and may be
subject to change.

Units of mass is defined in kilograms, a standard unit of measurement.
You will find the API to be mostly compatible of that offered by Garry's Mod.

@ingroup baseclass
*/
class NSPhysicsEntity:NSSurfacePropEntity
{
public:
	void NSPhysicsEntity(void);

	/* overrides */
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
#ifdef SERVER
	virtual void Spawned(void);
	virtual void Pain(entity, entity, int, vector, int);
	virtual void Death(entity, entity, int, vector, int);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Touch(entity);
#endif
#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual void postdraw(void);
#endif

	nonvirtual void _UpdateBuoyancy(void);
	nonvirtual void _UpdateMass(void);

	/** Sets the friction multiplier for this entity. Default is 1.0 */
	nonvirtual void SetFriction(float);
	/** Returns the friction multiplayer for this entity. */
	nonvirtual float GetFriction(void);

	/** Called by the physics routine to figure out the impact damage. */
	nonvirtual float CalculateImpactDamage(int,int);

	/* this merely mirrors the GMod API: https://wiki.facepunch.com/gmod/PhysObj */

	/** Call to align angles of the object to the ones passed. */
	nonvirtual vector AlignAngles(vector, vector);
	/** Call to apply a force (absolute velocity vector) to the center of the entity. */
	nonvirtual void ApplyForceCenter(vector);
	/** Call to apply force (absolute velocity vector) to an absolute position on the entity. */
	nonvirtual void ApplyForceOffset(vector,vector);
	/** Call to apply torque (angular velocity vector) to the center of the entity. */
	nonvirtual void ApplyTorqueCenter(vector);
	/** Call to set whether the entity should be affected by drag. */
	nonvirtual void EnableDrag(bool);
	/** Call to set whether the entity should be affected by gravity. */
	nonvirtual void EnableGravity(bool);
	/** Call to set whether the entity should be able to move. */
	nonvirtual void EnableMotion(bool);
	/** Returns the linear damping of the entity. */
	nonvirtual float GetLinearDamping(void);
	/** Returns the angular damping of the entity. */
	nonvirtual float GetAngularDamping(void);
	/** Returns the linear and rotational kinetic energy combined. */
	nonvirtual float GetEnergy(void);
	/** Returns the inertia modifier of this entity. */
	nonvirtual float GetInertia(void);
	/** Returns 1 divided by the angular inertia of this entity. */
	nonvirtual float GetInvInertia(void);
	/** Returns 1 divided by the mass of this entity. */
	nonvirtual float GetInvMass(void);
	/** Returns the mass of the entity. */
	nonvirtual float GetMass(void);
	/** Returns the center of mass of the entity. */
	nonvirtual vector GetMassCenter(void);
	/** Returns the rotational damping of the entity. */
	nonvirtual float GetRotDamping(void);
	/** Returns the speed damping of the entity. */
	nonvirtual float GetSpeedDamping(void);
	/** Returns the surface area of the entity. */
	nonvirtual float GetSurfaceArea(void);
	/** Returns the volume of the entity. */
	nonvirtual float GetVolume(void);
	/** Returns whether the entity is at rest and not moving. */
	nonvirtual bool IsAsleep(void);
	/** Returns whether the entity is able to collide with anything. */
	nonvirtual bool IsCollisionEnabled(void);
	/** Returns whether the entity is affected by drag. */
	nonvirtual bool IsDragEnabled(void);
	/** Returns whether the entity is affected by gravity. */
	nonvirtual bool IsGravityEnabled(void);
	/** Returns whether the entity is able to move by itself. */
	nonvirtual bool IsMotionEnabled(void);
	/** Returns whether the entity is able to move. */
	nonvirtual bool IsMoveable(void);
	/** Returns whether the entity is penetrating another object. */
	nonvirtual bool IsPenetrating(void);

	/** Call to set the amount of rotational drag the entity experiences. */
	nonvirtual void SetAngleDragCoefficient(float);
	/** Call to set the buoyancy ratio of the entity. 0 is not buoyant, 1 is very buoyant. */
	nonvirtual void SetBuoyancyRatio(float);
	/** Call to set the linear and angular damping of the entity. */
	nonvirtual void SetDamping(float, float);
	/** Call to set how much drag affects the entity. */
	nonvirtual void SetDragCoefficient(float);

	/** Sets the angular inertia for this entity. */
	nonvirtual void SetInertia(float);
	/** Sets the mass of the entity in kilograms. */
	nonvirtual void SetMass(float);

	/** Call to enable physics simulation on this entity. */
	nonvirtual void Wake(void);
	/** Call to freeze physics simulation on this entity. */
	nonvirtual void Sleep(void);

private:
	int m_iEnabled;
	int m_iShape;
	int m_iMaterial;
	int m_iFlags;
	float m_flInertiaScale;
	float m_flBuoyancyRatio;
	bool m_bInvincible;
	float m_flVolume;

	/* performance sanity checks */
	vector m_vecPrevOrigin;
	vector m_vecPrevAngles;
	float m_flCheckTime;
	PREDICTED_FLOAT(m_flMass)

	virtual void _TouchThink(void);

#ifdef SERVER
	PREDICTED_VECTOR(m_vecNetAngles)

	string m_strOnDamaged;
#endif
};

noref .bool isPhysics;