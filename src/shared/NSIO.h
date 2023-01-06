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

/** This class is responsible for handling core entity functionality.

It handles entity spawns, respawns,
save/load as well as key/value pair loading, as well as inputs/outputs
which is our basic entity model.

This is a very low-level class. You're never meant to use this.
Use NSEntity as a basis for your classes.
*/
class NSIO
{

private:
	void NSIO(void);

	virtual void Init(void);

#ifdef SERVER
	string m_strOnTrigger;
	string m_strOnUser1;
	string m_strOnUser2;
	string m_strOnUser3;
	string m_strOnUser4;
#endif

public:
	/** Called when the entity is fulled initialized.
		Any spawn key/value info pairs have already been
		dealt with. So now we can make full decisions on the entity.
		Always make sure to call `super::Spawned();` inside your method when overriding. */
	virtual void Spawned(void);

	/** Server: Called when the entity first spawns or when game-logic requests the entity to
		return to its original spawn state. */
	virtual void Respawn(void);

	/** This method handles entity key/value pairs on map load.
		You can easily convert the `strValue` parameter using the ReadFloat etc. methods
		that are part of NSIO. */
	virtual void SpawnKey(string,string);

#ifdef SERVER
	/** Handles saving a copy of this entity to a given filehandle.
		Within you want to use the ::SaveFloat() etc. methods to write
		the internal member attributes to the specified file handle. */
	virtual void Save(float);

	/** Similar to `::SpawnKey` but for save-game fields.
		Whatever you write into file handles within your `::Save()` method
		needs to be read back in here. */
	virtual void Restore(string,string);

	/** Called when the entity has been successfully restored from a savegame file. */
	virtual void RestoreComplete(void);

	/** Called when we are being prompted by another object/function with an input message. */
	virtual void Input(entity,string,string);

	/* helper functions to allocate outputs */
	/** Triggers an output field that has been created beforehand */
	nonvirtual void UseOutput(entity,string);
	/** Prepares an output field.
	Commonly used within ::SpawnKey() to prepare output fields.
	For example: m_someOutput = PrepareOutput(m_someOutput, strValue);`
	This will ensure that when an entity wants to trigger multiple outputs
	that those can be called with a single `UseOutput` call. */
	nonvirtual string PrepareOutput(string,string);

	/** Called at the end of setting up an entity's output field. 
	The input is a 5 parameter, commar separated string.
	The return value is the targetname of a minion object that'll handle 
	the triggering (and counting down of uses) as defined in the Source Engine's
	Input/Output specification. */
	nonvirtual string CreateOutput(string);

	/* save game related methods */
	/** Saves a floating point key/value pair to a filehandle. */
	nonvirtual void SaveFloat(float,string,float);
	/** Saves a integer key/value pair to a filehandle. */
	nonvirtual void SaveInt(float,string,int);
	/** Saves a string key/value pair to a filehandle. */
	nonvirtual void SaveString(float,string,string);
	/** Saves a vector key/value pair to a filehandle. */
	nonvirtual void SaveVector(float,string,vector);
	/** Saves a boolean key/value pair to a filehandle. */
	nonvirtual void SaveBool(float,string,bool);
	/** Saves an entity id key/value pair to a filehandle. */
	nonvirtual void SaveEntity(float,string,entity);

	/* load game/spawn helper functions */
	/** reads a floating point value from a string */
	nonvirtual float ReadFloat(string);
	/** reads an integer value from a string */
	nonvirtual int ReadInt(string);
	/** reads a string value from a string (with error checking) */
	nonvirtual string ReadString(string);
	/** reads a vector from a string */
	nonvirtual vector ReadVector(string);
	/** reads a boolean value from a string */
	nonvirtual bool ReadBool(string);
	/** read an entity id, converted to entity, from a string */
	nonvirtual entity ReadEntity(string);
#endif

	/** Get the level time the entity finds itself in.
		Always use this instead of the `time` global. The `time` global may not
		be valid on every type of entity. Specifically, MOVETYPE_PUSH entities only
		update upon movement (so that any think timers the entity may have are not triggered
		when it is at rest. */
	nonvirtual float GetTime(void);
};

.bool _mapspawned;
