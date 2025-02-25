
typedef enum
{
	STATE_OFFLINE,
	STATE_SIGNON,
	STATE_AUTHORIZING,
	STATE_ONLINE
} fnState_t;

void FragNet_SendMessage(string toUser, string messageString);
void FragNet_SignOn(void);
void FragNet_SignOff(void);
fnState_t FragNet_Status(void);
void FragNet_AddFriend(string);
void FragNet_RemoveFriend(string);
string FragNet_GetMessageOfTheDay(void);

void OnlineCallback_ConnectionEstablished(void);
void OnlineCallback_ConnectionClosed(void);
void ChatCallback_MessageReceived(string fromUser, string messageString);
void ChatCallback_GroupMessageReceived(string fromGroup, string fromUser, string messageString);
