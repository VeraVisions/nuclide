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
trigger_capture_area:ncBrushTrigger
{
public:
	void trigger_capture_area(void);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void SpawnKey(string,string);
	virtual void Input(entity,string,string);

	nonvirtual void PlayersLeft(void);
	nonvirtual void CaptureThink(void);
	nonvirtual void Event_StartCap(void);
	nonvirtual void Event_StartTeam(int team);
	nonvirtual void Event_BreakCap(void);
	nonvirtual void Event_BreakTeam(int offensiveTeam);
	nonvirtual void Event_EndCap(void);
	nonvirtual void Event_CapTeam(int team);
	nonvirtual void Event_NumCappersChanged(int team);

private:
	/* spawn data */
	string m_targetControlPoint;
	bool m_teamCanCap1;
	bool m_teamCanCap2;
	int m_playersNeededToCap1;
	int m_playersNeededToCap2;
	int m_teamCapturingLimit1;
	int m_teamCapturingLimit2;
	float m_teamSpawnAdjust1;
	float m_teamSpawnAdjust2;
	float m_timeToCapture;
	string m_outputOnStartCap;
	string m_outputOnStartTeam1;
	string m_outputOnStartTeam2;
	string m_outputOnBreakCap;
	string m_outputOnBreakTeam1;
	string m_outputOnBreakTeam2;
	string m_outputOnEndCap;
	string m_outputOnCapTeam1;
	string m_outputOnCapTeam2;
	string m_outputOnNumCappersChanged1;
	string m_outputOnNumCappersChanged2;

	/* state */
	int m_stateTeam1Players;
	int m_stateTeam2Players;
	int m_statePlayerPower;
	int m_stateCapturingTeam;
	bool m_stateCapturing;
	bool m_stateBreaking;
	int m_stateOwnerTeam;
	float m_stateBreakProgress;
	float m_stateCaptureProgress;
};

void
trigger_capture_area::trigger_capture_area(void)
{
	m_targetControlPoint = __NULL__;
	m_teamCanCap1 = false;
	m_teamCanCap2 = false;
	m_playersNeededToCap1 = 0i;
	m_playersNeededToCap2 = 0i;
	m_teamCapturingLimit1 = 0i;
	m_teamCapturingLimit2 = 0i;
	m_teamSpawnAdjust1 = 0.0f;
	m_teamSpawnAdjust2 = 0.0f;
	m_timeToCapture = 0.0f;
	m_outputOnStartCap = __NULL__;
	m_outputOnStartTeam1 = __NULL__;
	m_outputOnStartTeam2 = __NULL__;
	m_outputOnBreakCap = __NULL__;
	m_outputOnBreakTeam1 = __NULL__;
	m_outputOnBreakTeam2 = __NULL__;
	m_outputOnEndCap = __NULL__;
	m_outputOnCapTeam1 = __NULL__;
	m_outputOnCapTeam2 = __NULL__;
	m_outputOnNumCappersChanged1 = __NULL__;
	m_outputOnNumCappersChanged2 = __NULL__;
}

void
trigger_capture_area::Spawned(void)
{
	super::Spawned();

	if (STRING_SET(m_outputOnStartCap)) {
		m_outputOnStartCap = CreateOutput(m_outputOnStartCap);
	}
	if (STRING_SET(m_outputOnStartTeam1)) {
		m_outputOnStartTeam1 = CreateOutput(m_outputOnStartTeam1);
	}
	if (STRING_SET(m_outputOnStartTeam2)) {
		m_outputOnStartTeam2 = CreateOutput(m_outputOnStartTeam2);
	}
	if (STRING_SET(m_outputOnBreakCap)) {
		m_outputOnBreakCap = CreateOutput(m_outputOnBreakCap);
	}
	if (STRING_SET(m_outputOnBreakTeam1)) {
		m_outputOnBreakTeam1 = CreateOutput(m_outputOnBreakTeam1);
	}
	if (STRING_SET(m_outputOnBreakTeam2)) {
		m_outputOnBreakTeam2 = CreateOutput(m_outputOnBreakTeam2);
	}
	if (STRING_SET(m_outputOnEndCap)) {
		m_outputOnEndCap = CreateOutput(m_outputOnEndCap);
	}
	if (STRING_SET(m_outputOnCapTeam1)) {
		m_outputOnCapTeam1 = CreateOutput(m_outputOnCapTeam1);
	}
	if (STRING_SET(m_outputOnCapTeam2)) {
		m_outputOnCapTeam2 = CreateOutput(m_outputOnCapTeam2);
	}
	if (STRING_SET(m_outputOnNumCappersChanged1)) {
		m_outputOnNumCappersChanged1 = CreateOutput(m_outputOnNumCappersChanged1);
	}
	if (STRING_SET(m_outputOnNumCappersChanged2)) {
		m_outputOnNumCappersChanged2 = CreateOutput(m_outputOnNumCappersChanged2);
	}
}

void
trigger_capture_area::Input(entity activatingEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "CaptureCurrentCP":
		break;
	case "SetControlPoint":
		break;
	case "SetTeamCanCap":
		break;
	default:
		super::Input(activatingEntity, inputName, dataField);
	}
}

void
trigger_capture_area::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "area_cap_point":
		m_targetControlPoint = ReadString(setValue);
		break;
	case "team_cancap_2":
		m_teamCanCap1 = ReadBool(setValue);
		break;
	case "team_cancap_3":
		m_teamCanCap2 = ReadBool(setValue);
		break;
	case "team_startcap_2":
		m_playersNeededToCap1 = ReadInt(setValue);
		break;
	case "team_startcap_3":
		m_playersNeededToCap2 = ReadInt(setValue);
		break;
	case "team_numcap_2":
		m_teamCapturingLimit1 = ReadInt(setValue);
		break;
	case "team_numcap_3":
		m_teamCapturingLimit2 = ReadInt(setValue);
		break;
	case "team_spawn_2":
		m_teamSpawnAdjust1 = ReadFloat(setValue);
		break;
	case "team_spawn_3":
		m_teamSpawnAdjust2 = ReadFloat(setValue);
		break;
	case "area_time_to_cap":
		m_timeToCapture = ReadFloat(setValue);
		break;
	/* Outputs */
	case "OnStartCap":
		m_outputOnStartCap = PrepareOutput(m_outputOnStartCap, setValue);
		break;
	case "OnStartTeam1":
		m_outputOnStartTeam1 = PrepareOutput(m_outputOnStartTeam1, setValue);
		break;
	case "OnStartTeam2":
		m_outputOnStartTeam2 = PrepareOutput(m_outputOnStartTeam2, setValue);
		break;
	case "OnBreakCap":
		m_outputOnBreakCap = PrepareOutput(m_outputOnBreakCap, setValue);
		break;
	case "OnBreakTeam1":
		m_outputOnBreakTeam1 = PrepareOutput(m_outputOnBreakTeam1, setValue);
		break;
	case "OnBreakTeam2":
		m_outputOnBreakTeam2 = PrepareOutput(m_outputOnBreakTeam2, setValue);
		break;
	case "OnEndCap":
		m_outputOnEndCap = PrepareOutput(m_outputOnEndCap, setValue);
		break;
	case "OnCapTeam1":
		m_outputOnCapTeam1 = PrepareOutput(m_outputOnCapTeam1, setValue);
		break;
	case "OnCapTeam2":
		m_outputOnCapTeam2 = PrepareOutput(m_outputOnCapTeam2, setValue);
		break;
	case "OnNumCappersChanged":
		m_outputOnNumCappersChanged1 = PrepareOutput(m_outputOnNumCappersChanged1, setValue);
		break;
	case "OnNumCappersChanged2":
		m_outputOnNumCappersChanged2 = PrepareOutput(m_outputOnNumCappersChanged2, setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
trigger_capture_area::Respawn(void)
{
	InitBrushTrigger();
	Hide();

	/* set up the filter for which teams can touch this */
	if (m_teamCanCap1 == false && m_teamCanCap2 == false) {
		SetTeam(3);
	} else if (m_teamCanCap1 == true && m_teamCanCap1 == true) {
		SetTeam(0);
	} else if (m_teamCanCap1 == true) {
		SetTeam(1);
	} else if (m_teamCanCap2 == true) {
		SetTeam(2);
	}

	PlayersLeft();
}

void
trigger_capture_area::Event_StartCap(void)
{
	UseOutput(this, m_outputOnStartCap);
}

void
trigger_capture_area::Event_StartTeam(int team)
{
	EntLog("Capture started by team %i", team);
	m_stateCapturing = true;
	m_stateBreaking = false;
	m_stateCapturingTeam = team;

	if (team == 1) {
		UseOutput(this, m_outputOnStartTeam1);
	} else if (team == 2) {
		UseOutput(this, m_outputOnStartTeam2);
	}
}

void
trigger_capture_area::Event_BreakCap(void)
{
	EntLog("Break started by team %i", m_stateCapturingTeam);
	m_stateBreaking = true;
	m_stateCapturing = false;
	UseOutput(this, m_outputOnBreakCap);
}

void
trigger_capture_area::Event_BreakTeam(int offensiveTeam)
{
	if (m_stateOwnerTeam == 1) {
		UseOutput(this, m_outputOnBreakTeam1);
	} else if (m_stateOwnerTeam == 2) {
		UseOutput(this, m_outputOnBreakTeam2);
	}

	EntLog("Point owned by team %i broken by team %i", m_stateOwnerTeam, offensiveTeam);
	m_stateBreaking = false;
	m_stateBreakProgress = 0.0f;
	m_stateOwnerTeam = 0i;
}

void
trigger_capture_area::Event_EndCap(void)
{
	UseOutput(this, m_outputOnEndCap);
}

void
trigger_capture_area::Event_CapTeam(int team)
{
	EntLog("Point captured by team %i", team);

	m_stateCapturing = false;
	m_stateCaptureProgress = 0.0f;
	m_stateOwnerTeam = team;

	if (team == 1) {
		UseOutput(this, m_outputOnCapTeam1);
	} else if (team == 2) {
		UseOutput(this, m_outputOnCapTeam2);
	}
}

void
trigger_capture_area::Event_NumCappersChanged(int team)
{
	if (team == 1) {
		UseOutput(this, m_outputOnNumCappersChanged1);
	} else if (team == 2) {
		UseOutput(this, m_outputOnNumCappersChanged2);
	}
}

void
trigger_capture_area::PlayersLeft(void)
{
	EntLog("No players in the capture area any longer.");
	m_stateCapturingTeam = 0i;
	m_stateCapturing = false;
	m_stateBreaking = false;
	m_stateBreakProgress = 0.0f;
	m_stateCaptureProgress = 0.0f;
}

void
trigger_capture_area::CaptureThink(void)
{
	float ourTeam = GetTeam();
	int dominatingTeam = 0i;

	m_stateTeam1Players = 0i;
	m_stateTeam2Players = 0i;
	m_statePlayerPower = 0i;

	/* who is in our bounds? */
	for (ncPlayer nextPlayer = __NULL__; (nextPlayer = next.Player(nextPlayer));) {
		bool testPlayer = false;
		float playerTeam = nextPlayer.GetTeam();

		if (ourTeam == TEAM_ANY) {
			testPlayer = true;
		} else if (nextPlayer.GetTeam() == ourTeam) {
			testPlayer = true;
		}
		
		if (testPlayer == true) {
			if (WithinBounds(nextPlayer)) {
				if (playerTeam == 1) {
					m_stateTeam1Players++;
				} else if (playerTeam == 2) {
					m_stateTeam2Players++;
				}
			}
		}
	}

	/* no one is really standing here. */
	if (m_stateTeam1Players > 0i && m_stateTeam2Players > 0i) {
		ScheduleThink(PlayersLeft, 0.25f);
		return;
	}

	if (m_stateTeam1Players >= m_stateTeam2Players) {
		m_statePlayerPower = (m_stateTeam1Players - m_stateTeam2Players);

		if (m_statePlayerPower >= m_playersNeededToCap1) {
			m_stateCapturingTeam = 1;
		}
	} else if (m_stateTeam2Players >= m_stateTeam1Players) {
		m_statePlayerPower = (m_stateTeam2Players - m_stateTeam1Players);

		if (m_statePlayerPower >= m_playersNeededToCap2) {
			m_stateCapturingTeam = 2;
		}
	}

	if (m_stateCapturingTeam == 0) {
		return;
	}

	/* a different team is slowly taking ownership */
	if (m_stateCapturingTeam != m_stateOwnerTeam) {
		/* no one owns this yet */
		if (m_stateOwnerTeam == 0) {
			if (m_stateCapturing != true) {
				Event_StartTeam(m_stateCapturingTeam);
			}
		} else {
			if (m_stateBreaking != true) {
				Event_BreakCap();
			}
		}
	}

	if (m_stateCapturing) {
		m_stateCaptureProgress += frametime;

		if (m_stateCaptureProgress >= m_timeToCapture) {
			Event_CapTeam(m_stateCapturingTeam);
		}
	} else if (m_stateBreaking) {
		m_stateBreakProgress += frametime;

		if (m_stateBreakProgress >= m_timeToCapture) {
			Event_BreakTeam(m_stateCapturingTeam);
		}
	}
}

void
trigger_capture_area::Touch(entity eToucher)
{
	if (is.Player(eToucher) == false) {
		return;
	}

	ScheduleThink(CaptureThink, 0.0f);
}
