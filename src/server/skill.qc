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
	/* sometimes we have extra overrides that the original does not
	   provide. so we execute our mod-specific config here */
	readcmd(sprintf("exec skill_%s.cfg\n", cvar_string("game")));
	readcmd(sprintf("exec maps/%s_skl.cfg\n", mapname));
}

/*
=================
Skill_GetValue

Return a skill variable's value or return a defaultvalue if it's undefined.
=================
*/
float
Skill_GetValue(string variable, float defaultvalue)
{
	float skill = cvar("skill");
	float val = fabs(cvar(sprintf("sk_%s%d", variable, skill)));
	return (val == 0) ? defaultvalue : val;
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