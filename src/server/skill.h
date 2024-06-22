
/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/** @defgroup skill Skill
    @brief Skill/Difficulty related APIs.
    @ingroup server

The skill/difficulty APIs are used to retrieve variables that change
depending on the selected game difficulty setting.

The setting is controlled via the `skill` console variable, which is represented
by three different modes:

1. Easy
2. Medium
3. Hard

The framework will then query the active skill variables.
If a skill value isn't set, a fallback value will be used.
If the console variable `skill` is empty, or `0` it will
assume the default setting of `2` - the *medium* difficulty.

You can technically query higher values then `3`, just ensure you set them all up in your skill manifest.

## Setting Skill Defaults

Default values are loaded from `<gamedir>/cfg/skill_manifest.cfg`.

The format looks like this:

```
set sk_starthealth1 "100"
set sk_starthealth2 "75"
set sk_starthealth3 "25"
```

While you can set these in the `skill_manifest.cfg` file directly, it is encouraged
to put your own values in a separate config.  
That way when people mod your game, they can inherit updates from the other, separate config without having to duplicate the variables every time your game updates.

## Querying Skill Variables

Developers can query the variable set in the skill system using Skill_GetValue():

```
player.health = Skill_GetValue("starthealth", 75);
```

And [entity declarations](@ref entitydef) can query skills like so:

```
entityDef some_def
{
	"spawnclass"  "TestClass"
	"health"      "skill:starthealth"
}
```


@{
*/

/** Called by Nuclide in `init()` before entities, or even [EntityDef](@ref entitydef) are initialized. */
void Skill_Init(void);

/** Return a skill variable's value or return a defaultvalue if it's undefined. */
float Skill_GetValue(string, float);

/** Parses a specified config file. This should ideally be done before entities spawn. You are only allowed to parse files from a sub-directory such as `gamedir/cfg/`. Some directories are blocked by the engine for security reasons. */
bool Skill_ParseConfig(string fileName);

/** @} */ // end of skill
