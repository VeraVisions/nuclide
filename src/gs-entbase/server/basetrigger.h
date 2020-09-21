/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

enum
{ 
	USE_TOGGLE,
	USE_CONTINOUS
};

enum
{
	TRIG_OFF,
	TRIG_ON,
	TRIG_TOGGLE
};

class CBaseTrigger:CBaseEntity
{
	int m_strGlobalState;
	string m_strKillTarget;
	string m_strMessage;
	string m_strMaster;
	int m_iUseType;
	int m_iTeam;
	int m_iValue;

	void(void) CBaseTrigger;

	/* modern trigger architecture */
	string m_strOnTrigger;
	virtual void(entity, string) UseOutput;
	virtual string(string) CreateOutput;
	virtual void(entity, string, string) Input;

	/* legacy trigger architecture */
	float m_flDelay;
	virtual void(entity, int) Trigger;
	virtual void(entity, int, float) UseTargets;

	/* master feature */
	virtual int(void) GetValue;
	virtual int(void) GetMaster;

	/* spawn setup helpers */
	virtual void(void) InitBrushTrigger;
	virtual void(void) InitPointTrigger;

	virtual void(string, string) SpawnKey;
};
