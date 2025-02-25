/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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
ncSquadMonster::ncSquadMonster(void)
{
#ifdef SERVER
	m_inSquad = false;
	m_eSquadLeader = __NULL__;
	m_bStartAsLeader = false;

	for (int i = 0; i < NSSQUADMONSTER_MAXMEMBERS; i++) {
		m_eSquadMembers[i] = __NULL__;
	}

	m_strSquadLeaderBody = 0;
#endif
}

#ifdef SERVER
void
ncSquadMonster::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "squad_leader":
		m_bStartAsLeader = ReadBool(strValue);
		break;
	case "squad_leader_body":
		m_strSquadLeaderBody = ReadString(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
ncSquadMonster::Save(float handle)
{
	super::Save(handle);

	SaveString(handle, "m_strSquadLeaderBody", m_strSquadLeaderBody);
	SaveBool(handle, "m_bStartAsLeader", m_bStartAsLeader);
	SaveBool(handle, "m_inSquad", m_inSquad);
	SaveEntity(handle, "m_eSquadLeader", m_eSquadLeader);
	SaveEntity(handle, "m_eSquadMembers0", m_eSquadMembers[0]);
	SaveEntity(handle, "m_eSquadMembers1", m_eSquadMembers[1]);
	SaveEntity(handle, "m_eSquadMembers2", m_eSquadMembers[2]);
	SaveEntity(handle, "m_eSquadMembers3", m_eSquadMembers[3]);
	SaveEntity(handle, "m_eSquadMembers4", m_eSquadMembers[4]);
}

void
ncSquadMonster::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSquadLeaderBody":
		m_strSquadLeaderBody = ReadString(strValue);
		break;
	case "m_bStartAsLeader":
		m_bStartAsLeader = ReadBool(strValue);
		break;
	case "m_inSquad":
		m_inSquad = ReadBool(strValue);
		break;
	case "m_eSquadLeader":
		m_eSquadLeader = (ncSquadMonster)ReadEntity(strValue);
		break;
	case "m_eSquadMembers0":
		m_eSquadMembers[0] = (ncSquadMonster)ReadEntity(strValue);
		break;
	case "m_eSquadMembers1":
		m_eSquadMembers[1] = (ncSquadMonster)ReadEntity(strValue);
		break;
	case "m_eSquadMembers2":
		m_eSquadMembers[2] = (ncSquadMonster)ReadEntity(strValue);
		break;
	case "m_eSquadMembers3":
		m_eSquadMembers[3] = (ncSquadMonster)ReadEntity(strValue);
		break;
	case "m_eSquadMembers4":
		m_eSquadMembers[4] = (ncSquadMonster)ReadEntity(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
		break;
	}
}

void
ncSquadMonster::Spawned(void)
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
ncSquadMonster::HasBecomeSquadLeader(void)
{
	/* implemented by sub-class */
}

void
ncSquadMonster::HasJoinedSquad(void)
{
	/* implemented by sub-class */
}

bool
ncSquadMonster::InSquad(void)
{
	return m_inSquad;
}

bool
ncSquadMonster::IsSquadLeader(void)
{
	if (m_eSquadLeader == this)
		return true;

	return false;
}

ncSquadMonster
ncSquadMonster::GetSquadLeader(void)
{
	return m_eSquadLeader;
}

void
ncSquadMonster::FindSquadNearMe(float searchRadius)
{
	entity searchResult = findradius(GetOrigin(), searchRadius);

	while (searchResult) {
		/* found someone just like us */
		if (searchResult != this)
		if (searchResult.classname == classname) {
			ncSquadMonster squadMember = (ncSquadMonster)searchResult;

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
ncSquadMonster::AddToSquad(ncSquadMonster addMember)
{
	ncSquadMonster startMember = __NULL__;

	if (!addMember)
		return;

	/* no start? this monster just became a squad leader */
	if (InSquad() == false) {
		m_eSquadLeader = this;
		startMember = this;
		m_inSquad = true;
		ncMonsterLog("%s (%d) became squad leader\n", classname, num_for_edict(this));
		//SetBody(GetBody() | m_iSquadLeaderBody);

		/* apply the squad leader body */
		{
			int t = tokenizebyseparator(m_strSquadLeaderBody, ":");

			if (t == 1) {
				SetBodyInGroup(0, stoi(argv(0)));
			} else if (t == 2) {
				SetBodyInGroup(stoi(argv(0)), stoi(argv(1)));
			}
		}

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
			ncMonsterLog("%s (%d) added to squad, member %i\n", classname, num_for_edict(this), i);
			return;
		}
	}
}

void
ncSquadMonster::RemoveFromSquad(ncSquadMonster toRemove)
{
	ncSquadMonster startMember = __NULL__;

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

ncSquadMonster
ncSquadMonster::GetNearestSquadMember(void)
{
	ncSquadMonster member = __NULL__;
	ncSquadMonster nearestMember = __NULL__;
	float dist = 0.0f;
	float nearestDist = 99999.0f;
	ncSquadMonster startMember;

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

ncSquadMonster
ncSquadMonster::GetFarthestSquadMember(void)
{
	ncSquadMonster member = __NULL__;
	ncSquadMonster farthestMember = __NULL__;
	float dist = 0.0f;
	float farthestDist = 0.0f;
	ncSquadMonster startMember;

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
