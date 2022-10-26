Sentences are the voice-acting backbone of the sound system.

The definitions for each games' voice acting are stored inside
`sound/sentences.txt`.

# Syntax {#syntax}

Each line is a new sentence group.

`GROUPNAME [PARAMETERS] SAMPLES`

Real-world example:

**`MALETEST`**` attention(p120) male/hello how are you`

The above example lists 5 samples that'll get played.

If a sample is not in a sub-directory, it'll be assumed to be part of
the **vox** sub-directory, or the last valid path of a previous sample.
For example

`attention male/hello how are you`

plays the following samples:

**`vox`**`/attention.wav male/hello.wav male/how.wav male/are.wav male/you.wav`

*When parameters are surrounded by spaces, this means they apply to all
current samples.* They can be overwritten later down the parsing.

When a parameter is attached to a sample, e.g.

`attention(p120)`

Then this parameter only applies to said keyword.

Whereas...

`(p120) attention everyone alive`

Will apply the pitch effect to all three succeeding samples.

## Parameters {#parameters}

-   (pXX) = Pitch. Valid values are from 50 to 150.
-   (vXX) = Volume. Valid values are from 0 to 100.
-   (sXX) = Start point in %. E.g. 10 skips the first 10% of the sample.
-   (eXX) = End point in %. E.g. 75 ends playback 75% into the sample.
-   (tXX) = Time shift/compression in %. 100 is unaltered speed, wheras
    50 plays the sample back in half the time.

# Usage {#usage}

When an entity, say, a **scripted_sentence** wants to play a sentence,
it'll prefix it with an exclamation mark ( **!** ). For example:

`"sentence" "!GM_SUIT"`

Will play:

`GM_SUIT gman/gman_suit`

[Category: Nuclide Scripting](/Category:_Nuclide_Scripting "wikilink")