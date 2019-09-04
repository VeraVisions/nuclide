/*
Copyright 2019 <marco@icculus.org>
Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies. 

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
*/

var int autocvar_chatplug_suppresschat = 0;

entity csndemitter; 

typedef struct {
	string sentence;
	string sample;
} chatsentence_t;
chatsentence_t *g_chatsounds;
var int g_chatsounds_count;

int ChatLookUp(string cmd)
{
	for (int i = 0; i < g_chatsounds_count; i++) {
		int sc = tokenizebyseparator(g_chatsounds[i].sentence, ";");
		for (int c = 0; c < sc; c++) {
			if (cmd == argv(c)) {
				int count = tokenizebyseparator(g_chatsounds[i].sample, ";");
				int r = random(0, count);
				sound(csndemitter, CHAN_BODY, argv(r), 1.0f, ATTN_NONE, 100, SOUNDFLAG_NOREVERB);
				break;
			}
		}
	}

	/* Some jokester might set it to non 0/1 */
	return autocvar_chatplug_suppresschat == 1 ? TRUE : FALSE;
}

int FMX_ParseClientCommand(string cmd)
{
	tokenize(cmd);
	switch (argv(0)) {
		case "say":
			return ChatLookUp(strtolower(argv(1)));
			break;
		default:
			return FALSE;
	}
	return TRUE;
}

void initents(void)
{
	/* Why waste entity slots? */
	if (g_chatsounds_count > 0) {
		csndemitter = spawn();
	}
}

void init(float prevprogs)
{
	filestream chatfile;
	chatfile = fopen("chatsounds.txt", FILE_READ);

	if (chatfile >= 0) {
		string temp;
		int i = 0;
		int c = 0;

		/* count lines */
		while ((temp = fgets(chatfile))) {
			c = tokenize_console(temp);
			if (c != 2) {
				continue;
			}
			g_chatsounds_count++;
		}
		fseek(chatfile, 0);
		print(sprintf("Chat Sound Plugin: %i record(s) initialized\n", g_chatsounds_count));
		
		g_chatsounds = memalloc(sizeof(chatsentence_t) * g_chatsounds_count);
		while ((temp = fgets(chatfile))) {
			c = tokenize_console(temp);
			if (c != 2 ) {
				continue;
			}
			g_chatsounds[i].sentence = strtolower(argv(0));
			g_chatsounds[i].sample = strtolower(argv(1));
			c = tokenizebyseparator(g_chatsounds[i].sample, ";");
			for (int x = 0; x < c; x++) {
				precache_sound(argv(x));
				print(sprintf("Caching: %s\n", argv(x)));
			}
			i++;
		}
		fclose(chatfile);
	} else {
		print("Chat Sound Plugin: chatsounds.txt not found.\n");
	}
}
