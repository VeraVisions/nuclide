#ifdef CLIENT
void
NSDebris::NSDebris(void)
{
	m_strImpactDecal = __NULL__;
}

void
NSDebris::Touch(entity touchingEnt)
{
	if (m_strImpactDecal)
		DecalGroups_Place(m_strImpactDecal, origin);
}

void
NSDebris::SetImpactDecal(string impactDecal)
{
	m_strImpactDecal = impactDecal;
}
#endif