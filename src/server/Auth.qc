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

static void
SV_PutClientInServer(entity targetClient)
{
	entity oldSelf = self;
	self = targetClient;
	PutClientInServer();
	self = oldSelf;
}

void
ncAuthManager::ncAuthManager(void)
{
}

bool
ncAuthManager::Connect(ncClient targetClient)
{
	if (autocvar_auth_enabled == false) {
		return (true);
	}

	if (!targetClient) {
		ncError("invalid client entity reference");
		return (false);
	}

	/* waive bots through */
	if (is.Bot(targetClient)) {
		PassClient(targetClient);
		return (true);
	}

	string clientIdentifyClaim = infokey(targetClient, "apid");

	/* server cares about authed clients */
	if (autocvar_auth_connectUnauthorizedClients == false) {
		/* if they aren't set, fail them right away. */
		if (!STRING_SET(clientIdentifyClaim)) {
			sprint(targetClient, PRINT_HIGH, "This server needs you to authenticatate using a ActivityPub profile.\n");
			FailClient(targetClient);
			return (false);
		}
	}

	tokenizebyseparator(clientIdentifyClaim, "@");
	string userID = argv(1);
	string apInstance = argv(2);

	uri_get(sprintf("https://%s/api/v1/accounts/%s", apInstance, userID), num_for_edict(targetClient));
	targetClient.m_authLevel = AUTH_PROCESSING;

	/* tolerated for now */
	return (true);
}

bool
ncAuthManager::AllowRespawn(ncClient targetClient)
{
	string clientIdentifyClaim = infokey(targetClient, "apid");

	if (autocvar_auth_enabled == false) {
		return (true);
	}
	
	if (targetClient.AuthLevel() == AUTH_FAILED && autocvar_auth_connectUnauthorizedClients == true) {
		return (true);
	}

	/* server doesn't care, but we need to delay people who want to auth! */
	if (autocvar_auth_connectUnauthorizedClients == true && !STRING_SET(clientIdentifyClaim) ) {
		return (true);
	}

	if (targetClient.AuthLevel() == AUTH_VERIFIED) {
		return (true);
	}

	return (false);
}

void
ncAuthManager::Disconnect(ncClient targetClient)
{
	/* even on disconnect, player slots are not supposed to ever be removed */
	if (!targetClient) {
		ncError("invalid client entity reference");
		return;
	}

	targetClient.m_authLevel = AUTH_UNCONNECTED;
}

void
ncAuthManager::PassClient(ncClient targetClient)
{
	ncLog("authentication for client %d succeeded", num_for_edict(targetClient));
	targetClient.m_authLevel = AUTH_VERIFIED;
}

void
ncAuthManager::FailClient(ncClient targetClient)
{
	if (autocvar_auth_enabled == false) {
		return;
	}

	if (!targetClient) {
		ncError("invalid client entity reference");
		return;
	}

	ncLog("authentication for client %d failed", num_for_edict(targetClient));
	targetClient.m_authLevel = AUTH_FAILED;

	/* this server requests them be authorized */
	if (autocvar_auth_connectUnauthorizedClients == false) {
		ncLog("dropping client %d due to server setting", num_for_edict(targetClient));
		dropclient(targetClient);
	} else {
		SV_PutClientInServer(targetClient);
	}
}

void
ncAuthManager::VerifyFingerprint(float requestID, string dataString)
{
	ncClient targetClient = (ncClient)edict_num(requestID);

	/* the response may have come late, and the auth has since been disabled... force respawn */
	if (targetClient && autocvar_auth_enabled == false) {
		SV_PutClientInServer(targetClient);
		return;
	}

	string clientFingerprint = infokey(targetClient, "*cert_sha1");

	/* either client doesn't exist or refuses to authenticate */
	if (!targetClient || !STRING_SET(clientFingerprint)) {
		ncError("fingerprint verification for client %d failed (%S)", requestID, clientFingerprint);
		
		if (targetClient) {
			FailClient(targetClient);
		}
		return;
	}

	jsonnode acctNode = json_parse(dataString);

	if (!acctNode) {
		ncError("failed to parse ActivityPub profile of %d %s", num_for_edict(targetClient), targetClient.netname);
		FailClient(targetClient);
		return;
	}

	/* verify it's them */
	jsonnode acctSource = json_find_object_child(acctNode, "source");

	if (!acctSource) {
		ncError("failed to parse profile source field of %d %s", num_for_edict(targetClient), targetClient.netname);
		FailClient(targetClient);
		json_free(acctNode);
		return;
	}
	
	jsonnode acctFields = json_find_object_child(acctNode, "fields");

	if (!acctFields) {
		ncError("failed to parse profile table of %d %s", num_for_edict(targetClient), targetClient.netname);
		FailClient(targetClient);
		json_free(acctNode);
		return;
	}

	/* iterate over all activitypub profile fields */
	for (int i = 0i; i < json_get_length(acctFields); i++) {
		jsonnode fieldNode = json_get_child_at_index(acctFields, i);
		
		/* shouldn't happen, but yeah. */
		if (!fieldNode) {
			ncError("node corrupt");
			break;
		}

		string keyName = fieldNode["name"].s;
		string setValue = fieldNode["value"].s;
		
		if (keyName == "GID") {
			if (setValue == clientFingerprint) {
				PassClient(targetClient);
				break;
			}
		}
	}

	string stringName = acctNode["display_name"].s;
	string stringAvatar = acctNode["avatar_static"].s;
	string stringHeader = acctNode["header_static"].s;
	string stringURL = acctNode["url"].s;
	string stringUsername = acctNode["username"].s;

	tokenizebyseparator(stringURL, "/");
	string instanceName = argv(2);

	string fullUserName = strcat(stringUsername, "@", instanceName);

	/* we've failed to find anything */
	if (targetClient.AuthLevel() != AUTH_VERIFIED) {
		sprint(targetClient, PRINT_HIGH, sprintf("ActivityPub profile %s does not contain key 'GID' with value %S\n", fullUserName, clientFingerprint));
		FailClient(targetClient);
		json_free(acctNode);
		return;
	}

	if (!stringName) {
		ncError("ActivityPub display name invalid.");
	} else {
		userinfo.SetString(targetClient, "*dn", stringName);
	}

	if (!stringAvatar) {
		ncWarning("ActivityPub avatar invalid.");
	} else {
		userinfo.SetString(targetClient, "*av", stringAvatar);
	}

	if (!stringHeader) {
		ncWarning("ActivityPub background invalid.");
	} else {
		userinfo.SetString(targetClient, "*bg", stringHeader);
	}

	if (!stringURL) {
		ncWarning("ActivityPub url invalid.");
	} else {
		userinfo.SetString(targetClient, "*ap", strcat(stringUsername, "@", instanceName));
	}

	json_free(acctNode);

	/* late respawn */
	SV_PutClientInServer(targetClient);
}

void
URI_Get_Callback(float uriID, float returnCode, string dataString, int resourceBytes)
{
	if (returnCode != 0) {
		ncError("failed authenticating client %d", uriID);
		return;
	}

	ncAuthManager::VerifyFingerprint(uriID, dataString);
}
