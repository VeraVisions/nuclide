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


/* general purpose functions to interact with the material system */
static void
Materials_LoadFromText(string filename)
{
#if 0
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);

	if (fileMaterial >= 0) {
		//print(strcat("parsing material assignments from ", filename,"\n"));

		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = strtoupper(argv(0));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(g_hashMaterials, tex_name, str2chr(mat_type, 0), EV_STRING);
			}
		}

		fclose(fileMaterial);
	} else {
		dprint(strcat("^1Failed to load ", filename,"!\n"));
	}
#endif
}

static void
Materials_LoadFromMat(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string materialname = substring(filename, 0, -5);
	string extension = substring(filename, strlen(filename) - 3, 3);
	string command, parameters;

	fileMaterial = fopen(filename, FILE_READ);

	/* load the .mat and find which material we're supposed to be using */
	if (fileMaterial >= 0) {
		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				command = strtolower(argv(0));
				parameters = argv(1);

				if (command == "surfaceprop") {
					hash_add(g_hashMaterials, materialname, parameters, EV_STRING);
					//print(sprintf("added Material %S type %S\n", materialname, parameters));
					break;
				}
			}
		}

		fclose(fileMaterial);
	}
}

/** FIXME: all this should be done exclusively in surfaceproperties.qc, however that
is currently server-side only. Make it shared and then we can get rid of this
whole file! */

/** loads a temporary mapper so we can map letters to class names. */
static void
Materials_Mapper_Init(void)
{
	string sTemp;
	int c = 0;
	filestream fileLUT;
	string spname = "";
	bool inbrace = false;

	fileLUT = fopen("scripts/surfaceproperties.txt", FILE_READ);
	g_hlmlut_count = 0;

	/* count valid entries. */
	if (fileLUT >= 0) {
		while ((sTemp = fgets(fileLUT))) {
			if (tokenize_console(sTemp) == 2) {
				if (argv(0) == "gamematerial")
					g_hlmlut_count++;
			}
		}
	}

	/* back to the beginning... */
	fseek(fileLUT, 0);
	g_hlmlut = memalloc(sizeof(hlmaterials_lut) * g_hlmlut_count);

	/* read in the elements */
	if (fileLUT >= 0) {
		while ((sTemp = fgets(fileLUT))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				if (argv(0) == "gamematerial") {
					g_hlmlut[c].id = argv(1);
					g_hlmlut[c].matclass = spname;
					c++;
				}
			}
			
			if (argv(0) == "{")
				inbrace = true;
			else if (argv(0) == "}")
				inbrace = false;
			else if (inbrace == false)
				spname = argv(0);
		}
	}
}

/** takes a mat id and returns a classname */
static string
Materials_Mapper_Lookup(string character)
{
	int i;

	for (i = 0; i < g_hlmlut_count; i++)
		if (g_hlmlut[i].id == character)
			return g_hlmlut[i].matclass;

	return __NULL__;
}

/** unallocates the mapper */
static void
Materials_Mapper_Shutdown(void)
{
	g_hlmlut_count = 0;
	memfree(g_hlmlut);
}

/** loads a materials.txt type file into our hashtable. */
static void
Materials_LoadFromLegacyText(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);
	if (fileMaterial >= 0) {
		//print(strcat("parsing material definitions from ", filename,"\n"));
		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = Materials_Mapper_Lookup(strtoupper(argv(0)));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(g_hashMaterials, tex_name, mat_type, EV_STRING);
				///print(sprintf("hlmaterial: %S %S\n", tex_name, mat_type));
				g_hlmaterial_entries++;
			}
		}
		fclose(fileMaterial);
	} else {
		dprint(strcat("^1Failed to load ", filename,"!\n"));
	}
}

/** Initialize our material backbone */
void
Materials_Init(void)
{
	g_hashMaterials = __NULL__;
	g_hashMaterials = hash_createtab(2, EV_STRING | HASH_REPLACE);

	/* save away the type of material formats we're dealing with */
	switch (serverkeyfloat("*bspversion")) {
	case BSPVER_Q3: /* Q3 */
	case BSPVER_RTCW: /* RtCW */
	case BSPVER_RBSP: /* RFVBSP */
		g_materialsAreLegacy = false;
		break;
	case BSPVER_HL:
	default:
		g_materialsAreLegacy = true;
	}

	/* we're dealing with legacy materials */
	if (g_materialsAreLegacy) {
		/* prepare the mapper */
		Materials_Mapper_Init();

		/* the base definition, every GoldSrc game has this */
		Materials_LoadFromLegacyText("sound/materials.txt");

		/* Sven Coop 5.0 loads it from a worldspawn key */
		if (world.materials_file)
			Materials_LoadFromLegacyText(world.materials_file);

		/* search through our sound dir for material definitions */
		searchhandle pm;
		pm = search_begin("sound/materials_*.txt", TRUE, TRUE);
		for (int i = 0; i < search_getsize(pm); i++) {
			Materials_LoadFromLegacyText(search_getfilename(pm, i));
		}
		search_end(pm);

		/* the way TW did it back in '03 */
		Materials_LoadFromLegacyText(sprintf("maps/%s.mat", mapname));

		/* Trinity-Renderer does it this way */
		Materials_LoadFromLegacyText(sprintf("maps/%s_materials.txt", mapname));

		/* no longer needed! */
		Materials_Mapper_Shutdown();
	} else {
		/* iterate through our mat files */
		searchhandle searchy = search_begin("textures/*/*.mat", SEARCH_NAMESORT, TRUE);
		for (int i = 0; i < search_getsize(searchy); i++) {
			Materials_LoadFromMat(search_getfilename(searchy, i));
		}
	}
}
