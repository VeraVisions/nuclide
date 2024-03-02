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

/*
   This file adds support for GoldSrc styled detail texture definitions.
   Currently, it's map specific (but we can make a global detail file as well.

   maps/mapname_detail.txt contains a list made up of 4 components per line.

   MAPTEXTURENAME PATH_TO_SOME_OVERLAY XSCALE YSCALE
*/

static int g_detail_initialized;

const string g_detail_shader = \
	"{\n" \
		"{\n" \
			"program defaultwall\n" \
			"map $diffuse\n" \
		"}\n" \
		"{\n" \
			"map gfx/%s.tga\n" \
			"tcMod scale %f %f\n" \
			"blendFunc filter\n" \
		"}\n" \
	"}";

const string g_detail_debug = \
	"{\n" \
		"{\n" \
			"map $blackimage\n" \
		"}\n" \
	"}";

void
DetailTex_Parse(string maptex, string detailtex, float xscale, float yscale)
{
	xscale *= autocvar(r_detailtextures_xscale, 1.0, "X scale multiplier for detail tex");
	yscale *= autocvar(r_detailtextures_yscale, 1.0, "Y scale multiplier for detail tex");

	NSLog("DETAIL: %s %s %f %f", maptex, detailtex, xscale, yscale);

#if 1
	shaderforname(strcat(maptex, "_detail"), sprintf(g_detail_shader, detailtex, xscale, yscale));
#else
	shaderforname(strcat(maptex, "_detail"), g_detail_debug);
#endif

	remapshader(maptex, strcat(maptex, "_detail"), 0.0f);
}

void
DetailTex_Reload(void)
{
	filestream fh;
	string line;
	int n = 0;

	g_detail_initialized = 0;

	if (!autocvar(r_detailtextures, 0, "High-res detail texture overlays for selected maps"))
		return;

	fh = fopen(strcat("maps/", mapname, "_detail.txt"), FILE_READ);

	if (fh < 0) {
		NSError("DeailTex definition missing for %s.", mapname);
		return;
	}

	while ((line = fgets(fh))) {
		int c = tokenize_console(line);

		if (c != 4)
			continue;

		DetailTex_Parse(strtolower(argv(0)), argv(1), stof(argv(2)), stof(argv(3)));
		n++;
	}

	NSLog("DeailTex initialized with %i entries.", n);
	fclose(fh);
	g_detail_initialized = 1;
}
