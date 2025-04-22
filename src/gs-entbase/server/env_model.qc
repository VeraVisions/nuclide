/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/*! \brief Server-Entity: Decorative Model With Animation Features */
/*!QUAKED env_model (1 .5 0) (-8 -8 -8) (8 8 8) START_OFF DROPTOFLOOR SOLID
# OVERVIEW
Model that can switch framegroups when triggered.

# KEYS
- "targetname" : Name
- "model" : Path to the model.
- "rendercolor" : Render color
- "renderamt" : Render amount
- "m_iszSequence_On" : Sequence when 'ON'
- "m_iszSequence_Off" : Sequence when 'OFF'

# SPAWNFLAGS
- START_OFF (1) : Start 'off'.
- DROPTOFLOOR (2) : Drop down to floor below (or else, stay in the air).
- SOLID (4) : Enable collision.

# TRIVIA
This entity was introduced in Spirit of Half-Life (2000).

@ingroup serverentity
@ingroup pointentity
*/
class
env_model:ncRenderableEntity
{
public:
	void env_model(void);
	virtual void SpawnKey(string, string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);

private:
	bool m_modelState;
	int m_iOnSequence;
	int m_iOffSequence;
	int m_iOnAction;
	int m_iOffAction;
};

void
env_model::env_model(void)
{
	m_modelState = true;
	m_iOnSequence = 0i;
	m_iOffSequence = 0i;
	m_iOnAction = 0i;
	m_iOffAction = 0i;
}

void
env_model::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "m_iszSequence_On":
		m_iOnSequence = ReadInt(setValue);
		break;
	case "m_iszSequence_Off":
		m_iOffSequence = ReadInt(setValue);
		break;
	case "m_iAction_On":
		m_iOnAction = ReadInt(setValue);
		break;
	case "m_iAction_Off":
		m_iOffAction = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
env_model::Respawn(void)
{
	super::Respawn();

	/* solid */
	if (HasSpawnFlags(4)) {
		SetSolid(SOLID_BBOX);
	} else {
		SetSolid(SOLID_NOT);
	}

	/* droptofloor */
	if (HasSpawnFlags(2)) {
		DropToFloor();
	}

	/* start off */
	if (HasSpawnFlags(1)) {
		Trigger(this, TRIG_OFF);
	} else {
		Trigger(this, TRIG_ON);
	}
}

void
env_model::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_modelState = false;
		break;
	case TRIG_ON:
		m_modelState = true;
		break;
	default:
		m_modelState = true - m_modelState;
		break;
	}

	SetFrame(m_modelState == true ? m_iOnSequence : m_iOffSequence);
}