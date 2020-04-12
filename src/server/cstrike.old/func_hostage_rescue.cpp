/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

class func_hostage_rescue
{
	void(void) func_hostage_rescue;
	virtual void(void) touch;
};

void func_hostage_rescue::touch(void)
{
	if ((other.classname == "player") && (other.team == TEAM_CT)) {
		/* This will be cleared every frame inside SV_RunClientCommand */
		other.fInHostageZone = TRUE; 
	} else if (other.classname == "hostage_entity") {
		hostage_entity hosty = (hostage_entity)other;

		if (solid == SOLID_NOT) {
			return;
		}

		Radio_BroadcastMessage(RADIO_RESCUED);
		iHostagesRescued++;

		Money_AddMoney(hosty.m_eRescuer, 1000);
		
		/* In Hostage Rescue, all Counter-Terrorists receive an $850
		 * bonus for every hostage they rescue, even if they lose the round. */
		Money_QueTeamReward(TEAM_CT, 850);

		CBaseEntity targa = (CBaseEntity)other;
		targa.Hide();

		if (iHostagesRescued >= iHostagesMax) {
			// TODO: Broadcast_Print: All Hostages have been rescued!
			Rules_RoundOver(TEAM_CT, 0, FALSE);
			iHostagesRescued = 0;
		}
	}
}

void func_hostage_rescue::func_hostage_rescue(void)
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
