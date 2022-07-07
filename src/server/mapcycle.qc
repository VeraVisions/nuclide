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

var int autocvar_mapcycle_enabled = TRUE;
var string autocvar_mapcycle_file = "mapcycle.txt";
var string g_mapcycle_override = __NULL__;

void
Mapcycle_Load(string filename)
{
	filestream fs_mapcycle;
	string temp;
	int mapcount = 0i;
	string lastmap = "";
	int map_next = 0i;

	if (!autocvar_mapcycle_enabled)
		return;

	/*if (Rules_IsMultiplayer())
		return;*/

	fs_mapcycle = fopen(filename, FILE_READ);

	if (fs_mapcycle < 0) {
		print(strcat("^1could not load ", filename, "\n"));
		return;
	}

	/* read the lines in, see if the map exists and define an enumerated alias */
	while ((temp = fgets(fs_mapcycle))) {
		if not (whichpack(strcat("maps/", temp, ".bsp")))
			continue;

		readcmd(sprintf("alias m%i \"map %s;alias nextmap m%i\"\n", mapcount, temp, mapcount + 1i));

		if (mapname == lastmap)
			map_next = mapcount;

		lastmap = temp;
		mapcount++;
	}

	fclose(fs_mapcycle);

	if (mapcount <= 0i)
		return;

	/* override the last map so that it goes back to m0 */
	readcmd(sprintf("alias m%i \"map %s;alias nextmap m0\"\n", mapcount - 1i, lastmap));

	/* the current map in the list will decide the nextmap */
	readcmd(sprintf("alias nextmap m%i\n", map_next));

	print(sprintf("mapcycle initialized with %i entries.\n", mapcount));
}

void
Mapcycle_Init(void)
{
	print("--------- Initializing MapCycle ----------\n");

	Mapcycle_Load(autocvar_mapcycle_file);
}
