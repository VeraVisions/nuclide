/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/* voice sentence samples for AI and other triggers that are supposed to talk.
 * the formatting is messy as hell and I feel dirty for even bothering with all
 * this to begin with.
 * 
 * the server will send a short string identifer over and we'll look it up.
 * what's annoying is that some NPCs got their own pitch overrides so I guess
 * we'll just default to those whenever there's no custom value set.
 */

/* sentences are the voice-acting backbone of the sound system.
 * http://articles.thewavelength.net/230/
 * has pretty good documentation of how the format is meant to work */

/* enable this if you want to use memalloc */
#define DYNAMIC_SENTENCES 1

typedef struct
{
	string m_strID;
	string m_strSamples;
} sentences_t;

#ifdef DYNAMIC_SENTENCES
	sentences_t *g_sentences;
	int g_sentences_count;
#else
	sentences_t g_sentences[1024];
	int g_sentences_count;
#endif

void
Sentences_Init(void)
{
	filestream fs_sentences;
	string temp;
	int c, i;

	fs_sentences = fopen("sound/sentences.txt", FILE_READ);

	if (fs_sentences < 0) {
		print("^1WARNING: ^7Could NOT load sound/sentences.txt");
		return;
	}

	if (g_sentences_count > 0) {
		print("^1WARNING: ^7Attempted to load sentences twice!");
		return;
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
		g_sentences = memrealloc(g_sentences,
				sizeof(sentences_t),
				g_sentences_count,
				++g_sentences_count);
#else
		g_sentences_count++;
#endif

		/* loop through the parts of the line */
		for (i=0; i < c; i++) {
			/* first entry is the id, prefix with ! as well */
			if (i==0) {
				g_sentences[x].m_strID = strcat("!", argv(0));
			} else {
				if (i == 1) {
					g_sentences[x].m_strSamples = sprintf("%s", argv(i));
				} else {
					g_sentences[x].m_strSamples = sprintf("%s %s", g_sentences[x].m_strSamples, argv(i));
				}
			}
		}
	}
}

string
Sentences_GetSamples(string msg)
{
	for (int i = 0; i < g_sentences_count; i++) {
		if (g_sentences[i].m_strID == msg) {
			return g_sentences[i].m_strSamples;
		}
	}

	return "";
}
