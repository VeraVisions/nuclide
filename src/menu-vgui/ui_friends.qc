/*
 * Copyright (c) 2024 Vera Visions LLC.
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

int g_iLoadGameInitialized;





class
VGUIFNMOTD:vguiWindow
{
	void VGUIFNMOTD(void);

	virtual void Spawned(void);
	virtual void ChatWindowResized(void);

private:
	vguiTextView messageBuffer;
};

void
VGUIFNMOTD::VGUIFNMOTD(void)
{
	messageBuffer = __NULL__;
}

void
VGUIFNMOTD::Spawned(void)
{
	super::Spawned();
	SetMinSize([200,112]);
	SetSize([320,240]);
	SetPos([g_vidsize[0] - 336, 16]);

	if (!messageBuffer) {
		messageBuffer = spawn(vguiTextView);
		messageBuffer.SetPos([8,36]);
		messageBuffer.SetSize([544,324]);
		Add(messageBuffer);
	}

	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(ChatWindowResized);
	ChatWindowResized();

	SetTitle("Message Of The Day");
	SetIcon("gfx/icon16/newspaper");
	messageBuffer.AddLine(FragNet_GetMessageOfTheDay());
}

void
VGUIFNMOTD::ChatWindowResized(void)
{
	messageBuffer.SetSize(GetSize() - [16, 76]);
}














class
VGUIChatWindow:vguiWindow
{
	void VGUIChatWindow(void);

	virtual void Spawned(void);
	nonvirtual void SendMessage(void);
	nonvirtual void MessageReceived(string);
	nonvirtual void SetUser(string);
	virtual void ChatWindowResized(void);

private:
	string userNick;
	vguiTextBox textBox;
	vguiButton sendButton;
	vguiTextView messageBuffer;
};

void
VGUIChatWindow::VGUIChatWindow(void)
{
	sendButton = __NULL__;
	textBox = __NULL__;
	userNick = __NULL__;
	messageBuffer = __NULL__;
}

void
VGUIChatWindow::SetUser(string userName)
{
	userNick = userName;
	string conName = strcat("Chat_", userName);

	string date = strftime(true, "%A, %B %-d, %Y");
	messageBuffer.AddLine(sprintf("^7Never tell your password to anyone.\n^xAAA%s\n", date));
}

void
VGUIChatWindow::MessageReceived(string messageString)
{
	messageBuffer.AddLine(strcat("^xAAA", userNick, " says:\n^xDDD", messageString, "\n"));
}

void
VGUIChatWindow::SendMessage(void)
{
	string textMessage = textBox.GetText();
	if (!STRING_SET(textMessage)) {
		return;
	}

	if (FragNet_Status() != STATE_ONLINE) {
		return;
	}

	FragNet_SendMessage(userNick, textMessage);
	messageBuffer.AddLine(strcat("^xAAA", cvar_string("name"), " says:\n^xBB9", textMessage, "\n"));
	textBox.SetText("");
}

void
VGUIChatWindow::ChatWindowResized(void)
{
	messageBuffer.SetSize(GetSize() - [16, 76]);
	textBox.SetSize([GetWidth() - 88,24]);
	textBox.SetPos([8, GetHeight() - 32]);
	sendButton.SetPos([GetWidth() - 72, GetHeight() - 32]);
}

void
VGUIChatWindow::Spawned(void)
{
	static void VGUIChatWindow_Send(void) {
		vguiWidget winSelf = (vguiWidget)self;
		VGUIChatWindow ourConsole = (VGUIChatWindow)winSelf.m_parent;
		ourConsole.SendMessage();
	}

	super::Spawned();
	SetSize([320,240]);

	if (!textBox) {
		textBox = spawn(vguiTextBox);
		textBox.CallOnEnter(VGUIChatWindow_Send);
		textBox.SetSize([240,24]);
		Add(textBox);

		sendButton = spawn(vguiButton);
		sendButton.SetSize([64,24]);
		sendButton.SetTitle("Send");
		sendButton.SetFunc(VGUIChatWindow_Send);
		Add(sendButton);

		messageBuffer = spawn(vguiTextView);
		messageBuffer.SetPos([8,36]);
		messageBuffer.SetSize([544,324]);
		Add(messageBuffer);
	}

	SetStyleMask( vguiWindowStyleDefault | vguiWindowResizeable );
	CallOnResize(ChatWindowResized);
	ChatWindowResized();
}



class
VGUIFriendsList:vguiWindow
{
	void VGUIFriendsList(void);

	virtual void Draw(void);
	virtual void Spawned(void);
	nonvirtual void RefreshStatus(fnState_t);
	nonvirtual void MessageFriend(vguiList, int);
	static VGUIChatWindow NewWindow(string);

private:

	vguiList friendsTable;
	vguiButton addFriend;
	fnState_t previousStatus;
	vguiColor m_friendsFrameColor;
};

void
VGUIFriendsList::VGUIFriendsList(void)
{
	friendsTable = __NULL__;
	addFriend = __NULL__;
	previousStatus = STATE_OFFLINE;
	m_friendsFrameColor = __NULL__;
}


void
VGUIFriendsList::Draw(void)
{
	fnState_t checkStatus = FragNet_Status();

	if (checkStatus != previousStatus) {
		RefreshStatus(checkStatus);
		previousStatus = checkStatus;
	}

	if (checkStatus == STATE_ONLINE) {
		ShowContents();
	} else {
		HideContents();
	}

	super::Draw();

	if (checkStatus == STATE_OFFLINE) {
		vguiTheme ourTheme = GetTheme();
		ourTheme.DrawBorder(m_vecOrigin + [8,32], friendsTable.GetSize(), VGUI_BORDER_INSET, m_friendsFrameColor);

		Font_DrawField(m_vecOrigin + [8,32] + [12,12], friendsTable.GetSize() - [24,24], "You failed to connect to the Friends servers.", g_fntDefault, AF_DEFAULT);
	}
}

void
VGUIFriendsList::RefreshStatus(fnState_t newStatus)
{
	switch (newStatus) {
	case STATE_SIGNON:
		SetTitle("Friends - Sign on...");
		SetIcon( "gfx/icon16/status_busy" );
		break;
	case STATE_AUTHORIZING:
		SetTitle("Friends - Authorizing...");
		SetIcon( "gfx/icon16/status_away" );
		break;
	case STATE_ONLINE:
		SetTitle("Friends - Online");
		SetIcon( "gfx/icon16/status_online" );
		break;
	case STATE_OFFLINE:
	default:
		SetTitle("Friends - Offline");
		SetIcon( "gfx/icon16/status_offline" );
	}
}

VGUIChatWindow
VGUIFriendsList::NewWindow(string playerNick)
{
	VGUIChatWindow newChat = spawn(VGUIChatWindow);
	newChat.classname = "Chat";
	newChat.SetTitle(sprintf("%s - Instant Message", playerNick));
	newChat.SetIcon( "gfx/icon16/user_comment" );
	newChat.SetUser(playerNick);
	g_uiDesktop.Add(newChat);
	newChat.Focus();
	return newChat;
}

void
VGUIFriendsList::MessageFriend(vguiList friendsList, int friendID)
{
	string playerNick = friendsList.GetItem(friendID);

	if (!STRING_SET(playerNick)) {
		return;
	}

	for (VGUIChatWindow chat = __NULL__; (chat = (VGUIChatWindow)find(chat, ::classname, "Chat"));) {
		if (playerNick == chat.userNick) {
			chat.Show();
			chat.Focus();
			return;
		}
	}

	NewWindow(playerNick);
}

void
VGUIFriendsList::Spawned(void)
{
	super::Spawned();


	SetSize([230,390]);
	RefreshStatus(FragNet_Status());

	if (!friendsTable) {
		friendsTable = spawn(vguiList);
		friendsTable.SetSize( [230-16, 390 - 70] );
		friendsTable.SetPos( [8, 32] );
		friendsTable.SetItemCount( 32 );
		friendsTable.CallOnDoubleClick( MessageFriend );

		for (int i = 0i; i < tokenize_console(cvar_string("ui_friends")); i++) {
			friendsTable.AddItem(argv(i));
		}

		Add(friendsTable);


		addFriend = spawn(vguiButton);
		addFriend.SetTitle("Options");
		addFriend.SetPos([8, 390 - 32]);
		Add(addFriend);
	}

}

void UI_Friends_Show ( void )
{
	static VGUIFriendsList winFriends;

	if ( !g_iLoadGameInitialized ) {
		g_iLoadGameInitialized = TRUE;
		winFriends = spawn( VGUIFriendsList );

		g_uiDesktop.Add( winFriends );
	}

	winFriends.Show();
	winFriends.SetPos( ( g_vidsize / 2 ) - ( winFriends.GetSize() / 2 ) );
}

void
ChatCallback_MessageReceived(string fromUser, string messageString)
{
	for (VGUIChatWindow chat = __NULL__; (chat = (VGUIChatWindow)find(chat, ::classname, "Chat"));) {
		if (fromUser == chat.userNick) {
			chat.MessageReceived(messageString);
			return;
		}
	}

	VGUIChatWindow new = VGUIFriendsList::NewWindow(fromUser);
	new.MessageReceived(messageString);
}

void
ChatCallback_GroupMessageReceived(string groupName, string fromUser, string messageString)
{

}

void
OnlineCallback_ConnectionEstablished(void)
{
	VGUIFNMOTD motd = spawn(VGUIFNMOTD);
	g_uiDesktop.Add(motd);
}
