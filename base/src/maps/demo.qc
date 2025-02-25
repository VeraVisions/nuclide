#pragma PROGS_DAT  "../../maps/demo.dat"

#include "../../../src/server/api.h"

void
CSEv_TriggerTarget_s(string toTrigger)
{
	for (entity e = world; (e = find(e, ::targetname, "laser1"));) {
		ents.Input(e, "Trigger", "", e);
	}
}
