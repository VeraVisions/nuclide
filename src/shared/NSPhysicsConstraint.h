/*
 * Copyright (c) 2023 Vera Visions LLC.
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
typedef enum
{
	CONSTRAINT_FIXED = -1,	/**< Fixed constraint, aka weld, aka phys_constraint. */
	CONSTRAINT_INVALID,		/**< Nothing. Default. */
	CONSTRAINT_POINT,		/**< Point constraint, aka ballsocket or ball constraint, like phys_ballsocket. */
	CONSTRAINT_HINGE,		/**< Hinge joint constraint. Like phys_hinge */
	CONSTRAINT_SLIDER,		/**< Slider setup. Like phys_slideconstraint. */
	CONSTRAINT_UNIVERSAL,	/**< Universal? TBA. */
	CONSTRAINT_HINGE2		/**< Hinge 2. TBA. */
} constraint_t;

/** This entity class represents constraints for physically-simulated entities. 

If you want to create an easy 'weld' type connection, a ballsocket or even a rope
type connection - this class is what you need.

@ingroup baseclass
*/
class
NSPhysicsConstraint:NSEntity
{
public:
	void NSPhysicsConstraint(void);

	virtual void SpawnKey(string, string);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity, string, string);
#endif

	virtual void Spawned(void);
	virtual void OnRemoveEntity(void);

	/** Awakes the entities this constraint is connected to. */
	nonvirtual void WakeTargets(void);

	/** Breaks the constraint. */
	nonvirtual void Break(entity);

	/** Returns the type of this constraint entity. */
	nonvirtual constraint_t GetConstraintType(void);
	/** Returns the first entity connection. Should not return world/__NULL__ */
	nonvirtual entity GetEntity1(void);
	/** Returns the second entity connection. Can also return world/__NULL__ */
	nonvirtual entity GetEntity2(void);

	/** Will override the constraint type this entity represents. See constraint_t for choices. */
	nonvirtual void SetConstraintType(constraint_t);
	/** Sets the first entity in the connection. Needs to be set. */
	nonvirtual void SetEntity1(entity);
	/** Sets the second entity in the connection. Can be world. */
	nonvirtual void SetEntity2(entity);
	//nonvirtual void SetBone1(float);
	//nonvirtual void SetBone2(float);

	/** Sets the velocity on a CONSTRAINT_SLIDER type NSPhysicsConstraint. */
	nonvirtual void SetSliderVelocity(float);
	/** Sets the max velocity on a CONSTRAINT_SLIDER type NSPhysicsConstraint. */
	nonvirtual void SetSliderMaxVelocity(float);
	/** Sets the maximum travel distance of the slider. */
	nonvirtual void SetSliderStop(float);
	/** Sets the friction of the slider. */
	nonvirtual void SetSliderFriction(float);

	/** Returns the velocity of a CONSTRAINT_SLIDER type NSPhysicsConstraint. */
	nonvirtual float GetSliderVelocity(void);
	/** Returns the max velocity of a CONSTRAINT_SLIDER type NSPhysicsConstraint. */
	nonvirtual float GetSliderMaxVelocity(void);
	/** Returns the maximum travel distance of the slider. */
	nonvirtual float GetSliderStop(void);
	/** Returns the friction of the slider. */
	nonvirtual float GetSliderFriction(void);
	/** Returns the unique joint group ID associated with a phys_constraintsystem. */
	nonvirtual float GetConstraintSystemID(void);

	/** Creates a ballsocket constraint and returns it. */
	nonvirtual NSPhysicsConstraint Ballsocket(entity, entity, vector, vector, float, bool);
	/** Creates a ballsocket constraint and returns it. */
	nonvirtual NSPhysicsConstraint Weld(entity, entity, float, float, float, bool, bool);
	/** Creates a ballsocket constraint and returns it. */
	nonvirtual NSPhysicsConstraint Rope(entity, entity, vector, vector);

	nonvirtual NSPhysicsConstraint KeepUpright(entity, vector, float);

	nonvirtual void ConstraintThink(void);

private:

	float m_flTorqueLimit;
	float m_flForceLimit;
	string m_strEnt1;
	string m_strEnt2;
	string m_strBreakSound;
	string m_strOnBreak;
	string m_strConstraintSystem;
};