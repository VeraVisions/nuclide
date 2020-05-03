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
	m_eUser = eActivator;
	m_flDefusalState += frametime;
}

void
item_c4::Logic(void)
{
	// If the guy who started using us stopped using us, reset the defuser counter
	if (m_eUser != world) {
		m_eUser= world;
		m_flDefusalState = 0.0f;
	}

	// If our time has passed, explode
	if (m_flExplodeTime < time) {
		CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;

		/* In Bomb Defusal, all Terrorists receive $3500
		 * if they won by detonating the bomb. */
		rules.RoundOver(TEAM_T, 3500, FALSE);
		Damage_Radius(origin, this.owner, 500, g_cstrike_bombradius, TRUE, WEAPON_C4BOMB);
		sound(this, CHAN_VOICE, "weapons/c4_explode1.wav", 1.0, ATTN_NONE);

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

	sound(this, CHAN_WEAPON, "weapons/c4_plant.wav", 1.0f, ATTN_IDLE);
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
