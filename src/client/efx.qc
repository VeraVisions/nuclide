/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#ifndef EFXDATA_DYNAMIC
	#ifndef EFXDATA_MAX
		#define EFXDATA_MAX 64
	#endif
#endif

/*
#define EFXDATA_DYNAMIC

Your game can define EFXDATA_DYNAMIC in its progs.src if you want an unpredictable amount of EFX definitions.
Other than that, you can increase the value of EFXDATA_MAX.

We switched to up-front allocation because QCLIB fragments memory like hell as there's
no real garbage collector to speak of
*/

void
EFX_DebugInfo(void)
{
	static vector pos = [16, 16];

	static void epr(string tx) {
		Font_DrawText(pos, tx, FONT_CON);
		pos[1] += 12;
	}

	pos = [16,16];
	epr("OpenAL EFX Debug Information:");
	epr(strcat("EFX Name: ", g_efx_name[g_iEFX]));
	epr(sprintf("Density: %d", g_efx[g_iEFX].flDensity));
	epr(sprintf("Diffusion: %d", g_efx[g_iEFX].flDiffusion));
	epr(sprintf("Gain: %d", g_efx[g_iEFX].flGain));
	epr(sprintf("Gain HF: %d", g_efx[g_iEFX].flGainHF));
	epr(sprintf("Gain LF: %d", g_efx[g_iEFX].flGainLF));
	epr(sprintf("Decay Time: %d", g_efx[g_iEFX].flDecayTime));
	epr(sprintf("Decay HF Ratio: %d", g_efx[g_iEFX].flDecayHFRatio));
	epr(sprintf("Decay LF Ratio: %d", g_efx[g_iEFX].flDecayLFRatio));
	epr(sprintf("Reflections Gain: %d", g_efx[g_iEFX].flReflectionsGain));
	epr(sprintf("Reflections Delay: %d", g_efx[g_iEFX].flReflectionsDelay));
	epr(sprintf("Reflections Pan: %v", g_efx[g_iEFX].flReflectionsPan));
	epr(sprintf("Late Reverb Gain: %d", g_efx[g_iEFX].flLateReverbGain));
	epr(sprintf("Late Reverb Delay: %d", g_efx[g_iEFX].flLateReverbDelay));
	epr(sprintf("Late Reverb Pan: %v", g_efx[g_iEFX].flLateReverbPan));
	epr(sprintf("Echo Time: %d", g_efx[g_iEFX].flEchoTime));
	epr(sprintf("Echo Depth: %d", g_efx[g_iEFX].flEchoDepth));
	epr(sprintf("Modulation Time: %d", g_efx[g_iEFX].flModulationTime));
	epr(sprintf("Modulation Depth: %d", g_efx[g_iEFX].flModulationDepth));
	epr(sprintf("Air Absorption Gain HF: %d", g_efx[g_iEFX].flAirAbsorptionGainHF));
	epr(sprintf("HF Reference: %d", g_efx[g_iEFX].flHFReference));
	epr(sprintf("LF Reference: %d", g_efx[g_iEFX].flLFReference));
	epr(sprintf("Romm Rolloff Factor: %d", g_efx[g_iEFX].flRoomRolloffFactor));
	epr(sprintf("Decay HF Limit: %i", g_efx[g_iEFX].iDecayHFLimit));
}

int
EFX_Load(string efx_file)
{
	filestream fh;
	string line;
	int i;

	if (!efx_file) {
		return (0);
	}

	i = g_efx_count;
	efx_file = strtolower(efx_file);

	/* check if it's already cached */
	for (int x = 0; x < g_efx_count; x++) {
		if (efx_file == g_efx_name[x]) {
			return x;
		}
	}

	g_efx_count++;

#ifdef EFXDATA_DYNAMIC
	g_efx = (reverbinfo_t *)memrealloc(g_efx, sizeof(reverbinfo_t), i, g_efx_count);
	g_efx_name = (string *)memrealloc(g_efx_name, sizeof(string), i, g_efx_count);
#else
	if (g_efx_count > EFXDATA_MAX) {
		error(sprintf("EFX_Load: Reached EFXDATA_MAX (%d)\n", EFXDATA_MAX));
	}
#endif

	fh = fopen(strcat("efx/", efx_file, ".efx"), FILE_READ);

	if (fh < 0) {
		return (0);
	}

	/* cache the name */
	g_efx_name[i] = efx_file;

	/* add some default values */
	g_efx[i].flDensity = 1.000000;
	g_efx[i].flDiffusion = 1.000000;
	g_efx[i].flGain = 0.000000;
	g_efx[i].flGainHF = 1.000000;
	g_efx[i].flGainLF = 1.000000;
	g_efx[i].flDecayTime = 1.000000;
	g_efx[i].flDecayHFRatio = 1.000000;
	g_efx[i].flDecayLFRatio = 1.000000;
	g_efx[i].flReflectionsGain = 0.000000;
	g_efx[i].flReflectionsDelay = 0.000000;
	g_efx[i].flReflectionsPan = [0,0,0];
	g_efx[i].flLateReverbGain = 1.000000;
	g_efx[i].flLateReverbDelay = 0.000000;
	g_efx[i].flLateReverbPan = [0,0,0];
	g_efx[i].flEchoTime = 0.250000;
	g_efx[i].flEchoDepth = 0.000000;
	g_efx[i].flModulationTime = 0.250000;
	g_efx[i].flModulationDepth = 0.000000;
	g_efx[i].flAirAbsorptionGainHF = 1.000000;
	g_efx[i].flHFReference = 5000.000000;
	g_efx[i].flLFReference = 250.000000;
	g_efx[i].flRoomRolloffFactor = 0.000000;
	g_efx[i].iDecayHFLimit = 1i;

	while ((line = fgets(fh))) {
		int c = tokenize_console(line);

		switch (argv(0)) {
		case "density":
			g_efx[i].flDensity = stof(argv(1));
			break;
		case "diffusion":
			g_efx[i].flDiffusion = stof(argv(1));
			break;
		case "gain":
			g_efx[i].flGain = stof(argv(1));
			break;
		case "gain_hf":
			g_efx[i].flGainHF = stof(argv(1));
			break;
		case "gain_lf":
			g_efx[i].flGainLF = stof(argv(1));
			break;
		case "decay_time":
			g_efx[i].flDecayTime = stof(argv(1));
			break;
		case "decay_hf_ratio":
			g_efx[i].flDecayHFRatio = stof(argv(1));
			break;
		case "decay_lf_ratio":
			g_efx[i].flDecayLFRatio = stof(argv(1));
			break;
		case "reflections_gain":
			g_efx[i].flReflectionsGain = stof(argv(1));
			break;
		case "reflections_delay":
			g_efx[i].flReflectionsDelay = stof(argv(1));
			break;
		case "reflections_pan": /* VECTOR! */
			g_efx[i].flReflectionsPan = stov(argv(1));
			break;
		case "late_reverb_gain":
			g_efx[i].flLateReverbGain = stof(argv(1));
			break;
		case "late_reverb_delay":
			g_efx[i].flLateReverbDelay = stof(argv(1));
			break;
		case "late_reverb_pan":
			g_efx[i].flLateReverbPan = stov(argv(1));
			break;
		case "echo_time":
			g_efx[i].flEchoTime = stof(argv(1));
			break;
		case "echo_depth":
			g_efx[i].flEchoDepth = stof(argv(1));
			break;
		case "modulation_time":
			g_efx[i].flModulationTime = stof(argv(1));
			break;
		case "modulation_depth":
			g_efx[i].flModulationDepth = stof(argv(1));
			break;
		case "air_absorbtion_hf":
			g_efx[i].flAirAbsorptionGainHF = stof(argv(1));
			break;
		case "hf_reference":
			g_efx[i].flHFReference = stof(argv(1));
			break;
		case "lf_reference":
			g_efx[i].flLFReference = stof(argv(1));
			break;
		case "room_rolloff_factor":
			g_efx[i].flRoomRolloffFactor = stof(argv(1));
			break;
		case "decay_limit":
			g_efx[i].iDecayHFLimit = stoi(argv(1));
			break;
		}
	}

	print(sprintf("parsed EFXDef file %s\n", efx_file));
	fclose(fh);
	return i;
}

void
EFX_SetEnvironment(int id)
{
	/* out of bounds... MAP BUG! */
	if (id >= g_efx_count)
		return;

	/* same as before, skip */
	if (g_iEFX == id)
		return;

	g_iEFXold = g_iEFX;
	g_iEFX = id;
	g_flEFXTime = 0.0f;
}

void
EFX_Interpolate(int id)
{
	mix.flDensity = Math_Lerp(mix.flDensity, g_efx[id].flDensity, g_flEFXTime);
	mix.flDiffusion = Math_Lerp(mix.flDiffusion, g_efx[id].flDiffusion, g_flEFXTime);
	mix.flGain = Math_Lerp(mix.flGain, g_efx[id].flGain, g_flEFXTime);
	mix.flGainHF = Math_Lerp(mix.flGainHF, g_efx[id].flGainHF, g_flEFXTime);
	mix.flGainLF = Math_Lerp(mix.flGainLF, g_efx[id].flGainLF, g_flEFXTime);
	mix.flDecayTime = Math_Lerp(mix.flDecayTime, g_efx[id].flDecayTime, g_flEFXTime);
	mix.flDecayHFRatio = Math_Lerp(mix.flDecayHFRatio, g_efx[id].flDecayHFRatio, g_flEFXTime);
	mix.flDecayLFRatio = Math_Lerp(mix.flDecayLFRatio, g_efx[id].flDecayLFRatio, g_flEFXTime);
	mix.flReflectionsGain = Math_Lerp(mix.flReflectionsGain, g_efx[id].flReflectionsGain, g_flEFXTime);
	mix.flReflectionsDelay = Math_Lerp(mix.flReflectionsDelay, g_efx[id].flReflectionsDelay, g_flEFXTime);
	mix.flReflectionsPan[0] = Math_Lerp(mix.flReflectionsPan[0], g_efx[id].flReflectionsPan[0], g_flEFXTime);
	mix.flReflectionsPan[1] = Math_Lerp(mix.flReflectionsPan[1], g_efx[id].flReflectionsPan[1], g_flEFXTime);
	mix.flReflectionsPan[1] = Math_Lerp(mix.flReflectionsPan[2], g_efx[id].flReflectionsPan[2], g_flEFXTime);
	mix.flLateReverbGain = Math_Lerp(mix.flLateReverbGain, g_efx[id].flLateReverbGain, g_flEFXTime);
	mix.flLateReverbDelay = Math_Lerp(mix.flLateReverbDelay, g_efx[id].flLateReverbDelay, g_flEFXTime);
	mix.flLateReverbPan[0] = Math_Lerp(mix.flLateReverbPan[0], g_efx[id].flLateReverbPan[0], g_flEFXTime);
	mix.flLateReverbPan[1] = Math_Lerp(mix.flLateReverbPan[1], g_efx[id].flLateReverbPan[1], g_flEFXTime);
	mix.flLateReverbPan[2] = Math_Lerp(mix.flLateReverbPan[2], g_efx[id].flLateReverbPan[2], g_flEFXTime);
	mix.flEchoTime = Math_Lerp(mix.flEchoTime, g_efx[id].flEchoTime, g_flEFXTime);
	mix.flEchoDepth = Math_Lerp(mix.flEchoDepth, g_efx[id].flEchoDepth, g_flEFXTime);
	mix.flModulationTime = Math_Lerp(mix.flModulationTime, g_efx[id].flModulationTime, g_flEFXTime);
	mix.flModulationDepth = Math_Lerp(mix.flModulationDepth, g_efx[id].flModulationDepth, g_flEFXTime);
	mix.flAirAbsorptionGainHF = Math_Lerp(mix.flAirAbsorptionGainHF, g_efx[id].flAirAbsorptionGainHF, g_flEFXTime);
	mix.flHFReference = Math_Lerp(mix.flHFReference, g_efx[id].flHFReference, g_flEFXTime);
	mix.flLFReference = Math_Lerp(mix.flLFReference, g_efx[id].flLFReference, g_flEFXTime);
	mix.flRoomRolloffFactor = Math_Lerp(mix.flRoomRolloffFactor, g_efx[id].flRoomRolloffFactor, g_flEFXTime);
	mix.iDecayHFLimit = Math_Lerp(mix.iDecayHFLimit, g_efx[id].iDecayHFLimit, g_flEFXTime);
}

void
EFX_UpdateListener(NSView playerView)
{
	static int old_dsp;

	vector vecPlayer;

	if (autocvar_s_al_use_reverb == FALSE) {
		return;
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	float bestdist = 999999;
	for (entity e = world; (e = find(e, classname, "env_sound"));) {
		env_sound scape = (env_sound)e;
		
		other = world;
		traceline(scape.origin, vecPlayer, MOVE_OTHERONLY, scape);
		if (trace_fraction < 1.0f) {
			continue;
		}

		float dist = vlen(e.origin - vecPlayer);
		if (dist > scape.m_iRadius) {
			continue;
		}

		if (dist > bestdist) {
			continue;
		}

		bestdist = dist;
		EFX_SetEnvironment(scape.m_iRoomType);
	}

	makevectors(playerView.GetCameraAngle());
	SetListener(playerView.GetCameraOrigin(), v_forward, v_right, v_up, 12);

	if (old_dsp == g_iEFX) {
		return;
	}

#ifdef EFX_LERP
	if (g_flEFXTime < 1.0)
	{
		EFX_Interpolate(g_iEFX);
		setup_reverb(12, &mix, sizeof(reverbinfo_t));
	} else {
		old_dsp = g_iEFX;
	}
	g_flEFXTime += clframetime;
#else
	NSLog("EFX_UpdateListener: Changed style to %s (%i)", 
		g_efx_name[g_iEFX], g_iEFX);

	old_dsp = g_iEFX;
	setup_reverb(12, &g_efx[g_iEFX], sizeof(reverbinfo_t));
#endif
}

void
EFX_Init(void)
{
	int efx_default;
	int efx_underwater;

	print("--------- Initializing EFXDefs ----------\n");

#ifndef EFXDATA_DYNAMIC
	g_efx = (reverbinfo_t *)memalloc(sizeof(reverbinfo_t) * EFXDATA_MAX);
	g_efx_name = (string *)memalloc(sizeof(string) * EFXDATA_MAX);
	print(sprintf("allocated %d bytes for EFXDefs.\n", (sizeof(string) * EFXDATA_MAX) + (sizeof(reverbinfo_t) * EFXDATA_MAX)));
#else
	print("dynamic allocation for EFXDefs enabled.\n");
#endif

	efx_default = EFX_Load("default");
	efx_underwater = EFX_Load("underwater");
	EFX_SetEnvironment(efx_default);

	/* mix the final value immediately */
#ifdef EFX_LERP
	g_flEFXTime = 1.0f;
	EFX_Interpolate(g_iEFX);
#endif

	setup_reverb(12, &g_efx[g_iEFX], sizeof(reverbinfo_t));
	setup_reverb(10, &g_efx[efx_underwater], sizeof(reverbinfo_t));
}

void
EFX_Shutdown(void)
{
	if (!g_efx_count)
		return;

	g_efx_count = 0;
	memfree(g_efx);
}
