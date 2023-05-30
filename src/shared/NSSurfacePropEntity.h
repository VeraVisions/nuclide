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

/** This entity represents an NSRenderableEntity with interactive surface properties.
It can take damage and can handle variously different types of impact. */
class NSSurfacePropEntity:NSRenderableEntity
{
private:
	float m_flBurnNext;

	PREDICTED_FLOAT(armor)
	PREDICTED_FLOAT_N(health)

#ifdef SERVER
	/* fire/burning */
	entity m_eBurner;
	int m_iBurnWeapon;
	float m_flBurnTime;
	float m_flBurnDmgTime; /* for whenever they touch a hot flame */

	/* I/O */
	string m_strOnBreak;

	/* life, death */
	float m_oldHealth;

	/* Surface/PropKit */
	int m_iMaterial;
	string m_strSurfData;
	int m_iPropData;
	string m_strPropData;

	float m_flDeathTime;

	nonvirtual void _SurfaceDataFinish(void);
	nonvirtual void _PropDataFinish(void);
#endif

public:
	void NSSurfacePropEntity(void);

	/* overrides */
	virtual void Spawned(void);
	virtual void SetModel(string);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
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

	/* new */
#ifdef SERVER
	/** Sets the entity on fire. */
	nonvirtual void Ignite(entity, float, int);
	/** If the entity is on fire, it'll have it extinguished */
	nonvirtual void Extinguish(void);
	/** Returns whether or not this entity is on fire. */
	nonvirtual bool IsOnFire(void);
	/** Called whenever the entity receives damage. */
	virtual void Pain(void);
	/** Called when the health is equal or below 0 */
	virtual void Death(void);
	/** Returns whether or not the entity is alive. */
	virtual bool IsAlive(void);

	/** Sets whether the entity can bleed. */
	nonvirtual void SetCanBleed(bool);
	/** Returns whether the entity can bleed. */
	nonvirtual bool CanBleed(void);

	/* Generic Damage */
	/** Sets whether the entity can take damage */
	nonvirtual void SetTakedamage(float);
	/** Sets the current health of the entity. */
	nonvirtual void SetHealth(float);
	/** Sets the maximum amount of health the entity can have */
	nonvirtual void SetMaxHealth(float);
	/** Returns the current health of the entity. */
	nonvirtual float GetHealth(void);
	/** Returns the maximum health the entity can have. */
	nonvirtual float GetMaxHealth(void);

	/** Sets the current armor of the entity. */
	nonvirtual void SetArmor(float);
	/** Returns the current armor of the entity. */
	nonvirtual float GetArmor(void);

	/** Returns the health the entity spawned with at map load */
	nonvirtual float GetSpawnHealth(void);
	/** Returns if the entity has prop data information set. */ 
	nonvirtual bool HasPropData(void) ;
	/** Returns a variable type of information about the entity's prop data */
	nonvirtual __variant GetPropData(int);
	/** Returns if the entity has surface data information set. */ 
	nonvirtual bool HasSurfaceData(void);
	/** Returns a variable type of information about the entity's surface data */
	nonvirtual __variant GetSurfaceData(int);
	/** Assigns the surface data of a given description onto this entity. */
	nonvirtual void SetSurfaceData(string);
	/** Assigns the prop data of a given description onto this entity. */
	nonvirtual void SetPropData(string);
	/** Returns how many seconds have passed since we died. Will return -1 if not applicable. */
	nonvirtual float TimeSinceDeath(void);
#endif

#ifdef CLIENT
	/** Called every frame to render a fire effect, but will only do so if the entity is burning. */
	virtual void RenderFire(void);
#endif

	/* misc 'being' methods */
	/** Returns the absolute world position of where the eyes are located. */
	nonvirtual vector GetEyePos(void);
	/** Sets the relative position of the eyes */
	nonvirtual void SetEyePos(vector);
};

#ifdef CLIENT
void NSSurfacePropEntity_ReadEntity(bool);
#endif

