void
ncCapturePoint::ncCapturePoint(void)
{

}

void
ncCapturePoint::Captured(string classTarget, float teamNum)
{
	for (ncCaptureItem e = world; ((e = (ncCaptureItem)find(e, ::classname, classTarget)));) {
		if (e.m_goalNo == teamNum) {
			e.Respawn();
			e.Show();
		}
	}
}

void
ncCapturePoint::Respawn(void)
{
	super::Respawn();

	m_desiredItem = GetSpawnString("needs");
	m_playerScore = GetSpawnInt("playerScore");
	m_teamScore = GetSpawnInt("teamScore");
	m_goalNo = GetSpawnFloat("goal_no");

	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetSize(GetSpawnVector("goal_min"), GetSpawnVector("goal_max"));

	if (GetSpawnBool("dropToFloor") == true) {
		DropToFloor();
	}
}

void
ncCapturePoint::Touch(entity touchingEntity)
{
	ncActor ourToucher = (ncActor)touchingEntity;

	if (is.Player(touchingEntity) == false) {
		return;
	}

	if (ourToucher.team != m_goalNo) {
		return;
	}

	ncItem theItem = ourToucher.GetItem(m_desiredItem);

	if (theItem) {
		if (m_teamScore >= 1i) {
			teams.AddScore(touchingEntity.team, m_teamScore);
		}

		if (m_playerScore >= 1i) {
			ourToucher.frags += (float)m_playerScore;
		}

		Captured(theItem.target, theItem.team);
		ourToucher.RemoveItem(m_desiredItem);
	}
}
