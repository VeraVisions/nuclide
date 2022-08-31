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

/* NSIO class is responsible for handling entity spawns, respawns,
   save/load as well as key/value pair loading, as well as inputs/outputs
   which is our basic entity model.

   This is a very low-level class. You're never meant to use this.
   Use NSEntity as a basis for your classes.
*/
class NSIO
{
	void(void) NSIO;

	virtual void(void) Init;
	virtual void(void) Spawned;

	/* whenever gamerules want entities to respawn */
	virtual void(void) Respawn;

	/* Handle entity key/value pairs on init */
	virtual void(string, string) SpawnKey;

	nonvirtual float(void) GetTime;

#ifdef SERVER
	/* Input/Output System */
	string m_strOnTrigger;
	string m_strOnUser1;
	string m_strOnUser2;
	string m_strOnUser3;
	string m_strOnUser4;

	/* helper functions to allocate outputs */
	nonvirtual void(entity, string) UseOutput;
	nonvirtual string(string, string) PrepareOutput;
	nonvirtual string(string) CreateOutput;

	virtual void(float) Save;
	virtual void(string,string) Restore;

	/* save game */
	nonvirtual void(float, string, float) SaveFloat;
	nonvirtual void(float, string, int) SaveInt;
	nonvirtual void(float, string, string) SaveString;
	nonvirtual void(float, string, vector) SaveVector;
	nonvirtual void(float, string, bool) SaveBool;
	nonvirtual void(float, string, entity) SaveEntity;

	/* load game */
	nonvirtual float(string) ReadFloat;
	nonvirtual int(string) ReadInt;
	nonvirtual string(string) ReadString;
	nonvirtual vector(string) ReadVector;
	nonvirtual bool(string) ReadBool;
	nonvirtual entity(string) ReadEntity;

	/* Handle incoming entities input messaging */
	virtual void(entity, string, string) Input;
#endif
};

.bool _mapspawned;
