/* C4 entity logic */

class item_c4:CBaseEntity
{
	entity m_eUser;
	float m_flBeepTime;
	float m_flExplodeTime;
	float m_flDefusalState;

	void(void) item_c4;
	virtual void(void) PlayerUse;
	virtual void(void) Logic;
};

void
item_c4::PlayerUse(void)
{
	/* don't allow anyone else to hijack. */
	if (m_eUser == world) {
		m_eUser = eActivator;
		sound(this, CHAN_ITEM, "weapons/c4_disarm.wav", 1.0, ATTN_NONE);
	}
}

void
item_c4::Logic(void)
{
	CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;

	/* check if we're being used */
	if (m_eUser != world) {
		/* we need to check if the user has changed every frame. */
		if (!m_eUser.button5) {
			m_eUser = world;
			m_flDefusalState = 0.0f;
		} else {
			player pl = (player)m_eUser;

			/* defusal kit always cuts the time in half */
			if (pl.g_items & ITEM_DEFUSAL)
				m_flDefusalState += (frametime * 2);
			else
				m_flDefusalState += frametime;
		}
	}

	if (m_flDefusalState > 10.0f) {
		sound(this, CHAN_VOICE, "weapons/c4_disarmed.wav", 1.0, ATTN_NORM);
		rules.RoundOver(TEAM_CT, 3600, TRUE);
		Radio_BroadcastMessage(RADIO_BOMBDEF);
		m_flBeepTime = 0.0f;
		m_flDefusalState = 0;
		remove(this);
		return;
	}

	/* if our time has passed, explode */
	if (m_flExplodeTime < time) {

		/* In Bomb Defusal, all Terrorists receive $3500
		 * if they won by detonating the bomb. */
		rules.RoundOver(TEAM_T, 3500, FALSE);
		Damage_Radius(origin, this.owner, 500, g_cstrike_bombradius, FALSE, WEAPON_C4BOMB);
		Sound_Play(this, CHAN_VOICE, "weapon_c4bomb.explode");

		for (entity e = world; (e = find(e, ::classname, "func_bomb_target"));) {
			CBaseTrigger trigger = (CBaseTrigger)e;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger();
			}
		}

		m_flBeepTime = 0.0f;
		m_flDefusalState = 0;
		remove(this);
		return;
	}

	if (m_flBeepTime > time) {
		return;
	}
	m_flBeepTime = time + 1.5;

	if (m_flExplodeTime - time < 2) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NONE);
	} else if (m_flExplodeTime - time < 5) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 10) {
		sound(this, CHAN_VOICE, "weapons/c4_beep4.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 20) {
		sound(this, CHAN_VOICE, "weapons/c4_beep3.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 30) {
		sound(this, CHAN_VOICE, "weapons/c4_beep2.wav", 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "weapons/c4_beep1.wav", 1.0, ATTN_NORM);
	}
}

void
item_c4::item_c4(void)
{
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetModel("models/w_c4.mdl");
	SetSize([-6,-6,0], [6,6,6]);

	customphysics = Logic;
	m_flExplodeTime = time + 45.0f;

	Sound_Play(this, CHAN_WEAPON, "weapon_c4bomb.plant");
}

void
C4Bomb_Plant(base_player planter)
{
	item_c4 bomb = spawn(item_c4);
	bomb.owner = planter;

	/* place directly below */
	traceline(planter.origin, planter.origin + [0,0,-64], FALSE, planter);
	setorigin(bomb, trace_endpos);

	Radio_BroadcastMessage(RADIO_BOMBPL);
	g_cs_bombplanted = TRUE;
}
