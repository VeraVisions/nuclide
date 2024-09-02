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

/** This class is responsible for handling core entity functionality.

It handles entity spawns, respawns,
save/load as well as key/value pair loading, as well as inputs/outputs
which is our basic entity model.

This is a very low-level class. You're never meant to use this.
Use NSEntity as a basis for your classes.
*/
class NSIO
{
public:
	void NSIO(void);

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

	/* EntityDef interactions */
	/** Looks up a sequence from an act of a key within this entity's declaration. */
	nonvirtual float GetDefAct(string);
	/** Looks up the string value of a key within this entity's declaration. */
	nonvirtual string GetDefString(string);
	/** Looks up the floating-point value of a key within this entity's declaration. */
	nonvirtual float GetDefFloat(string);
	/** Looks up the boolean value of a key within this entity's declaration. */
	nonvirtual bool GetDefBool(string);
	/** Looks up the integer value of a key within this entity's declaration. */
	nonvirtual int GetDefInt(string);
	/** Looks up the integer value of a key within this entity's declaration. */
	nonvirtual vector GetDefVector(string);

	/** Like GetDefAct, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual float GetSubDefAct(string, string);
	/** Like GetDefString, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual string GetSubDefString(string, string);
	/** Like GetDefFloat, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual float GetSubDefFloat(string, string);
	/** Like GetDefBool, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual bool GetSubDefBool(string, string);
	/** Like GetDefInt, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual int GetSubDefInt(string, string);
	/** Like GetDefVector, but queries a specified def, falling back to reading from our own if it's not defined. */
	nonvirtual vector GetSubDefVector(string, string);

	/** When called, will remove the entity from the game entirely. */
	nonvirtual void Destroy(void);
	/** Handles what happens before the entity gets removed from the client game. */
	virtual void OnRemoveEntity(void);

#ifdef SERVER
	/** Handles saving a copy of this entity to a given filehandle.
		Within you want to use the NSIO::SaveFloat() etc. methods to write
		the internal member attributes to the specified file handle. */
	virtual void Save(float);

	/** Similar to `NSIO::SpawnKey` but for save-game fields.
		Whatever you write into file handles within your `NSIO::Save()` method
		needs to be read back in here. */
	virtual void Restore(string,string);

	/** Called when the entity has been successfully restored from a savegame file. */
	virtual void RestoreComplete(void);

	/** Called when the entity has successfully completed a level transition. */
	virtual void TransitionComplete(void);

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

	/** Returns whether the Output is ready, or has done firing - not currently scheduled to fire, etc.
	Input is the identifier of an output. */
	nonvirtual bool CheckOutput(string);

	/** Called when we need to re-align the entity to our parent entity. */
	virtual void ParentUpdate(void);

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

#endif

	/** Returns the floating-point value of a named key in the entity's spawn data. */
	nonvirtual float GetSpawnFloat(string);
	/** Returns the integer value of a named key in the entity's spawn data. */
	nonvirtual int GetSpawnInt(string);
	/** Returns the string value of a named key in the entity's spawn data. */
	nonvirtual string GetSpawnString(string);
	/** Returns the vector value of a named key in the entity's spawn data. */
	nonvirtual vector GetSpawnVector(string);
	/** Returns the boolean value of a named key in the entity's spawn data. */
	nonvirtual bool GetSpawnBool(string);
	/** Returns an entity of a named key in the entity's spawn data. 
	    @param keyName Name of the key in the spawn data.
	    @param startEntity Start search at this entity. Can be `world` or `__NULL__`.*/
	nonvirtual entity GetSpawnEntity(string, entity);

	/* load game/spawn helper functions */
	/** Returns a floating point value from a string value. */
	nonvirtual float ReadFloat(string);
	/** Returns an integer value from a string. */
	nonvirtual int ReadInt(string);
	/** Returns a string value from a string (with error checking). */
	nonvirtual string ReadString(string);
	/** Returns a vector from a string. */
	nonvirtual vector ReadVector(string);
	/** Returns a boolean value from a string. */
	nonvirtual bool ReadBool(string);
	/** Reads an entity id from a string and returns the entity. */
	nonvirtual entity ReadEntity(string);

	/** Get the level time the entity finds itself in.
		Always use this instead of the `time` global. The `time` global may not
		be valid on every type of entity. Specifically, MOVETYPE_PUSH entities only
		update upon movement (so that any think timers the entity may have are not triggered
		when it is at rest. */
	nonvirtual float GetTime(void);

	/* save game related methods */
	/** Debug print for a given float. */
	nonvirtual void DebugFloat(string,float);
	/** Debug print for a given integer. */
	nonvirtual void DebugInt(string,int);
	/** Debug print for a given string. */
	nonvirtual void DebugString(string,string);
	/** Debug print for a given vector. */
	nonvirtual void DebugVector(string,vector);
	/** Debug print for a given boolean. */
	nonvirtual void DebugBool(string,bool);
	/** Debug print for a given entity. */
	nonvirtual void DebugEntity(string,entity);

private:
	string m_strSpawnData;
#ifdef SERVER
	string m_strOnTrigger;
	string m_strOnUser1;
	string m_strOnUser2;
	string m_strOnUser3;
	string m_strOnUser4;

	/* entityDef powered modelevent callbacks */
	string m_strModelEventCB;
#endif
};

.bool _mapspawned;

void
_NSEntLog(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		print(sprintf("^9%f ^7%s (%d)^7: %s\n", time, className, edictNum, warnMessage));
	else
		print(sprintf("^7%s (%d)^7: %s\n", className, edictNum, warnMessage));
}

void
_NSEntWarning(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		print(sprintf("^9%f ^3%s (%d)^7: %s\n", time, functionName, edictNum, warnMessage));
	else
		print(sprintf("^3%s (%d)^7: %s\n", functionName, edictNum, warnMessage));
}

void
_NSEntError(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_logTimestamps)
		print(sprintf("^9%f ^1%s (id: %d)^7: %s\n", time, functionName, edictNum, warnMessage));
	else
		print(sprintf("^1%s (id: %d)^7: %s\n", functionName, edictNum, warnMessage));
}
/** Logs an entity class specific log message, with detailed info.
	 The console variable `entity_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define EntLog(...) if (autocvar_g_logLevel >= LOGLEVEL_DEBUG) _NSEntLog(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/** Logs an entity class specific warning message, with detailed info.
	 The console variable `entity_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define EntWarning(...) if (autocvar_g_logLevel >= LOGLEVEL_WARNINGS) _NSEntWarning(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/** Logs an entity class specific error message, with detailed info.
	 The console variable `entity_developer` has to be `1` for them to be visible.

@param description(...) contains a formatted string containing a description. */
#define EntError(...) if (autocvar_g_logLevel >= LOGLEVEL_ERRORS) _NSEntError(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))
