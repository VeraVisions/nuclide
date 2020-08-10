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

/*QUAKED env_spark (1 0 0) (-8 -8 -8) (8 8 8) x x x x x EVSPARK_TOGGLE EVSPARK_STARTON
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"angles"        Sets the pitch, yaw and roll angles of the spark.
"MaxDelay"      Delay between sparks when start-on (or toggle) is set

Creates a series (or just one) spark effect with sound when triggered.
*/

enumflags
{
	EVSPARK_UNUSED1,
	EVSPARK_UNUSED2,
	EVSPARK_UNUSED3,
	EVSPARK_UNUSED4,
	EVSPARK_UNUSED5,
	EVSPARK_TOGGLE,
	EVSPARK_STARTON
};

string spark_snd[] = {
	"buttons/spark1.wav",
	"buttons/spark2.wav",
	"buttons/spark3.wav",
	"buttons/spark4.wav",
	"buttons/spark5.wav",
	"buttons/spark6.wav"
};

class env_spark:CBaseTrigger
{
	float m_flMaxDelay;

	void(void) env_spark;
	virtual void(void) CreateSpark;
	virtual void(void) TimedSpark;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
};

void env_spark::CreateSpark(void)
{
	int r = floor((random() * spark_snd.length));
	sound(this, CHAN_AUTO, spark_snd[r], 1.0f, ATTN_IDLE);
	FX_Spark(self.origin, self.angles);
}

void env_spark::TimedSpark(void)
{
	CreateSpark();
	nextthink = time + (random() * m_flMaxDelay);
}

/* TODO: Implement state */
void env_spark::Trigger(entity act, int state)
{
	if (spawnflags & EVSPARK_TOGGLE) {
		if (think != __NULL__) {
			think = __NULL__;
			nextthink = 0;
		} else {
			think = TimedSpark;
			nextthink = time + (random() * m_flMaxDelay);
		}
	} else {
		CreateSpark();
	}
}

void env_spark::Respawn(void)
{
	if (m_flMaxDelay <= 0) {
		m_flMaxDelay = 1.0f;
	}

	if (spawnflags & EVSPARK_STARTON) {
		think = TimedSpark;
		nextthink = time + (random() * m_flMaxDelay);
	}
}

void env_spark::env_spark(void)
{
	int i;
	for (i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "MaxDelay":
			m_flMaxDelay = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
	for (i = 0; i < spark_snd.length; i++) {
		precache_sound(spark_snd[i]);
	}
	CBaseTrigger::CBaseTrigger();
}
