/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

#include "util.h"
#include "achievements.h"
#include "master.h"
#include "modserver.h"
#include "music.h"
#include "richpresence.h"
#include "servers.h"
#include "tcp.h"
#include "updates.h"
#include "gamelibrary.h"

/** Definitions for FTE's internal package manager. We don't want you to talk to this one directly within Nuclide. */
typedef enum
{
	GPMI_NAME,			/**< name of the package, for use with the pkg command. */
	GPMI_CATEGORY,		/**< category text */
	GPMI_TITLE,			/**< name of the package, for showing the user. */
	GPMI_VERSION,		/**< version info (may have multiple with the same name but different versions) */
	GPMI_DESCRIPTION,	/**< some blurb */
	GPMI_LICENSE,		/**< what license its distributed under */
	GPMI_AUTHOR,		/**< name of the person(s) who created it */
	GPMI_WEBSITE,		/**< where to contribute/find out more info/etc */
	GPMI_INSTALLED,		/**< current state */
	GPMI_ACTION,		/**< desired state */
	GPMI_AVAILABLE,		/**< whether it may be downloaded or not. */
	GPMI_FILESIZE,		/**< size to download. */
} packageType_t;