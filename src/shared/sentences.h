/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/** @defgroup sentences Sentences
@brief Sentences are the voice-acting backbone of the sound system.
@ingroup sound

# Sentences Documentation

A lot of information was implemented with the help of:
http://articles.thewavelength.net/230/

## Specification of sound/sentences.txt
Each line is a new sentence group.  

```
[GROUPNAME] [...PARAMETERS] [...SAMPLES]
```

If a sample is not in a sub-directory, it'll be assumed to be part
of the 'vox' sub-directory, or the last valid path of a previous sample.  
For example:

```
attention male/hello how are you  
```

becomes:

```
vox/attention.wav male/hello.wav male/how.wav male/are.wav male/you.wav
```

When parameters are surrounded by spaces, this means they apply
to all current samples. They can be overwritten later down the parsing.  

When a parameter is attached to a sample, e.g.:

```
attention(p120)
```

Then this parameter only applies to said keyword.  
Whereas...

```
(p120) attention everyone alive
```

Will apply the pitch effect to all three succeeding samples.

Parameters:  
    (pXX) = Pitch. Valid values are from 50 to 150.  
    (vXX) = Volume. Valid values are from 0 to 100.  
    (sXX) = Start point in %. E.g. 10 skips the first 10% of the sample.  
    (eXX) = End point in %. E.g. 75 ends playback 75% into the sample.  
    (tXX) = Time shift/compression in %. 100 is unaltered speed, wheras 50 plays the sample back in half the time.  

@{
*/

#ifdef SERVER
#define DYNAMIC_SENTENCES

#ifdef DYNAMIC_SENTENCES
	string *g_sentences;
	int g_sentences_count;
#else
	#define SENTENCES_LIMIT 1024
	string g_sentences[SENTENCES_LIMIT];
	int g_sentences_count;
#endif

/** Returns a string of sample for a given sentence. */
string Sentences_GetSamples(string);
/** Returns the shared network ID for a given sentence. */
int Sentences_GetID(string);


#endif

#ifdef CLIENT
/** Gets the sentences string for a given id. */
string Sentences_GetString(int id);

/** Called by CSQC_Shutdown() when the client game exits to clear the sentences buffer. */
void Sentences_Shutdown(void);

#endif

/** @} */ // end of sentences

/** Called by CSQC_Init on the client, as well as init() on the server. */
void Sentences_Init(void);

var hashtable g_hashsentences;