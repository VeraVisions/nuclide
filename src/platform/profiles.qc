ncProfile g_activeProfile;

/* Profile Containers */
void
ncProfile::ncProfile(void)
{

}

void
ncProfile::LoadConfig(void)
{
	/* load the profile data */
	localcmd(sprintf("cfg_load \"%s.cfg\"\n", m_profileName));
	localcmd(sprintf("set cl_cred %S\n", m_profileName));
}

void
ncProfile::SaveConfig(void)
{
	/* save the profile data */
	localcmd(sprintf("cfg_save \"%s.cfg\"\n", m_profileName));
}

ncProfile
ncProfile::NewNamed(string profileName)
{
	ncProfile outputProfile = __NULL__;
	filestream keyFile = fopen(sprintf("players/%s/key", profileName) , FILE_WRITE);

	/* write the key file */
	if (keyFile >= 0) {
		fputs(keyFile, "// Vera Key File - do not share the contents of this file");
		fputs(keyFile, " ");
		fclose(keyFile);

		/* register the creds */
		localcmd(sprintf("cl_cred_register %S\n", profileName));

		/* now we load it like any other profile. */
		outputProfile = LoadFromDiskByName(profileName);
		
		/* force a config file to be created */
		outputProfile.SaveConfig();
		return (outputProfile);
	}

	return (__NULL__);	
}

ncProfile
ncProfile::LoadFromDiskByName(string profileName)
{
	ncProfile newProfile = spawn(ncProfile);
	newProfile.m_profileName = profileName;
	newProfile.m_profileCert = profileName;
	/* we could load the key file here, if we had any use for it */
	ncLog("Loaded profile %S.", profileName);
	return (newProfile);	
}

void
ncProfile::Delete(void)
{
	fremove(sprintf("players/%s/key", m_profileName));
	fremove(sprintf("players/%s", m_profileName));
	localcmd(sprintf("cl_cred_delete %S\n", m_profileName));
	ncLog("Deleted profile %S.", m_profileName);
	remove(this);
}

/* The manager of profiles... */
void
ncProfileManager::ncProfileManager(void)
{
}

void
ncProfileManager::Init(void)
{
	searchhandle searchProfiles;
	string activeProfileName = "Default";
	filestream activeProfileFile;

	/* search for available profiles, init them into ncProfile objects. */
	searchProfiles = search_begin("data/players/*/key", SEARCH_NAMESORT, true);

	for (int i = 0i; i < search_getsize(searchProfiles); i++) {
		int c = tokenizebyseparator(search_getfilename(searchProfiles, i), "/");
		string profileName = argv(2);

		/* make a record of the profile */
		ncProfile::LoadFromDiskByName(profileName);
	}

	/* read players/active.txt to find out what our last selected profile was. */
	activeProfileFile = fopen("players/active.txt", FILE_READ);

	/* it's not the end of the world if it doesn't exist. we'll assume we have to create a new profile later */
	if (activeProfileFile >= 0) {
		activeProfileName = fgets(activeProfileFile);
		fclose(activeProfileFile);
	}

	/* switch to named profile. */
	if (NamedProfileExistsOnDisk(activeProfileName) == false) {
		/* doesn't exist? create it - most likely "Default" here */
		if (CreateNamedProfile(activeProfileName) == false) {
			error("Will not proceed without profile container. Abort.");
			return;
		}
	}

	SetProfileByName(activeProfileName);
}

void
ncProfileManager::Shutdown(void)
{
	SaveActiveProfile();
}

ncProfile
ncProfileManager::GetActiveProfile(void)
{
	return (g_activeProfile);
}

void
ncProfileManager::SaveActiveProfile(void)
{
	ncProfile activeProfile = GetActiveProfile();

	if (!activeProfile) {
		ncError("Can't save. No active profile set.");
		return;
	}

	activeProfile.SaveConfig();
}

ncProfile
ncProfileManager::FindProfileByName(string profileName)
{
	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (__NULL__);
	}

	for (ncProfile f = __NULL__; (f = (ncProfile)find(f, ::classname, "ncProfile"));) {
		if (f.m_profileName == profileName) {
			return (f);
		}
	}

	return (__NULL__);
}

bool
ncProfileManager::SetProfileByName(string profileName)
{
	ncProfile foundProfile = __NULL__;
	filestream activeProfileFile;
	
	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (false);
	}

	foundProfile = FindProfileByName(profileName);

	if (!foundProfile) {
		return (false);
	}

	foundProfile.LoadConfig();
	g_activeProfile = foundProfile;
	ncLog("Set active profile to %S.", profileName);

	/* save our current preference to disk (imitating iw) */
	activeProfileFile = fopen("players/active.txt", FILE_WRITE);

	/* we won't fail here, as we may be reading from a read-only copy of a game */
	if (activeProfileFile >= 0) {
		fputs(activeProfileFile, profileName);
		fclose(activeProfileFile);
	}

	return (true);
}

bool
ncProfileManager::CreateNamedProfile(string profileName)
{
	ncProfile result = __NULL__;
	string targetName = strtrim(profileName);

	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(targetName)) {
		ncError("Empty name won't work");
		return (false);
	}

	if (FindProfileByName(targetName) != __NULL__) {
		ncError("Profile %S already exists.", targetName);
		return (false);
	}

	result = ncProfile::NewNamed(targetName);

	if (!result) {
		ncError("Unable to create profile %S.", targetName);
		return (false);
	}

	return (true);
}

bool
ncProfileManager::DeleteNamedProfile(string profileName)
{
	ncProfile foundProfile = __NULL__;
	ncProfile activeProfile = GetActiveProfile();

	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (false);
	}

	foundProfile = FindProfileByName(profileName);

	if (!foundProfile) {
		ncError("Won't delete %S, no such profile.", profileName);
		return (false);
	}

	if (activeProfile == foundProfile) {
		ncError("Won't delete %S, profile is currently active.", profileName);
		return (false);
	}

	foundProfile.Delete();
	return (true);
}

bool
ncProfileManager::NamedProfileExistsOnDisk(string targetName)
{
	/* if the key file doesn't exist, it's a safe bet. */
	if not (whichpack(sprintf("data/players/%s/key", targetName))) {
		return (false);
	}

	return (true);
}

void
ncProfileManager::ListProfiles(void)
{
	ncProfile activeProfile = GetActiveProfile();
	printf("List of profiles:\n");

	for (ncProfile f = __NULL__; (f = (ncProfile)find(f, ::classname, "ncProfile"));) {
		if (f == activeProfile) {
			printf("\t[%s]\n", f.m_profileName);
		} else {
			printf("\t^8%s\n", f.m_profileName);
		}
	}
}
