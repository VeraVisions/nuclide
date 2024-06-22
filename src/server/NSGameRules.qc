/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

var bool autocvar_sv_friendlyFire = false;
var int autocvar_mp_td_dmgToKick = 300i;
var int autocvar_mp_td_dmgToWarn = 200i;

void
NSGameRules::NSGameRules(void)
{
	forceinfokey(world, "teamplay", "0");
	identity = 2;
}

void
NSGameRules::Save(float handle)
{
	SaveInt(handle, "m_iIntermission", m_iIntermission);
	SaveFloat(handle, "m_flIntermissionTime", m_flIntermissionTime);
	SaveFloat(handle, "m_flIntermissionCycle", m_flIntermissionCycle);
}

void
NSGameRules::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iIntermission":
		m_iIntermission = ReadInt(strValue);
		break;
	case "m_flIntermissionTime":
		m_flIntermissionTime = ReadFloat(strValue);
		break;
	case "m_flIntermissionCycle":
		m_flIntermissionCycle = ReadFloat(strValue);
		break;
	}
}

void
NSGameRules::RestoreComplete(void)
{
	/* mark this as our active game-rule upon restore. */
	g_grMode = this;
}

/* init */
void
NSGameRules::InitPostEnts(void)
{
	//print("Init!\n");
}

/* logic */
void
NSGameRules::FrameStart(void)
{
	//print("StartFrame!\n");
}
bool
NSGameRules::ConsoleCommand(NSClientPlayer pl, string cmd)
{
	return (false);
}
bool
NSGameRules::ClientCommand(NSClient pl, string cmd)
{
	return (false);
}
bool
NSGameRules::ImpulseCommand(NSClient pl, float num)
{
	return (false);
}

/* client */
void
NSGameRules::PlayerConnect(NSClientPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s^d connected.\n", pl.netname));
}
void
NSGameRules::PlayerDisconnect(NSClientPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s^d disconnected.\n", pl.netname));
}

void
NSGameRules::PlayerKill(NSClientPlayer pl)
{
	//Damage_Apply(pl, pl, pl.health, 0, DMG_SKIP_ARMOR);
}
void
NSGameRules::PlayerDeath(NSClientPlayer pl)
{
	/* implemented by sub-class */
}
void
NSGameRules::PlayerPain(NSClientPlayer pl)
{
	/* implemented by sub-class */
}
void
NSGameRules::PlayerSpawn(NSClientPlayer pl)
{
	/* implemented by sub-class */
}
void
NSGameRules::PlayerPreFrame(NSClientPlayer pl)
{
	/* implemented by sub-class */
}
void
NSGameRules::PlayerPostFrame(NSClientPlayer pl)
{
	/* implemented by sub-class */
}

/* level transitions */
void
NSGameRules::LevelNewParms(void)
{
	/* implemented by sub-class */
}
void
NSGameRules::LevelChangeParms(NSClientPlayer pl)
{
	//print("LevelChangeParms!\n");
}

/* spectator */
/*void
NSGameRules::SpectatorConnect(NSClientSpectator pl)
{
	//print("SpectatorConnect!\n");
}
void
NSGameRules::SpectatorDisconnect(NSClientSpectator pl)
{
	//print("SpectatorDisconnect!\n");
}
void
NSGameRules::SpectatorThink(NSClientSpectator pl)
{
	//print("SpectatorThink!\n");
}*/

int
NSGameRules::MaxItemPerSlot(int slot)
{
	return (-1);
}

void
NSGameRules::IntermissionStart(void)
{
	if (m_iIntermission)
		return;

	m_iIntermission = TRUE;
	m_flIntermissionTime = time + 5.0f;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		p.health = 0;
		p.modelindex = 0;
	}
}

void
NSGameRules::IntermissionCycle(void)
{
	NSEntity targ;

	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionCycle)
		return;

	/* make the clients aware */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	m_eIntermissionPoint = (NSEntity)find(m_eIntermissionPoint, ::classname, "info_intermission");

	/* if we have an intermission point, send it to all players. */
	if (m_eIntermissionPoint) {
		targ = (NSEntity)find(world, ::targetname, m_eIntermissionPoint.target);

		if (targ) {
			vector foo;
			foo = vectoangles(targ.origin - m_eIntermissionPoint.origin);
			m_eIntermissionPoint.angles = foo;
		}

		WriteByte(MSG_MULTICAST, 1);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[0]);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[1]);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[2]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[0]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[1]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[2]);

		for (entity pl = world; (pl = find(pl, ::classname, "player"));) {
			setorigin(pl, m_eIntermissionPoint.origin);
		}
	} else {
		WriteByte(MSG_MULTICAST, 0);
	}

	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	if (!m_eIntermissionPoint)
		m_flIntermissionCycle = 0.0f;
	else
		m_flIntermissionCycle = time + 5.0f;
}

void
NSGameRules::IntermissionToPlayer(NSClientPlayer targetPlayer)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	/* we're in an intermission already, so this should be set. */
	if (g_grMode.m_eIntermissionPoint) {
		WriteByte(MSG_MULTICAST, 1);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[0]);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[1]);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[2]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[0]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[1]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[2]);
	} else {
		WriteByte(MSG_MULTICAST, 0);
	}

	msg_entity = targetPlayer;
	multicast([0,0,0], MULTICAST_ONE_R);
}

bool
NSGameRules::InIntermission(void)
{
	return (m_iIntermission) ? true : false;
}

bool
NSGameRules::MonstersSpawn(void)
{
	return (true);
}

/* init */
bool
NSGameRules::IsTeamplay(void)
{
	return (false);
}
bool
NSGameRules::IsMultiplayer(void)
{
	return (false);
}

void
NSGameRules::DamageApply(entity t, entity c, float dmg, int w, damageType_t type)
{
	NSError("Deprecated!");
}

/* checks if we can hit an entity at 5 of the same spots */
bool
NSGameRules::DamageCheckTrace(entity t, vector vecHitPos)
{
	NSError("Deprecated!");
	return (false);
}

void
NSGameRules::DamageRadius(vector org, entity attacker, float dmg, float r, bool checkCollision, int w)
{
	NSError("Deprecated!");
}

void
NSGameRules::IntermissionEnd(void)
{
	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionTime)
		return;

	if (!(input_buttons & INPUT_PRIMARY) && !(input_buttons & INPUT_JUMP))
		return;

	localcmd("nextmap\n");

	m_iIntermission = 0;
	m_flIntermissionTime = -1;
}

bool
NSGameRules::PlayerCanAttack(NSClientPlayer bp)
{
	return true;
}

bool
NSGameRules::PlayerRequestRespawn(NSClientPlayer bp)
{
	return false;
}

void
NSGameRules::ChatMessageAll(NSClient cl, string strMessage)
{
	float edictNum = num_for_edict(cl) - 1;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CHAT);
	WriteByte(MSG_MULTICAST, edictNum);
	WriteByte(MSG_MULTICAST, cl.team); 
	WriteString(MSG_MULTICAST, strMessage);
	multicast([0,0,0], MULTICAST_ALL_R);

	/* TODO: don't print on listen games */
	print(Util_ChatFormat(edictNum, 0, strMessage));
	print("\n");
}

void
NSGameRules::ChatMessageTeam(NSClient cl, string strMessage)
{
	float edictNum = num_for_edict(cl) - 1;

	/* their finger probably slipped */
	if (IsTeamplay() == false) {
		ChatMessageAll(cl, strMessage);
		return;
	}

	/* single handedly pick out team members */
	for (entity a = world; (a = find(a, ::classname, "player"));) {
		/* not one of us! */
		if (a.team != cl.team)
			continue;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_CHAT_TEAM);
		WriteByte(MSG_MULTICAST, edictNum); 
		WriteByte(MSG_MULTICAST, cl.team); 
		WriteString(MSG_MULTICAST, strMessage);

		msg_entity = a;
		multicast([0,0,0], MULTICAST_ONE_R);
	}

	print(Util_ChatFormat(edictNum, cl.team, strMessage));
	print("\n");
}

string
NSGameRules::Title(void)
{
	return "Default";
}
