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
NSDict::NSDict(void)
{
	m_strBody = "";
}

string
NSDict::GetDeclBody(void)
{
	return (m_strBody);
}

void
NSDict::SetDeclBody(string textBody)
{
	m_strBody = textBody;
}

float
NSDict::GetFloat(string keyName)
{
	return stof(GetString(keyName));
}

string
NSDict::GetString(string keyName)
{
	int spawnWords = (int)tokenize_console(m_strBody);

	/* iterate over our own spawnkeys first */
	for (int c = 0i; c < spawnWords; c+= 2i) {
		if (argv(c) == keyName) {
			return argv(c+1);
		}
	}
}

vector
NSDict::GetVector(string keyName)
{
	return stov(GetString(keyName));
}

bool
NSDict::GetBool(string keyName)
{
	return stof(GetString(keyName)) ? true : false;
}

void
NSDict::_AddRemoveKey(string keyName, string setValue, bool delete)
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
NSDict::AddKey(string keyName, string setValue)
{
	_AddRemoveKey(keyName, setValue, false);
}

void
NSDict::RemoveKey(string keyName)
{
	_AddRemoveKey(keyName, "", true);
}
