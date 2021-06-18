
typedef enum
{
	PLATFORM_UNINITIALIZED = -1,
	PLATFORM_UNKNOWN = 0,
	PLATFORM_PC,
	PLATFORM_CONSOLE,
	PLATFORM_TOUCH,
	PLATFORM_WEB
} platform;

var platform g_platform = PLATFORM_UNINITIALIZED;

/* fast way to query which system we're on */
platform
Platform_GetPlatform(void)
{
	if (g_platform == PLATFORM_UNINITIALIZED) {
		string osname = cvar_string("sys_platform");
		g_platform = PLATFORM_UNKNOWN;

		switch (osname) {
		case "Web":
			g_platform = PLATFORM_WEB;
			break;
		case "WinCE":
		case "Xbox":
			g_platform = PLATFORM_CONSOLE;
			break;
		case "WinRT":
		case "iOSSim":
		case "iOS":
		case "Android":
			g_platform = PLATFORM_TOUCH;
			break;
		case "Unknown":
		case "Nacl":
		case "Win":
		case "Win16":
		case "Cygwin":
		case "Linux":
		case "Mac":
		case "Apple":
		case "FreeBSD":
		case "OpenBSD":
		case "NetBSD":
		case "BSD":
		case "MorphOS":
		case "AmigaOS":
		case "MacOS X":
		case "Dos":
		default:
			g_platform = PLATFORM_PC;
			break;
		}
	}

	return g_platform;
}
