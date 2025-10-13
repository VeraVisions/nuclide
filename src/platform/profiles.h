/** Platform: Player Profile

Player profiles don't just tell us details about the identity but also
preferences. If a player doesn't consent to an external online service
we'll query the player profile and ensure in all the right places that it works.
*/
class
ncProfile
{
public:
	void ncProfile(void);

	nonvirtual ncProfile NewNamed(string profileName);
	nonvirtual ncProfile LoadFromDiskByName(string profileName);
	nonvirtual void LoadConfig(void);
	nonvirtual void SaveConfig(void);
	nonvirtual void Delete(void);

private:
	string m_profileName;	/** The name of the local profile. */
	string m_profileCert;	/** The name of the certificate/identity */
	//bool m_offlineOnly;	/** When true, this account will not connect to the online service. LAN games only or direct connect. */
};

/** Platform: Player Profile Manager

Often more than one player wants to play on a local machine, or sometimes you want
a special account with an offline only setting.

A profile stores a unique location for user configs, progression and the certificates
are generally tied to it as well. */
class
ncProfileManager
{
	void ncProfileManager(void);

	/** Called by the platform init system upon start. */
	nonvirtual void Init(void);

	/** Called by platform shutdown for cleanup. */
	nonvirtual void Shutdown(void);

	/** Returns an object container with the desired profile information. */
	nonvirtual ncProfile GetActiveProfile(void);

	/** Requests the current settings to be saved to the active profile. */
	nonvirtual void SaveActiveProfile(void);
	
	nonvirtual ncProfile FindProfileByName(string profileName);

	/** Sets the current, active profile to a desired one. Returns `true` on success. */
	nonvirtual bool SetProfileByName(string profileName);

	/** Creates a new profile under a desired name. Returns `true` on success. */
	nonvirtual bool CreateNamedProfile(string targetName);

	/** Deletes a named profile. Returns `true` on success. */
	nonvirtual bool DeleteNamedProfile(string profileName);

	/** Returns `true` or `false` depending on whether a named profile exists. */
	nonvirtual bool NamedProfileExistsOnDisk(string targetName);

	nonvirtual void ListProfiles(void);
};
