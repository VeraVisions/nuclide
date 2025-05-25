void
ncCaptureItem::ncCaptureItem(void)
{
	m_outputOnCapture = __NULL__;
	m_outputOnTake = __NULL__;
	m_outputOnReturn = __NULL__;
}

void
ncCaptureItem::Precache(void)
{
	if (STRING_SET(m_outputOnCapture))
		m_outputOnCapture = CreateOutput(m_outputOnCapture);
	if (STRING_SET(m_outputOnTake))
		m_outputOnTake = CreateOutput(m_outputOnTake);
	if (STRING_SET(m_outputOnReturn))
		m_outputOnReturn = CreateOutput(m_outputOnReturn);
}

void
ncCaptureItem::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "OnCapture":
		m_outputOnCapture = PrepareOutput(m_outputOnCapture, strValue);
		break;
	case "OnTake":
		m_outputOnTake = PrepareOutput(m_outputOnTake, strValue);
		break;
	case "OnReturn":
		m_outputOnReturn = PrepareOutput(m_outputOnReturn, strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
ncCaptureItem::Respawn(void)
{
	super::Respawn();

	m_desiredItem = GetSpawnString("needs");
	m_goalItem = GetSpawnString("goalItem");
	m_requiresItem = GetSpawnString("needs");
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
ncCaptureItem::Captured(float teamNum)
{
	for (ncCaptureItem e = __NULL__; ((e = (ncCaptureItem)find(e, ::spawnclass, spawnclass)));) {
		if (e.m_goalNo == teamNum) {
			e.Respawn();
			e.Show();
		}
	}
}

void
ncCaptureItem::Return(void)
{
	Respawn();
	UseOutput(this, m_outputOnReturn);
}

void
ncCaptureItem::WatchPlayer(void)
{
	if (m_watchPlayer.health <= 0) {
		ncItem dropFlag = (ncItem)spawnClass(m_goalItem, m_watchPlayer.GetOrigin());
		m_watchPlayer = __NULL__;
		dropFlag.ScheduleThink(Destroy, 30.0f);
		dropFlag.SetMovetype(MOVETYPE_TOSS);
		dropFlag.AddVelocity([0,0, 200]);
		dropFlag.target = classname;
		dropFlag.team = m_goalNo;
		ScheduleThink(Return, 30.0f);
	}

	/* continue */
	if (m_watchPlayer) {
		ScheduleThink(WatchPlayer, 0.0f);
	}
}

void
ncCaptureItem::Touch(entity touchingEntity)
{
	ncActor ourToucher = (ncActor)touchingEntity;
	ncItem theItem = __NULL__;

	if (is.Player(touchingEntity) == false) {
		return;
	}

	if (ourToucher.team != m_goalNo) {
		ourToucher.GiveItem(m_goalItem);
		theItem = ourToucher.GetItem(m_goalItem);
		theItem.team = m_goalNo;
		theItem.target = classname;
		Disappear();
		UseOutput(touchingEntity, m_outputOnTake);

		m_watchPlayer = (ncPlayer)ourToucher;
		ScheduleThink(WatchPlayer, 0.0f);
	} else if (STRING_SET(m_desiredItem)) {
		theItem = ourToucher.GetItem(m_desiredItem);

		if (theItem) {
			if (m_teamScore >= 1i) {
				teams.AddScore(touchingEntity.team, m_teamScore);
			}

			if (m_playerScore >= 1i) {
				ourToucher.frags += (float)m_playerScore;
			}

			Captured(theItem.team);
			UseOutput(touchingEntity, m_outputOnCapture);
			ourToucher.RemoveItem(m_desiredItem);
		}
	}
}
