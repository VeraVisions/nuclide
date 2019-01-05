/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class func_hostage_rescue
{
	void() func_hostage_rescue;
	virtual void() touch;
};

void func_hostage_rescue::touch(void)
{
	if ((other.classname == "player" ) && ( other.team == TEAM_CT )) {
		/* This will be cleared every frame inside SV_RunClientCommand */
		other.fInHostageZone = TRUE; 
	} else if (other.classname == "hostage_entity") {
		hostage_entity hosty = (hostage_entity)other;
		if (solid == SOLID_NOT) {
			return;
		}

		Radio_BroadcastMessage(RADIO_RESCUED);
		iHostagesRescued++;

		Money_AddMoney(hosty.m_eUser, 1000);
		Money_QueTeamReward(TEAM_CT, 800);

		CBaseEntity targa = (CBaseEntity)other;
		targa.Hide();

		if (iHostagesRescued >= iHostagesMax) {
			// TODO: Broadcast_Print: All Hostages have been rescued!
			Rules_RoundOver(TEAM_CT, 0, FALSE);
		}
	}
}

void func_hostage_rescue::func_hostage_rescue( void )
{
	angles = '0 0 0';
	movetype = MOVETYPE_NONE;
	solid = SOLID_TRIGGER;

	if (model) {
		setmodel(this, model);
	} else {
		mins = '-128 -128 -36';
		maxs = '128 128 36';
		setsize(this, mins, maxs);
	}
	model = 0;

	iRescueZones++;
}
