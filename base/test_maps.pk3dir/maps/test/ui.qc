#pragma PROGS_DAT  "ui.dat"

#include "../../../../src/server/api.h"

void
CSEv_TriggerTarget_s(string toTrigger)
{
	entity findMe = find(world, ::targetname, toTrigger);

	if (findMe) {
		sendInput(findMe, "Trigger", "", self);
	}
}
