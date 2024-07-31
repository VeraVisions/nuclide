/*
 * Copyright (c) 2024 Vera Visions LLC.
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

enumflags
{
	SOUNDSCAPE_ORIGIN,
	SOUNDSCAPE_REVERB,
	SOUNDSCAPE_DECAY,
	SOUNDSCAPE_REFLECTION,
	SOUNDSCAPE_Late,
	SOUNDSCAPE_ECHO,
	SOUNDSCAPE_MODULATION,
	SOUNDSCAPE_MISC
};

/*! \brief Shared-Entity: Sound System Scape/Reverb Controller */
/*!QUAKED NSSoundScape (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Environmental soundscape and reverb controller.

# KEYS
 - "efx_file" : File to load EFX values from.
 - "density" : See SetDensity()
 - "diffusion" : See SetDiffusion()
 - "gain" : See SetGain()
 - "gain_hf" : See SetGainHF()
 - "gain_lf" : See SetGainLF()
 - "decay_time" : See SetDecayTime()
 - "decay_hf_ratio" : See SetDecayHFRatio()
 - "decay_lf_ratio" : See SetDecayLFRatio()
 - "reflection_gain" : See SetReflectionGain()
 - "reflection_delay" : See SetReflectionDelay()
 - "reflection_pan" : See SetReflectionPan()
 - "late_reverb_gain" : See SetLateGain()
 - "late_reverb_delay" : See SetLateDelay()
 - "late_reverb_pan" : See SetLatePan()
 - "echo_time" : See SetEchoTime()
 - "echo_depth" : See SetEchoDepth()
 - "modulation_time" : See SetModulationTime()
 - "modulation_depth" : See SetModulationDepth()
 - "air_absorbtion_hf" : See SetAirAbsorptionGainHF()
 - "hf_reference" : See SetHFReference()
 - "lf_reference" : See SetLFReference()
 - "room_rolloff_factor" : See SetRoomRolloffFactor()
 - "decay_limit" : See SetDecayHFLimit()
 - "radius" : See SetRadius()

# HISTORY

## Creative's Environmental Audio Extensions (EAX) {#eax}
Creative Technology's **Environmental Audio Extensions**, also known as **EAX**, attempted to create more ambiance within video games by more accurately simulating a real-world audio environment.

The release of Windows Vista deprecated the DirectSound3D API on which EAX relied on in 2007, so Creative Technology encouraged the move to OpenAL's EFX.

## EFX

EFX is a system in [OpenAL](https://www.openal.org/) that delivers high quality sound reverberation. It is the successor to @ref eax.

**Nuclide** offers abstraction for new and old entities relying on **digital signal processing**.

# NOTES
Reverb effects only work with the OpenAL sound backend.

# See Also
- https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf

@ingroup shared
@ingroup sound
@ingroup baseclass
*/
class
NSSoundScape:NSPointTrigger
{
public:
	void NSSoundScape(void);

	/* overrides */
	

#ifdef SERVER
	/** Reverb Density, controls the effect of the reverb. Values `0.0f` to `1.0f`. Default is `1.0f`.*/
	nonvirtual void SetDensity(float);
	/** Reverb Diffusion, linear multiplier. Values `0.0f` to `1.0f`. Default is `1.0f`. */
	nonvirtual void SetDiffusion(float);
	/** Reverb Gain, linear gain control. Affects the volume of sound reflections and reverberation. Values `0.0f` to `1.0f`. Default is `0.32f`. */
	nonvirtual void SetGain(float);
	/** Reverb Gain HF, linear gain control for high frequency sounds. Values `0.0f` to `1.0f`. Default is `0.89f`. */
	nonvirtual void SetGainHF(float);
	/** Reverb Gain LF, linear gain control for low frequency sounds. Values `0.0f` to `1.0f`. Default is `0.0f`. */
	nonvirtual void SetGainLF(float);
	/** Decay Time, in seconds. Values `0.1f` to `20.0f`. Default is `1.49f`. */
	nonvirtual void SetDecayTime(float);
	/** Decay HF Ratio, linear multiplier. Values `0.1f` to `20.0f`. Default is `0.83f`. */
	nonvirtual void SetDecayHFRatio(float);
	/** Decay LF Ratio, linear multiplier. Values `0.1f` to `20.0f`. Default is `1.0f`. */
	nonvirtual void SetDecayLFRatio(float);
	/** Reflection Gain, linear gain control. Values `0.0f` to `3.16f`. Default is `0.05f`. */
	nonvirtual void SetReflectionGain(float);
	/** Reflection Delay, in seconds. Values `0.0f` to `0.3f`. Default is `0.007f`. */
	nonvirtual void SetReflectionDelay(float);
	/** Reflection Pan. X = Left/Right, Y = Up/Down, Z = Forward/Back. Values from `-1.0f` to `1.0` on each axis. Default is `[0,0,0]`. */
	nonvirtual void SetReflectionPan(vector);
	/** Late Reverb Gain, linear gain control. Values `0.0f` to `10.0f`. Default is `1.26f`.*/
	nonvirtual void SetLateGain(float);
	/** Late Reverb Delay, in seconds. values `0.0f` to `0.1f`. Default is `0.011f`. */
	nonvirtual void SetLateDelay(float);
	/** Late Reverb Pan. X = Left/Right, Y = Up/Down, Z = Forward/Back. Values from `-1.0f` to `1.0` on each axis. Default is `[0,0,0]`. */
	nonvirtual void SetLatePan(vector);
	/** Echo Time, in seconds. Values `0.075f` to `0.25f`. Default is `0.25f`. */
	nonvirtual void SetEchoTime(float);
	/** Echo Depth, linear multiplier. Values `0.0f` to `1.0f`. Default is `0.0f`. */
	nonvirtual void SetEchoDepth(float);
	/** Modulation Time, in seconds. Values `0.004f` to `4.0f`. Default is `0.25f`. */
	nonvirtual void SetModulationTime(float);
	/** Modulation Depth, linear multiplier. Values `0.0f` to `1.0f`. Default is `0.0f`. */
	nonvirtual void SetModulationDepth(float);
	/** Air Absorption Gain HF, linear gain per meter. Values `0.892f` to `1.0f`. Default is `0.994f`. */
	nonvirtual void SetAirAbsorptionGainHF(float);
	/** HF Reference, in Hz. Values `1000.0f` to `20000.0f`. Default is `5000.0f`. */
	nonvirtual void SetHFReference(float);
	/** LF Reference, in Hz. Values `20.0f` to `1000.0f`. Default is `250.0f`. */
	nonvirtual void SetLFReference(float);
	/** Room Rolloff Factor, linear multiplier. Values `0.0f` to `10.0f`. Default is `0.0f`. */
	nonvirtual void SetRoomRolloffFactor(float);
	/** Decay HF Limit, integer value. Values are `0i` (false) and `1i` (true). Default is `1i` (true). */
	nonvirtual void SetDecayHFLimit(int);

	/** Sets the radius of the soundscape. When a client is outside the radius the effects are nil. */
	nonvirtual void SetRadius(float);
#endif

#ifdef CLIENT
	nonvirtual float GetDensity(void);
	nonvirtual float GetDiffusion(void);
	nonvirtual float GetGain(void);
	nonvirtual float GetGainHF(void);
	nonvirtual float GetGainLF(void);
	nonvirtual float GetDecayTime(void);
	nonvirtual float GetDecayHFRatio(void);
	nonvirtual float GetDecayLFRatio(void);
	nonvirtual float GetReflectionGain(void);
	nonvirtual float GetReflectionDelay(void);
	nonvirtual vector GetReflectionPan(void);
	nonvirtual float GetLateGain(void);
	nonvirtual float GetLateDelay(void);
	nonvirtual vector GetLatePan(void);
	nonvirtual float GetEchoTime(void);
	nonvirtual float GetEchoDepth(void);
	nonvirtual float GetModulationTime(void);
	nonvirtual float GetModulationDepth(void);
	nonvirtual float GetAirAbsorptionGainHF(void);
	nonvirtual float GetHFReference(void);
	nonvirtual float GetLFReference(void);
	nonvirtual float GetRoomRolloffFactor(void);
	nonvirtual int GetDecayHFLimit(void);
	nonvirtual float GetRadius(void);
#endif


#ifdef SERVER
	virtual void SpawnKey(string, string);
	virtual void Input(entity,string, string);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);
	virtual void Save(float);
	virtual void Restore(string,string);
#endif

	nonvirtual bool LoadFromEFX(string);

#ifdef CLIENT
	virtual void DebugDraw(void);
	virtual void ReceiveEntity(float, float);
	nonvirtual void SetupEFXReverb(reverbinfo_t *);
#endif


private:
	NETWORKED_FLOAT(m_density)
	NETWORKED_FLOAT(m_diffusion)
	NETWORKED_FLOAT(m_gain)
	NETWORKED_FLOAT(m_gainHF)
	NETWORKED_FLOAT(m_gainLF)
	NETWORKED_FLOAT(m_decayTime)
	NETWORKED_FLOAT(m_decayHFRatio)
	NETWORKED_FLOAT(m_decayLFRatio)
	NETWORKED_FLOAT(m_reflectionGain)
	NETWORKED_FLOAT(m_reflectionDelay)
	NETWORKED_VECTOR(m_reflectionPan)
	NETWORKED_FLOAT(m_LateGain)
	NETWORKED_FLOAT(m_LateDelay)
	NETWORKED_VECTOR(m_LatePan)
	NETWORKED_FLOAT(m_echoTime)
	NETWORKED_FLOAT(m_echoDepth)
	NETWORKED_FLOAT(m_modulationTime)
	NETWORKED_FLOAT(m_modulationDepth)
	NETWORKED_FLOAT(m_airAbsorptionGainHF)
	NETWORKED_FLOAT(m_HFReference)
	NETWORKED_FLOAT(m_LFReference)
	NETWORKED_FLOAT(m_roomRolloffFactor)
	NETWORKED_INT(m_decayHFLimit)
	NETWORKED_FLOAT(m_radius)
};

#ifdef CLIENT
void EFX_UpdateSoundScape(NSSoundScape);
#endif
