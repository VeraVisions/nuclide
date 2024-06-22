# Decl/Defs {#scripting}

## Sentences {#sentences}

Sentences are the voice-acting backbone of the sound system.

The definitions for each games' voice acting are stored inside
`sound/sentences.txt`.

One **keyword**, referred to as the **Sentence**, substitutes a range of voiced samples. Sometimes spanning multiple *real sentences*.

In addition, it is capable of playing a random **Sentence** from a group of **Sentences**.

Due to their versatility, they should be used exclusively to deliver spoken dialog in the game.

### Syntax {#sentences_syntax}

Within a **Sentences** definition file, each new line is a new **Sentence** entry.

The syntax:

`SENTENCE [PARAMETERS] SAMPLES`

And here a practical, advanced, real-world example of a **Sentence**:

```
MALETEST (vol50) attention(p120) male/hello how are you
```

The above example lists 5 samples that'll get played. One sample (the first) is special in that it gets pitch shifted up by 20%. All of them play at %50 volume.

If a sample is not in a sub-directory, it'll be assumed to be part of
the **vox/** sub-directory under **sound/**, or the last valid path of a previous sample.

As a demonstration, the following, minimized samples:

```
attention male/hello how are you
```

will unpack to become the following samples:

```
vox/attention.wav male/hello.wav male/how.wav male/are.wav male/you.wav
```

*When parameters are surrounded by spaces, this means they apply to all
current samples.* They can be overwritten later down the parsing.

When a parameter is attached to the end of a sample:

```
attention(p120)
```

...then this parameter only applies to said keyword.

Whereas...

```
(p120) attention everyone alive
```

Will apply the pitch effect to all three succeeding samples.

### Parameters {#sentences_parameters}

- (pXX) = Pitch. Valid values are from 50 to 150. **Default**: 100
- (vXX) = Volume. Valid values are from 0 to 100. **Default**: 100
- (sXX) = Start point in %. E.g. 10 skips the first 10% of the sample. **Default**: 0
- (eXX) = End point in %. E.g. 75 ends playback 75% into the sample. **Default**: 100
- (tXX) = Time shift/compression in %. 100 is unaltered speed, wheras 50 plays the sample back in half the time.

### Random Sentences {#sentences_random}

When naming your **Sentences**, enumerate them, starting with the number **0**.
An example syntax would be as follows:

```
TEST0 yes
TEST1 no
TEST2 maybe
```

And when referring to this **Group** of Sentences, simply refer to the name without the enumeration at the end:

```
"sentence" "!TEST"
```

### Entity Usage {#sentences_usage}

When referencing a **Sentence** level designers are asked to prefix keys referring to them with an exclamation mark ( **!** ). 
You'll find this in **scripted_sentence** type entities:

```
"sentence" "!GM_SUIT"
```

which in turn, will look up **GM_SUIT**:

```
GM_SUIT gman/gman_suit
```

This will also apply to any other entity that supports working with **Sentences**, like **ambient_generic**.
