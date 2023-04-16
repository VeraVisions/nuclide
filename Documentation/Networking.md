# Networking

## Preface

Networking in FTEQW is an extension of the design decisions made for QuakeWorld. All you have to know is that we use NACK feedback to network the changes from client to server. There are a lot of other great resources that document the QuakeWorld protocol, so we will focus on the additions that matter here.

## Leveraged by FTE QuakeWorld

In Nuclide, we make heavy use of custom entity networking. In FTE, you can set the entity field `.SendEntity` and `.SendFlags` to control network updates for the given entity. You have to implement your own `.SendEntity` function that communicates:

1. The type of entity (so the client can interpret it once it arrives)
2. The type of information that has changed (you'll see references to `flChanged` in code a lot)
3. The data that itself has to be networked manually, with fixed and agreed upon size.

## Entity updates within Nuclide

To see the type of entity updates we handle internally in Nuclide, look no further than `src/shared/entities.h`. For one-time event updates, you can check `src/shared/events.h`.

Generally, those entity updates happen and are controlled by these three common methods that are implemented by any entity class that chooses to override networking:

- EvaluateEntity
- SendEntity
- ReceiveEntity

Let's go over them, one by one.

### EvaluateEntity

Called once every frame. This is where we check if anything has changed. We commonly use the macros `EVALUATE_FIELD( field, changedFlag )` and `EVALUATE_VECTOR( field, xyz, changedFLAG )` to test if any particular field has changed since last frame.

For these macros to work, your entity needs to have declared attributes with the `PREDICTED_INT( x ) `, `PREDICTED_FLOAT( x )`, `PREDICTED_VECTOR( x )`, `PREDICTED_BOOL( x )`, `PREDICTED_ENTITY( x )`, or `PREDICTED_STRING( x )` macros.

Once the frame ends, we will network the differences in the next method.

### SendEntity

As already mentioned in the FTE section, this is where the actual networking gets done.

This is where we have helper macros for dealing with sending and flagging the updates reliably.

- SENDENTITY_BYTE( field, changedFlag )
- SENDENTITY_SHORT( field, changedFlag )
- SENDENTITY_INT( field, changedFlag )
- SENDENTITY_FLOAT( field, changedFlag )
- SENDENTITY_STRING( field, changedFlag )
- SENDENTITY_COORD( field, changedFlag )
- SENDENTITY_ANGLE( field, changedFlag )
- SENDENTITY_ENTITY( field, changedFlag )

Most of them are self explanatory, but in the case of `SENDENTITY_ANGLE` we actually network a short, since we don't need full floating point precision for most types of angles. Keep that in mind if you're running into precision issues.

### ReceiveEntity

Method is called on the client-side for each respective entity class we want to handle. 
First however, we need to talk about the handler.

We allow any game to implement their own handler for entity updates in the function `ClientGame_EntityUpdate(float type, bool isNew)` which you're encouraged to implement. This is where we check for a handler first, then Nuclide will attempt to handle it instead.

We usually just read the flags field (which we assume is a float for most entities) and then call the `ReceiveEntity(float isNew, float flChanged)` method, in which we'll use the following macros to help read networked information:

- READENTITY_BYTE( field, changedFlag )
- READENTITY_SHORT( field, changedFlag )
- READENTITY_INT( field, changedFlag )
- READENTITY_FLOAT( field, changedFlag )
- READENTITY_STRING( field, changedFlag )
- READENTITY_COORD( field, changedFlag )
- READENTITY_ANGLE( field, changedFlag )
- READENTITY_ENTITY( field, changedFlag )

As you can tell, it's the same setup as in `SendEntity` - which is by design. This will make keeping fields in check much easier. A simple find-and-replace of the word **SEND** with **READ** will do the job most of the time.

We'd like to streamline a lot of this further, so this may be subject to change.

## Event updates

This is pretty simple. The server will use the FTE QuakeWorld supported `SVC_CGAMEPACKET` packet type to network events.

An example of such an event is as follows, it can be called at any time:

```
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_TEST);
	WriteByte(MSG_MULTICAST, 123); 
	multicast([0,0,0], MULTICAST_ALL_R);
```

This event will then be sent to **ALL** clients, **reliably** as indicated by the **MULTICAST_ALL_R**. On the client-side, we will handle any event in `Event_Parse(float eventType)` that you are not handling yourself within `ClientGame_EventParse(float eventType)`.

From there you can use the builtins `readbyte()`, `readshort()` etc. which are also used under-the-hood in the macros for entity updates above. Yes, ideally this should be more consistent and nicer to use in the future - but we left it pretty stock in this case.

## Client to Server communication

There's a few different means of networking things to the server as a client.

### infokeys

Clients can set their own custom infokey data at any time, using the `setinfo` console command. For example: `setinfo foo bar` will set the infokey `foo` to the value of `bar`. The server can then read any given infokey on a given client like so: `string value = infokey(someplayer, "foo");`

The server can also assign its own infokeys to a player. These can be overriden by the client at any given time as well, **unless the server prefixes them** with an asterisk. Here is an example: `forceinfokey(somePlayer, "*team", "1");`

infokeys are visible to all other clients. So be careful about the type of data you store in them. Storing passwords or other sensitive information is not recommended.

### sendevent

`sendevent()` is the builtin you call from the client game to communicate, reliably, to
the server game running on the other end.

The first parameter of `sendevent()` specifies the function to call in server game:

```
	sendevent( "Myfunction", "" );
```

However, it will not look for `void() Myfunction` on the server game, there is a prefix
reserved for all sendevent calls. That one is `CSEv`.
So in reality, the above command will execute this on the server game:

	void CSEv_Myfunction ( void ) { }

Now, what about that second parameter?

	.. , "" );

Well, `sendevent()` has the ability to send data. 6 arguments can be passed, max.
That second parameter string specifies the type of data you want to send.

For example, you want to ask the server to set the health of a player to a
specific value...

Client game:
```
	sendevent( "SetPlayerHealth", "f", 124 );
```

Server game:
```
	void CSEv_SetPlayerHealth_f ( float h ) {
		self.health = h; // naughty! clients can spoof these packets...
	}
```

As you can see, the `f` indicates the type float.
`s` would indicate a string.
`v` would indicate a vector.
`i` would indicate an integer.
`e` would indicate an entity (more about that in the last chapter).

The second parameter specifying the arguments will append to the name of the
function you're trying to call.

Client game:

```
	sendevent( "SetColorAndName", "fffs", 255, 0, 128, "Tommy" );
```

Server game:
```
	void CSEv_SetColorAndName_fffs ( float r, float g, float b, string name ) {
		self.colormod = [r, g, b];
		self.netname = name;
	}
```

..is what a longer sendevent with multiple arguments would look like.
6 arguments are the maximum. This is because QuakeC supports 8 arguments max per
function call. If you, however, only want to send floats and require more than
6 arguments, you can store them inside vectors:

Client game:

```
	vector v1 = [ myfloat1, myfloat2, myfloat3 ];
	vector v2 = [ myfloat4, myfloat5, myfloat6 ];
	vector v3 = [ myfloat7, myfloat8, myfloat9 ];
	vector v4 = [ myfloat10, myfloat11, myfloat12 ];
	vector v5 = [ myfloat13, myfloat14, myfloat15 ];
	vector v6 = [ myfloat16, myfloat17, myfloat18 ];
	sendevent( "Bah", "vvvvvv", v1, v2, v3, v4, v5, v6 );
```

Server game:
```
	void CSEv_Bah_vvvvvv ( vector v1, vector v2, vector v3, vector v4, vector v5,
	vector v6 ) {
		myfloat1 = v1[0];
		myfloat2 = v1[1];
		myfloat3 = v1[2];
		myfloat4 = v2[0];
		...
	}
```
	
#### Note about sendevent() and entities

If you pass an entity via sendevent, it'll in reality send only the entnum.
The entnum is the essentially the entity-id.
If the entity does not exist via the server game (like, it has been removed since or
is a client-side only entity) then the entity parameter on the server game function
call will return `world` aka 0/__NULL__.

For protective reasons, entities that are removed have their entnums reserved
for a specific amount of time before being able to be used again.
Player entities, for example, will allow their entnums to be recycled after 2
seconds. Any other entity its entnum will be reusable after only half a second.
This should avoid most entnum conflicts.

Basically, during this time, the parameter will not return `world`.

**Note**: This is entirely unreliable behaviour.
Check if the .classname is **valid** on the server before doing anything fancy on it.

### clientcommand

Whenever the client issues a `cmd` based command, say: `cmd say foobar` in console or via the client game in general, the server will forward it to the active NSGameRules based game rule class within the `ClientCommand(NSClient client, string command)` method. This is useful for things you do every once in a while.

## ServerInfo

To be written.