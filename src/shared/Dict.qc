/*
 * Copyright (c) 2024 Vera Visions LLC.
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
ncDict::ncDict(void)
{
	m_strBody = "";
}

string
ncDict::GetDeclBody(void)
{
	return (m_strBody);
}

void
ncDict::SetDeclBody(string textBody)
{
	m_strBody = textBody;
}

int
ncDict::GetInteger(string keyName)
{
	return (int)stoi(GetString(keyName));
}

float
ncDict::GetFloat(string keyName)
{
	return stof(GetString(keyName));
}

string
ncDict::GetString(string keyName)
{
	int spawnWords = (int)tokenize_console(m_strBody);

	/* iterate over our own spawnkeys first */
	for (int c = 0i; c < spawnWords; c+= 2i) {
		if (argv(c) == keyName) {
			return argv(c+1);
		}
	}

	return "";
}

vector
ncDict::GetVector(string keyName)
{
	return stov(GetString(keyName));
}

bool
ncDict::GetBool(string keyName)
{
	return stof(GetString(keyName)) ? true : false;
}

void
ncDict::_AddRemoveKey(string keyName, string setValue, bool delete)
{
	string newBody = "";
	int spawnWords = (int)tokenize_console(m_strBody);

	/* collect all existing key (except the one we wanna add, if it exists */
	for (int c = 0i; c < spawnWords; c+= 2i) {
		if (argv(c) != keyName) {
			newBody = sprintf("%s%S %S\n", newBody, argv(c), argv(c+1));
		}
	}

	if (delete == false) {
		newBody = sprintf("%s%S %S\n", newBody, keyName, setValue);
	}

	m_strBody = newBody;
}

void
ncDict::AddKey(string keyName, string setValue)
{
	_AddRemoveKey(keyName, setValue, false);
}

void
ncDict::RemoveKey(string keyName)
{
	_AddRemoveKey(keyName, "", true);
}

int
ncDict::TokenCount(void)
{
	return (int)tokenize_console(m_strBody);
}

ncDict
ncDict::InitWithSpawnData(string spawnData)
{
	ncDict newDict = spawn(ncDict);
	newDict.SetDeclBody(spawnData);
	return (newDict);
}

ncDict
ncDict::LoadDeclFromFile(string declName, string fileName)
{
	filestream fh;
	ncDict newDict;
	string tempString;
	int braceDepth = 0i;
	string lastWord = __NULL__;
	string lastDecl = "";

	fh = fopen(strcat("decls/", fileName), FILE_READ);

	if (fh < 0) {
		NSError("Can't read %S", fileName);
		return __NULL__;
	}

	newDict = spawn(ncDict);

	while ((tempString = fgets(fh))) {
		int lineSegments = tokenize_console(tempString);

		for (int i = 0i; i < lineSegments; i++) {
			string word = argv(i);

			switch (word) {
			case "{":
				braceDepth++;
				break;
			case "}":
				braceDepth--;

				/* we've reached the end of a definition */
				if (braceDepth == 0) {
					/* we found it, we're done */
					if (STRING_SET(lastDecl) && lastDecl == declName) {
						break;
					}
					lastDecl = "";
				}
				break;
			default:
				/* anything outside braces defines the classname for the next def */
				if (braceDepth == 0 && lastWord == "typeInfo") {
					lastDecl = word;
				} /* else if (braceDepth == 0 && lastWord == "#include") {
					g_entDefInclude = strcat(g_entDefInclude, word, ";");
				} else if (braceDepth == 0 && lastWord == "#define") {
					Constants_Add(argv(i), argv(i+1));
				} */ else if (braceDepth == 1) {
					/* spawnclass is reserved and the next keyword specs it */
					/*if (word == "spawnclass") {
						currentDef.spawnClass = argv(i+1);
						i++;
					} else if (word == "inherit") {
						currentDef.inheritKeys = argv(i+1);
						i++;
					} else*/ if (lastDecl == declName) { /* rest gets dumped into spawndata */
						newDict.m_strBody = strcat(newDict.m_strBody, "\"", word, "\"", " ");
					}
				}
			}
			lastWord = word;
		}

#if 0
		if (c == 1) {

		} else if (c == 2) {
			newDict.AddKey(argv(0), argv(1));
		}
#endif
	}

	fclose(fh);

	/* failed to find any key-value pairs. empty */
	if (!STRING_SET(newDict.m_strBody)) {
		remove(newDict);
		return (__NULL__);
	}

	return (newDict);
}

