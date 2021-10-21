/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
   Use NSEntity as a basis for your classes
*/

class NSIO
{
	void(void) NSIO;

	virtual void(void) Init;
	virtual void(void) Initialized;
	
	/* Handle entity key/value pairs on init */
	virtual void(string, string) SpawnKey;

#ifdef SERVER
	/* Input/Output System */
	string m_strOnTrigger;
	string m_strOnUser1;
	string m_strOnUser2;
	string m_strOnUser3;
	string m_strOnUser4;

	/* helper functions to allocate outputs */
	nonvirtual void(entity, string) UseOutput;
	nonvirtual string(string) CreateOutput;

	/* whenever gamerules want entities to respawn */
	virtual void(void) Respawn;

	virtual void(float) Save;
	virtual void(float) Restore;

	/* Handle incoming entities input messaging */
	virtual void(entity, string, string) Input;
#endif
};