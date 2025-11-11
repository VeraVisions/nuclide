void SoundDef_Distance(entity target, string shader);
void SoundDef_DistancePos(vector pos, string shader);

static void pointsound_proper(vector origin, string sample, float volume, float attenuation, float pitch) = #483;

void
ncSoundDict::ncSoundDict(void)
{
	dist_min = 0;
	dist_max = 1000.0f;
	offset = 0;
	pitch_min = 100.0f;
	pitch_max = 100.0f;
	shakes = 0.0f;
	volume = 1.0f;
	flags = 0;
	playc = 0i;
	sample_count = 0i;
	samples = "";
	name = "";
	distshader = "";
	pointparticle = -1;
}

void
ncSoundDict::Play()
{
	PlayOnEntityChannel(world, CHAN_AUTO);
}

void
ncSoundDict::PlayOnEntity(entity targetEntity)
{
	PlayOnEntityChannel(targetEntity, CHAN_AUTO);
}

void
ncSoundDict::PlayOnEntityChannel(entity targetEntity, int audioChannel)
{
	int r;
	float radius;
	float pitch;
	int flag;
	string randomSample;

	if (sample_count <= 0) {
		return;
	}

	r = floor(random(0,  sample_count));
	tokenizebyseparator(samples, "\n");
	randomSample = argv(r);

	/* set pitch */
	pitch = random(pitch_min, pitch_max);
	radius = AttenuationValue();

	/* flags */
	if (flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (flags & SNDFL_GLOBAL) {
		radius = ATTN_NONE;
	}
	if (flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (flags & SNDFL_NODUPS) {
		if (playc >= sample_count) {
			playc = 0;
		}
		r = playc++;
	}
	if (flags & SNDFL_FOLLOW) {
		flag |= SOUNDFLAG_FOLLOW;
	}
	if (flags & SNDFL_STEP) {
		float s = vlen(targetEntity.velocity);

		if (s <= (g_pmoveVars.pm_walkspeed * 0.5)) {
			return;
		} else if (s <= g_pmoveVars.pm_walkspeed) {
			volume *= 0.35f;
		} else {
			volume *= 0.75f;
		}
	}

#ifdef CLIENT
	if (flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#else
	if (flags & SNDFL_PRIVATE) {
		flag |= SOUNDFLAG_UNICAST;
		msg_entity = targetEntity;
	}
	if (flags & SNDFL_ALERTS) {
		ncMonster_AlertEnemyAlliance(targetEntity.origin, dist_max, targetEntity.m_iAlliance);
		BotLib_Alert(targetEntity.origin, dist_max, targetEntity.team);
	}
#endif

	SndLog("Playing %S (radius: %f (%f))", randomSample, dist_max, radius );

#ifdef SERVER
	if (shakes > 0.0) {
		Client_ShakeOnce(targetEntity.origin, 512, 2.5, 1.0, 1.0f);
	}
#else
	if (shakes > 0.0) {
		float srad = 512;
		float dist = vlen(pSeat->m_vecPredictedOrigin - targetEntity.origin);
		if (dist < srad) {
			float dif = 1.0 - (dist/srad);
			pSeat->m_flShakeFreq = (1.0 * dif) * shakes;
			pSeat->m_flShakeAmp = (1.0 * dif) * shakes;
			pSeat->m_flShakeDuration = soundlength(randomSample);
			pSeat->m_flShakeTime = pSeat->m_flShakeDuration;
		}
	}
#endif

#ifdef CLIENT
	if (pointparticle > -1)
		pointparticles(pointparticle, targetEntity.origin, [0,0,0], 1);
#else
	if (pointparticle > -1)
		ncWarning("SoundDef %S is attempting to spawn a particle on the server side.", name);
#endif

	sound(
		targetEntity,
		audioChannel,
		randomSample,
		volume,
		radius,
		pitch,
		flag,
		offset
	);

#ifdef SERVER
	if (music_count > 0) {
		r = floor(random(0,  music_count));
		tokenizebyseparator(musictracks, "\n");
		randomSample = argv(r);
		
		if (flags & SNDFL_PRIVATE) {
			if (flags & SNDFL_LOOPING) {
				music.PlayOnClient(precache.Music(randomSample), targetEntity);
			} else {
				music.PlayOnceOnClient(precache.Music(randomSample), targetEntity);
			}
		} else {
			if (flags & SNDFL_LOOPING) {
				music.Play(precache.Music(randomSample));
			} else {
				music.PlayOnce(precache.Music(randomSample));
			}
		}
	}
#endif

	if (STRING_SET(distshader)) {
		SoundDef_Distance(targetEntity, distshader);
	}
}

void
ncSoundDict::PlayOnSpot(vector targetSpot)
{
	int r;
	float radius;
	float pitch;
	int flag;
	int sample;
	string randomSample;

	r = floor(random(0,  sample_count));
	tokenizebyseparator(samples, "\n");

	/* set pitch */
	pitch = random(pitch_min, pitch_max);

	/* flags */
	if (flags & SNDFL_NOREVERB) {
		flag |= SOUNDFLAG_NOREVERB;
	}
	if (flags & SNDFL_GLOBAL) {
		radius = 0;
	}
	if (flags & SNDFL_LOOPING) {
		flag |= SOUNDFLAG_FORCELOOP;
	}
	if (flags & SNDFL_NODUPS) {
		if (playc >= sample_count) {
			playc = 0;
		}
		r = playc++;
	}

#ifdef CLIENT
	if (flags & SNDFL_OMNI) {
		flag |= SOUNDFLAG_NOSPACIALISE;
	}
#endif

	SndLog("Playing %s %S (radius: %f)", name, randomSample, dist_max );

	/* really? this doesn't do any more? */
	pointsound_proper(targetSpot, randomSample, volume, AttenuationValue(), pitch);

	if (STRING_SET(distshader)) {
		SoundDef_DistancePos(targetSpot, distshader);
	}
}

float
ncSoundDict::AttenuationValue(void)
{
	if (dist_max == 0) {
		return 0;
	} else {
		return autocvar_s_nominaldistance / dist_max;
	}
}
