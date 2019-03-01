/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define MM_MULTITHREADED 1

class multi_manager : CBaseTrigger
{
	CBaseTrigger m_eTriggers[16];
	string m_strBuffer;
	int m_iBusy;
	virtual void() Trigger;
};

void multi_manager :: Trigger (void)
{
	static void mm_enttrigger (void) {
		CBaseTrigger wow = (CBaseTrigger) self;
		wow.m_strTarget = wow.netname;
		
		entity eFind = find(world, CBaseTrigger::m_strTargetName, self.netname);

#ifdef GS_DEVELOPER
		print(sprintf("multi_manager: %s (%s)\n", wow.m_strTarget, eFind.classname));
#endif

		CBaseTrigger::UseTargets();
	}
	
	/* If not multi-threaded, we have to watch out 'til all triggers are done. */
	if (!(spawnflags & MM_MULTITHREADED)) {
		for (int i = 0; i < 16; i++) {
			if (m_eTriggers[i].nextthink > time) {
				return;
			}
		}
	}

	int iFields = tokenizebyseparator(m_strBuffer, " ");
	int b = 0;
	for (int i = 0; i < iFields; i+=2) {

		if (b >= 16) {
			break;
		}

		// HACK: Avoid infinite loops
		if (m_strTargetName != argv(i)) {
			entity eTemp = m_eTriggers[b];
			eTemp.netname = argv(i);
			eTemp.think = mm_enttrigger;
			eTemp.nextthink = time + stof(argv(i + 1));
			b++;
		}
	}
}

void multi_manager :: multi_manager (void)
{
	m_strBuffer = "";
	int iFields = tokenize(__fullspawndata);
	for (int i = 1; i < (iFields - 1); i += 2) {
		// Sigh, let's attempt to sanitize this
		switch (argv(i)) {
		case "{":
		case "}":
		case "classname":
		case "origin":
		case "targetname":
		case "spawnflags":
			continue;
			break;
		default:
			if (substring(argv(i), strlen(argv(i)) - 3,  1) == "#") {
				m_strBuffer = sprintf("%s%s %s ", m_strBuffer, substring(argv(i), 0, strlen(argv(i)) - 3), argv(i + 1));
			} else if (substring(argv(i), strlen(argv(i)) - 2,  1) == "#") {
				m_strBuffer = sprintf("%s%s %s ", m_strBuffer, substring(argv(i), 0, strlen(argv(i)) - 2), argv(i + 1));
			} else {
				m_strBuffer = sprintf("%s%s %s ", m_strBuffer, argv(i), argv(i + 1));
			}
		}
	}
	
	for (int b = 0; b < 16; b++) {
		m_eTriggers[b] = spawn(CBaseTrigger);
	}

	CBaseTrigger::CBaseTrigger();
}
