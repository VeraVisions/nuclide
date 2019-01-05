/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class func_vip_safetyzone
{
	void() func_vip_safetyzone;
	virtual void() touch;
};

/* Hack! Make this better? */
void VIP_Rescue(entity targ)
{
	entity eOld = self;
	self = other;
	Spawn_MakeSpectator();
	self.classname = "player";
	self.team = TEAM_CT;
	forceinfokey(self, "*dead", "0");
	iAlivePlayers_CT--;
	self = eOld;
}

void func_vip_safetyzone::touch(void)
{
	if (other.classname == "player") {
		if (other.team == TEAM_VIP) {
			Rules_RoundOver(TEAM_CT, 2500, FALSE);
			VIP_Rescue(other);
		}
		other.fInVIPZone = TRUE;
	}
}

void func_vip_safetyzone::func_vip_safetyzone(void)
{
	angles = '0 0 0';
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if (model) {
		setmodel(this, model);
	} else {
		setsize(this, mins, maxs);
	}

	model = 0;
	iVIPZones++;
}
