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

/* apUserID is argv(1) from a console command */
void
ActivityPub_FetchAccountData(string apUserID)
{
	string userID = __NULL__;
	string apInstance = __NULL__;

	if (!apUserID) {
		return;
	}

	tokenizebyseparator(apUserID, "@");
	userID = argv(1);
	apInstance = argv(2);

	uri_get(sprintf("https://%s/api/v1/accounts/%s", apInstance, userID), ACTIVITYPUB_ACCOUNTS);
}

/* the json string passed from uri's callback function as data */
void
ActivityPub_UpdatePlayerInfo(string jsonData)
{
	jsonnode acctNode = json_parse(jsonData);

	if (!acctNode) {
		NSError("Unable to parse ActivityPub info.");
		return;
	}

	string stringName = acctNode["display_name"].s;
	string stringAvatar = acctNode["avatar_static"].s;

	if (!stringName) {
		NSError("ActivityPub display name invalid.");
	} else {
		cvar_set("name", stringName);
	}

	if (!stringAvatar) {
		NSError("ActivityPub avatar invalid.");
	} else {
		localcmd(sprintf("setinfo avatar %S\n", stringAvatar));
	}

	json_free(acctNode);
}
