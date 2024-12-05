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

/** @defgroup decl Declaration Files
    @brief External plain text files often containing groups of key-value pairs.

The core of Nuclide embraces external files called 'declaration files'.
They often contain key-value pairs, much like the entity spawn data
within a level.

You will commonly find them within `<gamedir>/decls/`.

@{
*/

/** This class is responsible for handling groups of key/value pairs.

It handles entity spawns, respawns,
save/load as well as key/value pair loading, as well as inputs/outputs
which is our basic entity model.

This is a very low-level class. You're never meant to use this.
Use ncEntity as a basis for your classes.

@ingroup decl
*/
class
ncDict
{
public:
	void ncDict(void);

	nonvirtual int GetInteger(string);
	nonvirtual float GetFloat(string);
	nonvirtual string GetString(string);
	nonvirtual vector GetVector(string);
	nonvirtual bool GetBool(string);

	nonvirtual void SetDeclBody(string);
	nonvirtual string GetDeclBody(void);

	nonvirtual void AddKey(string, string);
	nonvirtual void RemoveKey(string);

	nonvirtual int TokenCount(void);

	static ncDict InitWithSpawnData(string);
	static ncDict LoadDeclFromFile(string, string);

private:
	nonvirtual void _AddRemoveKey(string, string, bool);
	string m_strBody;
};

/** @} */ // end of decl
