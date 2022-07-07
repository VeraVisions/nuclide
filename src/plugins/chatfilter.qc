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

var int autocvar_chatplug_filter = 1;

string *g_wordlist;
var int g_words;

string
ChatFilter_CreateWord(int i)
{
	float len = strlen(g_wordlist[i]);
	string word = "";

	for (int x = 0; x < len; x++)
		word = sprintf("%s*", word);

	return word;
}

string
ChatFilter(string cmd)
{
	for (int i = 0; i < g_words; i++)
		cmd = strreplace(g_wordlist[i], ChatFilter_CreateWord(i), cmd);

	return (cmd);
}

/* plugin hook */
string
FMX_ParseClientCommand(string cmd)
{
	tokenize(cmd);
	switch (argv(0)) {
		case "say":
			return ChatFilter(cmd);
			break;
	}
	return (cmd);
}

void
FMX_Init(void)
{
	string temp;
	int i = 0;
	int c = 0;
	filestream fhWords;

	fhWords = fopen("chatfilter.txt", FILE_READ);

	if (fhWords < 0) {
		print("Chat Filter Plugin: chatfilter.txt not found.\n");
		return;
	}

	/* count lines */
	while ((temp = fgets(fhWords))) {
		c = tokenize_console(temp);

		if (c != 1)
			continue;

		g_words++;
	}
	fseek(fhWords, 0);

	g_wordlist = memalloc(sizeof(string) * g_words);
	while ((temp = fgets(fhWords))) {
		c = tokenize_console(temp);

		if (c != 1)
			continue;

		g_wordlist[i] = strtolower(argv(0));
		i++;
	}
	fclose(fhWords);
}
