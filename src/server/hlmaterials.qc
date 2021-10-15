/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/* FIXME: world.... sigh, we should box this into a worldspawn class */
.string materials_file;

float
HLMaterials_Fetch(string tex_name)
{
	return (float)hash_get(hashMaterials, tex_name);
}

void
HLMaterials_Load(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);
	if (fileMaterial >= 0) {
		print(strcat("^2HLMaterials_Load: loading ", filename,"!\n"));
		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = strtoupper(argv(0));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(hashMaterials, strtolower(argv(1)), str2chr(mat_type, 0));
			}
		}
		fclose(fileMaterial);
	} else {
		dprint(strcat("^1Failed to load ", filename,"!\n"));
	}
}

void
HLMaterials_Init(void)
{
	hashMaterials = __NULL__;
	hashMaterials = hash_createtab(2, HASH_ADD);

	/* the base definition, every GoldSrc game has this */
	HLMaterials_Load("sound/materials.txt");

	/* Sven Coop 5.0 does this, fun. */
	if (world.materials_file)
		HLMaterials_Load(world.materials_file);

	/* search through our sound dir for material definitions */
	searchhandle pm;
	pm = search_begin("sound/materials_*.txt", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		HLMaterials_Load(search_getfilename(pm, i));
	}
	search_end(pm);

	/* the way TW did it back in '03 */
	HLMaterials_Load(sprintf("maps/%s.mat", mapname));

	/* Trinity does it this way */
	HLMaterials_Load(sprintf("maps/%s_materials.txt", mapname));
}
