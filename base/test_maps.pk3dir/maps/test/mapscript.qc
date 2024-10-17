#pragma PROGS_DAT  "mapscript.dat"

#include "../../../src/server/api.h"

void main()
{
	entity radio = spawnClass("info_player_start", [0, 0, 128]);
	radio.angles = [0, random(-180, 180), 0];
	radio.targetname = "SPSpawn";

	radio = spawnClass("info_player_deathmatch", [0, 0, 128]);
	radio.angles = [0, random(-180, 180), 0];
	radio.targetname = "MPSpawn";
}

void CSEv_TriggerTarget_s(string toTrigger)
{
	
}