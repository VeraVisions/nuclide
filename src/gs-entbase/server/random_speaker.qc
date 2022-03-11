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

/*QUAKED random_speaker (1 0 0) (-8 -8 -8) (8 8 8)
This entity plays a .wav file at random intervals.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered
"killtarget" : Target to kill when triggered
"rsnoise" : Path to the sound file.
"volume" : Volume to play the sound as (normalized, 0.0 - 1.0).
"wait" : Minimum time for sound repetition in %.
"random" : Random % of this added to wait.

-------- NOTES --------
To explain the math behind it:
The 'wait' key specifies the minimum time it waits to play itself again,
however we always add a bit of a random interval on top.
The random interval is a set percentage of the specified 'wait' time.
For example, if 'wait' is 10 and 'random' is 50, then it'll always be
a random interval between 10 and 15 seconds in total.

-------- TRIVIA --------
It was introduced in Gunman Chronicles (2000).
*/

class random_speaker:NSPointTrigger
{
	string m_strSample;
	float m_flVolume;
	float m_flMinPos;
	float m_flRandPercent;

	void(void) random_speaker;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;

	virtual void(void) PlaySample;
	virtual void(void) Enable;
	virtual void(void) Disable;
};

void
random_speaker::Save(float handle)
{
	SaveString(handle, "sample", m_strSample);
	SaveFloat(handle, "volume", m_flVolume);
	SaveFloat(handle, "min_pos", m_flMinPos);
	SaveFloat(handle, "rand_percent", m_flRandPercent);
	super::Save(handle);
}

void
random_speaker::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "sample":
		m_strSample = ReadString(strValue);
		break;
	case "volume":
		m_flVolume = ReadFloat(strValue);
		break;
	case "min_pos":
		m_flMinPos = ReadFloat(strValue);
		break;
	case "rand_percent":
		m_flRandPercent = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
random_speaker::PlaySample(void)
{
	sound(this, CHAN_VOICE, m_strSample, m_flVolume, ATTN_NONE);

	/* cue the next time we're playing this sample */
	Enable();
}

void
random_speaker::Enable(void)
{
	float r;

	m_iValue = 1;

	/* at least wait this amount */
	r = time + m_flMinPos;

	/* then take the specified percentage of 'wait', by random and add it */
	r += (m_flMinPos * (m_flRandPercent / 100)) * random();

	think = PlaySample;
	nextthink = r;

	print("^2random_speaker::^3Disable^7: " \
	       "%s playing %s in %d\n", \
	       targetname, m_strSample, r);
}

void
random_speaker::Disable(void)
{
	dprint("^2random_speaker::^3Disable^7: " \
	       "Disabled %s playing %s\n", \
	       targetname, m_strSample);

	m_iValue = 0;
	think = __NULL__;
	nextthink = 0;
}

void
random_speaker::Trigger(entity act, int state)
{
	if (GetMaster() == FALSE)
		return;

	switch (state) {
	case TRIG_OFF:
		Disable();
		break;
	case TRIG_ON:
		Enable();
		break;
	default:
		if (m_iValue)
			Trigger(act, TRIG_OFF);
		else
			Trigger(act, TRIG_ON);
	}
	
}

void
random_speaker::Respawn(void)
{
	Disable();
}

void
random_speaker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "rsnoise":
		m_strSample = strValue;
		break;
	case "volume":
		m_flVolume = stof(strValue);
		break;
	case "wait":
		m_flMinPos = stof(strValue);
		break;
	case "random":
		m_flRandPercent = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
random_speaker::random_speaker(void)
{
	super::NSPointTrigger();
}
