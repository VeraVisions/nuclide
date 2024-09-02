void
NSSoundScape::NSSoundScape(void)
{
	m_density = 1.0f;
	m_diffusion = 1.0f;
	m_gain = 0.32f;
	m_gainHF = 0.89f;
	m_gainLF = 0.0f;
	m_decayTime = 1.49f;
	m_decayHFRatio = 0.83f;
	m_decayLFRatio = 1.0f;
	m_reflectionGain = 0.05f;
	m_reflectionDelay = 0.007f;
	m_reflectionPan = g_vec_null;
	m_LateGain = 1.26f;
	m_LateDelay = 0.011f;
	m_LatePan = g_vec_null;
	m_echoTime = 0.25f;
	m_echoDepth = 0.0f;
	m_modulationTime = 0.25f;
	m_modulationDepth = 0.0f;
	m_airAbsorptionGainHF = 0.994f;
	m_HFReference = 5000.0f;
	m_LFReference = 250.0f;
	m_roomRolloffFactor = 0.0f;
	m_decayHFLimit = 1i;
	m_radius = 0.0f;
}

#ifdef SERVER
void
NSSoundScape::SetDensity(float newDensity)
{
	m_density = newDensity;
}

void
NSSoundScape::SetDiffusion(float newDiffusion)
{
	m_diffusion = newDiffusion;
}

void
NSSoundScape::SetGain(float newGain)
{
	m_gain = newGain;
}

void
NSSoundScape::SetGainHF(float newGainHF)
{
	m_gainHF = newGainHF;
}

void
NSSoundScape::SetGainLF(float newGainLF)
{
	m_gainLF = newGainLF;
}

void
NSSoundScape::SetDecayTime(float newDecayTime)
{
	m_decayTime = newDecayTime;
}

void
NSSoundScape::SetDecayHFRatio(float newDecayHFRatio)
{
	m_decayHFRatio = newDecayHFRatio;
}

void
NSSoundScape::SetDecayLFRatio(float newDecayLFRatio)
{
	m_decayLFRatio = newDecayLFRatio;
}

void
NSSoundScape::SetReflectionGain(float newReflectionGain)
{
	m_reflectionGain = newReflectionGain;
}

void
NSSoundScape::SetReflectionDelay(float newReflectionDelay)
{
	m_reflectionDelay = newReflectionDelay;
}

void
NSSoundScape::SetReflectionPan(vector newReflectionPan)
{
	m_reflectionPan = newReflectionPan;
}

void
NSSoundScape::SetLateGain(float newLateGain)
{
	m_LateGain = newLateGain;
}

void
NSSoundScape::SetLateDelay(float newLateDelay)
{
	m_LateDelay = newLateDelay;
}

void
NSSoundScape::SetLatePan(vector newLatePan)
{
	m_LatePan = newLatePan;
}

void
NSSoundScape::SetEchoTime(float newLateEchoTime)
{
	m_echoTime = newLateEchoTime;
}

void
NSSoundScape::SetEchoDepth(float newEchoDepth)
{
	m_echoDepth = newEchoDepth;
}

void
NSSoundScape::SetModulationTime(float newModulationTime)
{
	m_modulationTime = newModulationTime;
}

void
NSSoundScape::SetModulationDepth(float newModulationDepth)
{
	m_modulationDepth = newModulationDepth;
}

void
NSSoundScape::SetAirAbsorptionGainHF(float newAirAbsorptionGainHF)
{
	m_airAbsorptionGainHF = newAirAbsorptionGainHF;
}

void
NSSoundScape::SetHFReference(float newHFReference)
{
	m_HFReference = newHFReference;
}

void
NSSoundScape::SetLFReference(float newLFReference)
{
	m_LFReference = newLFReference;
}

void
NSSoundScape::SetRoomRolloffFactor(float newRoomRolloffFactor)
{
	m_roomRolloffFactor = newRoomRolloffFactor;
}

void
NSSoundScape::SetDecayHFLimit(int newDecayHFLimit)
{
	m_decayHFLimit = newDecayHFLimit;
}

void
NSSoundScape::SetRadius(float newRadius)
{
	m_radius = newRadius;
}
#endif

#ifdef CLIENT
float
NSSoundScape::GetDensity(void)
{
	return (m_density);
}

float
NSSoundScape::GetDiffusion(void)
{
	return (m_diffusion);
}

float
NSSoundScape::GetGain(void)
{
	return (m_gain);
}

float
NSSoundScape::GetGainHF(void)
{
	return (m_gainHF);
}

float
NSSoundScape::GetGainLF(void)
{
	return (m_gainLF);
}

float
NSSoundScape::GetDecayTime(void)
{
	return (m_decayTime);
}

float
NSSoundScape::GetDecayHFRatio(void)
{
	return (m_decayHFRatio);
}

float
NSSoundScape::GetDecayLFRatio(void)
{
	return (m_decayLFRatio);
}

float
NSSoundScape::GetReflectionGain(void)
{
	return (m_reflectionGain);
}

float
NSSoundScape::GetReflectionDelay(void)
{
	return (m_reflectionDelay);
}

vector
NSSoundScape::GetReflectionPan(void)
{
	return (m_reflectionPan);
}

float
NSSoundScape::GetLateGain(void)
{
	return (m_LateGain);
}

float
NSSoundScape::GetLateDelay(void)
{
	return (m_LateDelay);
}

vector
NSSoundScape::GetLatePan(void)
{
	return (m_LatePan);
}

float
NSSoundScape::GetEchoTime(void)
{
	return (m_echoTime);
}

float
NSSoundScape::GetEchoDepth(void)
{
	return (m_echoDepth);
}

float
NSSoundScape::GetModulationTime(void)
{
	return (m_modulationTime);
}

float
NSSoundScape::GetModulationDepth(void)
{
	return (m_modulationDepth);
}

float
NSSoundScape::GetAirAbsorptionGainHF(void)
{
	return (m_airAbsorptionGainHF);
}

float
NSSoundScape::GetHFReference(void)
{
	return (m_HFReference);
}

float
NSSoundScape::GetLFReference(void)
{
	return (m_LFReference);
}

float
NSSoundScape::GetRoomRolloffFactor(void)
{
	return (m_roomRolloffFactor);
}

int
NSSoundScape::GetDecayHFLimit(void)
{
	return (m_decayHFLimit);
}

float
NSSoundScape::GetRadius(void)
{
	return (m_radius);
}
#endif

/* Networking */
#ifdef SERVER
void
NSSoundScape::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, SOUNDSCAPE_ORIGIN)
	EVALUATE_VECTOR(origin, 1, SOUNDSCAPE_ORIGIN)
	EVALUATE_VECTOR(origin, 2, SOUNDSCAPE_ORIGIN)
	EVALUATE_FIELD(m_density, SOUNDSCAPE_REVERB)
	EVALUATE_FIELD(m_diffusion, SOUNDSCAPE_REVERB)
	EVALUATE_FIELD(m_gain, SOUNDSCAPE_REVERB)
	EVALUATE_FIELD(m_gainHF, SOUNDSCAPE_REVERB)
	EVALUATE_FIELD(m_gainLF, SOUNDSCAPE_REVERB)
	EVALUATE_FIELD(m_decayTime, SOUNDSCAPE_DECAY)
	EVALUATE_FIELD(m_decayHFRatio, SOUNDSCAPE_DECAY)
	EVALUATE_FIELD(m_decayLFRatio, SOUNDSCAPE_DECAY)
	EVALUATE_FIELD(m_reflectionGain, SOUNDSCAPE_REFLECTION)
	EVALUATE_FIELD(m_reflectionDelay, SOUNDSCAPE_REFLECTION)
	EVALUATE_VECTOR(m_reflectionPan, 0, SOUNDSCAPE_REFLECTION)
	EVALUATE_VECTOR(m_reflectionPan, 1, SOUNDSCAPE_REFLECTION)
	EVALUATE_VECTOR(m_reflectionPan, 2, SOUNDSCAPE_REFLECTION)
	EVALUATE_FIELD(m_LateGain, SOUNDSCAPE_Late)
	EVALUATE_FIELD(m_LateDelay, SOUNDSCAPE_Late)
	EVALUATE_VECTOR(m_LatePan, 0, SOUNDSCAPE_Late)
	EVALUATE_VECTOR(m_LatePan, 1, SOUNDSCAPE_Late)
	EVALUATE_VECTOR(m_LatePan, 2, SOUNDSCAPE_Late)
	EVALUATE_FIELD(m_echoTime, SOUNDSCAPE_ECHO)
	EVALUATE_FIELD(m_echoDepth, SOUNDSCAPE_ECHO)
	EVALUATE_FIELD(m_modulationTime, SOUNDSCAPE_MODULATION)
	EVALUATE_FIELD(m_modulationDepth, SOUNDSCAPE_MODULATION)
	EVALUATE_FIELD(m_airAbsorptionGainHF, SOUNDSCAPE_MISC)
	EVALUATE_FIELD(m_HFReference, SOUNDSCAPE_MISC)
	EVALUATE_FIELD(m_LFReference, SOUNDSCAPE_MISC)
	EVALUATE_FIELD(m_roomRolloffFactor, SOUNDSCAPE_MISC)
	EVALUATE_FIELD(m_decayHFLimit, SOUNDSCAPE_MISC)
	EVALUATE_FIELD(m_radius, SOUNDSCAPE_MISC)
}

float
NSSoundScape::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_SOUNDSCAPE);

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SOUNDSCAPE_ORIGIN)
	SENDENTITY_COORD(origin[1], SOUNDSCAPE_ORIGIN)
	SENDENTITY_COORD(origin[2], SOUNDSCAPE_ORIGIN)

	SENDENTITY_FLOAT(m_density, SOUNDSCAPE_REVERB)
	SENDENTITY_FLOAT(m_diffusion, SOUNDSCAPE_REVERB)
	SENDENTITY_FLOAT(m_gain, SOUNDSCAPE_REVERB)
	SENDENTITY_FLOAT(m_gainHF, SOUNDSCAPE_REVERB)
	SENDENTITY_FLOAT(m_gainLF, SOUNDSCAPE_REVERB)

	SENDENTITY_FLOAT(m_decayTime, SOUNDSCAPE_DECAY)
	SENDENTITY_FLOAT(m_decayHFRatio, SOUNDSCAPE_DECAY)
	SENDENTITY_FLOAT(m_decayLFRatio, SOUNDSCAPE_DECAY)

	SENDENTITY_FLOAT(m_reflectionGain, SOUNDSCAPE_REFLECTION)
	SENDENTITY_FLOAT(m_reflectionDelay, SOUNDSCAPE_REFLECTION)
	SENDENTITY_FLOAT(m_reflectionPan[0], SOUNDSCAPE_REFLECTION)
	SENDENTITY_FLOAT(m_reflectionPan[1], SOUNDSCAPE_REFLECTION)
	SENDENTITY_FLOAT(m_reflectionPan[2], SOUNDSCAPE_REFLECTION)

	SENDENTITY_FLOAT(m_LateGain, SOUNDSCAPE_Late)
	SENDENTITY_FLOAT(m_LateDelay, SOUNDSCAPE_Late)
	SENDENTITY_FLOAT(m_LatePan[0], SOUNDSCAPE_Late)
	SENDENTITY_FLOAT(m_LatePan[1], SOUNDSCAPE_Late)
	SENDENTITY_FLOAT(m_LatePan[2], SOUNDSCAPE_Late)

	SENDENTITY_FLOAT(m_echoTime, SOUNDSCAPE_ECHO)
	SENDENTITY_FLOAT(m_echoDepth, SOUNDSCAPE_ECHO)

	SENDENTITY_FLOAT(m_modulationTime, SOUNDSCAPE_MODULATION)
	SENDENTITY_FLOAT(m_modulationDepth, SOUNDSCAPE_MODULATION)

	SENDENTITY_FLOAT(m_airAbsorptionGainHF, SOUNDSCAPE_MISC)
	SENDENTITY_FLOAT(m_HFReference, SOUNDSCAPE_MISC)
	SENDENTITY_FLOAT(m_LFReference, SOUNDSCAPE_MISC)
	SENDENTITY_FLOAT(m_roomRolloffFactor, SOUNDSCAPE_MISC)
	SENDENTITY_INT(m_decayHFLimit, SOUNDSCAPE_MISC)
	SENDENTITY_FLOAT(m_radius, SOUNDSCAPE_MISC)

	return (true);
}
#else
void
NSSoundScape::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], SOUNDSCAPE_ORIGIN)
	READENTITY_COORD(origin[1], SOUNDSCAPE_ORIGIN)
	READENTITY_COORD(origin[2], SOUNDSCAPE_ORIGIN)

	READENTITY_FLOAT(m_density, SOUNDSCAPE_REVERB)
	READENTITY_FLOAT(m_diffusion, SOUNDSCAPE_REVERB)
	READENTITY_FLOAT(m_gain, SOUNDSCAPE_REVERB)
	READENTITY_FLOAT(m_gainHF, SOUNDSCAPE_REVERB)
	READENTITY_FLOAT(m_gainLF, SOUNDSCAPE_REVERB)

	READENTITY_FLOAT(m_decayTime, SOUNDSCAPE_DECAY)
	READENTITY_FLOAT(m_decayHFRatio, SOUNDSCAPE_DECAY)
	READENTITY_FLOAT(m_decayLFRatio, SOUNDSCAPE_DECAY)

	READENTITY_FLOAT(m_reflectionGain, SOUNDSCAPE_REFLECTION)
	READENTITY_FLOAT(m_reflectionDelay, SOUNDSCAPE_REFLECTION)
	READENTITY_FLOAT(m_reflectionPan[0], SOUNDSCAPE_REFLECTION)
	READENTITY_FLOAT(m_reflectionPan[1], SOUNDSCAPE_REFLECTION)
	READENTITY_FLOAT(m_reflectionPan[2], SOUNDSCAPE_REFLECTION)

	READENTITY_FLOAT(m_LateGain, SOUNDSCAPE_Late)
	READENTITY_FLOAT(m_LateDelay, SOUNDSCAPE_Late)
	READENTITY_FLOAT(m_LatePan[0], SOUNDSCAPE_Late)
	READENTITY_FLOAT(m_LatePan[1], SOUNDSCAPE_Late)
	READENTITY_FLOAT(m_LatePan[2], SOUNDSCAPE_Late)

	READENTITY_FLOAT(m_echoTime, SOUNDSCAPE_ECHO)
	READENTITY_FLOAT(m_echoDepth, SOUNDSCAPE_ECHO)

	READENTITY_FLOAT(m_modulationTime, SOUNDSCAPE_MODULATION)
	READENTITY_FLOAT(m_modulationDepth, SOUNDSCAPE_MODULATION)

	READENTITY_FLOAT(m_airAbsorptionGainHF, SOUNDSCAPE_MISC)
	READENTITY_FLOAT(m_HFReference, SOUNDSCAPE_MISC)
	READENTITY_FLOAT(m_LFReference, SOUNDSCAPE_MISC)
	READENTITY_FLOAT(m_roomRolloffFactor, SOUNDSCAPE_MISC)
	READENTITY_INT(m_decayHFLimit, SOUNDSCAPE_MISC)
	READENTITY_FLOAT(m_radius, SOUNDSCAPE_MISC)

	Relink();

	EFX_UpdateSoundScape(this);
}
#endif

/* Input/Output */
#ifdef SERVER
void
NSSoundScape::Input(entity entityActivator, string inputName, string dataString)
{
	switch (inputName) {
	case "LoadFromEFX":
		LoadFromEFX(dataString);
		break;
	case "SetDensity":
		SetDensity(ReadFloat(dataString));
		break;
	case "SetDiffusion":
		SetDiffusion(ReadFloat(dataString));
		break;
	case "SetGain":
		SetGain(ReadFloat(dataString));
		break;
	case "SetGainHF":
		SetGainHF(ReadFloat(dataString));
		break;
	case "SetGainLF":
		SetGainLF(ReadFloat(dataString));
		break;
	case "SetDecayTime":
		SetDecayTime(ReadFloat(dataString));
		break;
	case "SetDecayHFRatio":
		SetDecayHFRatio(ReadFloat(dataString));
		break;
	case "SetDecayLFRatio":
		SetDecayLFRatio(ReadFloat(dataString));
		break;
	case "SetReflectionGain":
		SetReflectionGain(ReadFloat(dataString));
		break;
	case "SetReflectionDelay":
		SetReflectionDelay(ReadFloat(dataString));
		break;
	case "SetReflectionPan":
		SetReflectionPan(ReadVector(dataString));
		break;
	case "SetLateGain":
		SetLateGain(ReadFloat(dataString));
		break;
	case "SetLateDelay":
		SetLateDelay(ReadFloat(dataString));
		break;
	case "SetLatePan":
		SetLatePan(ReadVector(dataString));
		break;
	case "SetEchoTime":
		SetEchoTime(ReadFloat(dataString));
		break;
	case "SetEchoDepth":
		SetEchoDepth(ReadFloat(dataString));
		break;
	case "SetModulationTime":
		SetModulationTime(ReadFloat(dataString));
		break;
	case "SetModulationDepth":
		SetModulationDepth(ReadFloat(dataString));
		break;
	case "SetAirAbsorptionGainHF":
		SetAirAbsorptionGainHF(ReadFloat(dataString));
		break;
	case "SetHFReference":
		SetHFReference(ReadFloat(dataString));
		break;
	case "SetLFReference":
		SetLFReference(ReadFloat(dataString));
		break;
	case "SetRoomRolloffFactor":
		SetRoomRolloffFactor(ReadFloat(dataString));
		break;
	case "SetDecayHFLimit":
		SetDecayHFLimit(ReadInt(dataString));
		break;
	case "SetRadius":
		SetRadius(ReadFloat(dataString));
		break;
	default:
		super::Input(entityActivator, inputName, dataString);
	}
}

void
NSSoundScape::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "efx_file":
		LoadFromEFX(setValue);
		break;
	case "density":
		m_density = ReadFloat(setValue);
		break;
	case "diffusion":
		m_diffusion = ReadFloat(setValue);
		break;
	case "gain":
		m_gain = ReadFloat(setValue);
		break;
	case "gain_hf":
		m_gainHF = ReadFloat(setValue);
		break;
	case "gain_lf":
		m_gainLF = ReadFloat(setValue);
		break;
	case "decay_time":
		m_decayTime = ReadFloat(setValue);
		break;
	case "decay_hf_ratio":
		m_decayHFRatio = ReadFloat(setValue);
		break;
	case "decay_lf_ratio":
		m_decayLFRatio = ReadFloat(setValue);
		break;
	case "reflection_gain":
		m_reflectionGain = ReadFloat(setValue);
		break;
	case "reflection_delay":
		m_reflectionDelay = ReadFloat(setValue);
		break;
	case "reflection_pan":
		m_reflectionPan = ReadVector(setValue);
		break;
	case "late_reverb_gain":
		m_LateGain = ReadFloat(setValue);
		break;
	case "late_reverb_delay":
		m_LateDelay = ReadFloat(setValue);
		break;
	case "late_reverb_pan":
		m_LatePan = ReadVector(setValue);
		break;
	case "echo_time":
		m_echoTime = ReadFloat(setValue);
		break;
	case "echo_depth":
		m_echoDepth = ReadFloat(setValue);
		break;
	case "modulation_time":
		m_modulationTime = ReadFloat(setValue);
		break;
	case "modulation_depth":
		m_modulationDepth = ReadFloat(setValue);
		break;
	case "air_absorbtion_hf":
		m_airAbsorptionGainHF = ReadFloat(setValue);
		break;
	case "hf_reference":
		m_HFReference = ReadFloat(setValue);
		break;
	case "lf_reference":
		m_LFReference = ReadFloat(setValue);
		break;
	case "room_rolloff_factor":
		m_roomRolloffFactor = ReadFloat(setValue);
		break;
	case "decay_limit":
		m_decayHFLimit = ReadInt(setValue);
		break;
	case "radius":
		m_radius = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
NSSoundScape::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_density", m_density);
	SaveFloat(handle, "m_diffusion", m_diffusion);
	SaveFloat(handle, "m_gain", m_gain);
	SaveFloat(handle, "m_gainHF", m_gainHF);
	SaveFloat(handle, "m_gainLF", m_gainLF);
	SaveFloat(handle, "m_decayTime", m_decayTime);
	SaveFloat(handle, "m_decayHFRatio", m_decayHFRatio);
	SaveFloat(handle, "m_decayLFRatio", m_decayLFRatio);
	SaveFloat(handle, "m_reflectionGain", m_reflectionGain);
	SaveFloat(handle, "m_reflectionDelay", m_reflectionDelay);
	SaveVector(handle, "m_reflectionPan", m_reflectionPan);
	SaveFloat(handle, "m_LateGain", m_LateGain);
	SaveFloat(handle, "m_LateDelay", m_LateDelay);
	SaveVector(handle, "m_LatePan", m_LatePan);
	SaveFloat(handle, "m_echoTime", m_echoTime);
	SaveFloat(handle, "m_echoDepth", m_echoDepth);
	SaveFloat(handle, "m_modulationTime", m_modulationTime);
	SaveFloat(handle, "m_modulationDepth", m_modulationDepth);
	SaveFloat(handle, "m_airAbsorptionGainHF", m_airAbsorptionGainHF);
	SaveFloat(handle, "m_HFReference", m_HFReference);
	SaveFloat(handle, "m_LFReference", m_LFReference);
	SaveFloat(handle, "m_roomRolloffFactor", m_roomRolloffFactor);
	SaveInt(handle, "m_decayHFLimit", m_decayHFLimit);
	SaveFloat(handle, "m_radius", m_radius);
}

void
NSSoundScape::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_density":
		m_density = ReadFloat(setValue);
		break;
	case "m_diffusion":
		m_diffusion = ReadFloat(setValue);
		break;
	case "m_gain":
		m_gain = ReadFloat(setValue);
		break;
	case "m_gainHF":
		m_gainHF = ReadFloat(setValue);
		break;
	case "m_gainLF":
		m_gainLF = ReadFloat(setValue);
		break;
	case "m_decayTime":
		m_decayTime = ReadFloat(setValue);
		break;
	case "m_decayHFRatio":
		m_decayHFRatio = ReadFloat(setValue);
		break;
	case "m_decayLFRatio":
		m_decayLFRatio = ReadFloat(setValue);
		break;
	case "m_reflectionGain":
		m_reflectionGain = ReadFloat(setValue);
		break;
	case "m_reflectionDelay":
		m_reflectionDelay = ReadFloat(setValue);
		break;
	case "m_reflectionPan":
		m_reflectionPan = ReadVector(setValue);
		break;
	case "m_LateGain":
		m_LateGain = ReadFloat(setValue);
		break;
	case "m_LateDelay":
		m_LateDelay = ReadFloat(setValue);
		break;
	case "m_LatePan":
		m_LatePan = ReadVector(setValue);
		break;
	case "m_echoTime":
		m_echoTime = ReadFloat(setValue);
		break;
	case "m_echoDepth":
		m_echoDepth = ReadFloat(setValue);
		break;
	case "m_modulationTime":
		m_modulationTime = ReadFloat(setValue);
		break;
	case "m_modulationDepth":
		m_modulationDepth = ReadFloat(setValue);
		break;
	case "m_airAbsorptionGainHF":
		m_airAbsorptionGainHF = ReadFloat(setValue);
		break;
	case "m_HFReference":
		m_HFReference = ReadFloat(setValue);
		break;
	case "m_LFReference":
		m_LFReference = ReadFloat(setValue);
		break;
	case "m_roomRolloffFactor":
		m_roomRolloffFactor = ReadFloat(setValue);
		break;
	case "m_decayHFLimit":
		m_decayHFLimit = ReadInt(setValue);
		break;
	case "m_radius":
		m_radius = ReadFloat(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}
#endif

bool
NSSoundScape::LoadFromEFX(string efxFile)
{
	filestream fh;
	string line;

	if (!efxFile) {
		return (false);
	}

	fh = fopen(strcat("decls/efx/", efxFile, ".efx"), FILE_READ);

	if (fh < 0) {
		EntError("Unable to load EFX file %S", efxFile);
		return (false);
	}

	while ((line = fgets(fh))) {
		int c = (int)tokenize_console(line);

		if (c == 2i) {
			SpawnKey(argv(0), argv(1));
		}
	}

	return (true);
}


#ifdef CLIENT
void
NSSoundScape::SetupEFXReverb(reverbinfo_t *info)
{
	info->flDensity = m_density;
	info->flDiffusion = m_diffusion;
	info->flGain = m_gain;
	info->flGainHF = m_gainHF;
	info->flGainLF = m_gainLF;
	info->flDecayTime = m_decayTime;
	info->flDecayHFRatio = m_decayHFRatio;
	info->flDecayLFRatio = m_decayLFRatio;
	info->flReflectionsGain = m_reflectionGain;
	info->flReflectionsDelay = m_reflectionDelay;
	info->flReflectionsPan = m_reflectionPan;
	info->flLateReverbGain = m_LateGain;
	info->flLateReverbDelay = m_LateDelay;
	info->flLateReverbPan = m_LatePan;
	info->flEchoTime = m_echoTime;
	info->flEchoDepth = m_echoDepth;
	info->flModulationTime = m_modulationTime;
	info->flModulationDepth = m_modulationDepth;
	info->flAirAbsorptionGainHF = m_airAbsorptionGainHF;
	info->flHFReference = m_HFReference;
	info->flLFReference = m_LFReference;
	info->flRoomRolloffFactor = m_roomRolloffFactor;
	info->iDecayHFLimit = m_decayHFLimit;
}

void
NSSoundScape::DebugDraw(void)
{
	static vector pos = [16, 16];

	static void epr(string tx) {
		Font_DrawText(pos, tx, FONT_CON);
		pos[1] += 12;
	}

	pos = [192,16];
	epr("Environmental FX Reverb:");
	epr(sprintf("Density: %f", GetDensity()));
	epr(sprintf("Diffusion: %.2fx", GetDiffusion()));
	epr(sprintf("Gain: %f mB", GetGain()));
	epr(sprintf("Gain HF: %f mB", GetGainHF()));
	epr(sprintf("Gain LF: %f mB", GetGainLF()));
	epr(sprintf("Decay Time: %.2f seconds", GetDecayTime()));
	epr(sprintf("Decay HF Ratio: %.2fx", GetDecayHFRatio()));
	epr(sprintf("Decay LF Ratio: %.2fx", GetDecayLFRatio()));
	epr(sprintf("Reflection: %f mB", GetReflectionGain()));
	epr(sprintf("Reflection Delay: %.2f seconds", GetReflectionDelay()));
	epr(sprintf("Reflection Pan: %v", GetReflectionPan()));
	epr(sprintf("Late Reverb Gain: %f", GetLateGain()));
	epr(sprintf("Late Reverb Delay: %.2f seconds", GetLateDelay()));
	epr(sprintf("Late Reverb Pan: %v", GetLatePan()));
	epr(sprintf("Echo Time: %.2f seconds", GetEchoTime()));
	epr(sprintf("Echo Depth: %.2fx", GetEchoDepth()));
	epr(sprintf("Modulation Time: %.2f seconds", GetModulationTime()));
	epr(sprintf("Modulation Depth: %.2fx", GetModulationDepth()));
	epr(sprintf("Air Absorption Gain HF: %f", GetAirAbsorptionGainHF()));
	epr(sprintf("HF Reference: %d Hz", GetHFReference()));
	epr(sprintf("LF Reference: %d Hz", GetLFReference()));
	epr(sprintf("Room Rolloff Factor: %.2fx", GetRoomRolloffFactor()));
	epr(sprintf("Decay HF Limit: %s", GetDecayHFLimit() == 1i ? "true" : "false"));
}

var bool autocvar_s_al_use_reverb = true;

void
EFX_UpdateSoundScape(NSSoundScape scape)
{
	reverbinfo_t reverbInfo;

	/* ignore any refresh requests from non-active soundscapes. */
	if (g_view.m_soundScape != scape) {
		return;
	}

	scape.SetupEFXReverb(&reverbInfo);
	setup_reverb(12, &reverbInfo, sizeof(reverbinfo_t));
	//NSError("Updated sound scape (expensive) %f", reverbInfo.flDensity);
}

void
EFX_UpdateListener(NSView playerView)
{
	static NSSoundScape lastScape;
	vector camPos = playerView.GetCameraOrigin();
	vector camAngle = playerView.GetCameraAngle();
	NSSoundScape bestScape = __NULL__;
	float bestDistance = 999999.0f;

	if (lastScape) {
	//	printf("%s: %v: %v; %v\n", lastScape.classname, lastScape.origin, camPos, camAngle);
		makevectors(camAngle);
		SetListener(camPos, v_forward, v_right, v_up, 12);
	} else {
		//printf("%v; %v\n", camPos, camAngle);
		makevectors(camAngle);
		SetListener(camPos, v_forward, v_right, v_up, 0);
	}

	if (autocvar_s_al_use_reverb == false) {
		return;
	}

	for (entity e = world; (e = find(e, classname, "NSSoundScape"));) {
		float deltaPos;
		NSSoundScape scape = (NSSoundScape)e;

		/* don't get blocked by entities */
		other = world;
		traceline(scape.GetOrigin(), camPos, MOVE_OTHERONLY, scape);

		/* collided */
		if (trace_fraction < 1.0f) {
			continue;
		}

		/* max-radius check */
		deltaPos = length(scape.GetOrigin() - camPos);

		if ((deltaPos > scape.GetRadius()) || (deltaPos > bestDistance)) {
			continue;
		}

		bestDistance = deltaPos;
		bestScape = scape;
	}

	/* no valid scape found. */
	if (bestScape == __NULL__) {
		return;
	}

	/* same as last time. */
	if (lastScape == bestScape) {
		return;
	}

	//NSError("Soundscape changed to %v", bestScape.GetOrigin());
	playerView.SetSoundScape(bestScape);
	EFX_UpdateSoundScape(bestScape);
	lastScape = bestScape;
}
#endif
