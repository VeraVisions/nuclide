# Decl/Defs {#scripting}

## EFXDefs {#efxdefs}

### History {#efxdefs_history}

#### Creative's Environmental Audio Extensions (EAX) {#eax}
Creative Technology's **Environmental Audio Extensions**, also known as **EAX**, attempted to create more ambiance within video games by more accurately simulating a real-world audio environment.


The release of Windows Vista deprecated the DirectSound3D API on which EAX relied on in 2007, so Creative Technology encouraged the move to OpenAL's EFX.

#### EFX {#efx}

EFX is a system in [OpenAL](https://www.openal.org/) that delivers high quality sound reverberation. It is the successor to @ref eax.

**Nuclide** offers abstraction for new and old entities relying on **digital signal processing**.

### Entities interacting with EFX

**env_sound** is most commonly used to change the environmental sound processing of a room/area.

In GoldSrc, it'll specify which enumeration of DSP preset to use for audio playback, in Nuclide however we just map it to a definitions file in the filesystem. See **EFX files** below.

### EFX defintion files

Entities that specify a EFX type, usually want to load one from a file.

Here's an example one, `efx/city.efx`:

```
  density "1.000000"
  diffusion "0.500000"
  gain "0.316200"
  gain_hf "0.398100"
  gain_lf "1.000000"
  decay_time "1.490000"
  decay_hf_ratio "0.670000"
  decay_lf_ratio "1.000000"
  reflections_gain "0.073000"
  reflections_delay "0.007000"
  reflections_pan "0 0 0"
  late_reverb_gain "0.142700"
  late_reverb_delay "0.011000"
  late_reverb_pan "0 0 0"
  echo_time "0.250000"
  echo_depth "0.000000"
  modulation_time "0.250000"
  modulation_depth "0.000000"
  air_absorbtion_hf "0.994300"
  hf_reference "5000.000000"
  lf_reference "250.000000"
  room_rolloff_factor "0.000000"
  decay_limit "1"
```

Most of the parameters are self explanatory.

### Console Variables

With the cvar `s_al_debug` set to 1 you'll get an overlay of information about which EFX file is currently being used, as well as what every single parameter is set to.

You can refresh EFX definitions with a map restart.

### Legacy translation table

*This section describes behaviour specific to converting entities from Half-Life based levels into the Nuclide environment.*

Here you can see which **efx file** is responsible for handling a legacy **env_sound** room-type.

**roomtype ID**|**EFX file**
:-----:|:-----:
0|efx/default.efx
1|efx/gs\_generic.efx
2|efx/gs\_metal\_s.efx
3|efx/gs\_metal\_m.efx
4|efx/gs\_metal\_l.efx
5|efx/gs\_tunnel\_s.efx
6|efx/gs\_tunnel\_m.efx
7|efx/gs\_tunnel\_l.efx
8|efx/gs\_chamber\_s.efx
9|efx/gs\_chamber\_m.efx
10|efx/gs\_chamber\_l.efx
11|efx/gs\_bright\_s.efx
12|efx/gs\_bright\_m.efx
13|efx/gs\_bright\_l.efx
14|efx/gs\_water1.efx
15|efx/gs\_water2.efx
16|efx/gs\_water3.efx
17|efx/gs\_concrete\_s.efx
18|efx/gs\_concrete\_m.efx
19|efx/gs\_concrete\_l.efx
20|efx/gs\_big1.efx
21|efx/gs\_big2.efx
22|efx/gs\_big3.efx
23|efx/gs\_cavern\_s.efx
24|efx/gs\_cavern\_m.efx
25|efx/gs\_cavern\_l.efx
26|efx/gs\_weirdo1.efx
27|efx/gs\_weirdo2.efx
28|efx/gs\_weirdo3.efx 