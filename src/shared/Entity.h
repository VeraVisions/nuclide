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

/**
Bitfield enumeration for ncEntity its SendFlags field.

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

/** ncEntity is the lowest of the user-accessible entity class.
It's responsible for handling practically every entity in Nuclide.

Try to avoid using the built-in 'entity' type unless you know exactly
what you are doing. Otherwise, you will deal with loss of savegames and much more.

# INPUTS

- "Kill" : Removes the entity from the game.
- "KillHierarchy" : Removes the entity and anything owned by the entity.
- "KillChildClass" : Removes anything owned by the entity.
- "SetParent" : Parents the entity to a named one.
- "SetParentAttachment" : Sets the attachment that it'll be parented to. You still have to SetParent.
- "ClearParent" : Removes any parenting info.
- "Use" : Simulates a player 'using' it.
- "ShootGib" : Shoots gibs. Three arguments: "model" "speed" "count"
- "SpawnDef" : Reserved. Use SpawnDefOffset instead.
- "SpawnDefOffset" : Spawns an entityDef relative to us, plus an offset vector. "classname" "forward" "right" "up"
- "SpawnProjectileOffset" : Launches a projectile relative to us, plus an offset vector. "classname" "forward" "right" "up"
- "SpawnProjectileDef" : Launches a projectile relative to us, on the first attachment position (defined in the model).
- "StartSoundDef" : Plays a sound on the VOICE channel.
- "AddVelocity" : Applies linear velocity to the entity, relative to the view angle. "forward" "right" "up"
- "Shockwave" : Casts a shockwave effect. 
- "SetOrigin" : Sets the absolute position in-world.
- "SetEditorColor" : Reserved.
- "Respawn" : Requests the item to respawn, which resets it to its initial state.

@ingroup baseclass
*/
class ncEntity:ncTrigger
{
public:
	/** The constructor.
		Not much may be known of what the entity will be just yet. */
	void ncEntity(void);

#ifdef CLIENT
	/** Client: Handles network updates from the server for the associated entity. */
	virtual void ReceiveEntity(float,float);

	virtual void ReceiveEvent(float);

	virtual float predraw(void);

	/** Client: Run after the rendering of 3D world is complete. 2D calls can happen here. */
	virtual void postdraw(void);

	/** Client: Called when video resources need to be allocated or reloaded for the entity. */
	virtual void ReloadVideoResources(void);
#endif

	/* overrides */
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Precache(void);
	nonvirtual void Spawn(void);

	/** Tells the engine to make the entity static, effectively making it inaccessible.
		It will be removed from the game-logic but remain visible and it will retain its
		collision and maintain the appearance it had before getting removed. */
	virtual void MakeStatic(void);

	/** Returns if this entity can spawned from the map file.
	@param clientSide If it's being spawned on the client-side. */
	virtual bool CanSpawn(bool clientSide);

	/** Returns if this entity has a model set. */
	nonvirtual bool HasModel(void);

#ifdef SERVER
	virtual void Respawn(void);
	virtual void Input(entity,string,string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void ParentUpdate(void);

	nonvirtual void Event_SpawnDefCenter(string);
	nonvirtual void Event_SpawnDefRelative(string, float, float, float);

	nonvirtual bool SharesPVSWithPlayer(void);

	/* Server-side rendering function. Expensive, but useful. */
	virtual void DebugDraw(void);

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

	/** Restore the entity's angles to the value the spawndata contains. */
	nonvirtual void RestoreAngles(void);

	/** Unsets any any angle related values within the entity. */
	nonvirtual void ClearAngles(void);

	/** Simulates the press of the use/activate key, with the passed entity being the activator. */
	nonvirtual void UseBy(entity);

	/** Forces the entity to re-network updates to all clients. */
	nonvirtual void ForceNetworkUpdate(void);
#endif

	/* sets */
	/** Sets the whole effects field. Check the effects_t enum for available effects.*/
	nonvirtual void SetEffects(__int32);
	/** Appends one or more effects to the entity. Check the effects_t enum for available effects.*/
	nonvirtual void AddEffects(__int32);
	/** Removes one or more effects from the entity. Check the effects_t enum for available effects.*/
	nonvirtual void RemoveEffects(__int32);
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

	/** Adds onto the existing angular velocity. */
	nonvirtual void AddAngularVelocity(vector);
	/** Adds onto the existing velocity. */
	nonvirtual void AddVelocity(vector);

	/** Overrides the touch function of a the entity to the specified function.
		As a result Start/EndTouch will be unreliable. */
	nonvirtual void SetTouch(void());
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
	virtual void SetAngles(vector);
	/** Sets the angular velocity of the entity in degrees per second on each axis. */
	nonvirtual void SetAngularVelocity(vector);
	/** Sets the absolute 3D world position of the entity. */
	virtual void SetOrigin(vector);
	/** Same as SetOrigin(), but will push the entity out the ground if needed. */
	nonvirtual void SetOriginUnstick(vector);
	/** Sets the bounding box size of the entity.
		This affects both collision and rendering bounds checking. */
	nonvirtual void SetSize(vector,vector);
	/** Adds one or more engine specific flags to the entity. */
	nonvirtual void AddFlags(float);
	/** Remove one or more engine specific flags from the entity. */
	nonvirtual void RemoveFlags(float);
	/** Adds one or more nuclide specific flags to the entity. */
	nonvirtual void AddVFlags(float);
	/** Remove one or more nuclide specific flags from the entity. */
	nonvirtual void RemoveVFlags(float);

	/** Turns to the specified angle. */
	nonvirtual void TurnTo(float);
	/** Turns towards the specified position. */
	nonvirtual void TurnToPos(vector);

	/* gets */
	/** Returns a bitfield of the active effects running on the entity. */
	nonvirtual __int32 GetEffects(void);
	/** Returns the currently active framegroup of the entity. */
	nonvirtual float GetFrame(void);
	/** Returns the currently equipped skin of the entity. */
	nonvirtual float GetSkin(void);
	/** Returns the scale modifier of the entity. */
	nonvirtual float GetScale(void);
	/** Returns the owner of the entity. */
	nonvirtual entity GetOwner(void);
	/** Returns the movement velocity of the entity. */
	virtual vector GetVelocity(void);
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
	virtual vector GetAngles(void);
	/** Returns the direction the entity is spinning in degrees per second for each axis. */
	virtual vector GetAngularVelocity(void);
	/** Returns the absolute world position of the entity. */
	virtual vector GetOrigin(void);
	/** Returns the virtual size of the entity. */
	nonvirtual vector GetSize(void);
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
	/** Returns an engine flags bitfield that the entity associates with. */
	nonvirtual float GetFlags(void);
	/** Returns true if the entity has the specified engine flags. */
	nonvirtual float HasFlags(float);
	/** Returns a nuclide flags bitfield that the entity associates with. */
	nonvirtual float GetVFlags(void);
	/** Returns true if the entity has the specified, nuclide specific, flags. */
	nonvirtual float HasVFlags(float);

	/** When called, will clear anything related to physical movement on the entity. */
	nonvirtual void ClearVelocity(void);

	/* eye/shoot pos/angle */
	/** Returns the absolute world position of where the eyes are located. */
	nonvirtual vector GetEyePos(void);
	/** Sets the relative position of the eyes. */
	nonvirtual void SetEyePos(vector);
	/** Returns an euler angle of where the entity is 'looking' at. These are not necessarily eye values. */
	nonvirtual vector GetViewAngle(void);

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
	/** Call this if you want to update bounding boxes to take angles into account. */
	nonvirtual void UpdateBounds(void);

	/* useful methods, (some) based on GMod's API */
	/** Returns the unique entity id of the entity. */
	nonvirtual float EntIndex(void);
	/** When called, will drop the entity down onto the surface it's hovering over. Will return `false` if the entity fell through the floor, or something else that's undesirable. */
	nonvirtual bool DropToFloor(void);
	/** Returns a normalized forward vector of the entity to more easily test which way it's facing. */
	virtual vector GetForward(void);
	/** Returns a normalized right vector of the entity to more easily test what's right next to it. */
	virtual vector GetRight(void);
	/** Returns a normalized up vector of the entity to more easily test what may be above it. */
	virtual vector GetUp(void);
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
	/** Returns a normalized value of how far away the target is from the entity's view direction. 1 means dead-center. -1 means it's behind.*/
	nonvirtual float DistanceFromYaw(vector);
	/** Returns if the entity has any spawnflags set. */
	nonvirtual bool HasSpawnFlags(float);
	/** Returns if the entity is aligned to the ground. */
	nonvirtual bool IsOnGround(void);
	/** Returns the entity we're standing on.
		If the result is `__NULL__` that does not mean that we're in air.
		Check `ncEntity::IsOnGround()` for that information. */
	nonvirtual entity GetGroundEntity(void);
	/** Returns if the entity was spawned by the map we're on. */
	nonvirtual bool CreatedByMap(void);
	/** Returns if the entity is still being loaded from the map data. */
	nonvirtual bool Loading(void);
	/** Returns whether or not we are fully within the bounds of a given entity. */
	nonvirtual bool WithinBounds(entity);
	/** Returns whether or not the given entity insersects with us. Like a more lenient WithinBounds(). */
	nonvirtual bool IntersectsWith(entity);

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

	/** Returns either true or false depending on if this entity is facing a position in question. */
	nonvirtual bool IsFacingPosition(vector);

	/** Returns the time that's passed since the entity has been spawned. */
	nonvirtual float GetSpawnAge(void);

	/** Returns the absolute timestamp of when the entity had been spawned. */
	nonvirtual float GetSpawnTime(void);
	/** Move the entity to a new position, with updated angles. */
	nonvirtual void Transport(vector, vector);

	/** Finds a free spot of an entity near itself of same size. Extra padding as argument. */
	nonvirtual vector GetNearbySpot(void);

	/** Returns a unique id between shared entities. */
	nonvirtual int GetSharedID(void);

	/** Will read from the named def to perform an attack. */
	virtual bool AttackByDef(string, bool);

	/** Sets the @ref bot_info tag on this entity to the desired botInfo_t tag. */
	nonvirtual void SetBotTag(botInfo_t);

	/** Will enable collision with players, which is the default. */
	nonvirtual void EnablePlayerCollision(void);
	/** Will disable collision with player entities. */
	nonvirtual void DisablePlayerCollision(void);
	/** Returns whether this entity is being held in the hands of a player. As in via ncPlayer::PickupEntity(). */
	nonvirtual bool HeldByPlayer(void);
	/** Returns whether this entity is a brush or using a sub-model of the level. */
	nonvirtual bool IsBrush(void);

private:
	/** Will read from the named def to perform a projectile attack. */
	nonvirtual bool _ProjectileAttack(string, bool);

#ifdef SERVER
	nonvirtual vector GetModelMins(void);
	nonvirtual vector GetModelMaxs(void);
	nonvirtual void _RelinkToSpawnParent(void);
#endif
	nonvirtual void _ModelChanged(void);

	NETWORKED_INT(entityDefID)

	NETWORKED_VECTOR_N(origin)
	NETWORKED_VECTOR_N(angles)
	NETWORKED_FLOAT_N(modelindex)
	NETWORKED_VECTOR_N(size)
	NETWORKED_VECTOR_N(mins)
	NETWORKED_VECTOR_N(maxs)
	NETWORKED_FLOAT_N(solid)
	NETWORKED_FLOAT_N(movetype)
	NETWORKED_FLOAT_N(scale)
	NETWORKED_FLOAT_N(flags)
	NETWORKED_FLOAT_N(m_nuclideFlags)
	NETWORKED_VECTOR_N(velocity)
	NETWORKED_VECTOR_N(avelocity)
	NETWORKED_FLOAT_N(frame)
	NETWORKED_FLOAT_N(skin)
	__int32 effects_net;

	entity m_holdingPlayer;
	float m_lastHeldTime;
	float m_spawnTime;
	vector m_internalMins; /**< REAL min bounding box value, without .scale affecting it */
	vector m_internalMaxs; /**< REAL max bounding box value, without .scale affecting it */
	bool m_modelBrushBased;
	vector m_editorColor;
	vector m_modelMins;
	vector m_modelMaxs;
	bool _loading;

#ifdef SERVER
	string m_parent;
	string m_parent_old;
	string m_parent_attachment;
	vector m_parentPosOffs;
	vector m_parentAngOffs;
#endif
};

/** Returns a new entity. Guaranteed to be something. Never __NULL__
   unless we're seriously out of memory. */
ncEntity spawnClass(string className, vector desiredPos);

#ifdef SERVER
bool changeClass(entity target, string className)
#endif

void sendInput(entity target, string inputName, string dataString, entity activator);
