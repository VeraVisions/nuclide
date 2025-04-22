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

#ifdef CLIENT
noref .float health;
#endif

typedef enumflags
{
	SRFENT_CHANGED_ORIGIN_X,
	SRFENT_CHANGED_ORIGIN_Y,
	SRFENT_CHANGED_ORIGIN_Z,
	SRFENT_CHANGED_ANGLES_X,
	SRFENT_CHANGED_ANGLES_Y,
	SRFENT_CHANGED_ANGLES_Z,
	SRFENT_CHANGED_MODELINDEX,
	SRFENT_CHANGED_SIZE,
	SRFENT_CHANGED_FLAGS,
	SRFENT_CHANGED_SOLIDMOVETYPE,
	SRFENT_CHANGED_FRAME,
	SRFENT_CHANGED_SKIN,
	SRFENT_CHANGED_EFFECTS,
	SRFENT_CHANGED_BODY,
	SRFENT_CHANGED_SCALE,
	SRFENT_CHANGED_VELOCITY,
	SRFENT_CHANGED_ANGULARVELOCITY,
	SRFENT_CHANGED_RENDERCOLOR,
	SRFENT_CHANGED_RENDERAMT,
	SRFENT_CHANGED_RENDERMODE,
	SRFENT_CHANGED_CONTROLLER
} nssurfacepropentity_changed_t;



/** @defgroup damage Damage
@brief Combat interactions between entities.
@ingroup server

# KEYS
- "damage" : Damage points to apply.
- "damage_random" : Random damage points to add on top of the points provided in "damage".
- "noArmor" : Ignore armor entirely.
- "knockback" : Applies said linear velocity to the target.
- "push" : Applies said push force to only physics objects.
- "type" : Identifier for special damage types.
- "flags" : Integer field of flags, networked and game specific to the client.
- "hitbody" : Which body will have been hit. Usually set internally.

*/

/** This entity represents an ncRenderableEntity with interactive surface properties.
It can take damage and can handle variously different types of impact. 

@ingroup baseclass
*/
class ncSurfacePropEntity:ncRenderableEntity
{
public:
	void ncSurfacePropEntity(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void SetModel(string);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void RestoreComplete(void);
	virtual void Respawn(void);
	virtual void Input(entity,string,string);
	virtual void SpawnKey(string,string);
	virtual void ParentUpdate(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual float predraw(void);
	virtual void ReceiveEntity(float,float);
#endif

	/** Returns whether or not this entity is on fire. */
	nonvirtual bool IsOnFire(void);

	/* new */
#ifdef SERVER
	/** Applies damage to the entity. */
	virtual void Damage(entity, entity, ncDict, float, vector, vector);
	/** Called when a different entity gets damaged by this entity. */
	virtual void DamageFeedback(entity, entity, int);
	/** Called whenever the entity receives damage. */
	virtual void Pain(entity, entity, int, vector, vector, int);
	/** Called when the health is equal or below 0 */
	virtual void Death(entity, entity, int, vector, vector, int);
	/** Called when the health is equal or below 0 */
	virtual void BreakModel(int, vector, int);
	/** Returns whether or not the entity is alive. That is different from having health, as the entity may be a corpse that can be destroyed further.*/
	virtual bool IsAlive(void);

	/** Sets the entity on fire. */
	nonvirtual void Ignite(entity, float, string);
	/** If the entity is on fire, it'll have it extinguished */
	nonvirtual void Extinguish(void);

	/** Returns whether the entity can be damaged. */
	nonvirtual bool IsVulnerable(void);

	/* Generic Damage */
	/** Makes the entity visible to other entity their aim-assists. */
	nonvirtual void EnableAimAssist(void);
	/** Makes the entity invisible to other entity their aim-assists. */
	nonvirtual void DisableAimAssist(void);
	/** Makes the entity vulnerable if it wasn't already. */
	nonvirtual void MakeVulnerable(void);
	/** Makes the entity invulnerable if it wasn't already. */
	nonvirtual void MakeInvulnerable(void);
	/** Sets the current health of the entity. */
	nonvirtual void SetHealth(float);
	/** Sets the maximum amount of health the entity can have */
	nonvirtual void SetMaxHealth(float);
	/** Returns the current health of the entity. */
	nonvirtual float GetHealth(void);
	/** Returns the maximum health the entity can have. */
	nonvirtual float GetMaxHealth(void);
	/** Adds bonus health to the entity. That's the amount of health it's allowed to go over max_health. It'll decrease over time by itself and affect max_health in the meantime. Maximum is 100. */
	nonvirtual void AddBonusHealth(float);
	/** Returns the bonus health of the entity. That is the amount of health above max_health. */
	nonvirtual float GetBonusHealth(void);
	/** Adds bonus armor to the entity. That's the amount of armor it's allowed to go over max_armor. It'll decrease over time by itself and affect max_armor in the meantime. Maximum is 100. */
	nonvirtual void AddBonusArmor(float);
	/** Returns the bonus armor of the entity. That is the amount of armor above max_armor. */
	nonvirtual float GetBonusArmor(void);

	/** Sets the current armor of the entity. */
	nonvirtual void SetArmor(float);
	/** Returns the current armor of the entity. */
	nonvirtual float GetArmor(void);

	/** Sets the maximum amount of armor the entity can have */
	nonvirtual void SetMaxArmor(float);
	/** Returns the maximum armor value the entity can have. */
	nonvirtual float GetMaxArmor(void);

	/** Returns how many seconds have passed since we died. Will return -1 if not applicable. */
	nonvirtual float TimeSinceDeath(void);

	/** Returns whether this entity reacts to damage being inflicted. */
	nonvirtual bool CanBeDamaged(vector,vector);
#endif

	/** Assigns the surface data of a given description onto this entity. */
	nonvirtual void SetSurfaceData(string);
	/** Assigns the prop data of a given description onto this entity. */
	nonvirtual void SetPropData(string);
	/** Returns if the entity has prop data information set. */
	nonvirtual bool HasPropData(void) ;
	/** Returns a variable type of information about the entity's prop data */
	nonvirtual __variant GetPropData(int);
	/** Returns if the entity has surface data information set. */
	nonvirtual bool HasSurfaceData(void);
	/** Returns a variable type of information about the entity's surface data */
	nonvirtual __variant GetSurfaceData(int);

#ifdef CLIENT
	/** Called every frame to render a fire effect, but will only do so if the entity is burning. */
	virtual void RenderFire(void);
#endif

private:
	nonvirtual void _SurfaceDataFinish(void);
	nonvirtual void _PropDataFinish(void);
	
	float m_timeUntilNextBurnDamage;

	PREDICTED_FLOAT(armor)
	PREDICTED_FLOAT_N(health)

	/* Surface/PropKit */
	int m_surfdataID;
	string m_surfData;
	int m_propdataID;
	string m_propData;

#ifdef SERVER
	nonvirtual void _UpdateTakedamage(void);

	float m_bonusHealth;
	float m_timeUntilBonusHealthDecreases;
	float m_bonusArmor;
	float m_timeUntilBonusArmorDecreases;
	float max_armor;
	float m_timeOfDeath;
	bool m_autoAim;
	bool m_vulnerable;

	/* fire/burning */
	entity m_burningAttacker;
	string m_burningWeapon;
	float m_timeUntilBurningStops;
	float m_timeUntilNextBurnDamage; /* for whenever they touch a hot flame */

	/* I/O */
	string m_outputOnDamaged;
	string m_outputOnDamagedByPlayer;
	string m_outputOnHalfHealth;
	string m_outputOnDeath;
	string m_outputOnBreak;

#endif
};

#ifdef CLIENT
void ncSurfacePropEntity_ReadEntity(bool);
#endif
