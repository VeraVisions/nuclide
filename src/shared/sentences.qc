/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

var string autocvar_sentences_File = "sound/sentences.txt";

#ifdef CLIENT
/* enable this if you want to use memalloc */
#define DYNAMIC_SENTENCES

typedef struct
{
	string m_strID;
	string m_strSamples;
} sentences_t;

#ifdef DYNAMIC_SENTENCES
	sentences_t *g_sentences;
	int g_sentences_count;
#else
	#define SENTENCES_LIMIT 1024
	sentences_t g_sentences[SENTENCES_LIMIT];
	int g_sentences_count;
#endif

var string g_sentences_samplepath;

void
Sentences_Shutdown(void)
{
#ifdef DYNAMIC_SENTENCES
	if (g_sentences)
		memfree(g_sentences);
#endif

	g_sentences_count = 0;
}

void
Sentences_Init(void)
{
	filestream fs_sentences = -1;
	string temp;
	int c, i;

	InitStart();

	Sentences_Shutdown();

	if (STRING_SET(autocvar_sentences_File)) {
		fs_sentences = fopen(autocvar_sentences_File, FILE_READ);
	}

	if (fs_sentences < 0) {
		ncWarning("No Sentences, missing %S", autocvar_sentences_File);
		InitEnd();
		return;
	}

	/* create the hash-table if it doesn't exist */
	if (!g_hashsentences) {
		g_hashsentences = hash_createtab(2, HASH_ADD);
	}

	while ((temp = fgets(fs_sentences))) {
		/* tons of comments/garbage in those files,
		 * so tokenize appropriately */
		c = tokenize_console(temp);

		/* not enough for an entry. */
		if (c < 2) {
			continue;
		}

		/* starts of at 0, for every line increases */
		int x = g_sentences_count;

		/* allocate memory and increase count */
#ifdef DYNAMIC_SENTENCES
		g_sentences_count++;
		g_sentences = (sentences_t *)memreallocOld(g_sentences,
				sizeof(sentences_t),
				x,
				g_sentences_count);
#else
		if (g_sentences_count + 1 >= SENTENCES_LIMIT) {
			ncError("Reached limit of %d SentenceDefs.", SENTENCES_LIMIT);
			return;
		}

		g_sentences_count++;
#endif

		/* loop through the parts of the line */
		for (i=0; i < c; i++) {
			/* first entry is the id, prefix with ! as well */
			if (i==0) {
				g_sentences[x].m_strID = strtoupper(strcat("!", argv(0)));
				hash_add(g_hashsentences, g_sentences[x].m_strID, x);
			} else {
				if (i == 1) {
					g_sentences[x].m_strSamples = sprintf("%s", argv(i));
				} else {
					g_sentences[x].m_strSamples = sprintf("%s %s", g_sentences[x].m_strSamples, argv(i));
				}

				g_sentences[x].m_strSamples =
					strreplace(",", " vox/comma.wav", g_sentences[x].m_strSamples);
			}
		}
	}

	fclose(fs_sentences);
	ncLog("...SentencesDef initialized with %i entries.", g_sentences_count);
	InitEnd();
}

string
Sentences_ProcessSample(string sample)
{
	int c = tokenizebyseparator(sample, "/");

	/* this sample contains a path */
	if (c > 1) {
		g_sentences_samplepath = argv(0);
		return sample;
	}

	/* we don't have a path, so supply the default */
	return sprintf("%s/%s", g_sentences_samplepath, argv(0));
}

void
Sentences_ResetSample(void)
{
	g_sentences_samplepath = "vox";
}

string
Sentences_GetSamples(string msg)
{
	Sentences_ResetSample();
	int i = (int)hash_get(g_hashsentences, msg, -1i);

	if (i != -1i)
		return g_sentences[i].m_strSamples;
	else {
		ncError("Can't find sentence %S", msg);
		return "";
	}
}

string
Sentences_GetString(int idx)
{
	return g_sentences[idx].m_strID;
}
#endif

#ifdef SERVER
void
Sentences_Init(void)
{
	filestream fs_sentences = -1;
	string temp;
	int c;

	InitStart();

	if (g_sentences_count > 0) {
		g_sentences_count = 0;
#ifndef DYNAMIC_SENTENCES
		if (g_sentences) {
			memfree(g_sentences);
		}
#endif
	}

	if (STRING_SET(autocvar_sentences_File)) {
		fs_sentences = fopen(autocvar_sentences_File, FILE_READ);
	}

	if (fs_sentences < 0) {
		ncWarning("No Sentences, missing %S", autocvar_sentences_File);
		InitEnd();
		return;
	}

	/* create the hash-table if it doesn't exist */
	if (!g_hashsentences) {
		g_hashsentences = hash_createtab(2, HASH_ADD);
	}

	while ((temp = fgets(fs_sentences))) {
		/* tons of comments/garbage in those files,
		 * so tokenize appropriately */
		c = tokenize_console(temp);

		/* not enough for an entry. */
		if (c < 2) {
			continue;
		}

		/* starts of at 0, for every line increases */
		int x = g_sentences_count;

		/* allocate memory and increase count */
#ifdef DYNAMIC_SENTENCES
		g_sentences_count++;
		g_sentences = (string *)memreallocOld(g_sentences,
				sizeof(string),
				x,
				g_sentences_count);
#else
		if (g_sentences_count + 1 >= SENTENCES_LIMIT) {
			ncError("Reached limit of max sentences!");
			InitEnd();
			return;
		}

		g_sentences_count++;
#endif

		g_sentences[x] = strtoupper(strcat("!", argv(0)));
		hash_add(g_hashsentences, g_sentences[x], x);
	}

	fclose(fs_sentences);
	ncLog("SentencesDef initialized with %i entries.", g_sentences_count);
	InitEnd();
}

string
Sentences_GetSamples(string word)
{
	int len;
	int gc = 0;
	int r, x;

	/* you never know what NPCs might do */
	if (word == "") {
		return ("");
	}

	/* check if the word is present at all */
	x = (int)hash_get(g_hashsentences, word, -1i);
	if (x != -1i) {
		return g_sentences[x];
	}

	/* it may be a random group of words. */
	/* start at [WORD]0 */
	r = (int)hash_get(g_hashsentences, strcat(word, "0"), 0i);

	len = strlen(word);
	for (int i = r; i < g_sentences_count; i++) {
		string sub = substring(g_sentences[i], 0, len);
		if (sub == word) {
			gc++;
		}
	}

	/* if we've got one, choose a random sample of them */
	if (gc) {
		r = floor(random(0, gc));
		SndLog("Choosing %s%i", word, r);
		return sprintf("%s%i", word, r);
	}

	/* we've somehow messed up catastrophically */
	ncError("Invalid sentence keyword %s", word);
	return ("");
}

int
Sentences_GetID(string sentence)
{
	int i = (int)hash_get(g_hashsentences, sentence, -1i);

	if (i != -1i) {
		SndLog("Found sentence %S", sentence);
		return i;
	} else {
		ncError("Can't find sentence %S", sentence);
		return 0;
	}
}
#endif
