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
ncGameRules::ncGameRules(void)
{
	forceinfokey(world, "teams", "");
	forceinfokey(world, "teamplay", "");
	forceinfokey(world, "coop", "");

	/* clean up... */
	for (int teamID = 1; teamID < 1000; teamID++) {
		forceinfokey(world, sprintf("team_%i", teamID), "");
		forceinfokey(world, sprintf("teamscore_%i", teamID), "");
		forceinfokey(world, sprintf("teamcolor_%i", teamID), "");
		forceinfokey(world, sprintf("teamclosed_%i", teamID), "");
		forceinfokey(world, sprintf("teamspawn_%i", teamID), "");
		forceinfokey(world, sprintf("teamclass_%i", teamID), "");
	}

	forceinfokey(world, sprintf("teamspawn_%d", TEAM_CONNECTING), "");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_UNASSIGNED), "info_player_start");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_SPECTATOR), "info_spectator_start");
	identity = 2;
}

void
ncGameRules::Save(float handle)
{
	SaveInt(handle, "m_iIntermission", m_iIntermission);
	SaveFloat(handle, "m_flIntermissionTime", m_flIntermissionTime);
	SaveFloat(handle, "m_flIntermissionCycle", m_flIntermissionCycle);
}

void
ncGameRules::Restore(string strKey, string strValue)
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
ncGameRules::Input(entity eAct, string strInput, string strData)
{
}

void
ncGameRules::RestoreComplete(void)
{
	/* mark this as our active game-rule upon restore. */
	g_grMode = this;
}

/* init */
void
ncGameRules::InitPostEnts(void)
{
}

/* logic */
void
ncGameRules::FrameStart(void)
{

}
bool
ncGameRules::ConsoleCommand(ncPlayer pl, string cmd)
{
	return (false);
}
bool
ncGameRules::ClientCommand(ncClient pl, string cmd)
{
	return (false);
}

bool
ncGameRules::ImpulseCommand(ncClient pl, float num)
{
	return (false);
}

void
ncGameRules::PlayerConnect(ncPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == false) {
		bprint(PRINT_HIGH, sprintf("%s^d connected.\n", pl.netname));
	}
}
void
ncGameRules::PlayerDisconnect(ncPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s^d disconnected.\n", pl.netname));
}

void
ncGameRules::PlayerKill(ncPlayer pl)
{
	ncDict damageDecl = spawn(ncDict);
	damageDecl.AddKey("damage", itos(1000));
	damageDecl.AddKey("noGod", "1");
	damageDecl.AddKey("noArmor", "1");
	pl.Damage(pl, pl, damageDecl, 1.0, g_vec_null, pl.GetOrigin());
	remove(damageDecl);
}

void
ncGameRules::NPCDeath(ncActor npc, ncEntity attacker, ncEntity inflictor)
{
}

void
ncGameRules::PlayerDeath(ncPlayer deadPlayer, ncEntity inflictor, ncEntity attacker, string weaponDef)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	WriteString(MSG_MULTICAST, (attacker.netname) ? attacker.netname : attacker.classname);
	WriteString(MSG_MULTICAST, deadPlayer.netname);
	WriteByte(MSG_MULTICAST, 0);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	/* death-counter */
	deadPlayer.deaths++;
	deadPlayer.SetInfoKey("*deaths", ftos(deadPlayer.deaths));

	/* update score-counter */
	if (isPlayer(attacker)) {
		if (deadPlayer == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

void
ncGameRules::PlayerPain(ncPlayer pl, ncActor attacker, ncDict damageDecl)
{
	/* fallback code here, or rest implemented by sub-class */
}

void
ncGameRules::PlayerSpawn(ncPlayer pl)
{
	/* implemented by sub-class */
}
void
ncGameRules::PlayerPreFrame(ncPlayer pl)
{
	/* implemented by sub-class */
}
void
ncGameRules::PlayerPostFrame(ncPlayer pl)
{
	/* implemented by sub-class */
}

/* level transitions */
void
ncGameRules::LevelNewParms(void)
{
	/* implemented by sub-class */
}
void
ncGameRules::LevelChangeParms(ncPlayer pl)
{
	//print("LevelChangeParms!\n");
}

/* spectator */
/*void
ncGameRules::SpectatorConnect(ncSpectator pl)
{
	//print("SpectatorConnect!\n");
}
void
ncGameRules::SpectatorDisconnect(ncSpectator pl)
{
	//print("SpectatorDisconnect!\n");
}
void
ncGameRules::SpectatorThink(ncSpectator pl)
{
	//print("SpectatorThink!\n");
}*/

int
ncGameRules::MaxItemPerSlot(int slot)
{
	return (-1);
}

void
ncGameRules::IntermissionStart(void)
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
ncGameRules::IntermissionCycle(void)
{
	ncEntity targ;

	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionCycle)
		return;

	/* make the clients aware */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	m_eIntermissionPoint = (ncEntity)find(m_eIntermissionPoint, ::classname, "info_intermission");

	/* if we have an intermission point, send it to all players. */
	if (m_eIntermissionPoint) {
		targ = (ncEntity)find(world, ::targetname, m_eIntermissionPoint.target);

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
ncGameRules::IntermissionToPlayer(ncPlayer targetPlayer)
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
ncGameRules::InIntermission(void)
{
	return (m_iIntermission) ? true : false;
}

bool
ncGameRules::MonstersSpawn(void)
{
	return (true);
}

/* init */
bool
ncGameRules::IsTeamplay(void)
{
	return (serverkeyfloat("teams") > 0);
}
bool
ncGameRules::IsMultiplayer(void)
{
	return (false);
}

void
ncGameRules::IntermissionEnd(void)
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
ncGameRules::PlayerCanAttack(ncPlayer bp)
{
	return (true);
}

bool
ncGameRules::PlayerRequestRespawn(ncPlayer pl)
{
	return (true);
}

bool
ncGameRules::PlayerRequestTeam(ncPlayer pl, int teamNum)
{
	return (false);
}

void
ncGameRules::ChatMessageAll(ncClient cl, string strMessage)
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
ncGameRules::ChatMessageTeam(ncClient cl, string strMessage)
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
ncGameRules::Title(void)
{
	string gameType = cvars.GetString("g_gametype");

	if (STRING_SET(gameType)) {
		return gameType;
	}

	return "Default";
}

ncGameRules
ncGameRules::InitFromProgs(string pathToProgs)
{
	ncGameRules newRule;

	/* No progs .dat, exit out */
	if (fileExists(pathToProgs) == false) {
		NSError("Progs at %S does not exist.", pathToProgs);
		return (__NULL__);
	}

	newRule = spawn(ncGameRules);

	if (g_ruleCProgs) {
		RULEMAP(newRule, ClientCommand, "CodeCallback_ClientCommand")
		RULEMAP(newRule, ConsoleCommand, "CodeCallback_ConsoleCommand")
		RULEMAP(newRule, FrameStart, "CodeCallback_FrameStart")
		RULEMAP(newRule, ImpulseCommand, "CodeCallback_ImpulseCommand")
		RULEMAP(newRule, InitPostEnts, "CodeCallback_StartGameType")
		RULEMAP(newRule, Input, "CodeCallback_Input")
		RULEMAP(newRule, NPCDeath, "CodeCallback_NPCKilled")
		RULEMAP(newRule, PlayerCanAttack, "CodeCallback_PlayerCanAttack")
		RULEMAP(newRule, PlayerConnect, "CodeCallback_PlayerConnect")
		RULEMAP(newRule, PlayerDeath, "CodeCallback_PlayerKilled")
		RULEMAP(newRule, PlayerDisconnect, "CodeCallback_PlayerDisconnect")
		RULEMAP(newRule, PlayerPain, "CodeCallback_PlayerDamage")
		RULEMAP(newRule, PlayerPreFrame, "CodeCallback_PlayerPreFrame")
		RULEMAP(newRule, PlayerRequestRespawn, "CodeCallback_PlayerRequestRespawn")
		RULEMAP(newRule, PlayerRequestTeam, "CodeCallback_CallRequestTeam")
		RULEMAP(newRule, PlayerSpawn, "CodeCallback_PlayerSpawn")
		RULEMAP(newRule, Title, "CodeCallback_Title")
	}

	return (newRule);
}
