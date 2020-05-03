/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

void
Sentences_Init(void)
{
	filestream fs_sentences;
	string temp;
	int c;

	iprint("Initializing Sentences-Subsystem");

	if (g_sentences_count > 0) {
		g_sentences_count = 0;
#ifndef DYNAMIC_SENTENCES
		if (g_sentences) {
			memfree(g_sentences);
		}
#endif
	}

	fs_sentences = fopen("sound/sentences.txt", FILE_READ);

	if (fs_sentences < 0) {
		print("^1WARNING: ^7Could NOT load sound/sentences.txt\n");
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
		g_sentences_count++;
		g_sentences = memrealloc(g_sentences,
				sizeof(string),
				x,
				g_sentences_count);
#else
		if (g_sentences_count + 1 >= SENTENCES_LIMIT) {
			print("^1WARNING: ^7Reached limit of max sentences!\n");
			return;
		}

		g_sentences_count++;
#endif

		g_sentences[x] = strcat("!", argv(0));
	}

	fclose(fs_sentences);
}

string
Sentences_GetSamples(string word)
{
	int len;
	int gc;

	/* you never know what NPCs might do */
	if (word == "") {
		return "";
	}

	/* check if the word is present at all */
	for (int i = 0; i < g_sentences_count; i++) {
		if (g_sentences[i] == word) {
			dprint(sprintf("^3Sentences_GetSamples^7: Found %s\n", word));
			return word;
		}
	}

	/* it may be a random group of words. */
	len = strlen(word);
	for (int i = 0; i < g_sentences_count; i++) {
		string sub = substring(g_sentences[i], 0, len);
		if (sub == word) {
			gc++;
		}
	}

	/* if we've got one, choose a random sample of them */
	if (gc) {
		int r = floor(random(0, gc));
		dprint(sprintf("^3Sentences_GetSamples^7: Choosing %s%i\n", word, r));
		return sprintf("%s%i", word, r);
	}

	/* we've somehow messed up catastrophically */
	print(sprintf("^1ERROR: Invalid sentence keyword %s\n", word));
	return "";
}
