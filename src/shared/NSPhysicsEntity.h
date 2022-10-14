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

/** This entity class represents physically-simulated entities. */
class NSPhysicsEntity:NSSurfacePropEntity
{
private:
	int m_iEnabled;
	int m_iShape;
	int m_iMaterial;
	int m_iFlags;
	float m_flInertiaScale;

	virtual void _TouchThink(void);

#ifdef SERVER
	PREDICTED_VECTOR(m_vecNetAngles);
#endif

public:
	void NSPhysicsEntity(void);

	/* overrides */
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
#ifdef SERVER
	virtual void Pain(void);
	virtual void Death(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Save(float);
	virtual void Restore(string,string);
#else
	virtual void ReceiveEntity(float,float);
#endif

	/** Sets the mass of the entity in ??? */
	nonvirtual void SetMass(float);
	/** Returns the mass of the entity. */
	nonvirtual float GetMass(void);
	/** Sets the friction multiplier for this entity. Default is 1.0 */
	nonvirtual void SetFriction(float);
	/** Returns the friction multiplayer for this entity. */
	nonvirtual float GetFriction(void);
	/** Sets the bounce factor for this entity. Default is 1.0 */
	nonvirtual void SetBounceFactor(float);
	/** Returns the bounce factor of this entity. */
	nonvirtual float GetBounceFactor(void);
	/** Sets the bounce stop factor for this entity. */
	nonvirtual void SetBounceStop(float);
	/** Returns the bounce stop factor of this entity. */
	nonvirtual float GetBounceStop(void);
	/** Sets the inertia modifier for this entity. */
	nonvirtual void SetInertia(float);
	/** Returns the inertia modifier of this entity. */
	nonvirtual float GetInertia(void);
	/** Call to enable physics simulation on this entity. */
	nonvirtual void PhysicsEnable(void);
	/** Call to freeze physics simulation on this entity. */
	nonvirtual void PhysicsDisable(void);
	/** Call to apply a force (absolute velocity vector) to the center of the entity. */
	nonvirtual void ApplyForceCenter(vector);
	/** Call to apply force (absolute velocity vector) to a specific position on the entity. */
	nonvirtual void ApplyForceOffset(vector,vector);
	/** Call to apply torque (angular velocity vector) to the center of the entity. */
	nonvirtual void ApplyTorqueCenter(vector);
	/** Called by the physics routine to figure out the impact damage. */
	nonvirtual float CalculateImpactDamage(int,int);
};

#ifdef CLIENT
void NSPhysicsEntity_ReadEntity(bool);
#endif