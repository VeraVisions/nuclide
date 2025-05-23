/*
 * Copyright (c) 2024-2025 Vera Visions LLC.
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

class
team_control_point:ncPointTrigger
{
public:
	void team_control_point(void);
	virtual void Spawned(void);
	virtual void SpawnKey(string,string);
	virtual void Input(entity,string,string);

private:
	bool m_pointStartsLocked;
	string m_pointLocalizedName;
	int m_pointGroupIndex;
	int m_pointOwnerTeam;
	int m_pointUID;
	int m_pointWarningType;
	string m_sndPointWarning;
	bool m_pointRandomOwner;
	float m_pointTimedPoints1;
	float m_pointTimedPoints2;
	string m_sndPointReset;
	string m_sndPointCapTeam1;
	string m_sndPointCapTeam2;
	int m_pointDefaultBody;
	string m_iconNeutral;
	string m_iconTeam1;
	string m_iconTeam2;
	int m_pointDefaultBodyTeam1;
	int m_pointDefaultBodyTeam2;
	string m_overlayNeutral;
	string m_overlayTeam1;
	string m_overlayTeam2;
	string m_pointPreviousTeam1A;
	string m_pointPreviousTeam1B;
	string m_pointPreviousTeam1C;
	string m_pointPreviousTeam2A;
	string m_pointPreviousTeam2B;
	string m_pointPreviousTeam2C;

	string m_outputOnOwnerChangedToTeam1;
	string m_outputOnOwnerChangedToTeam2;
	string m_outputOnCapReset;
	string m_outputOnRoundStartOwnedByTeam1;
	string m_outputOnRoundStartOwnedByTeam2;
	string m_outputOnCapTeam1;
	string m_outputOnCapTeam2;
	string m_outputOnUnlocked;
};

void
team_control_point::team_control_point(void)
{
	m_pointStartsLocked = false;
	m_pointLocalizedName = __NULL__;
	m_pointGroupIndex = 0i;
	m_pointOwnerTeam = 0i;
	m_pointUID = 0i;
	m_pointWarningType = 0i;
	m_sndPointWarning = __NULL__;
	m_pointRandomOwner = false;
	m_pointTimedPoints1 = 0.0f;
	m_pointTimedPoints2 = 0.0f;
	m_sndPointReset = __NULL__;
	m_sndPointCapTeam1 = __NULL__;
	m_sndPointCapTeam2 = __NULL__;
	m_pointDefaultBody = 0i;
	m_iconNeutral = __NULL__;
	m_iconTeam1 = __NULL__;
	m_iconTeam2 = __NULL__;
	m_pointDefaultBodyTeam1 = 0i;
	m_pointDefaultBodyTeam2 = 0i;
	m_overlayNeutral = __NULL__;
	m_overlayTeam1 = __NULL__;
	m_overlayTeam2 = __NULL__;
	m_pointPreviousTeam1A = __NULL__;
	m_pointPreviousTeam1B = __NULL__;
	m_pointPreviousTeam1C = __NULL__;
	m_pointPreviousTeam2A = __NULL__;
	m_pointPreviousTeam2B = __NULL__;
	m_pointPreviousTeam2C = __NULL__;

	m_outputOnOwnerChangedToTeam1 = __NULL__;
	m_outputOnOwnerChangedToTeam2 = __NULL__;
	m_outputOnCapReset = __NULL__;
	m_outputOnRoundStartOwnedByTeam1 = __NULL__;
	m_outputOnRoundStartOwnedByTeam2 = __NULL__;
	m_outputOnCapTeam1 = __NULL__;
	m_outputOnCapTeam2 = __NULL__;
	m_outputOnUnlocked = __NULL__;
}


void
team_control_point::Spawned(void)
{
	super::Spawned();

	/* input/output */
	if (STRING_SET(m_outputOnOwnerChangedToTeam1))
		m_outputOnOwnerChangedToTeam1 = CreateOutput(m_outputOnOwnerChangedToTeam1);
	if (STRING_SET(m_outputOnOwnerChangedToTeam2))
		m_outputOnOwnerChangedToTeam2 = CreateOutput(m_outputOnOwnerChangedToTeam2);
	if (STRING_SET(m_outputOnCapReset))
		m_outputOnCapReset = CreateOutput(m_outputOnCapReset);
	if (STRING_SET(m_outputOnRoundStartOwnedByTeam1))
		m_outputOnRoundStartOwnedByTeam1 = CreateOutput(m_outputOnRoundStartOwnedByTeam1);
	if (STRING_SET(m_outputOnRoundStartOwnedByTeam2))
		m_outputOnRoundStartOwnedByTeam2 = CreateOutput(m_outputOnRoundStartOwnedByTeam2);
	if (STRING_SET(m_outputOnCapTeam1))
		m_outputOnCapTeam1 = CreateOutput(m_outputOnCapTeam1);
	if (STRING_SET(m_outputOnCapTeam2))
		m_outputOnCapTeam2 = CreateOutput(m_outputOnCapTeam2);
	if (STRING_SET(m_outputOnUnlocked))
		m_outputOnUnlocked = CreateOutput(m_outputOnUnlocked);
}

void
team_control_point::Input(entity activatingEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "SetOwner":
		break;
	case "HideModel":
		break;
	case "ShowModel":
		break;
	case "SetLocked":
		break;
	case "SetUnlockTime":
		break;
	case "RoundActivate":
		break;
	default:
		super::Input(activatingEntity, inputName, dataField);
	}
}

void
team_control_point::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "point_start_locked":
		m_pointStartsLocked = ReadBool(setValue);
		break;
	case "point_printname":
		m_pointLocalizedName = ReadString(setValue);
		break;
	case "point_group":
		m_pointGroupIndex = ReadInt(setValue);
		break;
	case "point_default_owner":
		m_pointOwnerTeam = ReadInt(setValue);
		break;
	case "point_index":
		m_pointUID = ReadInt(setValue);
		break;
	case "point_warn_on_cap":
		m_pointWarningType = ReadInt(setValue);
		break;
	case "point_warn_sound":
		m_sndPointWarning = ReadString(setValue);
		break;
	case "random_owner_on_restart":
		m_pointRandomOwner = ReadBool(setValue);
		break;
	case "team_timedpoints_2":
		m_pointTimedPoints1 = ReadFloat(setValue);
		break;
	case "team_timedpoints_3":
		m_pointTimedPoints2 = ReadFloat(setValue);
		break;
	case "team_capsound_0":
		m_sndPointReset = ReadString(setValue);
		break;
	case "team_capsound_1":
		m_sndPointCapTeam1 = ReadString(setValue);
		break;
	case "team_capsound_2":
		m_sndPointCapTeam2 = ReadString(setValue);
		break;
	case "team_bodygroup_0":
		m_pointDefaultBody = ReadInt(setValue);
		break;
	case "team_icon_0":
		m_sndPointReset = ReadString(setValue);
		break;
	case "team_icon_2":
		m_sndPointCapTeam2 = ReadString(setValue);
		break;
	case "team_icon_3":
		m_sndPointCapTeam1 = ReadString(setValue);
		break;
	case "team_bodygroup_1":
		m_pointDefaultBodyTeam1 = ReadInt(setValue);
		break;
	case "team_bodygroup_2":
		m_pointDefaultBodyTeam2 = ReadInt(setValue);
		break;
	case "team_overlay_0":
		m_iconNeutral = ReadString(setValue);
		break;
	case "team_overlay_2":
		m_iconTeam1 = ReadString(setValue);
		break;
	case "team_overlay_3":
		m_iconTeam2 = ReadString(setValue);
		break;
	case "team_previouspoint_2_0":
		m_pointPreviousTeam1A = ReadString(setValue);
		break;
	case "team_previouspoint_2_1":
		m_pointPreviousTeam1B = ReadString(setValue);
		break;
	case "team_previouspoint_2_2":
		m_pointPreviousTeam1C = ReadString(setValue);
		break;
	case "team_previouspoint_3_0":
		m_pointPreviousTeam2A = ReadString(setValue);
		break;
	case "team_previouspoint_3_1":
		m_pointPreviousTeam2B = ReadString(setValue);
		break;
	case "team_previouspoint_3_2":
		m_pointPreviousTeam2C = ReadString(setValue);
		break;
	/* Outputs */
	case "OnOwnerChangedToTeam1":
		m_outputOnOwnerChangedToTeam1 = PrepareOutput(m_outputOnOwnerChangedToTeam1, setValue);
		break;
	case "OnOwnerChangedToTeam2":
		m_outputOnOwnerChangedToTeam2 = PrepareOutput(m_outputOnOwnerChangedToTeam2, setValue);
		break;
	case "OnCapReset":
		m_outputOnCapReset = PrepareOutput(m_outputOnCapReset, setValue);
		break;
	case "OnRoundStartOwnedByTeam1":
		m_outputOnRoundStartOwnedByTeam1 = PrepareOutput(m_outputOnRoundStartOwnedByTeam1, setValue);
		break;
	case "OnRoundStartOwnedByTeam2":
		m_outputOnRoundStartOwnedByTeam2 = PrepareOutput(m_outputOnRoundStartOwnedByTeam2, setValue);
		break;
	case "OnCapTeam1":
		m_outputOnCapTeam1 = PrepareOutput(m_outputOnCapTeam1, setValue);
		break;
	case "OnCapTeam2":
		m_outputOnCapTeam2 = PrepareOutput(m_outputOnCapTeam2, setValue);
		break;
	case "OnUnlocked":
		m_outputOnUnlocked = PrepareOutput(m_outputOnUnlocked, setValue);
		break;

	default:
		super::SpawnKey(keyName, setValue);
	}
}
