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

/*QUAKED speaker (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"    Name
"preset"        Preset sentence group.
"message"       Sentence group name (used when preset is 0)
"health"        Message volume (value from 0-10)

Creates a public announcement system that randomly plays announcements from
the sentences.txt file.

Valid values for 'preset":
    0 = Use Sentence group name
    1 = C1A0_
    2 = C1A1_
    3 = C1A2_
    4 = C1A3_
    5 = C1A4_
    6 = C2A1_
    7 = C2A2_
    8 = C2A3_
    9 = C2A4_
    10 = C2A5_
    11 = C3A1_
    12 = C3A2_
*/

enumflags
{
	SPEAKFL_SILENT
};

string g_speaker_hlpresets[] = {
	"!C1A0_",
	"!C1A1_",
	"!C1A2_",
	"!C1A3_",
	"!C1A4_",
	"!C2A1_",
	"!C2A2_",
	"!C2A3_",
	"!C2A4_",
	"!C2A5_",
	"!C3A1_",
	"!C3A2_"
};

class speaker:CBaseNPC
{
	string m_strSentence;
	float m_flVolume;

	void(void) speaker;

	virtual void(void) Annouce;
	virtual void(void) Respawn;
	virtual void(void) Trigger;
};

void
speaker::Annouce(void)
{
	string seq = Sentences_GetSamples(m_strSentence);

	if (seq == "") {
		return;
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, seq);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);

	nextthink = time + random(30,60);
}

void
speaker::Respawn(void)
{
	/* force this thing to be networked */
	SetModel("models/player.mdl");
	SetOrigin(m_oldOrigin);
	SetRenderMode(RM_COLOR);
	SetRenderAmt(0);

	think = Annouce;

	if (!(spawnflags & SPEAKFL_SILENT))
		nextthink = time + 10.0f;
}

void
speaker::Trigger(void)
{
	nextthink = time;
}

void
speaker::speaker(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "preset":
			int p = stoi(argv(i+1));

			/* fit in a valid preset string */
			if (p > 0 && p < g_speaker_hlpresets.length)
				m_strSentence = g_speaker_hlpresets[p-1];
			break;
		case "message":
			m_strSentence = argv(i+1);
			break;
		case "health":
			m_flVolume = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
	CBaseNPC::CBaseNPC();
}
