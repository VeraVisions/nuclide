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

/**
Bitfield enumeration for NSEntity its SendFlags field.

These give hint as to which internal fields get networked to the client.
*/
typedef enumflags
{
	BASEFL_CHANGED_MODELINDEX,
	BASEFL_CHANGED_ORIGIN_X,
	BASEFL_CHANGED_ORIGIN_Y,
	BASEFL_CHANGED_ORIGIN_Z,
	BASEFL_CHANGED_ANGLES_X,
	BASEFL_CHANGED_ANGLES_Y,
	BASEFL_CHANGED_ANGLES_Z,
	BASEFL_CHANGED_VELOCITY_X,
	BASEFL_CHANGED_VELOCITY_Y,
	BASEFL_CHANGED_VELOCITY_Z,
	BASEFL_CHANGED_ANGULARVELOCITY,
	BASEFL_CHANGED_SIZE,
	BASEFL_CHANGED_FLAGS,
	BASEFL_CHANGED_SOLID,
	BASEFL_CHANGED_FRAME,
	BASEFL_CHANGED_SKIN,
	BASEFL_CHANGED_MOVETYPE,
	BASEFL_CHANGED_EFFECTS,
	BASEFL_CHANGED_SCALE,
} nsentity_changed_t;

/** NSEntity is the lowest of the user-accessible entity class.
It's responsible for handling practically every entity in Nuclide.

Try to avoid using the built-in 'entity' type unless you know exactly
what you are doing. Otherwise, you will deal with loss of savegames and much more.
*/
class NSEntity:NSTrigger
{
private:
	float m_flSpawnTime;
	bool m_bHidden; /**< decides whether the entity is visible or not, without affecting collision */
	vector m_vecMins; /**< REAL min bounding box value, without .scale affecting it */
	vector m_vecMaxs; /**< REAL max bounding box value, without .scale affecting it */

	vector m_oldOrigin; /**< contains the origin that the entity spawned in */
	vector m_oldAngle; /**< contains the angle that the entity spawned in */
	string m_oldModel; /**< contains the model that the entity spawned with */
	float m_oldSolid; /**< contains the collision type the entity spawned with */
	bool m_bIsBrush;

	PREDICTED_VECTOR_N(origin)
	PREDICTED_VECTOR_N(angles)
	PREDICTED_FLOAT_N(modelindex)
	PREDICTED_VECTOR_N(size)
	PREDICTED_VECTOR_N(mins)
	PREDICTED_VECTOR_N(maxs)
	PREDICTED_FLOAT_N(solid)
	PREDICTED_FLOAT_N(movetype)
	PREDICTED_FLOAT_N(scale)
	PREDICTED_FLOAT_N(flags)
	PREDICTED_VECTOR_N(velocity)
	PREDICTED_VECTOR_N(avelocity)

#ifdef SERVER
	string m_parent;
	string m_parent_attachment;
	PREDICTED_FLOAT_N(frame)
	PREDICTED_FLOAT_N(skin)
	PREDICTED_FLOAT_N(effects)
#endif

public:
	/** The constructor.
		Not much may be known of what the entity will be just yet. */
	void NSEntity(void);

#ifdef CLIENT
	/** Client: Handles network updates from the server for the associated entity. */
	virtual void ReceiveEntity(float,float);

	/** Client: Run after the rendering of 3D world is complete. 2D calls can happen here. */
	virtual void postdraw(void);

	/** Client: Called when video resources need to be allocated or reloaded for the entity. */
	virtual void RendererRestarted(void);
#endif

	/* overrides */
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);

	/** Handles what happens before the entity gets removed from the client game. */
	virtual void OnRemoveEntity(void);

	/** Tells the engine to make the entity static, effectively making it inaccessible.
		It will be removed from the game-logic but remain visible and it will retain its
		collision and maintain the appearance it had before getting removed. */
	virtual void MakeStatic(void);

	/** Returns if this entity can spawned from the map file.
	@param clientSide If it's being spawned on the client-side. */
	virtual bool CanSpawn(bool clientSide);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void Input(entity,string,string);
	virtual void Save(float);
	virtual void Restore(string,string);

	/** Called when we need to re-align the entity to our parent entity. */
	virtual void ParentUpdate(void);

	/** Run each tic after physics are run to determine if we need to send updates over the network. */
	virtual void EvaluateEntity(void);

	/** Called by the engine whenever we need to send a client an update about this entity. */
	virtual float SendEntity(entity,float);

	/** Returns the entity this is parented to. May be __NULL__ when we have no parent. */
	nonvirtual entity GetParent(void);

	/** Call this to parent the entity to another entity. */
	nonvirtual void SetParent(string);

	/** Call this to parent the entity to an attachment of another entity. */
	nonvirtual void SetParentAttachment(string);

	/** Call this on an entity to remove the connection to its parent. */
	nonvirtual void ClearParent(void);

	/** Restore the entity's angles to the value they spawned with. */
	nonvirtual void RestoreAngles(void);

	/** Unsets any any angle related values within the entity. */
	nonvirtual void ClearAngles(void);
#endif

	/* sets */
	/** Sets the whole effects field. Check the effects_t enum for available effects.*/
	nonvirtual void SetEffects(float);
	/** Appends one or more effects to the entity. Check the effects_t enum for available effects.*/
	nonvirtual void AddEffects(float);
	/** Removes one or more effects from the entity. Check the effects_t enum for available effects.*/
	nonvirtual void RemoveEffects(float);
	/** Sets the framegroup sequence of the entity. Must be positive.*/
	nonvirtual void SetFrame(float);
	/** Sets the skingroup of the entity. Must be positive. */
	nonvirtual void SetSkin(float);
	/** Sets the scale of the entity. Affects collision as well. */
	nonvirtual void SetScale(float);
	/** Sets the owner of the entity. Entities will no longer collide with the specified owner. */
	nonvirtual void SetOwner(entity);
	/** Sets the movement velocity of the given entity. */
	nonvirtual void SetVelocity(vector);

	/** Overrides the touch function of a the entity to the specified function.
		As a result Start/EndTouch will be unreliable. */
	nonvirtual void SetTouch(void());
	/** Overrides the field that's used to determine which information should be networked. */
	nonvirtual void SetSendFlags(float);
	/** Sets the collision type of the entity. Check the solid_t enum for available types. */
	nonvirtual void SetSolid(float);
	/** Sets the 3D model representation of the entity from a file path and name. */
	virtual void SetModel(string);
	/** Sets the 3D model representation of the entity from an already precached resource id. */
	nonvirtual void SetModelindex(float);
	/** Sets the movement type of the entity. Check the movetype_t enum for available types. */
	nonvirtual void SetMovetype(float);
	/** Sets the gravitational modifier of the entity. The default is 1.0. */
	nonvirtual void SetGravity(float);
	/** Sets the direction the entity is facing in eueler angles. */
	nonvirtual void SetAngles(vector);
	/** Sets the angular velocity of the entity in degrees per second on each axis. */
	nonvirtual void SetAngularVelocity(vector);
	/** Sets the absolute 3D world position of the entity. */
	nonvirtual void SetOrigin(vector);
	/** Sets the bounding box size of the entity.
		This affects both collision and rendering bounds checking. */
	nonvirtual void SetSize(vector,vector);
	/** Adds one or more special flags to the entity. */
	nonvirtual void AddFlags(float);
	/** Remove one or more special flags from the entity. */
	nonvirtual void RemoveFlags(float);

	/** Overrides the Think function of the entity.
		Only use it when you want to retain a think timer that's already been set for the entity. */
	nonvirtual void SetThink(void());
	/** Sets the next think timer of the entity.
		It has to be a positive value. For example `::SetNextThink(1.5f); will trigger the think
		1.5 seconds from then on.*/
	nonvirtual void SetNextThink(float);
	/** Schedules a think timer. You can only have one going at any given time.
		This is the preferred way of setting think timers.
		Note that when an entity of movement type `MOVETYPE_PUSH` is not moving, 
		it will never get to think. */
	nonvirtual void ScheduleThink(void(void),float);

	/* gets */
	/** Returns the world coordinates of where the entity originally spawned. */
	nonvirtual vector GetSpawnOrigin(void);
	/** Returns the direction the entity was facing when it originally spawned. */
	nonvirtual vector GetSpawnAngles(void);
	/** Returns the 3D model representation of the entity of when it originally spawned. */
	nonvirtual string GetSpawnModel(void);
	/** Returns a bitfield of the active effects running on the entity. */
	nonvirtual float GetEffects(void);
	/** Returns the currently active framegroup of the entity. */
	nonvirtual float GetFrame(void);
	/** Returns the currently equipped skin of the entity. */
	nonvirtual float GetSkin(void);
	/** Returns the scale modifier of the entity. */
	nonvirtual float GetScale(void);
	/** Returns the owner of the entity. */
	nonvirtual entity GetOwner(void);
	/** Returns the movement velocity of the entity. */
	nonvirtual vector GetVelocity(void);
	/** Returns the collision type of the entity. */
	nonvirtual float GetSolid(void);
	/** Returns the name of the 3D model representation of the entity. */
	nonvirtual string GetModel(void);
	/** Returns the model id of the 3D model representation of the entity. */
	nonvirtual float GetModelindex(void);
	/** Returns the movement type of the entity. */
	nonvirtual float GetMovetype(void);
	/** Returns the gravity modifier of the entity. */
	nonvirtual float GetGravity(void);
	/** Returns the direction the entity is facing in euler angles. */
	nonvirtual vector GetAngles(void);
	/** Returns the direction the entity is spinning in degrees per second for each axis. */
	nonvirtual vector GetAngularVelocity(void);
	/** Returns the absolute world position of the entity. */
	nonvirtual vector GetOrigin(void);
	/** Returns the bounding box mins of the entity. */
	nonvirtual vector GetMins(void);
	/** Returns the bounding box maxs of the entity. */
	nonvirtual vector GetMaxs(void);
	/** Returns the actual bounding box mins of the entity,
		before having been affected by scale modifiers. */
	nonvirtual vector GetRealMins(void);
	/** Returns the actual bounding box maxs of the entity,
		before having been affected by scale modifiers. */
	nonvirtual vector GetRealMaxs(void);
	/** Returns the absolute bounding box mins of the entity,
		instead of being relative to the world position. */
	nonvirtual vector GetAbsoluteMins(void);
	/** Returns the absolute bounding box maxs of the entity,
		instead of being relative to the world position. */
	nonvirtual vector GetAbsoluteMaxs(void);
	/** Returns a flag bitfield that the entity associates with. */
	nonvirtual float GetFlags(void);
	/** Returns true if the entity has the specified flags. */
	nonvirtual float HasFlags(float);
	/** Returns an absolute value of when the entity will be think again.
		Any result should be tested against `::GetTime()`. */
	nonvirtual float GetNextThinkTime(void);
	/** Returns whether or not we're currently expecting to think any time soon. */
	nonvirtual bool IsThinking(void);
	/** When called, will unset anything related to ongoing think operations. */
	nonvirtual void ReleaseThink(void);
	/** When called, will clear anything related to physical movement on the entity. */
	nonvirtual void ClearVelocity(void);

	/* drawing related */
	/** When called, will unhide the entity. */
	nonvirtual void Show(void);
	/** When called, the entity will stop being rendered on the client. */
	nonvirtual void Hide(void);
	/** Returns if the entity is currently being hidden explicitly. */
	nonvirtual bool IsHidden(void);

	/** Returns if the entity is solid or non-solid */
	nonvirtual bool IsSolid(void);

	/** When called it'll make the entity uninteractable (but not destroy it).
		It will hide it, as well as remove any collision associated with it. */
	nonvirtual void Disappear(void);
	/** When called, will remove the entity from the game entirely. */
	nonvirtual void Destroy(void);
	/** Call this if you want to update bounding boxes to take angles into account. */
	nonvirtual void UpdateBounds(void);

	/* useful methods, (some) based on GMod's API */
	/** Returns the unique entity id of the entity. */
	nonvirtual float EntIndex(void);
	/** When called, will drop the entity down onto the surface it's hovering over. Will return `false` if the entity fell through the floor, or something else that's undesirable. */
	nonvirtual bool DropToFloor(void);
	/** Returns a normalized forward vector of the entity to more easily test which way it's facing. */
	nonvirtual vector GetForward(void);
	/** Returns a normalized right vector of the entity to more easily test what's right next to it. */
	nonvirtual vector GetRight(void);
	/** Returns a normalized up vector of the entity to more easily test what may be above it. */
	nonvirtual vector GetUp(void);
	/** Returns absolute world coordinates of the center of the entity according to its pivot point. */
	nonvirtual vector WorldSpaceCenter(void);
	/** Returns the water level the entity is in.

	0 - Entity is not in any water/liquid.

	1 - Entity 1/4 submerged.

	2 - Entity 3/4 submerged.

	3 - Entity is fully submerged */
	nonvirtual float WaterLevel(void);

	/** Returns if the entity is visible by another entity and a field of view of 90 degrees. */
	nonvirtual bool Visible(entity);
	/** Returns if the entity is visible from a given position and a field of view of 90 degrees. */
	nonvirtual bool VisibleVec(vector);
	/** Returns a normalized value of how far away the target is from the entity's view direction. 1 means dead-center. 0 means it's behind.*/
	nonvirtual bool DistanceFromYaw(entity);
	/** Returns if the entity has any spawnflags set. */
	nonvirtual bool HasSpawnFlags(float);
	/** Returns if the entity is aligned to the ground. */
	nonvirtual bool IsOnGround(void);
	/** Returns the entity we're standing on.
		If the result is `__NULL__` that does not mean that we're in air.
		Check `::IsOnGround()` for that information. */
	nonvirtual entity GetGroundEntity(void);
	/** Returns if the entity was spawned by the map we're on. */
	nonvirtual bool CreatedByMap(void);
	/** Returns whether or not we are within the bounds of a given entity. */
	nonvirtual bool WithinBounds(entity);

	/* useful methods, (some) based on Doom 3's API */
	/** Plays a sound sample directly onto the entity.
		Returns `FALSE` if the sample was not found. */
	nonvirtual bool StartSound(string,float,float,bool);
	/** Plays a soundDef on the entity.
		Returns `FALSE` if the soundDef was not found. */
	nonvirtual bool StartSoundDef(string,float,bool);
	/** Stops a sound sample or soundDef that is playing on the given channel. */
	nonvirtual void StopSound(float,bool);

	/** Returns the nearest point on a wall of this entity within a specified radius. 
		If there is nothing nearby, it'll return the position of the entity. */
	nonvirtual vector NearestWallPointForRadius(float);

	/** For physics functions only. Call this inside your customphysics function
		of any entity class that you want to support think functions in.
		This saves you the effort of writing your own routines and methods. */
	nonvirtual void HandleThink(void);

	/** Returns either true or false depending on if this entity is facing the entity in question. */
	nonvirtual bool IsFacing(entity);

	/** Returns the time that's passed since the entity has been spawned. */
	nonvirtual float GetSpawnAge(void);

	/** Returns the absolute timestamp of when the entity had been spawned. */
	nonvirtual float GetSpawnTime(void);
	/** Move the entity to a new position, with updated angles. */
	nonvirtual void Transport(vector, vector);
};

#ifdef CLIENT
void NSEntity_ReadEntity(float);
#endif