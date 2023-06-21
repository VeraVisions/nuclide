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

void
NSSquadMonster::NSSquadMonster(void)
{
#ifdef SERVER
	m_inSquad = false;
	m_eSquadLeader = __NULL__;
	m_bStartAsLeader = false;

	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		m_eSquadMembers[i] = __NULL__;
	}
#endif
}

#ifdef SERVER
void
NSSquadMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "squad_leader":
		m_bStartAsLeader = ReadBool(strValue);
		break;
	case "squad_leader_body":
		m_iSquadLeaderBody = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
NSSquadMonster::Spawned(void)
{
	static void AttachToNearBySquad(void) {
		FindSquadNearMe(1024);
	}

	super::Spawned();

	/* unless specified manually, make up who becomes squad member */
	if (m_bStartAsLeader) {
		m_eSquadLeader = this;
		m_inSquad = true;
	} else {
		ScheduleThink(AttachToNearBySquad, 0.5f);
	}
}

void
NSSquadMonster::HasBecomeSquadLeader(void)
{
	/* implemented by sub-class */
}

void
NSSquadMonster::HasJoinedSquad(void)
{
	/* implemented by sub-class */
}

bool
NSSquadMonster::InSquad(void)
{
	return m_inSquad;
}

bool
NSSquadMonster::IsSquadLeader(void)
{
	if (m_eSquadLeader == this)
		return true;

	return false;
}

NSSquadMonster
NSSquadMonster::GetSquadLeader(void)
{
	return m_eSquadLeader;
}

void
NSSquadMonster::FindSquadNearMe(float searchRadius)
{
	entity searchResult = findradius(GetOrigin(), searchRadius);

	while (searchResult) {
		/* found someone just like us */
		if (searchResult != this)
		if (searchResult.classname == classname) {
			NSSquadMonster squadMember = (NSSquadMonster)searchResult;

			/* we found someone, they may not be in a squad (that's ok!) 
			   as they will then create one. */
			squadMember.AddToSquad(this);
			return;
		}

		/* advance the chain. */
		searchResult = searchResult.chain;
	}
}

void
NSSquadMonster::AddToSquad(NSSquadMonster addMember)
{
	NSSquadMonster startMember = __NULL__;

	if (!addMember)
		return;

	/* no start? this monster just became a squad leader */
	if (InSquad() == false) {
		m_eSquadLeader = this;
		startMember = this;
		m_inSquad = true;
		print(sprintf("%s (%d) became squad leader\n", classname, num_for_edict(this)));
		SetBody(GetBody() | m_iSquadLeaderBody);
		HasBecomeSquadLeader();
	}

	startMember = GetSquadLeader();

	/* fit the member into the nearest slot */
	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		if (startMember.m_eSquadMembers[i] == __NULL__) {
			startMember.m_eSquadMembers[i] = addMember;
			addMember.m_eSquadLeader = startMember;
			addMember.m_inSquad = true;
			addMember.HasJoinedSquad();
			print(sprintf("%s (%d) added to squad, member %i\n", classname, num_for_edict(this), i));
			return;
		}
	}
}

void
NSSquadMonster::RemoveFromSquad(NSSquadMonster toRemove)
{
	NSSquadMonster startMember = __NULL__;

	/* don't bother if not in squad. */
	if (InSquad() == false)
		return;
	if (!toRemove)
		return;

	startMember = GetSquadLeader();

	/* fit the member into the nearest slot */
	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		if (startMember.m_eSquadMembers[i] == toRemove) {
			startMember.m_eSquadMembers[i] = __NULL__;
			toRemove.m_eSquadLeader = __NULL__;
			toRemove.m_inSquad = false;
			return;
		}
	}
}

NSSquadMonster
NSSquadMonster::GetNearestSquadMember(void)
{
	NSSquadMonster member = __NULL__;
	NSSquadMonster nearestMember = __NULL__;
	float dist = 0.0f;
	float nearestDist = 99999.0f;
	NSSquadMonster startMember;

	if (InSquad() == false)
		return __NULL__;

	/* only leaders have the member list */
	startMember = GetSquadLeader();

	/* iterate through members... */
	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		member = startMember.m_eSquadMembers[i];

		/* don't recognize self, ever */
		if (member == __NULL__ || member == this)
			continue;

		/* check the distance from us to a valid member */
		member = startMember.m_eSquadMembers[i];
		dist = vlen(member.GetOrigin() - GetOrigin());

		/* found one */
		if (dist < nearestDist) {
			nearestDist = dist;
			nearestMember = member;
		}
	}

	return nearestMember;
}

NSSquadMonster
NSSquadMonster::GetFarthestSquadMember(void)
{
	NSSquadMonster member = __NULL__;
	NSSquadMonster farthestMember = __NULL__;
	float dist = 0.0f;
	float farthestDist = 0.0f;
	NSSquadMonster startMember;

	if (InSquad() == false)
		return __NULL__;

	/* only leaders have the member list */
	startMember = GetSquadLeader();

	/* iterate through members... */
	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		member = startMember.m_eSquadMembers[i];

		/* don't recognize self, ever */
		if (member == __NULL__ || member == this)
			continue;

		/* check the distance from us to a valid member */
		member = startMember.m_eSquadMembers[i];
		dist = vlen(member.GetOrigin() - GetOrigin());

		/* found one */
		if (dist > farthestDist) {
			farthestDist = dist;
			farthestMember = member;
		}
	}

	return farthestMember;
}

#endif