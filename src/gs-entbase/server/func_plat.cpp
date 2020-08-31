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

/*QUAKED func_plat (0 .5 .8) ?
"targetname"    Name

Brush that lets light to pass through it.
On idTech 2 BSPs, it will change texture variants when triggered.
*/

enum
{
	PLATSTATE_RAISED,
	PLATSTATE_LOWERED,
	PLATSTATE_UP,
	PLATSTATE_DOWN
};

class func_plat:CBaseTrigger
{
	int m_iState;

	float m_flSpeed;
	float m_flHeight;

	void(void) func_plat;
	virtual void(entity, int) Trigger;
	virtual void(void) MoveUp;
	virtual void(void) MoveDown;
	virtual void(void) ArrivedUp;
	virtual void(void) ArrivedDown;
	virtual void(void) Respawn;
	virtual void(void) touch;
};

void
func_plat::touch(void)
{
	if (other.movetype != MOVETYPE_WALK) {
		return;
	}

	Trigger(other, TRIG_TOGGLE);

}

void
func_plat::MoveDown(void)
{
	vector vecDifference;
	float flTravel, fTravelTime;

	m_iState = PLATSTATE_DOWN;
	vecDifference = ((m_oldOrigin - [0,0,m_flHeight]) - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);
	think = ArrivedDown;

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1f;
		return;
	}

	velocity = (vecDifference * (1.0f / fTravelTime));
	nextthink = (ltime + fTravelTime);
}

void
func_plat::MoveUp(void)
{
	vector vecDifference;
	float flTravel, fTravelTime;

	m_iState = PLATSTATE_UP;
	vecDifference = (m_oldOrigin - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);
	think = ArrivedUp;

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1f;
		return;
	}

	velocity = (vecDifference * (1.0f / fTravelTime));
	nextthink = (ltime + fTravelTime);
}

void
func_plat::ArrivedUp(void)
{
	velocity = [0,0,0];
	m_iState = PLATSTATE_RAISED;
}

void
func_plat::ArrivedDown(void)
{
	velocity = [0,0,0];
	m_iState = PLATSTATE_LOWERED;
}

void
func_plat::Trigger(entity act, int state)
{
	if (m_iState == PLATSTATE_RAISED) {
		MoveDown();
	} else if (m_iState == PLATSTATE_LOWERED) {
		MoveUp();
	}
}

void
func_plat::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	
	m_iState = PLATSTATE_RAISED;
}

void
func_plat::func_plat(void)
{
	m_flSpeed = 100.0f;

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "height":
			m_flHeight = stof(argv(i+1));
			break;
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
}
