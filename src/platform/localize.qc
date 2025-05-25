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

static string
localizeSuffixForLocale(string locale)
{
	switch (locale) {
	case "pt_BR":
		return "brazilian";
		break;
	case "bg_BG":
		return "bulgarian";
		break;
	case "cs_CZ":
		return "czech";
		break;
	case "da_DK":
		return "danish";
		break;
	case "nl_NL":
		return "dutch";
		break;
	case "en_US":
		return "english";
		break;
	case "fi_FI":
		return "finnish";
		break;
	case "fr_FR":
		return "french";
		break;
	case "de_DE":
		return "german";
		break;
	case "el_GR":
		return "greek";
		break;
	case "hu_HU":
		return "hungarian";
		break;
	case "it_IT":
		return "italian";
		break;
	case "ja_JP":
		return "japanese";
		break;
	case "ko_KR":
		return "koreana";
		break;
	case "no_NO":
		return "norwegian";
		break;
	case "pl_PL":
		return "polish";
		break;
	case "pt_PT":
		return "portuguese";
		break;
	case "ro_RO":
		return "romanian";
		break;
	case "ru_RU":
		return "russian";
		break;
	case "zh_CN":
		return "schinese";
		break;
	case "zh_TW":
		return "spanish";
		break;
	case "sv_SE":
		return "swedish";
		break;
	case "th_TH":
		return "thai";
		break;
	case "zh_TW":
		return "tchinese";
		break;
	case "tr_TR":
		return "turkish";
		break;
	default:
		return "english";
	}
}

string
localize(string lookUpToken)
{
	return (lookUpToken);
}

var string g_localeFiles;

void
Locale_AddFile(string resourceName)
{
	string languageCode = localizeSuffixForLocale(cvar_string("lang"));
	string fileName = sprintf("resource/%s_%s.txt", resourceName, languageCode);
	string fileNameFB = sprintf("resource/%s_english.txt", resourceName);

	/* TODO: check if the file has already been added to the list */
	if (fileExists(fileName) == true) {
		g_localeFiles = sprintf("%s%s;", g_localeFiles, fileName);
	} else if (fileExists(fileNameFB)) {
		ncWarning("Locale resource %S for %s not found. Falling back to english.", resourceName, languageCode);
		g_localeFiles = sprintf("%s%s;", g_localeFiles, fileNameFB);
	} else {
		ncError("Locale resource %S not found.", resourceName);
	}
}

void
Locale_Init(void)
{
	string gameDir = cvar_string("fs_game");

	g_localeFiles = "";

#if 0
	Locale_AddFile("gameui");
	Locale_AddFile(gameDir);
#endif
}

void
Locale_Reload(void)
{
	for (int i = 0; i < (tokenizebyseparator(g_localeFiles, ";") - 1); i++) {
		string fileToLoad = argv(i);
		ncLog("Indexing locale resource %s\n", fileToLoad);
	}
}
