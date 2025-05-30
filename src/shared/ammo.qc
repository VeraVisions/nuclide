/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

#warning Ammo capacity is able to slow people down in some games/mods.

/** Data holding ammo variant entries. */
typedef struct
{
	string m_strName; /**< Name of the ammo type. E.g. 'ammo_snowballs' */
	string m_strTitle; /**< Title of the ammo type. E.g. 'Snowballs' */
	int m_iMax; /**< Maximum reserve ammo of the type. Values <= 0 are infinite. */
} ammoInfo_t;

static ammoInfo_t g_ammoInfo[MAX_AMMO_TYPES];

string
ammoNameForNum(int ammoIndex)
{
	return (g_ammoInfo[ammoIndex].m_strName);
}

int
ammoNumForName(string ammoName)
{
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		if (g_ammoInfo[i].m_strName == ammoName) {
			return (i);
		}
	}

	return (-1);
}

int
ammoMaxForName(string ammoName)
{
	for (int i = 0; i < MAX_AMMO_TYPES; i++) {
		if (g_ammoInfo[i].m_strName == ammoName) {
			return (g_ammoInfo[i].m_iMax);
		}
	}

	return (0);
}

int
ammoMaxForNum(int ammoIndex)
{
	return (g_ammoInfo[ammoIndex].m_iMax);
}

void
Ammo_Init(void)
{
	int ammoTypeID = EntityDef_IDFromName("ammo_types");
	string ammoTypeData;

	if (ammoTypeID == -1) {
		ncWarning("Decl `ammo_types` not defined in `def/`. Ammo unavailable.");
		return;
	}

	ammoTypeData = EntityDef_GetSpawnData(ammoTypeID);

	int numKeys = tokenize_console(ammoTypeData);

	for (int c = 0; c < numKeys; c+=2) {
		string ammoName = argv(c);
		int ammoIndex = stoi(argv(c+1));
		g_ammoInfo[ammoIndex].m_strName = ammoName;
		g_ammoInfo[ammoIndex].m_strTitle = EntityDef_GetKeyValue("ammo_names", ammoName);
		string maxString = EntityDef_GetKeyValue("ammo_max", ammoName);
		string unpackedString = unpackStringCommand(maxString);
		g_ammoInfo[ammoIndex].m_iMax = (int)stof(unpackedString);
		numKeys = tokenize_console(ammoTypeData);
	}
}

/** Called by listAmmo */
void
Ammo_DebugList(void)
{
	for (int i = 0i; i < MAX_AMMO_TYPES; i++) {
		printf("%i %S: %S\n", i,
			g_ammoInfo[i].m_strName, g_ammoInfo[i].m_strTitle);
	}
}
