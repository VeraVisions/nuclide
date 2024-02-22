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
=================
Skill_Init

Usually just parses a config file. Make sure readcmd() is used here because
localcmd() does not parse files instantly - so monsters/weapons may be
initialized before the skill variables are read!
This will almost always result in them using default values, or (worst case) 0.
=================
*/
void
Skill_Init(void)
{
	Skill_ParseConfig("cfg/skill_manifest.cfg");
	Skill_ParseConfig(sprintf("maps/%s_skl.cfg", mapname));
}

/*
=================
Skill_GetValue

Return a skill variable's value or return a defaultValue if it's undefined.
=================
*/
float
Skill_GetValue(string variable, float defaultValue)
{
	float skill = cvar("skill");

	if (skill == 0)
		skill = 2; /* default to medium */

	float val = fabs(cvar(sprintf("sk_%s%d", variable, skill)));
	return (val == 0) ? defaultValue : val;
}

/* input string is potentially a skill variable */
float
Skill_GetDefValue(string variable)
{
	if (substring(variable, 0, 6) == "skill:") {
		return Skill_GetValue(substring(variable, 6, -1), 0);
	}

	return stof(variable);
}

bool
Skill_ParseConfig(string fileName)
{
	string tempString;
	filestream configFile = fopen(fileName, FILE_READ);

	if (configFile < 0) {
		print(sprintf("^1Warning: Unable to exec %S for parsing.\n", fileName));
		return (false);
	}

	while ((tempString = fgets(configFile))) {
		int argCount = (int)tokenize_console(tempString);
		string firstArg = argv(0);

		if (argCount == 2i) {
			if (firstArg == "exec") {
				Skill_ParseConfig(sprintf("cfg/%s", argv(1)));
			}
		} else if (argCount == 3i) {
			if (firstArg == "set" || firstArg == "seta")
				cvar_set(argv(1), argv(2));
		}
	}

	fclose(configFile);
	return (true);
}