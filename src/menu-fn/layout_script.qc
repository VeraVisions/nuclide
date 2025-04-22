/* Copyright (c) 2023, Vera Visions, L.L.C.  All rights reserved. */

/* Layout Script parser for Menu-FN

	Layout scripts are used for the advanced options for server and user settings.
	Those are found on the filesystem as 'settings.src' and 'user.scr'.

	The layout is usually this:

	{

		"some_cvar"
		{
			"Description"
			{ TYPE [PARAMETERS ...] }
			{ Default Value }
		}
		[...]
	}

	of which TYPE can be STRING, NUMBER, BOOL and LIST.

	The types for NUMBER specify a range like this:

		[...]
		{
			"Floating point cvar"
			{ NUMBER 0.0 1.0 }
			{ 0.5 }
		}
		[...]

	And you can set -1 to either min/max to disable a limit on either end.
	In the above example we set the default value to something in between
	the min/max.

	The types for LIST expect a whitespace separated key/value pair:

		[...]
		{
			"Damage setting"
			{ LIST "No damage" "0" "All damage" "1" }
			{ "1" }
		}
		[...]

	The default value for a LIST type needs to reference a value, not the key.
	The LIST parameter may also span multiple lines.
*/

enum
{
	LAYBR_OUT,
	LAYBR_CVAR,
	LAYBR_DESCR,
	LAYBR_VALUE, /* could be either type + params or default value */
};

static vector g_layoutPos;

static void
Layout_FromFile_Create(CPageTab target, string cvar, string descr, string type, string parms, string defval)
{
	int c = 0;
	int x_ofs = 309;
	CWidget new = __NULL__;

	//print(sprintf("New widget:\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n", cvar, descr, type, parms, defval));

	switch (type) {
	case "STRING":
	case "NUMBER":
		CCVarTextBox txtbox;
		new = spawn(CCVarTextBox);
		txtbox = (CCVarTextBox)new;
		txtbox.m_length = 156;
		txtbox.SetCvar(cvar, defval);
		break;
	case "BOOL":
		CCVarCheckBox chkbox;
		new = spawn(CCVarCheckBox);
		chkbox = (CCVarCheckBox)new;
		chkbox.SetCvar(cvar, defval);
		x_ofs = 138 + 28;
		break;
	case "LIST":
		//new = spawn(CTextBox);
		//break;
	default:
		ncWarning("Unknown widget type %S for cvar %S, ignoring.", type, cvar);
	}

	if (!new)
		return;

	new.SetPos(g_layoutPos[0], g_layoutPos[1]);
	target.AddWidget(new);

	/* add the label */
	CLabel lbl = spawn(CLabel);
	lbl.SetPos(x_ofs, g_layoutPos[1] + 5);
	lbl.SetText(descr, font_label);
	lbl.SetTextHeight(14);
	target.AddWidget(lbl);

	g_layoutPos[1] += 32;
}

static void
Layout_FromFile_Parse(string line, CPageTab target)
{
	static string cvar;
	static string descr;
	static string type;
	static string parms;
	static string defval;
	static int braced;	/* what brace level we are in */
	static int depth;	/* individual cvar brace depth */

	int c = 0;
	string key = __NULL__;

	c = tokenize_console(line);

	for (int i = 0; i < c; i++) {
		key = argv(i);

		if not (key)
			continue;

		switch (key) {
		case "{":
			braced++;

			if (braced > LAYBR_CVAR)
				depth++;
			break;
		case "}":
			braced--;

			/* we just got done with one widget */
			if (braced == LAYBR_CVAR) {
				Layout_FromFile_Create(target, cvar, descr, type, parms, defval);
				c = tokenize_console(line); /* the above function may tokenize */
				cvar = __NULL__;
				descr = __NULL__;
				type = __NULL__;
				parms = __NULL__;
				defval = __NULL__;
				depth = 0;
			}
			break;
		default:
			//if (braced >= LAYBR_CVAR)
			//	print(sprintf("%i (depth %i): %S\n", braced, depth, key));

			switch (braced) {
			case LAYBR_CVAR:
				cvar = key;
				break;
			case LAYBR_DESCR:
				descr = key;
				break;
			case LAYBR_VALUE:
				if (depth == 2) {
					if (!type)
						type = key;
					else {
						if (parms)
							parms = sprintf("%s %S", parms, key);
						else
							parms = key;
					}
				} else if (depth == 3) {
					if (defval)
						defval = sprintf("%s %S", defval, key);
					else
						defval = key;
				}
				break;
			default:
			}
			break;
		}
	}
}

void
Layout_FromFile(string filename, CWidget target)
{
	filestream fh;
	string line;

	CPageTab tab = spawn(CPageTab);

	//print(sprintf("Now loading: %S\n\n\n", filename));

	fh = fopen(filename, FILE_READ);
	if (fh < 0) {
		warning(sprintf("Cannot read layout file %S", filename));
		return;
	}

	/* reset the starting position */
	g_layoutPos = [138, 140];

	while ((line = fgets(fh))) {
		Layout_FromFile_Parse(line, tab);
	}

	fclose(fh);

	Widget_Add(target, tab);
}
