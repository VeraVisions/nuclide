var float g_portalSpawnBlue;
var float g_portalSpawnRed;
var float g_portalFizzleBlue;
var float g_portalFizzleRed;

class
prop_portal:ncPortal
{
public:
	void prop_portal(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	nonvirtual void DiscoverPortal(void);

	virtual void PortalWasClosed(void);
	virtual void PortalWasOpened(void);

private:
	bool m_bStartActive;
	bool m_bPortalTwo; /* orange when true */

#ifdef PORTAL2
	float m_flHalfWidth;
	float m_flHalfHeight;
#endif

	int m_iPortalID;
};

void
prop_portal::prop_portal(void)
{
	m_bStartActive = false;
	m_bPortalTwo = false;

#ifdef PORTAL2
	m_flHalfWidth = 0.0f;
	m_flHalfHeight = 0.0f;
#endif

	m_iPortalID = 0i;
	g_portalSpawnBlue = particleeffectnum("portal.te_portalspawn_blue");
	g_portalSpawnRed = particleeffectnum("portal.te_portalspawn_red");
	g_portalFizzleBlue = particleeffectnum("portal.te_portalfizzle_blue");
	g_portalFizzleRed = particleeffectnum("portal.te_portalfizzle_red");
}

void
prop_portal::PortalWasOpened(void)
{
	if (m_bPortalTwo == false)
		pointparticles(g_portalSpawnBlue, trace_endpos, trace_plane_normal, 1);
	else
		pointparticles(g_portalSpawnRed, trace_endpos, trace_plane_normal, 1);
}

void
prop_portal::PortalWasClosed(void)
{
	if (m_bPortalTwo == false)
		pointparticles(g_portalFizzleBlue, trace_endpos, trace_plane_normal, 1);
	else
		pointparticles(g_portalFizzleRed, trace_endpos, trace_plane_normal, 1);
}

void
prop_portal::Respawn(void)
{
#ifdef PORTAL2
	if (m_flHalfWidth <= 0)
		m_flHalfWidth = 32.0f;
	if (m_flHalfHeight <= 0)
		m_flHalfHeight = 54.0f;
#endif
	super::Respawn();

	SetOrigin(GetOrigin() + anglesToForward(GetAngles()) * 1.0f);
	SetPortalID(m_iPortalID);
	ScheduleThink(DiscoverPortal, 0.5f);

	if (m_bPortalTwo) {
		SetPortalModel("models/r_portal.bsp");
	} else {
		SetPortalModel("models/b_portal.bsp");
	}
}

void
prop_portal::DiscoverPortal(void)
{
	PortalAutoLink(m_bStartActive);
}

void
prop_portal::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "Activated":
		m_bStartActive = ReadBool(setValue);
		break;
	case "PortalTwo":
		m_bPortalTwo = ReadBool(setValue);
		break;
#ifdef PORTAL2
	case "HalfWidth":
		m_flHalfWidth = ReadFloat(setValue);
		break;
	case "HalfHeight":
		m_flHalfHeight = ReadFloat(setValue);
		break;
#endif
	case "LinkageGroupID":
		m_iPortalID = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
prop_portal::Input(entity activatorEnt, string strInput, string strData)
{
	switch (strInput) {
	case "SetName":
		targetname = strData;
		break;
	case "SetActivatedState":
		m_portalEnabled = ReadBool(strData);
		_PortalUpdated();

		if (m_ePortalTarget)
 {
			m_ePortalTarget._PortalUpdated();
		}
		break;
	case "Fizzle":
		m_portalEnabled = false;
		_PortalUpdated();

		if (m_ePortalTarget)
 {
			m_ePortalTarget._PortalUpdated();
		}
		break;
	case "NewLocation":
		vector newOrg, newAngles;
		int c = tokenize(strData);

		newOrg[0] = stof(argv(0));
		newOrg[1] = stof(argv(1));
		newOrg[2] = stof(argv(2));

		newAngles[0] = stof(argv(3));
		newAngles[1] = stof(argv(4));
		newAngles[2] = stof(argv(5));

		SetOrigin(newOrg);
		SetAngles(newAngles);
		break;
#ifdef PORTAL2
	case "Resize":
		break;
	case "SetLinkageGroupID":
		break;
#endif
	default:
		super::Input(activatorEnt, strInput, strData);
	}
}


bool
prop_portal_remove(entity portalOwner)
{
	bool hasDeleted = false;

	for ( entity e = world; ( e = find( e, ::classname, "prop_portal" ) ); ) {
		prop_portal portalFind = (prop_portal)e;

		/* it's one of the portalgun portals */
		if (portalFind.m_iPortalValue == 0i) {
			portalFind.PortalClose();
			portalFind.classname = "";
			portalFind.Destroy();
			hasDeleted = true;
		}
	}

	return hasDeleted;
}

void
prop_portal_spawn(vector endPos, vector vecAngle, entity portalOwner, bool altPortal)
{
	prop_portal newest = (prop_portal)world;

	for (prop_portal e = __NULL__; (e = (prop_portal)findfloat(e, ::isPortal, true));) {
		/* it's one of the portalgun portals */
		if (e.m_iPortalValue == 0i) {
			/* we're trying to fire an alt-portal, and we have one - so... */
			if (altPortal == true && e.m_bPortalTwo == true) {
				e.PortalClose();
				e.classname = "";
				e.Destroy();
			} else if (altPortal == false && e.m_bPortalTwo == false) {
				e.PortalClose();
				e.classname = "";
				e.Destroy();
			}
		}
	}

	prop_portal new_portal = spawn(prop_portal);
	new_portal.Spawn();
	new_portal.SetOrigin(endPos);
	new_portal.SetAngles(vecAngle);
	new_portal.SetPortalID(0i);

	if (altPortal) {
		new_portal.SetPortalModel("models/r_portal.bsp");
		new_portal.m_bPortalTwo = true;
	} else {
		new_portal.SetPortalModel("models/b_portal.bsp");
		new_portal.m_bPortalTwo = false;
	}

	new_portal.ReleaseThink();

	/* link against existing portals */
	for (prop_portal e = __NULL__; (e = (prop_portal)findfloat(e, ::isPortal, true));) {
		/* it's one of our own */
		if (e.m_iPortalValue == 0i) {
			if (altPortal == true && e.m_bPortalTwo == false)
				newest = e;
			else if (altPortal == false && e.m_bPortalTwo == true)
				newest = e;
		}
	}

	if (newest)
		new_portal.PortalLinkTo(newest, true);
}
