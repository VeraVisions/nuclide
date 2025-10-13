/*
 * Copyright (c) 2025 Vera Visions LLC.
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

/**
@defgroup localization Localization
@ingroup client
@ingroup menu

# Overview

Nuclide has its own system to handle localized text.

While the engine has its own localization support with .po files,
they're unfortunately not of any use with dynamically typed strings.

# Usage

Strings that are meant to represent localized text start with the `#` character. You'll find examples such as `#UI_ACCEPT".
Only the client and server actually handle localized text right now. That is by design to ensure best practices are followed, for now.

# Resouce Files

By default the client (and menu) loads both `resource/gameui_[LANG].txt`,
but only the client looks for `resources/[GAME]_[LANG].txt`.

The client or menu game code is allowed to call Locale_AddFile() to add
new resource files to the localization table.

The localization table, generated form said resource files, gets re-loaded upon a renderer restart. 
Invoking `vid_reload` via console can accomplish this, for example.

# Setting locale

The engine attempts to set the `lang` console variable to the operating system's appropriate
locale by default. We then do a look-up, falling back to `english` as the suffix
for our resource files.


# Language Table

| Language            | POSIX Locale | Resource Suffix |
|---------------------|--------------|-----------------|
| Brazilian           | pt_BR        | brazilian       |
| Bulgarian           | bg_BG        | bulgarian       |
| Czech               | cs_CZ        | czech           |
| Danish              | da_DK        | danish          |
| Dutch               | nl_NL        | dutch           |
| English             | en_US        | english         |
| Finnish             | fi_FI        | finnish         |
| French              | fr_FR        | french          |
| German              | de_DE        | german          |
| Greek               | el_GR        | greek           |
| Hungarian           | hu_HU        | hungarian       |
| Italian             | it_IT        | italian         |
| Japanese            | ja_JP        | japanese        |
| Korean              | ko_KR        | koreana         |
| Norwegian           | no_NO        | norwegian       |
| Polish              | pl_PL        | polish          |
| Portuguese          | pt_PT        | portuguese      |
| Romanian            | ro_RO        | romanian        |
| Russian             | ru_RU        | russian         |
| Simplified Chinese  | zh_CN        | schinese        |
| Spanish             | zh_TW        | spanish         |
| Swedish             | sv_SE        | swedish         |
| Thai                | th_TH        | thai            |
| Traditional Chinese | zh_TW        | tchinese        |
| Turkish             | tr_TR        | turkish         |

*/

/** Global function to look up localized strings. Only available on client and menu. 

Supplied tokens need to start with a `#` character in order to be recognized
as such.

@param lookUpToken Token string. E.g. `"#GameUI_SkillHard"`
@return Localized string. */
string localize(string lookUpToken);

void Locale_Init(void);
void Locale_Reload(void);
void Locale_AddFile(string resouceName);
