/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

float
Entities_ParseLump(void)
{
	entity eOld;
	CBaseEntity eEnt = __NULL__;
	string strField, strValue;
	__fullspawndata = "";
	int iClass = FALSE;

	eOld = self;

	while (1) {
		strField = getentitytoken();

		if (!strField) {
			break;
		}

		if (strField == "}") {
			/* invalid entity */
			if (!eEnt.classname) {
				break;
			}
			/* when we've reached the end of the lump, initialize the class! */
			if (iClass == TRUE) {
				eEnt.Init();
				return TRUE;
			}

			/* remove if we've found no valid class to go with us */
			if (eEnt) {
				remove(eEnt);
			}
			return TRUE;
		}

		strValue = getentitytoken();
		if (!strValue) {
			break;
		}

		switch (strField) {
		case "classname":
			eEnt = (CBaseEntity)spawn();

			/* check if our classname has a matching class */
			if (isfunction(strcat("spawnfunc_", strValue))) {
				self = eEnt;
				callfunction(strcat("spawnfunc_", strValue));
				self = eOld;
				iClass = TRUE;
			} else {
				eEnt.classname = strValue;
			}
			break;
		default:
			__fullspawndata = sprintf("%s\"%s\" \"%s\" ",
				__fullspawndata, strField, strValue);
			break;
		}
	}

	return FALSE;
}
