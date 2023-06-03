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

#define NSSQUADMONSTER_MAXMEMBERS 5

/** NSSquadMonster based NPCs are able to communicate strategies together. */
class
NSSquadMonster:NSMonster
{
public:
	void NSSquadMonster(void);

#ifdef SERVER
	/** Overridable: Called when this NPC became squad leader. */
	virtual void HasBecomeSquadLeader(void);
	/** Overridable: Called when this NPC joined a squad. */
	virtual void HasJoinedSquad(void);

	/** Returns true/false if they're in a squad. */
	nonvirtual bool InSquad(void);
	/** Returns whether or not they're the squad leader. */
	nonvirtual bool IsSquadLeader(void);
	/** Returns the leader of their squad. Invalid if none. */
	nonvirtual NSSquadMonster GetSquadLeader(void);

	/** Will find and attach to a Squad in the specified radius. */
	nonvirtual void FindSquadNearMe(float);

	/** Will add the specified NPC to this entity's current squad. */
	nonvirtual void AddToSquad(NSSquadMonster);
	/** Will remove the specified NPC from this entity's current squad. Can be called on self. */
	nonvirtual void RemoveFromSquad(NSSquadMonster);
	/** Returns the nearest available member of its squad. */
	nonvirtual NSSquadMonster GetNearestSquadMember(void);
	/** Returns the farthest available member of its squad. */
	nonvirtual NSSquadMonster GetFarthestSquadMember(void);
#endif

#ifdef SERVER
private:
	bool m_inSquad;
	NSSquadMonster m_eSquadLeader;

	/* stored only in the squad leader's memory */
	NSSquadMonster m_eSquadMembers[NSSQUADMONSTER_MAXMEMBERS];
#endif
};