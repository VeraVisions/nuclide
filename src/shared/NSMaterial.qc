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

void
NSMaterial::NSMaterial(void)
{
	m_bPenetrable = false;
	m_bFootsteps = false;
	m_flFriction = 1.0f;
	m_strStepSound = "step.default";

	/* no need to be around */
	think = Util_Destroy;
	nextthink = time + 0.25f;
}

float
NSMaterial::GetFriction(void)
{
	return (m_flFriction);
}

bool
NSMaterial::Footsteps(void)
{
	return (m_bFootsteps);
}

bool
NSMaterial::Penetrable(void)
{
	return (m_bPenetrable);
}

void
NSMaterial::FootstepSound(NSClient client)
{
	/* foobar */
}

void
NSMaterial::Impact(vector vecOrigin, vector vecAngle)
{
	print("IMPACT, WOOO\n");
}

/* general purpose functions to interact with the material system */
void
Materials_LoadFromText(string filename)
{
	filestream fileMaterial;
	string sTemp;
	string mat_type;
	string tex_name;

	fileMaterial = fopen(filename, FILE_READ);

	if (fileMaterial >= 0) {
		print(strcat("parsing material assignments from ", filename,"\n"));

		while ((sTemp = fgets(fileMaterial))) {
			/* tokenize and just parse this stuff in */
			if (tokenize_console(sTemp) == 2) {
				mat_type = strtoupper(argv(0));
				tex_name = Materials_FixName(strtolower(argv(1)));
				hash_add(g_hashMaterials, tex_name, str2chr(mat_type, 0));
			}
		}

		fclose(fileMaterial);
	} else {
		dprint(strcat("^1Failed to load ", filename,"!\n"));
	}
}

void
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

				if (command == "material") {
					hash_add(g_hashMaterials, materialname, parameters);
					print(sprintf("added Material %S type %S\n", materialname, parameters));
					break;
				}
			}
		}

		fclose(fileMaterial);
	}
}

void
Materials_Init(void)
{
	g_hashMaterials = __NULL__;
	g_hashMaterials = hash_createtab(2, EV_STRING);

	/* global table */
	Materials_LoadFromText("textures/materials.def");

	/* iterate through our mat files */
	searchhandle searchy = search_begin("textures/*/*.mat", SEARCH_NAMESORT, TRUE);
	for (int i = 0; i < search_getsize(searchy); i++) {
		Materials_LoadFromMat(search_getfilename(searchy, i));
	}
}

NSMaterial
Material_FromTexture(string tex_name)
{
	string mat = (string)hash_get(g_hashMaterials, tex_name);
	string func = strcat("spawnfunc_", mat);

	if (isfunction(func)) {
		entity oldself = self;
		void(void) vFunc;
		vFunc = externvalue(-2, func);
		NSMaterial new_mat = spawn(NSMaterial);
		self = new_mat;
		vFunc();
		self = oldself;
		return (new_mat);
	} else if (mat != "") {
		/* let the console know */
		print(sprintf("^1material %S does not exist!\n", mat));
	}

	/* return the builtin generic material */
	NSMaterial gen_mat = spawn(NSMaterial);
	return (gen_mat);
}
