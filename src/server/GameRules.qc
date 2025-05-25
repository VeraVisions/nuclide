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
ncRuleDelegate::ncRuleDelegate(void)
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
ncRuleDelegate::Save(float handle)
{
	SaveInt(handle, "m_iIntermission", m_iIntermission);
	SaveFloat(handle, "m_flIntermissionTime", m_flIntermissionTime);
	SaveFloat(handle, "m_flIntermissionCycle", m_flIntermissionCycle);
}

void
ncRuleDelegate::Restore(string strKey, string strValue)
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
ncRuleDelegate::Input(entity eAct, string strInput, string strData)
{
}

void
ncRuleDelegate::RestoreComplete(void)
{
	/* mark this as our active game-rule upon restore. */
	g_grMode = this;
}

/* init */
void
ncRuleDelegate::InitPostEnts(void)
{
}

void
ncRuleDelegate::Precache(void)
{
}

/* logic */
void
ncRuleDelegate::FrameStart(void)
{
	if (cvar("timelimit"))
	if (time >= (cvar("timelimit") * 60)) {
		IntermissionStart();
	}

	IntermissionCycle();

}
bool
ncRuleDelegate::ConsoleCommand(ncPlayer pl, string cmd)
{
	return (false);
}
bool
ncRuleDelegate::ClientCommand(ncClient pl, string cmd)
{
	return (false);
}

bool
ncRuleDelegate::ImpulseCommand(ncClient pl, float num)
{
	return (false);
}

void
ncRuleDelegate::PlayerConnect(ncPlayer pl)
{

}
void
ncRuleDelegate::PlayerDisconnect(ncPlayer pl)
{
}

void
ncRuleDelegate::PlayerKill(ncPlayer pl)
{
	ncDict damageDecl = spawn(ncDict);
	damageDecl.AddKey("damage", itos(1000));
	damageDecl.AddKey("noGod", "1");
	damageDecl.AddKey("noArmor", "1");
	pl.Damage(pl, pl, damageDecl, 1.0, g_vec_null, pl.GetOrigin());
	remove(damageDecl);
}

void
ncRuleDelegate::NPCDeath(ncActor npc, ncEntity attacker, ncEntity inflictor)
{
}

void
ncRuleDelegate::PlayerDeath(ncPlayer deadPlayer, ncEntity inflictor, ncEntity attacker, string weaponDef)
{
	/* death-counter */
	deadPlayer.deaths++;
	deadPlayer.SetInfoKey("*deaths", ftos(deadPlayer.deaths));

	/* update score-counter */
	if (is.Player(attacker)) {
		if (deadPlayer == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

void
ncRuleDelegate::PlayerPain(ncPlayer pl, ncActor attacker, ncDict damageDecl)
{
	/* fallback code here, or rest implemented by sub-class */
}

void
ncRuleDelegate::PlayerSpawn(ncPlayer pl)
{
	/* implemented by sub-class */
}
void
ncRuleDelegate::PlayerPreFrame(ncPlayer pl)
{
	/* implemented by sub-class */
}
void
ncRuleDelegate::PlayerPostFrame(ncPlayer pl)
{
	/* implemented by sub-class */
}

/* level transitions */
void
ncRuleDelegate::LevelNewParms(void)
{
	/* implemented by sub-class */
}
void
ncRuleDelegate::LevelChangeParms(ncPlayer pl)
{
	//print("LevelChangeParms!\n");
}

/* spectator */
/*void
ncRuleDelegate::SpectatorConnect(ncSpectator pl)
{
	//print("SpectatorConnect!\n");
}
void
ncRuleDelegate::SpectatorDisconnect(ncSpectator pl)
{
	//print("SpectatorDisconnect!\n");
}
void
ncRuleDelegate::SpectatorThink(ncSpectator pl)
{
	//print("SpectatorThink!\n");
}*/

int
ncRuleDelegate::MaxItemPerSlot(int slot)
{
	return (-1);
}

void
ncRuleDelegate::IntermissionStart(void)
{
	if (m_iIntermission)
		return;

	m_iIntermission = TRUE;
	m_flIntermissionTime = time + 5.0f;

	for (entity p = world; (p = next.Player(p));) {
		ents.ChangeToClass(p, "spectator");
	}
}

void
ncRuleDelegate::IntermissionCycle(void)
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

		for (entity pl = world; (pl = next.Player(pl));) {
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
ncRuleDelegate::IntermissionToPlayer(ncPlayer targetPlayer)
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
ncRuleDelegate::InIntermission(void)
{
	return (m_iIntermission) ? true : false;
}

bool
ncRuleDelegate::MonstersSpawn(void)
{
	return (true);
}

/* init */
bool
ncRuleDelegate::IsTeamplay(void)
{
	return (serverkeyfloat("teams") > 0);
}
bool
ncRuleDelegate::IsMultiplayer(void)
{
	return (false);
}

void
ncRuleDelegate::IntermissionEnd(void)
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
ncRuleDelegate::PlayerCanAttack(ncPlayer bp)
{
	return (true);
}

bool
ncRuleDelegate::PlayerRequestRespawn(ncPlayer pl)
{
	return (true);
}

bool
ncRuleDelegate::PlayerRequestTeam(ncPlayer pl, int teamNum)
{
	return (false);
}

void
ncRuleDelegate::ChatMessageAll(ncClient cl, string strMessage)
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
ncRuleDelegate::ChatMessageTeam(ncClient cl, string strMessage)
{
	float edictNum = num_for_edict(cl) - 1;

	/* their finger probably slipped */
	if (IsTeamplay() == false) {
		ChatMessageAll(cl, strMessage);
		return;
	}

	/* single handedly pick out team members */
	for (entity a = world; (a = next.Player(a));) {
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
ncRuleDelegate::Title(void)
{
	if (STRING_SET(g_ruleCName)) {
		return (g_ruleCName);
	}

	return ("Default");
}

ncRuleDelegate
ncRuleDelegate::ActiveInstance(void)
{
	return (g_grMode);
}

void
ncRuleDelegate::LinkProgs(void)
{
	ncRuleDelegate newRule = spawn(ncRuleDelegate);

	if (g_ruleCProgs) {
		RULEMAP(newRule, ClientCommand, "CodeCallback_ClientCommand")
		RULEMAP(newRule, ConsoleCommand, "CodeCallback_ConsoleCommand")
		RULEMAP(newRule, FrameStart, "CodeCallback_FrameStart")
		RULEMAP(newRule, ImpulseCommand, "CodeCallback_ImpulseCommand")
		RULEMAP(newRule, Precache, "CodeCallback_Precache")
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

	serverinfo.SetString("mode", newRule.Title());
	g_grMode = newRule;
}

__weak string
Game_DefaultRules(void)
{
	string gameType = cvars.GetString("g_gametype");

	if (!STRING_SET(gameType)) {
		bool isCoop = cvars.GetBool("coop");
		bool isSingle = (cvars.GetInteger("sv_playerslots") <= 1i) ? (true) : (false);
		gameType = ((isSingle || isCoop) == (true)) ? ("singleplayer") : ("deathmatch");
	}

	return (gameType);
}

/* Rule specific Scripting, nicknamed 'RuleC' because MapC exists. */
void
RuleC_Init(void)
{
	string gameType = g_ruleCName = Game_DefaultRules();
	string pathToProgs;

	pathToProgs = strcat("progs/", gameType, ".dat");

	/* No progs .dat, exit out */
	if (fileExists(pathToProgs) == false) {
		ncError("Progs at %S does not exist.", pathToProgs);
		g_ruleCProgs = 0;
		return;
	}

	ncLog("Active RuleC:");
	ncLog("\tType: %S", gameType);
	ncLog("\tProgs: %S", pathToProgs);

	g_ruleCProgs = addprogs(pathToProgs);

	if (g_ruleCProgs) {
		void(void) mainFunction;
		mainFunction = externvalue(g_ruleCProgs, "main");

		if (mainFunction) {
			mainFunction();
		} else {
			error(sprintf("RuleC %S does not have a main function.", pathToProgs));
		}
	}
}
