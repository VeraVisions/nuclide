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

/* inspired by https://developer.valvesoftware.com/wiki/Inputs_and_Outputs */

/* modern trigger architecture */
class CBaseOutput:CBaseEntity
{
	entity m_eActivator;
	string m_strTarget;
	string m_strInput;
	string m_strData;
	float m_flDelay;
	int m_iCount;
	int m_iOldCount;

	void(void) CBaseOutput;
	virtual void(void) TriggerOutput;
	virtual void(void) SpawnInit;
	virtual void(void) Respawn;
};

void
CBaseOutput::TriggerOutput(void)
{
	/* plug into all the inputs. */
	for (entity f = world; (f = find(f, ::targetname, m_strTarget));) {
		CBaseTrigger trigger = (CBaseTrigger)f;

		if (trigger.Input != __NULL__) {
			trigger.Input(m_eActivator, m_strInput, m_strData);
		}
	}

	/* we're not -1 (infinite) and we've still got one use to deduct */
	if (m_iCount > 0)
		m_iCount--;
}

void
CBaseOutput::SpawnInit(void)
{
	/* EMPTY! */
}

void
CBaseOutput::Respawn(void)
{
	m_iCount = m_iOldCount;
}

void
CBaseOutput::CBaseOutput(void)
{
	gflags = GF_CANRESPAWN;
}
