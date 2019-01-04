/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

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

	void() env_spark;
	virtual void() CreateSpark;
	virtual void() TimedSpark;
	virtual void() Trigger;
	virtual void() Respawn;
};

void env_spark::CreateSpark(void)
{
	int r = floor((random() * spark_snd.length));
	sound(this, CHAN_AUTO, spark_snd[r], 1.0f, ATTN_IDLE);
	Effect_CreateSpark(self.origin, self.angles);
}

void env_spark::TimedSpark(void)
{
	CreateSpark();
	nextthink = time + (random() * m_flMaxDelay);
}

void env_spark::Trigger(void)
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
			m_flMaxDelay = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}
	for (i = 0; i < spark_snd.length; i++) {
		precache_sound(spark_snd[i]);
	}
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
