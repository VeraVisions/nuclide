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

var int autocvar_chatplug_suppresschat = 0;

/* our sound boogeyman */
static entity emitter;
static int g_sounds;

/* where we save our lists */
typedef struct {
	string sentence;
	string sample;
} chatsentence_t;
static chatsentence_t *g_table;

void
ChatPlay(int id)
{
	int r, count, flags;
	count = tokenizebyseparator(g_table[id].sample, ";");
	r = random(0, count);
	flags = SOUNDFLAG_NOREVERB; /* this should be enough for now */
	sound(emitter, CHAN_BODY, argv(r), 1.0f, ATTN_NONE, 100, flags);
}

int
ChatLookUp(string cmd)
{
	int i;
	for (i = 0; i < g_sounds; i++) {
		int sc = tokenizebyseparator(g_table[i].sentence, ";");
		for (int c = 0; c < sc; c++) {
			if (cmd == argv(c)) {
				ChatPlay(i);
				break;
			}
		}
	}

	/* some joker might set it to non 0/1 */
	return autocvar_chatplug_suppresschat == 1 ? TRUE : FALSE;
}

void
initents(void)
{
	/* why waste entity slots? */
	if (g_sounds > 0) {
		emitter = spawn();
	}
}

void
init(float prevprogs)
{
	string temp;
	int i = 0;
	int c = 0;
	filestream chatfile;
	searchhandle list;

	list = search_begin("plugins/chatsounds/*.txt", TRUE, TRUE);
	for (int i = 0; i < search_getsize(list); i++) {
		print(sprintf("Found %s\n", search_getfilename(list, i)));
	}
	search_end(list);
	
	chatfile = fopen("chatsounds.txt", FILE_READ);

	if (chatfile < 0) {
		print("Chat Sound Plugin: chatsounds.txt not found.\n");
		return;
	}

	/* count lines */
	while ((temp = fgets(chatfile))) {
		c = tokenize_console(temp);
		if (c != 2) {
			continue;
		}
		g_sounds++;
	}
	fseek(chatfile, 0);

	g_table = memalloc(sizeof(chatsentence_t) * g_sounds);
	while ((temp = fgets(chatfile))) {
		c = tokenize_console(temp);
		if (c != 2 ) {
			continue;
		}
		g_table[i].sentence = strtolower(argv(0));
		g_table[i].sample = strtolower(argv(1));
		c = tokenizebyseparator(g_table[i].sample, ";");
		for (int x = 0; x < c; x++) {
			precache_sound(argv(x));
			print(sprintf("Caching: %s\n", argv(x)));
		}
		i++;
	}
	fclose(chatfile);
}

/* plugin hook */
int
FMX_ParseClientCommand(string cmd)
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
