void
ncDispenser::ncDispenser(void)
{
#ifdef SERVER
	m_nextDispenseTime = 0.0f;
#endif
}

#ifdef CLIENT
void
ncDispenser::ReceiveEntity(float flNew, float flChanged)
{
	ncRenderableEntity::ReceiveEntity(flNew, flChanged);
}
#endif

#ifdef SERVER
float
ncDispenser::SendEntity(entity pvsEnt, float flChanged)
{
	return ncRenderableEntity:: SendEntity(pvsEnt, flChanged);
}
void
ncDispenser::EvaluateEntity(void)
{
	ncRenderableEntity::EvaluateEntity();
}

void
ncDispenser::Touch(entity touchingEntity)
{
	if (m_nextDispenseTime > time) {
		return;
	}

	if (ItemBonusCheck(touchingEntity) == true) {
		GiveBonusItems(touchingEntity);
		UseTargets(touchingEntity, TRIG_TOGGLE, GetTriggerDelay());
	} 

	if (m_dispenseDelay > 0.0f) {
		m_nextDispenseTime = GetTime() + m_dispenseDelay;
	} else {
		m_nextDispenseTime = GetTime() + 1.0f;
	}
}

void
ncDispenser::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetModel(GetSpawnString("model"));
	SetOrigin(GetSpawnVector("origin"));
	SetAngles(GetSpawnVector("angles"));
	SetSize(GetSpawnVector("mins"), GetSpawnVector("maxs"));
	m_dispenseDelay = GetSpawnFloat("delay");
}
#endif