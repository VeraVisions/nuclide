/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

class CGameRules
{
	int m_iIntermission;
	float m_flIntermissionTime;
	float m_flIntermissionCycle;

	void() CGameRules;

	virtual void(void) InitPostEnts;

	/* logic */
	virtual void(void) FrameStart;
	virtual bool(NSClientPlayer,string) ConsoleCommand;

	/* client */
	virtual void(NSClientPlayer) PlayerConnect;
	virtual void(NSClientPlayer) PlayerDisconnect;
	virtual void(NSClientPlayer) PlayerKill;
	virtual void(NSClientPlayer) PlayerSpawn;
	virtual void(NSClientPlayer) PlayerPreFrame;
	virtual void(NSClientPlayer) PlayerPostFrame;
	virtual void(NSClientPlayer) PlayerDeath;
	virtual void(NSClientPlayer) PlayerPain;
	virtual bool(NSClientPlayer) PlayerCanAttack;

	/* level transitions */
	virtual void(void) LevelNewParms;
	virtual void(NSClientPlayer) LevelChangeParms;

	/* Entities/Item manipulation */
	virtual int(int) MaxItemPerSlot;
	virtual bool(void) MonstersSpawn;
	virtual void(entity,entity,float,int,damageType_t) DamageApply;
	virtual bool(entity, vector) DamageCheckTrace;
	virtual void(vector,entity,float,float,int,int) DamageRadius;

	/* end of a game */
	virtual void(void) IntermissionStart;
	virtual void(void) IntermissionCycle;
	virtual void(void) IntermissionEnd;
	virtual bool(void) InIntermission;

	virtual bool(void) IsTeamplay;
	virtual bool(void) IsMultiplayer;

	/* spectator */
	/*virtual void(NSClientPlayer) SpectatorConnect;
	virtual void(NSClientPlayer) SpectatorDisconnect;
	virtual void(NSClientPlayer) SpectatorThink;*/
};

/* our currently running mode */
CGameRules g_grMode;
