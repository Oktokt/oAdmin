#include <a_samp>
#include <YSI\y_ini>
#include <zcmd>
#include <3DTryg>
#include <irc>
#include <dini>
#include <streamer>
#include <sscanf>
/////////oCar Vehicle ID/////////
#define  ocar      411
//////////Colors/////////////////
#define  red 		0xFF0000AA
#define  Green     	0xFF00AA
#define  Gray       0xC0C0C0AA
/////////Colors2/////////////////
//////////Don't Tuach This till u understand what is it.
#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define USER_PATH "/oAdmin/Users/%s.ini"
//#define NotAdminMsg "Error:You Can't Use This Command."
//Dialogs
#define Config              4
#define DIALOGID            5
#define Click               6
#define D_ADMINS            7
#define dialog              8
#define evdialog            9
///////////////////////////////IRC Defines/////////////////////////////////
#define IRC true //true to turn IRC On | false to turn IRC Off
///////Bots
//Bot 1
#define BOT_1_USERNAME  "O-Bot1"
#define BOT_1_NICKNAME  "O-Bot1"
#define BOT_1_ALTERNATE "oAdmin1"
#define BOT_1_REALNAME  "oAdmin1"
//Bot 2
#define BOT_2_USERNAME  "O-Bot2"
#define BOT_2_NICKNAME  "O-Bot2"
#define BOT_2_ALTERNATE "oAdmin2"
#define BOT_2_REALNAME  "oAdmin2"
//Bot 3
#define BOT_3_USERNAME  "O-Bot3"
#define BOT_3_NICKNAME  "O-Bot3"
#define BOT_3_ALTERNATE "oAdmin3"
#define BOT_3_REALNAME  "oAdmin3"
////////////////Server&Channel////////
#define IRC_SERVER 		 "irc.tl"
#define IRC_PORT 		 (6667)
#define IRC_CHANNEL 	 "#oAdmin"
#define IRC_AdminChannel "#oAdmin1"

#define MAX_BOTS (3)
#define MAX_WARNINGS 3
#define PLUGIN_VERSION "1.4.8"
new botIDs[MAX_BOTS], groupID,GAdmins;
native WP_Hash(buffer[], len, const str[]);



//===================================================
enum {

    DIALOG_LOGIN,
    DIALOG_REGISTER
};
enum PlayerInfo {

    Password[129],
    AdminLevel,
    ReadPms,
    ReadCmds,
    VIPLevel,
    Money,
    PremMute,
	Banned,
	BannedTimes,
    Score,
	Reason[45],
	Kills,
    Deaths,
    bool:LoggedIn
};
enum ServerData {
	MaxPing,
	ReadPMs,
	ReadCmds,
	MaxAdminLevel,
	AdminSkin,
	Locked
};
new pInfo[MAX_PLAYERS][PlayerInfo];
new ServerInfo[ServerData];

enum EventData {
    Current,
    Locked
};
new EventInfo[EventData];
new InEvent[MAX_PLAYERS];
new EventBlock[MAX_PLAYERS];
new EvDerby[MAX_PLAYERS];
new Float:eventx, Float:eventy, Float:eventz;
new VehID[100];

new Hide[MAX_PLAYERS];
new AFK[MAX_PLAYERS];
new Mute[MAX_PLAYERS];
new PMOFF[MAX_PLAYERS];
new Jail[MAX_PLAYERS];
new ClickedPlayer[MAX_PLAYERS];
//new aDuty[MAX_PLAYERS];



new Str11[228], Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];


new Float:evderbyAngle[][] = {
	{200.2727},
	{85.5682}, 
	{105.3083}, 
	{175.1823}, 
	{312.7136}, 
	{216.2060},
	{-313.4188},
	{198.6409},
	{145.8048},
	{43.9704},
	{88.7775},
	{89.8888},
	{170.2999},
	{358.3043},
	{274.3367},
	{3.5239},
	{267.3979},
	{107.5000},
	{265.3724},
	{265.3724},
	{358.4199}
};




public OnFilterScriptInit()
{
    #if IRC == true
	// Connect First Bot
	botIDs[0] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_1_NICKNAME, BOT_1_REALNAME, BOT_1_USERNAME);
	IRC_SetIntData(botIDs[0], E_IRC_CONNECT_DELAY, 2);
	//Connect Second Bot
	botIDs[1] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_2_NICKNAME, BOT_2_REALNAME, BOT_2_USERNAME);
	IRC_SetIntData(botIDs[1], E_IRC_CONNECT_DELAY, 5);
	//////
	botIDs[2] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_3_NICKNAME, BOT_3_REALNAME, BOT_3_USERNAME);
	IRC_SetIntData(botIDs[2], E_IRC_CONNECT_DELAY, 7);
	groupID = IRC_CreateGroup();
	GAdmins = IRC_CreateGroup();
	CreateObject(4585, 1436.66235, -1089.27026, 366.73456,   0.00000, 0.00000, 3.62322);
	print("oAdmin Filter Script Loaded");
	print("Coded By Oktokt");
	#endif
	return 1;
}

public OnFilterScriptExit()
{
     // Disconnect the 1st bot
	IRC_Quit(botIDs[0], "Filterscript exiting");
	// Disconnect the 2nd bot
	IRC_Quit(botIDs[1], "Filterscript exiting");
	// Disconnect the 3rd bot
	IRC_Quit(botIDs[2], "Filterscript exiting");
	// Destroy the group
	IRC_DestroyGroup(groupID);
	IRC_DestroyGroup(GAdmins);
	return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}




public OnPlayerConnect(playerid)
{
    if(ServerInfo[Locked]==1)
	{
	    Kick(playerid);
		new str11[128];
		format(str11,sizeof(str11),"%s(%d) Has Kicked From The Server |Reason: The Server Is Closed.",GetName(playerid),playerid);
	    SCMTA(Gray,str11);
		
		return 1;
	}
	new ip[17],ipmsg[222];
	GetPlayerIp(playerid,ip,sizeof(ip));
	format(ipmsg, sizeof(ipmsg), "%s has join the server from this IP : %s",GetName(playerid),ip);
	Log("IPS",ipmsg);
    new joinmsg[128], name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	format(joinmsg, sizeof(joinmsg), "02[%d] 03-Server- %s has Connected to the server.", playerid, name);
	IRC_GroupSay(groupID, IRC_CHANNEL, joinmsg);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, joinmsg);
	if(ServerInfo[Locked]==1)
	{
		new str11[128];
		format(str11,sizeof(str11),"%s(%d) Has Kicked From The Server |Reason: The Server Is Closed.",GetName(playerid),playerid);
	    SCMTA(Gray,str11);
		Kick(playerid);
		return 1;
	}
	pInfo[playerid][AdminLevel] = 0;
    pInfo[playerid][VIPLevel] = 0;
    pInfo[playerid][Money] = 0;
    pInfo[playerid][Score] = 0;
	pInfo[playerid][Banned] = 0;
	pInfo[playerid][PremMute] = 0;
	pInfo[playerid][ReadPms] = 0;
	pInfo[playerid][ReadCmds] = 0;
    pInfo[playerid][Kills] = 0;
    pInfo[playerid][Deaths] = 0;
    pInfo[playerid][LoggedIn] = false;
    TogglePlayerSpectating(playerid, true);
    
    if(fexist(UserPath(playerid)))
	{
        INI_ParseFile(UserPath(playerid), "LoadPlayerData_PlayerData", .bExtra = true, .extra = playerid);
		if(pInfo[playerid][Banned] == 1)
		{
			new msg[128];
			format(msg,sizeof msg,"You Are Banned From This Server |Reason: %s",pInfo[playerid][Reason]);
            SCM(playerid,Green,msg);
            SetTimerEx("KickHim",1000,false,"u",playerid);
		}
		else
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Welcome back. This account is registered.\n\nEnter your password below to log in:", "Login", "Quit");
    }
    else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Register", "Welcome. This account is not registered.\n\nEnter your desired password below to register:", "Register", "Quit");
    }
	return 1;
}

forward LoadPlayerData_PlayerData(playerid, name[], value[]);
public LoadPlayerData_PlayerData(playerid, name[], value[]) {

    INI_String("Password", pInfo[playerid][Password], 129);
    INI_Int("AdminLevel", pInfo[playerid][AdminLevel]);
    INI_Int("ReadPms", pInfo[playerid][ReadPms]);
    INI_Int("ReadCmds", pInfo[playerid][ReadCmds]);
    INI_Int("VIPLevel", pInfo[playerid][VIPLevel]);
    INI_Int("Money", pInfo[playerid][Money]);
    INI_Int("Scores", pInfo[playerid][Score]);
    INI_Int("Kills", pInfo[playerid][Kills]);
    INI_Int("Deaths", pInfo[playerid][Deaths]);
    INI_Int("Banned", pInfo[playerid][Banned]);
    INI_Int("PremMute", pInfo[playerid][PremMute]);
    INI_Int("BannedTimes", pInfo[playerid][BannedTimes]);
    INI_String("Reason", pInfo[playerid][Reason], 45);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SaveStats(playerid);
	new leaveMsg[128], name[MAX_PLAYER_NAME], reasonMsg[8];
	switch(reason)
	{
		case 0: reasonMsg = "Timeout";
		case 1: reasonMsg = "Leaving";
		case 2: reasonMsg = "Kicked";
	}
	GetPlayerName(playerid, name, sizeof(name));
	format(leaveMsg, sizeof(leaveMsg), "02[%d] 03-Server- %s has Left the server. (%s)", playerid, name, reasonMsg);
	IRC_GroupSay(groupID, IRC_CHANNEL, leaveMsg);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, leaveMsg);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	EvDerby     [playerid]  =0;
	InEvent		[playerid]	=0;
	AFK			[playerid] 	=0;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(InEvent[playerid]== 1) return InEvent[playerid] = 0;
    new msg[128], killerName[MAX_PLAYER_NAME], reasonMsg[32], playerName[MAX_PLAYER_NAME];
	GetPlayerName(killerid, killerName, sizeof(killerName));
	GetPlayerName(playerid, playerName, sizeof(playerName));
	if (killerid != INVALID_PLAYER_ID)
	{
		switch (reason)
		{
			case 0: reasonMsg = "Unarmed";
			case 1: reasonMsg = "Brass Knuckles";
			case 2: reasonMsg = "Golf Club";
			case 3: reasonMsg = "Night Stick";
			case 4: reasonMsg = "Knife";
			case 5: reasonMsg = "Baseball Bat";
			case 6: reasonMsg = "Shovel";
			case 7: reasonMsg = "Pool Cue";
			case 8: reasonMsg = "Katana";
			case 9: reasonMsg = "Chainsaw";
			case 10: reasonMsg = "Dildo";
			case 11: reasonMsg = "Dildo";
			case 12: reasonMsg = "Vibrator";
			case 13: reasonMsg = "Vibrator";
			case 14: reasonMsg = "Flowers";
			case 15: reasonMsg = "Cane";
			case 22: reasonMsg = "Pistol";
			case 23: reasonMsg = "Silenced Pistol";
			case 24: reasonMsg = "Desert Eagle";
			case 25: reasonMsg = "Shotgun";
			case 26: reasonMsg = "Sawn-off Shotgun";
			case 27: reasonMsg = "Combat Shotgun";
			case 28: reasonMsg = "MAC-10";
			case 29: reasonMsg = "MP5";
			case 30: reasonMsg = "AK-47";
			case 31: reasonMsg = "M4";
			case 32: reasonMsg = "TEC-9";
			case 33: reasonMsg = "Country Rifle";
			case 34: reasonMsg = "Sniper Rifle";
			case 37: reasonMsg = "Fire";
			case 38: reasonMsg = "Minigun";
			case 41: reasonMsg = "Spray Can";
			case 42: reasonMsg = "Fire Extinguisher";
			case 49: reasonMsg = "Vehicle Collision";
			case 50: reasonMsg = "Vehicle Collision";
			case 51: reasonMsg = "Explosion";
			default: reasonMsg = "Unknown";
		}
		format(msg, sizeof(msg), "04-Kill- %s killed %s. (%s)", killerName, playerName, reasonMsg);
	}
	else
	{
		switch (reason)
		{
			case 53: format(msg, sizeof(msg), "04*** %s died. (Drowned)", playerName);
			case 54: format(msg, sizeof(msg), "04*** %s died. (Collision)", playerName);
			default: format(msg, sizeof(msg), "04*** %s died.", playerName);
		}
	}
	IRC_GroupSay(groupID, IRC_CHANNEL, msg);



 	AFK[playerid] = 0;
 	if(killerid != INVALID_PLAYER_ID) {

        // We check whether the killer is a valid player
        pInfo[playerid][Deaths] ++; // ++ means +1
        pInfo[killerid][Kills] ++;

        // Save the deaths
        new INI:file = INI_Open(UserPath(playerid));
        INI_SetTag(file, "PlayerData");
        INI_WriteInt(file, "Deaths", pInfo[playerid][Deaths]);
        INI_Close(file);

        // Save the kills
        new INI:file2 = INI_Open(UserPath(killerid));
        INI_SetTag(file2, "PlayerData");
        INI_WriteInt(file2, "Kills", pInfo[killerid][Kills]);
        INI_Close(file2);
    }

	return 1;
}
public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}
public OnPlayerCommandPerformed(playerid, cmdtext[])
{
    for(new i = 0; i < MAX_PLAYERS; i ++)
	if(pInfo[i][ReadCmds]==1 && pInfo[i][AdminLevel] >= 2)
	    {
	        new str[123];
	        format(str,sizeof(str), "Command From %s(%d): %s", GetName(playerid),playerid,cmdtext );
	        SCM(i,Gray,str);
 		}
	return 1;
}
public OnPlayerText(playerid, text[])
{
    if(text[0] == '!' )
    {
        if(pInfo[playerid][AdminLevel] >= 1)
        {
			new name[50],string[128];
			GetPlayerName(playerid,name,sizeof(name));
			format(string,sizeof(string),"Admin Chat: %s: %s",name,text[1]);
			Log("AdminChat",string);
			AdminChat(Green,string);
			format(string,sizeof(string),"11Admin Chat: 7%s: 0%s",name,text[1]);
			IRC_GroupSay(GAdmins, IRC_AdminChannel, string);
			return 0;
		}
		return 1;
	}
	if(text[0] == '@' )
	{
	    if(InEvent[playerid]== 1)
        {
			new name[50],string[128];
			GetPlayerName(playerid,name,sizeof(name));
			format(string,sizeof(string),"Event Chat: %s: %s",name,text[1]);
			Log("Events",string);
			AdminChat(Green,string);
			format(string,sizeof(string),"11Event Chat: 7%s: 0%s",name,text[1]);
			IRC_GroupSay(GAdmins, IRC_AdminChannel, string);
			return 0;
		}
		return 1;
	}
    if (Mute[playerid] == 1  || pInfo[playerid][PremMute] == 1)
	{
		SCM(playerid, red ,"[MUTE]You Are Muted.");
		return 0;
	}
	new str[200];
	format(str,sizeof(str),"%s: %s",GetName(playerid),text);
	Log("Chat",str);
    new name[MAX_PLAYER_NAME], ircMsg[256];
	GetPlayerName(playerid, name, sizeof(name));
	format(ircMsg, sizeof(ircMsg), "02[%d] 12%s: %s", playerid, name, text);
	IRC_GroupSay(groupID, IRC_CHANNEL, ircMsg);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    AFK[playerid] = 0;
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(EvDerby[playerid] == 1)
	{
		DestroyVehicle(vehicleid);
		SCM(playerid,-1,"{FF8CA3}[EVENT] {D9BFFF}You Have Lost This Event. Good Luck Next Event.");
		new str[222];
		format(str,sizeof(str),"{FF8CA3}[EVENT] {D9BFFF}%s is out of the event (Left His Vehicle).",GetName(playerid));
		EvChat(-1,str);
		SpawnPlayer(playerid);
	}
	return 1;
}
public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}
public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	SCM(playerid,0xFF0000,"Your Vehicle Fixed.");
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}





public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
switch(dialogid) {

        case DIALOG_REGISTER: {

            if(!response) Kick(playerid);
            else {

                if(!strlen(inputtext)) {

                    SendClientMessage(playerid, red, "You have to enter your desired password.");
                    return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Register", "Welcome. This account is not registered.\n\nEnter your desired password below to register:", "Register", "Quit");
                }
                WP_Hash(pInfo[playerid][Password], 129, inputtext);
                new INI:file = INI_Open(UserPath(playerid));
                INI_SetTag(file, "PlayerData");
                INI_WriteString(file, "Password", pInfo[playerid][Password]);
                INI_WriteInt(file, "AdminLevel", 0);
                INI_WriteInt(file, "ReadPms", 0);
                INI_WriteInt(file, "ReadCmds", 0);
                INI_WriteInt(file, "VIPLevel", 0);
                INI_WriteInt(file, "Money", 0);
                INI_WriteInt(file, "Score", 0);
                INI_WriteInt(file, "Kills", 0);
                INI_WriteInt(file, "Deaths", 0);
                INI_WriteInt(file, "PremMute", 0);
                INI_WriteInt(file, "Banned", 0);
                INI_WriteInt(file, "BannedTimes", 0);
                INI_WriteString(file, "Reason", pInfo[playerid][Reason]); 
				INI_Close(file);
                SendClientMessage(playerid, Green, "You have successfully registered.");
                pInfo[playerid][LoggedIn] = true;
                TogglePlayerSpectating(playerid, false);
                return 1;
            }
        }
        case DIALOG_LOGIN: {

            if(!response) Kick(playerid);
            else {

                new
                    hashpass[129];

                WP_Hash(hashpass, sizeof(hashpass), inputtext);

                if(!strcmp(hashpass, pInfo[playerid][Password])) {
                    SetPlayerScore(playerid, pInfo[playerid][Score]);
                    GivePlayerMoney(playerid, pInfo[playerid][Money]);
                    SendClientMessage(playerid, Green, "Welcome back! You have successfully logged in!");
                    pInfo[playerid][LoggedIn] = true;
                    TogglePlayerSpectating(playerid, false);
                }
                else {
                
                    SendClientMessage(playerid, red, "You have entered an incorrect password.");
                    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Welcome back. This account is registered.\n\nEnter your password below to log in:", "Login", "Quit");
                }
                return 1;
            }
        }
    }
if(dialogid == Click) 
{
	if(response)
	{
		switch(listitem)
		{
			case 0://Give Car
			{
			        new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
					new Float:x, Float:y, Float:z, Float:f, str[128];
					GetPlayerPos(clickedplayerid,x,y,z);
					GetPlayerFacingAngle(clickedplayerid,f);
					new car = CreateVehicle(411,x,y,z,f,1,2,30,0);
  					PutPlayerInVehicle(clickedplayerid,car,0);
					format(str,sizeof(str),"Admin %s have gave u a car.",GetName(playerid));
					SCM(clickedplayerid,Green,str);
					format(str,sizeof(str),"You have gave %s a car.",GetName(clickedplayerid));
					SCM(playerid,Green,str);
					format(str,sizeof(str),"Admin:%s[%d] Have Gave Player: %s[%d] a Car. /givecar",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
					IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 1: //Give Weapons
			{
			        new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
			        new str[128];
					GivePack(clickedplayerid);
					format(str,sizeof(str),"You have gave %s[%d] Weapons(Ktana,M4,Deagle,Sawn-Off,UZI,Sniper).",GetName(clickedplayerid),clickedplayerid);
			        SCM(playerid,Green,str);
			        format(str,sizeof(str),"Admin %s[%d] have gave You Weapons(Ktana,M4,Deagle,Sawn-Off,UZI,Sniper).",GetName(playerid),playerid);
			        SCM(clickedplayerid,Green,str);
			        format(str,sizeof(str),"Admin:%s[%d] Have Gave Player: %s[%d] Weapons.",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
			        IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 2://Disarm
			{
			        new clickedplayerid = ClickedPlayer[playerid];
			        new str[128];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
                    format(str,sizeof(str),"Admin %s[%d] Have Disarmed You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Disarm %s[%d] .",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    ResetPlayerWeapons(clickedplayerid);
                    format(str,sizeof(str),"Admin %s[%d] Have Disarmed %s[%d]. /Disarm",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 3://Slap
			{
			        new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
			        new str[128];
					new Float:x, Float:y, Float:z;
					GetPlayerPos(clickedplayerid,x ,y ,z);
					SetPlayerPos(clickedplayerid,x ,y ,z+11);
					PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
					format(str,sizeof(str),"Admin %s[%d] Slaped You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Slap %s[%d] .",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    format(str,sizeof(str),"Admin %s[%d] Slaped %s[%d].",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 4://Mute
			{
			        new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
					new str[128];
					Mute[clickedplayerid]=1;
					format(str,sizeof(str),"Admin %s[%d] Muted You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Mute %s[%d].",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    format(str,sizeof(str),"Admin %s[%d] Muted %s[%d].",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 5://unmute 
			{
   					new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
					new str[128];
					Mute[clickedplayerid]=0;
					format(str,sizeof(str),"Admin %s[%d] Un-Muted You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Been Un-Mute %s[%d] .",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    format(str,sizeof(str),"Admin %s[%d] Unmuted %s[%d].",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 6://Freeze
			{
   					new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
					new str[128];
					TogglePlayerControllable(clickedplayerid,0);
					format(str,sizeof(str),"Admin %s[%d] Freezed You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Freeze %s[%d] .",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    format(str,sizeof(str),"Admin %s[%d] Freezed %s[%d].",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			case 7://unfreeze
			{
					new clickedplayerid = ClickedPlayer[playerid];
			        if(!IsPlayerConnected(clickedplayerid)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
					new str[128];
					TogglePlayerControllable(clickedplayerid,1);
					format(str,sizeof(str),"Admin %s[%d] Un-Freezed You.",GetName(playerid),playerid);
                    SCM(clickedplayerid,Green,str);
                    format(str,sizeof(str),"You Have Un-Freeze %s[%d] .",GetName(clickedplayerid),clickedplayerid);
                    SCM(playerid,Green,str);
                    format(str,sizeof(str),"Admin %s[%d] Unfreezed %s[%d].",GetName(playerid),playerid,GetName(clickedplayerid),clickedplayerid);
                    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			}
			
		}
	}
	return 1;
}
return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    if (IsPlayerAdmin(playerid))
    {
		ClickedPlayer[playerid] = clickedplayerid;
		ShowPlayerDialog(playerid,Click,DIALOG_STYLE_LIST,"oAdmin Action","GiveCar \nGive Weapons \nDisarm \nSlap \nmute \nunmute \nFreeze \nunfreeze","Ok","Close");
	}
	return 1;
}
CMD:lsa(playerid,params[])
{
	if(pInfo[playerid][AdminLevel]>=1)
	{
		SetPlayerPos(playerid,1946.2505,-2374.4780,13.5469);
	}
	return 1;
}
CMD:report(playerid,params[])
{
	new reason[100],name[28],name1[28],id,str[500];
	GetPlayerName(playerid,name,28);
	GetPlayerName(id,name1,28);
	if(sscanf(params,"us[100]",id,reason)) return SendClientMessage(playerid,red,"Usge:/Report <PlayerID> <Reason>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That Player Isn't Connected");
	format(str,sizeof(str),"%s(%d) Has Reported %s(%d) | Reason: %s",name,playerid,name1,id,reason);
	SendClientMessageToAll(Green,str);
	format(str,sizeof(str),"{00FF00}%s(%d) {FFFF00}Has Reported {FF0000}%s(%d) | {FF00FF}Reason: %s",name,playerid,name1,id,reason);
	Log("Reports",str);
	return 1;
}
CMD:irc(playerid,prams[])
{
	new msg[500];
	new str[129];
 	if(sscanf(prams, "s[500]",msg)) return SendClientMessage(playerid,red,"Error: /irc (Message)");
 	format(str,sizeof(str), "{FFFF00}[IRC PM] %s(%d): %s", GetName(playerid),playerid, msg);
 	SCM(playerid,-1,str);
	format(str,sizeof(str),"7,1[IRC PM] %s(%d): %s",GetName(playerid),playerid,msg);
 	IRC_GroupSay(groupID, IRC_CHANNEL ,str);
 	format(str,sizeof(str), "IRC PM From %s(%d) : %s", GetName(playerid),playerid, msg);
	Log("Pms",str);
  	return 1;
}
CMD:pm(playerid, params[])
{
	new str[500],target,msg[120];
	if (Mute[playerid] == 1  || pInfo[playerid][PremMute] == 1) return SCM(playerid, red ,"[MUTE]You Are Muted.");
	if(sscanf(params, "us", target,msg)) return SCM(playerid, red, "USAGE: /pm [ID] [Msg]");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
  	if(target == playerid) return SCM(playerid, red, "Error: You Can't PM Your Self");
	if(PMOFF[target] == 1) return SCM(playerid, red, "This Player Is Not Accepting Any Private Messages.");
	if(PMOFF[playerid] == 1) return SCM(playerid, red," Turn Your Pm On First To Be Able To PM Someone.");
	format(str,sizeof(str), "{FFFF00}Private message From %s(%d) : %s", GetName(playerid),playerid,msg);
	SCM(target,-1,str);
	format(str,sizeof(str), "{FFFF00}Private message To %s(%d) : %s", GetName(target),target,msg);
	SCM(playerid,-1,str);
	format(str,sizeof(str), "9,11Private message From %s(%d)  To %s(%d) :11,9 %s", GetName(playerid),playerid, GetName(target),target,msg);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    for(new i = 0; i < MAX_PLAYERS; i ++)
	if(pInfo[i][ReadPms]==1 && pInfo[i][AdminLevel] >= 1)
	    {
	        format(str,sizeof(str), "Private message From %s(%d)  To %s(%d) : %s", GetName(playerid),playerid, GetName(target),target,msg);
	        SCM(i,Gray,str);
 		}
 	format(str,sizeof(str), "Private message From %s(%d)  To %s(%d) : %s", GetName(playerid),playerid, GetName(target),target,msg);
	Log("Pms",str);
	return 1;
}
CMD:pmoff(playerid, params[])
{
	new str[111];
	if(PMOFF[playerid]==1) return SCM(playerid,red,"You Already Turned Your PM off./PmOn To Turn It On Again.");
	PMOFF[playerid] = 1;
	SCM(playerid,Green,"You Have Turned Your PM Off.Use /PmOn To Turn It On.");
	format(str,sizeof(str), "Player %s(%d) has turned his pm off", GetName(playerid),playerid);
	AdminChat(Gray,str);
	return 1;
}
CMD:pmon(playerid, params[])
{
	new str[111];
	if(PMOFF[playerid]==0) return SCM(playerid,red,"You Already Turned Your PM On./PmOff To Turn It Off Again.");
	PMOFF[playerid] = 0;
	SCM(playerid,Green,"You Have Turned Your PM On.Use /PmOff To Turn It Off.");
	format(str,sizeof(str), "Player %s(%d) has turned his pm on", GetName(playerid),playerid);
	AdminChat(Gray,str);
	return 1;
}
CMD:kill(playerid, params[])
{
	new string[128];
	format(string,sizeof(string), "{FF0000}%s[%d] Has Killed Him-self using {FF0000}/Kill", GetName(playerid),playerid);
	SCMTA(-1,string);
	SetPlayerHealth(playerid,0);
	format(string,sizeof(string), "[Server]%s[%d] Has Killed Him-self using /Kill", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, string);
	return 1;
}
////////////////////////////////////////////////////////////////////Admin Cmds///////////////////////////
CMD:goto(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
  	new target,string[128];
  	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /goto [id]");
  	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
  	if(target == playerid) return SCM(playerid, red, "Error: You Can't Goto Your Self");
  	new Float:x, Float:y, Float:z;
	GetPlayerPos(target, x, y, z);
	SetPlayerPos(playerid, x+1, y+1, z);
	format(string,sizeof(string), "Admin: %s[%d] Have Teleported To %s[%d] . /Goto", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, string);
  	return 1;
}
CMD:get(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
  	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /get [id]");
  	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
  	if(target == playerid) return SCM(playerid, red, "Error: You Can't Get Your Self");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x ,y ,z);
    SetPlayerPos(target  ,x+1 ,y+1 ,z);
    new string[129];
    format(string,sizeof(string), "Admin: %s[%d] Have Bring %s[%d] to his Loacation . /Goto", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, string);
	return 1;
}
CMD:sethp(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new hp , target, str[128];
	if(sscanf(params, "ui", target,hp)) return SCM(playerid, red, "USAGE: /sethp <ID> <Amount>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	SetPlayerHealth(target,hp);
	format(str,sizeof(str), "Admin: %s[%d] Have Set %s[%d] health to %d . /SetHP", GetName(playerid),playerid,GetName(target),target,hp);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:setarmour(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new armour , target , str[128];
	if(sscanf(params, "ui", target,armour)) return SCM(playerid, red, "USAGE: /setarmour <ID> <Amount>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	SetPlayerArmour(target,armour);
	format(str,sizeof(str), "Admin: %s[%d] Have Set %s[%d]'s Armour to %d . /SetArmour", GetName(playerid),playerid,GetName(target),target,armour);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:rheal(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] >= 4) 
    {
    
	    new Float:range, Float:health;
	    if(sscanf(params, "ff",range,health)) return SendClientMessage(playerid, red, "Usage: /rheal [range] [health]");
	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(playerid, x, y, z);
	    for(new i = 0; i < MAX_PLAYERS; i ++)
	    {
	        if(IsPlayerInRangeOfPoint(i, range, x, y, z))
	        {
	            SetPlayerHealth(i, health);
	            SendClientMessage(i, red, "You have been range healed!");
	        }
	    }
	    return 1;
	} else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:rarmour(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] >= 4) 
	{
	    new Float:range, Float:armour;
	    if(sscanf(params, "ff",range,armour)) return SendClientMessage(playerid, red, "Usage: /rarmour [range] [armour]");
	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(playerid, x, y, z);
	    for(new i = 0; i < MAX_PLAYERS; i ++)
	    {
	        if(IsPlayerInRangeOfPoint(i, range, x, y, z))
	        {
	            SetPlayerArmour(i, armour);
	            SendClientMessage(i, red, "You have been range armoured!");
	        }
	    }
	    return 1;
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:healall(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    if(IsPlayerConnected(i))
    {
        SetPlayerHealth(i,100);
	}
 	return 1;
}
CMD:armourall(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    if(IsPlayerConnected(i))
    {
        SetPlayerArmour(i,100);
	}
 	return 1;
}


CMD:givepack(playerid, params[])
{
	new target;
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(sscanf(params, "u",target)) return SendClientMessage(playerid, red, "Usage: /givepack [ID] ");
    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
    new str[128];
	GivePack(target);
	format(str,sizeof(str),"You have gave %s[%d] Weapons Pack(Ktana,M4,Deagle,Sawn-Off,UZI,Sniper).",GetName(target),target);
    SCM(playerid,Green,str);
    format(str,sizeof(str),"Admin %s[%d] have gave You Weapons Pack(Ktana,M4,Deagle,Sawn-Off,UZI,Sniper).",GetName(playerid),playerid);
    SCM(target,Green,str);
    format(str,sizeof(str),"Admin:%s[%d] Have Gave Player: %s[%d] Weapons Pack.",GetName(playerid),playerid,GetName(target),target);
    IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:rgun(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new Float:range;
    if(sscanf(params, "f", range)) return SendClientMessage(playerid, red, "Usage: /rgun [range]");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_PLAYERS; i ++)
    {
        if(IsPlayerInRangeOfPoint(i, range, x, y, z))
        {
            GivePack(i);
            new str[200];
            format(str,sizeof(str),"Admin %s Have Gaved Weapons to all player in range meters: %d .",GetName(playerid),range);
            SendClientMessageToAll(red,str);
        }

    }
    return 1;
}
CMD:readpm(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] >= 2)
    {
        if(pInfo[playerid][ReadPms]==0)
        {
        	pInfo[playerid][ReadPms]=1;
        	new INI:file = INI_Open(UserPath(playerid));
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file, "ReadPms", pInfo[playerid][ReadPms]);
	        INI_Close(file);
        	SCM(playerid,Green,"Now You Will See Players Pms.");
		}
		else
		{
		 	pInfo[playerid][ReadPms]=0;
		 	new INI:file = INI_Open(UserPath(playerid));
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file, "ReadPms", pInfo[playerid][ReadPms]);
	        INI_Close(file);
            SCM(playerid,Green,"Now You Won't See Players Pms.");
		}
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:readcmds(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] >= 2)
    {
        if(pInfo[playerid][ReadCmds]==0)
        {
        	pInfo[playerid][ReadCmds]=1;
        	new INI:file = INI_Open(UserPath(playerid));
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file, "ReadCmds", pInfo[playerid][ReadCmds]);
	        INI_Close(file);
        	SCM(playerid,Green,"Now You Will See Players Commands.");
		}
		else
		{
		 	pInfo[playerid][ReadCmds]=0;
		 	new INI:file = INI_Open(UserPath(playerid));
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file, "ReadCmds", pInfo[playerid][ReadCmds]);
	        INI_Close(file);
            SCM(playerid,Green,"Now You Won't See Players Commands.");
		}
	}else  SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:cd(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");

	return 1;
}
CMD:slap(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] >= 2)
    {
		new target;
	    if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /slap <ID>");
		if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
		new Float:x, Float:y, Float:z;
		GetPlayerPos(target,x ,y ,z);
		SetPlayerPos(target,x ,y ,z+10);
		PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
		new str[128];
		format(str,sizeof(str), "Admin: %s[%d] Slaped %s[%d] . /Slap", GetName(playerid),playerid,GetName(target),target);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
    return 1;
}
CMD:rv(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
    for(new i = 0; i < MAX_VEHICLES; i++)
        {
	     SetVehicleToRespawn(i);
        }
    return 1;
}
CMD:reports(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] >= 1)
	{
	    new File:Reports= fopen("oAdmin/Logs/Reports.txt");
		fseek(Reports, 0, seek_start);
		new data[100],whole_data[500];
		while(fread(Reports,data))
		{
			strcat(whole_data,data);
		}
		fclose(Reports);
		if(isnull(whole_data)) return SendClientMessage(playerid,red,"Report is empty ");
		ShowPlayerDialog(playerid,dialog,DIALOG_STYLE_MSGBOX,"{00FF00}Reports",whole_data,"OK","Close");
		new str[100];
		format(str,sizeof(str),"%s(%d) Is Now Looking Into /reports.",GetName(playerid),playerid);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		AdminChat(Gray,str);
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:rreports(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error: You Can't Use This Command.");
	new str[233];
	Clear("Reports");
	SCM(playerid,Green,"Reports Cleared.");
	format(str,sizeof(str),"[Admin]:%s(%d) Cleared Players Reports",GetName(playerid),playerid);
	SCMTA(Gray,str);
	AdminChat(Gray,str);
	format(str,sizeof(str), "Admin: %s[%d] Cleared Players Reports. /rreports", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:givecar(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /givecar <PlayerID>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	if(IsPlayerInAnyVehicle(target)) SCM(playerid,red,"Error: This Player Already Have a Vehicle");
	new Float:x, Float:y, Float:z, Float:f;
	GetPlayerFacingAngle(target,f);
	GetPlayerPos(target,x ,y ,z);
	CreateVehicle(541,x,y,z,f,0,1,-1);
	SCM(target,Green,"An Admin Gived You Vehilce");
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Gave %s[%d] A Car . /GiveCar", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:vcolor(playerid, params[])
{
	new vehid,c1,c2;
	if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(sscanf(params, "ii", c1,c2)) return SCM(playerid, red, "USAGE: /vcolor <Color 1> <Color 2>");
	if(!IsPlayerInAnyVehicle(playerid)) return SCM(playerid,red,"Error: You Should be in a Vehicle to use this Command.");
	vehid = GetPlayerVehicleID(playerid);
	ChangeVehicleColor(vehid, 0, 1);
	SCM(playerid,Green,"Color Seted, :D");
	return 1;
}
CMD:ocar(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(IsPlayerInAnyVehicle(playerid)) SCM(playerid,red,"Error: You Already Have A Vehicle");
	new Car;
    new Float:x, Float:y, Float:z, Float:f;
	GetPlayerFacingAngle(playerid,f);
	GetPlayerPos(playerid,x ,y ,z);
	Car = CreateVehicle(ocar,x,y,z,f,0,1,-1);
	PutPlayerInVehicle(playerid, Car, 0);
	AddVehicleComponent(Car, 1010); // Nitro
	PutPlayerInVehicle(playerid, Car, 0);
 	SCM(playerid, Green, "Nitro added to the Vehicle");
 	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] spawned a Car. /oCar", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:onrg(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(IsPlayerInAnyVehicle(playerid)) SCM(playerid,red,"Error: You Already Have a Vehicle");
    new nrg;
    new Float:x, Float:y, Float:z, Float:f;
	GetPlayerFacingAngle(playerid,f);
	GetPlayerPos(playerid,x ,y ,z);
	nrg = CreateVehicle(522,x,y,z,f,0,1,-1);
	PutPlayerInVehicle(playerid, nrg, 0);
 	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] spawned a NRG-500. /oNRG", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:ohydra(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(IsPlayerInAnyVehicle(playerid)) SCM(playerid,red,"Error: You Already Have a Vehicle");
    new hydra;
    new Float:x, Float:y, Float:z, Float:f;
	GetPlayerFacingAngle(playerid,f);
	GetPlayerPos(playerid,x ,y ,z);
	hydra = CreateVehicle(520,x,y,z,f,0,1,-1);
	PutPlayerInVehicle(playerid, hydra, 0);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] spawned a Hydra. /oHydra", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:clearchat(playerid,params[])
{
    for( new i = 0; i <= 100; i ++ ) SendClientMessageToAll(-1, "" );
    new str[123];
    format(str,sizeof(str),"Chat has Been Cleared by %s.",GetName(playerid));
    SendClientMessageToAll(0xD2691EAA, str);
    return 1;
}
CMD:cc(playerid, params[])
{
	return cmd_clearchat(playerid, params);
}
CMD:pgoto(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new x,y,z,pos[128];
	if (sscanf(params, "iii", x, y, z)) return SCM(playerid, red, "Usage:/pgoto [X] [Y] [Z]");
 	SetPlayerPos(playerid,x,y,z);
 	format(pos,sizeof(pos),"You Have Teleported To : X = %d , Y = %d , Z = %d",x,y,z);
	SCM(playerid,Green,pos);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Set his Pos To X = %d Y = %d Z = %d ./pgoto", GetName(playerid),playerid,x,y,z);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:setpos(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new target,x,y,z,pos[128],pos2[128];
	if (sscanf(params, "iiii", target, x, y, z)) return SCM(playerid, red, "Usage:/setpos [PlayerID] [X] [Y] [Z]");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	if(target == playerid) return SCM(playerid, red, "Error: You Can't Use This Command On Your Self,use /pgoto");
 	SetPlayerPos(target,x,y,z);
 	format(pos,sizeof(pos),"You Have Teleported To : X = %d , Y = %d , Z = %d",x,y,z);
	SCM(target,Green,pos);
	format(pos2,sizeof(pos2),"You Have TelePorted %s[%d] To  : X = %d , Y = %d , Z = %d",GetName(target),target,x,y,z);
	SCM(playerid,Green,pos2);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Set Player : %s[%d] Pos To X = %d Y = %d Z = %d ./setpos", GetName(playerid),playerid,GetName(target),target,x,y,z);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:disarm(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new target;
    if (sscanf(params, "u",target)) return SCM(playerid, red, "Usage:/disarm [PlayerID]");
    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	ResetPlayerWeapons(target);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Disarmed %s[%d] ./disarm", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}

CMD:announce(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new text[128];
    if(sscanf(params, "s", text)) return SCM(playerid, red, "USAGE: /announce [Text]");
 	GameTextForAll(params,4000,3);
   	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Announced '%s' ./announce", GetName(playerid),playerid,text);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:an(playerid, params[])
{
	return cmd_announce(playerid, params);
}
CMD:jetpack(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
    if (sscanf(params, "u",target)) return SetPlayerSpecialAction(playerid,2); SCM(playerid,Green,"Enjoy With Your New Jetpack");
    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
    SetPlayerSpecialAction(target,2);
    SCM(target,Green,"[Server]Enjoy With Your New Jetpack");
    new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Spawned Jetpack . /jetpack", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:jp(playerid, params[])
{
	return cmd_jetpack(playerid, params);
}
CMD:destroyvehicle(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
    if (sscanf(params, "u",target)) return DestroyVehicle(GetPlayerVehicleID(playerid));
    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
    DestroyVehicle(GetPlayerVehicleID(target));
    new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Destroyed Vehicle ID: %d . /destroyvehicle", GetName(playerid),playerid,GetPlayerVehicleID(target));
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:dv(playerid, params[])
{
    return cmd_destroyvehicle(playerid, params);
}


CMD:destoryvehicleid(playerid, params [])
{
    new targetvehiclid;
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if (sscanf(params, "i",targetvehiclid)) return SCM(playerid,red,"USGE:DestoryCarID <VehicleID>");
	DestroyVehicle(targetvehiclid);
 	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Destroyed Vehicle ID: %d . /destroyvehicleid", GetName(playerid),playerid,targetvehiclid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:dvid(playerid, params [])
{
    return cmd_destoryvehicleid(playerid, params);
}

CMD:setskin(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,skin;
	if (sscanf(params, "ii",target,skin)) return SCM(playerid,red,"USAGE:setskin <PlayerID> <SkinID>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	if (skin < 0 || skin > 299) return SCM(playerid,red,"Error: Wrong Skid ID");
	SetPlayerSkin(target,skin);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Set %s[%d]'s Skin to %d . /setskin", GetName(playerid),playerid,GetName(target),target,skin);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:setmoney(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,money,msg[128];
	if (sscanf(params, "ui",target,money)) return SCM(playerid,red,"USAGE:setmoney <PlayerID> <Amount>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	ResetPlayerMoney(target);
	GivePlayerMoney(target,money);
	format(msg,sizeof(msg),"You Have Set %s[%d]'s Money To:%d $",GetName(target),target,money);
	SCM(playerid,Green,msg);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Has Set %s[%d]'s Cash to %d $ . /setmoney", GetName(playerid),playerid,GetName(target),target,money);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:givemoney(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,money,msg[128],msg1[128];
	if (sscanf(params, "ui",target,money)) return SCM(playerid,red,"USAGE:givemoney <PlayerID> <Amount>");
	if (!IsPlayerConnected(target)) return SCM(playerid,red,"ERROR: Player isn't Connected.");
	GivePlayerMoney(target,money);
	format(msg,sizeof(msg),"You Have Gave %s $ to %s[%d]",money,GetName(target),target);
	SCM(playerid,Green,msg);
	format(msg1,sizeof(msg1),"An Admin Gaved You %d $",money);
	SCM(target,Green,msg1);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Gave %s $ to %s[%d]. /givemoney", GetName(playerid),playerid,money,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:setscore(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,score,msg[128];
	if (sscanf(params, "ui",target,score)) return SCM(playerid,red,"USAGE:setscore <PlayerID> <Amount>");
	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	SetPlayerScore(target,score);
    format(msg,sizeof(msg),"You Have Set %s[%d]'s Score To : %d ",GetName(target),target,score);
	SCM(playerid,Green,msg);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Setted %s[%d]'s score to %d . /setscore", GetName(playerid),playerid,GetName(target),target,score);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:givescore(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,tscore,msg[128],msg1[128];
	if (sscanf(params, "ui",target,tscore)) return SCM(playerid,red,"USAGE:givescore <PlayerID> <Amount>");
	if (!IsPlayerConnected(target)) return SCM(playerid,red,"ERROR: Player isn't Connected.");
	SetPlayerScore(target,GetPlayerScore(target)+tscore);
	format(msg,sizeof(msg),"You Have Gave %d Score to %s",tscore,GetName(target));
	SCM(playerid,Green,msg);
	format(msg1,sizeof(msg1),"An Admin Gaved You %d Score",tscore);
	SCM(target,Green,msg1);
	new str[128];
	format(str,sizeof(str), "Admin: %s[%d] Gave %d score to %s[%d] . /givescore", GetName(playerid),playerid,tscore,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:giveweapon (playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target,wid,ammo,msg[120];
	if (sscanf(params,"uii",target,wid,ammo)) return SCM(playerid,red,"Error:USAGE:gg <PlayerID> <WeaponID> <Ammo>");
	GivePlayerWeapon(target,wid,ammo);
    format(msg,sizeof(msg),"Admin: %s[%d] has Gived %s[%d] WeaponID: %d with Ammo: %d .",GetName(playerid),playerid,GetName(target),target,wid,ammo);
	SCMTA(Green,msg);
	new str[128];
	format(str,sizeof(str), "4,2Admin: %s[%d] has Gave Weapon ID: %d with %d Ammo to : %s[%d] . /givweapon", GetName(playerid),playerid,wid,ammo,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}



CMD:setlevel(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] >= 6 || IsPlayerAdmin(playerid))
	{
		new target,lvl,msg[128],msg1[128];
		if (sscanf(params, "ui",target,lvl))
			return SCM(playerid,red,"USAGE:setlevel <PlayerID> <Amount>");
		if (!IsPlayerConnected(target))
			return SCM(playerid,red,"ERROR: Player isn't Connected.");
		if(pInfo[target][AdminLevel] == lvl)
			return SCM(playerid,red,"Error: This player already in this lvl");
		pInfo[target][AdminLevel] = lvl;
		// Save the level
        new INI:file = INI_Open(UserPath(target));
        INI_SetTag(file, "PlayerData");
        INI_WriteInt(file, "AdminLevel",lvl);
        INI_Close(file);
		format(msg,sizeof(msg),"Server Adminitstrator %s[%d] Has Promoted you to Admin Level %d | Congrats",GetName(playerid),playerid,lvl);
		format(msg1,sizeof(msg1),"Admin %s[%d] has Set %s[%d]'s Admin Level to %d | Congrats",GetName(playerid),playerid,GetName(target),target,lvl);
		SCM(target,Green,msg);
		SCMTA(Green,msg1);
		new str[128];
		format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Promoted %s[%d] to Admin Level %d | Congrats", GetName(playerid),playerid,GetName(target),target,lvl);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	}else SCM(playerid,red,"Error: You Can't Use This Command.");
	return 1;
}
CMD:object(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] < 5) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new object,msg[128];
	if (sscanf(params, "i",object)) return SCM(playerid,red,"USAGE:object <ObjectID>");
	if (IsValidObject(object)) return SCM(playerid,red,"Wrong Object ID");
	new Float:x , Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	CreateObject(object,x,y,z,0,0,0,0);
	format(msg,sizeof(msg),"You Have Created New Object.ObjectID = %d",object);
	SCM(playerid,Green,msg);
	new str[128];
	format(str,sizeof(str), "Adminintstrator %s[%d] Has Created an object ID: %d at his Pos : X= %d Y= %d Z= %d ./object", GetName(playerid),playerid,object,x,y,z);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}

CMD:ban(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new target,msg1[128],msg[128],reason[128];
    if (sscanf(params, "us",target,reason)) return SCM(playerid,red,"USAGE:Ban <PlayerID> <Reason>");
    format(msg1,sizeof(msg1),"You Have banned By Admin %s[%d] | Reason: %s",GetName(playerid),playerid,reason);
	SCM(target,Green,msg1);
	format(msg,sizeof(msg),"%s[%d] Has been Banned By Admin %s[%d] | Reason: %s",GetName(playerid),playerid,GetName(target),target,reason);
	SCMTA(Green,msg);
	Log("Ban",msg);
	GameTextForPlayer(target,"~r~Banned",4000,2);
	new str[128];
	format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Banned %s[%d] | Reason : %s", GetName(playerid),playerid,GetName(target),target,reason);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	pInfo[target][Banned] = 1;
	pInfo[target][BannedTimes]++;
	new INI:file = INI_Open(UserPath(target));
    INI_SetTag(file, "PlayerData");
    INI_WriteInt(file, "Banned", pInfo[target][Banned]);
    INI_WriteInt(file, "BannedTimes", pInfo[target][BannedTimes]);
	INI_WriteString(file,"Reason",reason);
    INI_Close(file);
	SetTimerEx("KickHim",1000,false,"u",target);
 	return 1;
}

CMD:nameban(playerid,params[])
{
    new string[200],string1[111];
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target[30],reason[128],str[500];
    if (sscanf(params, "s[30]s",target,reason)) return SCM(playerid,red,"USAGE:nameban <PlayerName> <Reason>");
    format(string,sizeof(string),USER_PATH,target);
	


	new ti = load_banned(target)+1;
	if(fexist(string))
    {
        new INI:file = INI_Open(string);//wait dont do anything...
        INI_SetTag(file, "PlayerData");
        INI_WriteInt(file,"Banned",1);
        INI_WriteString(file,"Reason",reason);
        INI_WriteInt(file,"BannedTimes",ti);
		INI_Close(file);

		format(string1,sizeof(string1),"You have banned %s.|Reason: %s",target,reason);
        SendClientMessage(playerid,Green,string1);
        format(str,sizeof(str), "Adminintstrator %s[%d] Has banned %s |Reason: %s",GetName(playerid),playerid,target,reason);
		AdminChat(Green,str);
		Log("Ban",str);
		format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Banned %s | Reason : %s", GetName(playerid),playerid,target,reason);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    }
    else SendClientMessage(playerid,red,"Account not found");
	return 1;
}
CMD:unban(playerid, params[])
{
	new string[200],string1[111];
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target[30],str[500];
    if (sscanf(params, "s[30]",target)) return SCM(playerid,red,"USAGE:unban <PlayerName>");
    format(string,sizeof(string),USER_PATH,target);
    if(fexist(string))
    {
        new INI:file = INI_Open(string);
        INI_SetTag(file, "PlayerData");
        INI_WriteInt(file,"Banned",0);
        INI_WriteString(file,"Reason","");
        INI_Close(file);
        format(str,sizeof(str), "Adminintstrator %s[%d] Has unbanned %s", GetName(playerid),playerid,target);
        Log("Ban",str);
        format(string1,sizeof(string1),"You have unbanned %s.",target);
        SendClientMessage(playerid,Green,string1);
		format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has unbanned %s", GetName(playerid),playerid,target);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		AdminChat(Green,str);
    }
    else SendClientMessage(playerid,red,"Account not found");
  
	return 1;
}
CMD:kick(playerid, params[])
{
    new target,msg1[128],msg[128],reason[128];
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if (sscanf(params, "us",target,reason)) return SCM(playerid,red,"USAGE:Kick <PlayerID> <Reason>");
    format(msg1,sizeof(msg1),"You Have Kicked By Admin %s[%d] | Reason: %s",GetName(playerid),playerid,reason);
	SCM(target,Green,msg1);
	format(msg,sizeof(msg),"%s[%d] Has been Kicked By Admin %s[%d] | Reason: %s",GetName(playerid),playerid,GetName(target),target,reason);
	SCMTA(Green,msg);
	Log("Kick",msg);
	GameTextForPlayer(target,"~r~Kicked",4000,2);
	SetTimerEx("KickHim",1000,false,"u",target);
	new str[128];
	format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Kicked %s[%d] | Reason : %s", GetName(playerid),playerid,GetName(target),target,reason);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
 	return 1;
}
forward KickHim(target);
public KickHim (target)
{
	Kick(target);
}
CMD:jail(playerid, params[])
{
	new str[500],target,JailTime,reason[128];
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if (sscanf(params, "uis",target,JailTime,reason)) return SCM(playerid,red,"USAGE:jail <PlayerID> <TimeSecs> <Reason>");
	if (Jail[target] == 1) return SCM(playerid,red,"Player Is Already In Jail");
	Jail[target] = 1;
	SetPlayerInterior(target,6);
    SetPlayerPos(target,264.2532,77.4431,1001.0391);
    SetPlayerFacingAngle(target,265.3724);
    TogglePlayerControllable(target,1);
    format(str,sizeof(str),"You Have Jailed For %d Secs By Admin : %s[%d] [Reason: %s]",JailTime,GetName(playerid),playerid,reason);
    SCM(target,Green,str);
	format(str,sizeof(str),"%s Has Jailed For %d Seconds By Admin : %s[%d] [Reason: %s]",GetName(target),JailTime,GetName(playerid),playerid,reason);
	SCMTA(Green,str);
	Log("Mute+Jail",str);
	/*format(str,sizeof(str),"~g~ Jail Time : %d",);
    GameTextForPlayer(target, string, 3000, 3);*/
	SetTimer("jail",JailTime*1000,false);
	format(str,sizeof(str), "4,11Adminintstrator %s[%d] Has Jailed %s[%d] (%d Seconds) | Reason : %s", GetName(playerid),playerid,GetName(target),target,JailTime,reason);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
forward jail(target);
public jail (target)
{
	if (Mute[target] == 1)
	{
		Jail[target] = 0;
		SCM(target,Gray,"Un-jailed");
		SpawnPlayer(target);
		new str[123];
		format(str,sizeof(str), "8,2%s Has been Auto-Unjailed",GetName(target));
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	}
}
CMD:unjail(playerid,params[])
{
	new target;
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if (sscanf(params, "u",target)) return SCM(playerid,red,"USAGE:unjail <PlayerID> ");
	if (Jail[target] == 0) return SCM(playerid,red,"Player Isn't Jailed");
	Jail[target] = 0;
	SpawnPlayer(target);
	SCM(playerid,Green,"[INFO]: You have Un-Jailed the Enterd ID");
	SCM(target,Green,"You have been Un-Jailed by Server Admin.");
	new str[123];
	format(str,sizeof(str), "Adminintstrator %s[%d] Has Un-Jailed %s[%d] ", GetName(playerid),playerid,GetName(target),target);
	Log("Mute+Jail",str);
	format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Un-Jailed %s[%d] ", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:mute(playerid,params[])
{
	new str[500],target,JailTime,reason[128];
	if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if (sscanf(params, "uis",target,JailTime,reason)) return SCM(playerid,red,"USAGE:Mute <PlayerID> <TimeSecs> <Reason>");
	if (Mute[target] == 1) return SCM(playerid,red,"Player Already Muted");
	Mute[target] = 1;
    format(str,sizeof(str),"You Have Muted For %d Secs By Admin : %s[%d] [Reason: %s]",JailTime,GetName(playerid),playerid,reason);
    SCM(target,Green,str);
	format(str,sizeof(str),"%s Has Muted For %d Seconds By Admin : %s[%d] [Reason: %s]",GetName(target),JailTime,GetName(playerid),playerid,reason);
	SCMTA(Green,str);
	Log("Mute+Jail",str);
	SetTimer("mute",JailTime*1000,false);
	format(str,sizeof(str), "4,11Adminintstrator %s[%d] Has Muted %s[%d] (%d Seconds) | Reason : %s", GetName(playerid),playerid,GetName(target),target,JailTime,reason);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:pmute(playerid,params[])
{
	new str[500],target,reason[128];
	if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if (sscanf(params, "us",target,reason)) return SCM(playerid,red,"USAGE:Pmute <PlayerID> <Reason>");
	if (pInfo[target][PremMute] == 1) return SCM(playerid,red,"Player Already Prem Muted");
    pInfo[target][PremMute] = 1;
    format(str,sizeof(str),"You Have Muted Prem Mute  By Admin : %s[%d] [Reason: %s]",GetName(playerid),playerid,reason);
    SCM(target,Green,str);
	format(str,sizeof(str),"%s Has MutedPrem Mute By Admin : %s[%d] [Reason: %s]",GetName(target),GetName(playerid),playerid,reason);
	SCMTA(Green,str);
	Log("Mute+Jail",str);
	format(str,sizeof(str), "4,11Adminintstrator %s[%d] Has Muted %s[%d] (Prem Mute) | Reason : %s", GetName(playerid),playerid,GetName(target),target,reason);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
forward mute(target);
public mute (target)
{
	if (Mute[target] == 1) {
	Mute[target] = 0;
	SCM(target,Green,"You Has been Auto-Unmuted");
	new str[123];
	format(str,sizeof(str), "8,2%s Has been Auto-Unmuted",GetName(target));
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	}
}
CMD:unmute(playerid,params[])
{
	new target;
	if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if (sscanf(params, "u",target)) return SCM(playerid,red,"USAGE:Mute <PlayerID> ");
	if (Mute[target] == 0 && pInfo[target][PremMute] == 0 ) return SCM(playerid,red,"Player Isn't muted");
	Mute[target] = 0;
	pInfo[target][PremMute] = 0;
	SCM(playerid,Green,"[INFO]: You have Unmuted the Enterd ID");
	SCM(target,Green,"You have been Unmuted by Server Admin.");
	new str[123];
	format(str,sizeof(str), "Adminintstrator %s[%d] Has Unmuted %s[%d] ", GetName(playerid),playerid,GetName(target),target);
	Log("Mute+Jail",str);
	format(str,sizeof(str), "8,2Adminintstrator %s[%d] Has Unmuted %s[%d] ", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:afk(playerid ,params[])
{
	new string[128];
	if(AFK[playerid] == 1) return SCM(playerid,Green,"You already AFK.Use /Back to Back to game.");
	AFK[playerid] = 1;
	TogglePlayerControllable(playerid,0);
	SetPlayerVirtualWorld(playerid, 1000000);
	format(string,sizeof(string), "%s[%d] Is Now Away from Keyboard",GetName(playerid),playerid);
	SCMTA(Green,string);
	new str[123];
	format(str,sizeof(str), "5,3%s[%d] Is Now Away from Keyboard", GetName(playerid),playerid);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:back(playerid ,params[])
{
	new string[128];
	if (AFK[playerid] == 0) return SCM(playerid,Green,"You Aren't AFK use /AFK If You Going away.");
	AFK[playerid] = 0;
	TogglePlayerControllable(playerid,1);
	SetPlayerVirtualWorld(playerid, 0);
	format(string,sizeof(string), "%s[%d] Is Now Back from his AFK!",GetName(playerid),playerid);
	SCMTA(Green,string);
	new str[123];
	format(str,sizeof(str), "5,3%s[%d] Is Now Back from his AFK!", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	return 1;
}

CMD:freeze(playerid ,params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new string[128],target;
	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /freeze [id]");
	TogglePlayerControllable(playerid,0);
	format(string,sizeof(string), "Administrator %s[%d] Has Freezed %s[%d]",GetName(playerid),playerid,GetName(target),target);
	SCMTA(Green,string);
	new str[123];
	format(str,sizeof(str), "5,3Administrator %s[%d] Has Freezed %s[%d]", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:unfreeze(playerid ,params[])
{
   	if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new string[128],target;
	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /unfreeze [id]");
	TogglePlayerControllable(playerid,1);
	format(string,sizeof(string), "Administrator %s[%d] Has Unfreezed %s[%d]",GetName(playerid),playerid,GetName(target),target);
	SCMTA(Green,string);
	new str[123];
	format(str,sizeof(str), "5,3Administrator %s[%d] Has Unfreezed %s[%d]",GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:flip(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(!IsPlayerInAnyVehicle(playerid)) return SCM(playerid,red,"Error: You are not in a vehicle.");
	new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle;
	GetPlayerPos(playerid, X, Y, Z);
	VehicleID = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(VehicleID, Angle);
	SetVehiclePos(VehicleID, X, Y, Z);
	SetVehicleZAngle(VehicleID, Angle);
	SetVehicleHealth(VehicleID,1000.0);
	AddVehicleComponent(VehicleID, 1010); // Nitro
	SCM(playerid, red,"Vehicle Flipped.");
	GameTextForPlayer(playerid,"~g~Vehicle Flipped",3000,3);
	new str[123];
	format(str,sizeof(str), "5,3%s[%d] Has Flipped His Vehicle", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:f(playerid, params[])
{
	return cmd_flip(playerid,params);
}
CMD:aflip(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 2 || !IsPlayerAdmin(playerid)) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new target,VehicleID,Float:X, Float:Y, Float:Z, Float:Angle;
    if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /aflip [PlayerID]");
    if(!IsPlayerInAnyVehicle(target)) return SCM(playerid,red,"Error: Player are not in a vehicle.");
    GetPlayerPos(target, X, Y, Z);
    VehicleID = GetPlayerVehicleID(target);
   	GetVehicleZAngle(VehicleID, Angle);
	SetVehiclePos(VehicleID, X, Y, Z);
	SetVehicleZAngle(VehicleID, Angle);
	SetVehicleHealth(VehicleID,1000.0);
	AddVehicleComponent(VehicleID, 1010); // Nitro
	SCM(playerid, Green,"Vehicle Flipped.");
	SCM(target, Green,"Vehicle Flipped.");
	new str[123];
	format(str,sizeof(str), "5,3Admin %s[%d] Has Flipped %s[%d] Vehicle.", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:nos(playerid, params[])
{
    if(pInfo[playerid][AdminLevel] >= 1 || IsPlayerAdmin(playerid))
    	{
			new Car;
			Car = GetPlayerVehicleID(playerid);
		    AddVehicleComponent(Car, 1010); // Nitro
		    SCM(playerid, Green, " Nitro Added");
			new str[123];
			format(str,sizeof(str), "5,3Admin %s[%d] Has Add Nitro To His Vehicle.", GetName(playerid),playerid);
			IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		}
	else
		{
			SCM(playerid,red,"Error:You Can't Use This Command.");
		}
	return 1;
}
CMD:explode(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] >= 4)
    {
		new target,String[128],string[128];//reason[128]
		new Float:X , Float:Y,Float:Z;
	    if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /explode [PlayerID] [Reason]");
	    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
		GetPlayerPos(target,X,Y,Z);
		CreateExplosion(X, Y , Z, 7,10.0);
		format(String,sizeof(String),"You have been exploded by Administrator %s[%d] [reason: %s]",GetName(playerid),playerid,params[2]);
		SCM(target,Green,String);
		format(string,sizeof(string),"You have been explode %s[%d] [reason: %s]",GetName(target),target,params[2]);
		SCM(playerid,Green,string);
		new str[123];
		format(str,sizeof(str), "5,3 %s[%d] Has Exploded by Server-Admin %s[%d] | Reason: %s", GetName(target),target,GetName(playerid),playerid,params[2]);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	} else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}

CMD:asay(playerid , params [])
{
    if(pInfo[playerid][AdminLevel] >= 1 || IsPlayerAdmin(playerid))
    {
		new msg[128],String[129];
		if(sscanf(params, "s", msg)) return SCM(playerid, red, "USAGE: /asay [msg]");
		format(String,sizeof(String),"{FF00AA}*Admin*:- {00FFFF}%s.",msg);
		SCMTA(-1,String);
		new str[123];
		format(str,sizeof(str), "5,3 %s[%d] Said: '%s' With /asay", GetName(playerid),playerid,msg);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		format(str,sizeof(str), "5 Admin:- 12 %s", GetName(playerid),playerid,msg);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		return 1;
	} else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:akill(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 2 || !IsPlayerAdmin(playerid)) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new target,str[128],str2[128];
    if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /akill [ID] [Reason]");
    if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	SetPlayerHealth(target,0);
	SetPlayerArmour(target,0);
	format(str,sizeof(str),"You have been killed by Administrator %s[%d] [reason: %s]",GetName(playerid),playerid,params[2]);
	SCM(target,Green,str);
	format(str2,sizeof(str2),"You have been killed %s[%d] [reason: %s]",GetName(target),target,params[2]);
	SCM(playerid,Green,str2);
	format(str,sizeof(str), "5,3Admin %s[%d] Has Killed %s[%d] | Reason: %s", GetName(playerid),playerid,GetName(target),target,params[2]);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:spawn(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 1 || !IsPlayerAdmin(playerid)) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
 	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /Spawn [ID]");
 	if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
    SpawnPlayer(target);
	SCM(playerid,Green,"Player has spawned");
	SCM(target,Green,"Admin has spawned you");
	GameTextForPlayer(target,"~g~Spawned",1500,3);
	new str[123];
	format(str,sizeof(str), "5,3Admin %s[%d] Has respawned %s[%d] ./spawn", GetName(playerid),playerid,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:savestats(playerid, params[])
{
	if(pInfo[playerid][AdminLevel] >=1 || IsPlayerAdmin(playerid))
	{
	    SCMTA(Green,"Save-Stats: Server Adminintstrator Has Saved Your Stats.");
		for(new i = 0; i < MAX_PLAYERS; i ++)
        SaveStats(i);
		return 1;
	}else {
	    SaveStats(playerid);
		SCM(playerid,Green,"Your Stats Saved.");
		return 1;
	}
}
CMD:ss(playerid, params[])
{
	return cmd_savestats(playerid, params);
}
CMD:fakechat(playerid,params [])
{
    if(pInfo[playerid][AdminLevel] < 6) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new msg[129],target;
	if(sscanf(params, "us", target,msg)) return SCM(playerid, red, "USAGE: /fakechat [ID] [MSG]");
	SendPlayerMessageToAll(target,msg);
	SCM(playerid,Green,"Fake Msg Sent :D ");
	new str[123];
	format(str,sizeof(str), "5,3Admin %s[%d] Has send '%s' fake chat by %s[%d] . /fakechat ", GetName(playerid),playerid,msg,GetName(target),target);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:fakecmd(playerid,params [])
{
    if(pInfo[playerid][AdminLevel] >= 6 || IsPlayerAdmin(playerid))
    {
	    new target,cmd[129],str[1128];
		if(!IsPlayerConnected(target)) return SCM(playerid, red,"ERROR: Player ins't Connected.");
	    if(sscanf(params, "us", target,cmd)) return SCM(playerid, red, "USAGE: /fakecmd [ID] [CMD]");
	    format(str,sizeof(str),"You have been sent Fake CMD %s to %s",cmd,GetName(target));
	    CallRemoteFunction("OnPlayerCommandText", "is", target, cmd);
		SCM(playerid,Green,str);
		AdminChat(Gray,"AdminCmds:FakeCMD");
		format(str,sizeof(str), "5,3Admin %s[%d] Has send '%s' fake command by %s[%d] ", GetName(playerid),playerid,cmd,GetName(target),target);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:3dl(playerid ,params[])
{
    if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
    new text[128];
    if(sscanf(params, "s[80]", text)) return SCM(playerid, red, "USAGE: /3dl [Text]");
    new Text3D:label = Create3DTextLabel(text, 0xFFFFFF, 30.0, 40.0, 50.0, 40.0, 0);
    Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
    SCM(playerid,0x00FF00,"3D Lable Created");
   	new str[123];
	format(str,sizeof(str), "5,3Admin %s[%d] has Created a 3D Lable On him-self : '%s' ./3dl", GetName(playerid),playerid,text);
	IRC_GroupSay(groupID, IRC_CHANNEL, str);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
    return 1;
}
CMD:hide(playerid ,params[])
{
	if(pInfo[playerid][AdminLevel] < 1 ) return SCM(playerid,red,"Error:You Can't Use This Command.");
	Hide[playerid]=1;
	SCM(playerid,Gray,"Now You Are Hiden From Admin List");
	return 1;
}
CMD:admins(playerid ,params[])
{
	new string[128];
	new count = 0;
 	new msg[1999];
	for(new i=-1;i<MAX_PLAYERS;i++)
	{
	if(IsPlayerConnected(i))
	{
 		if(pInfo[i][AdminLevel] > 1 && Hide[i] == 0)
	    {
	         {
	           	    switch(pInfo[i][AdminLevel])
					{
						case 1:
						{
						    format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Trial Moderator]",GetName(i),i);
						    strcat(msg,string,999);
						}
						case 2:
						{
						    format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Moderator]",GetName(i),i);
						    strcat(msg,string,999);
						}
						case 3:
						{
							format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Adminitstrator]",GetName(i),i);
							strcat(msg,string,999);
						}
						case 4:
						{
						    format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Server Manager]",GetName(i),i);
						    strcat(msg,string,999);
						}
						case 5:
						{
						    format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Co-Owner]",GetName(i),i);
						    strcat(msg,string,999);
						}
						case 6:
						{
						    format(string,sizeof(string),"{FFB700}\n %s[%d] {00FF00}[Owner]",GetName(i),i);
						    strcat(msg,string,999);
						}
					}
					ShowPlayerDialog(playerid,D_ADMINS,DIALOG_STYLE_MSGBOX,"{00FF00}.:|Server Admins|:.",msg,"OK","");
					count++;
				 }
			}
		}
	}
	if( count == 0) SendClientMessage(playerid,red,"There are no Admins online at the moment");
	return 1;
}
CMD:cmds(playerid,params[])
{
	new string[952];
	strcat(string, "/Kill\n");
	strcat(string, "/AFK\n");
	strcat(string, "/Back\n");
	strcat(string, "/Admins\n");
	strcat(string, "/PM\n");
	strcat(string, "/pmon\n");
	strcat(string, "/pmoff\n");
	strcat(string, "/IRC\n");
	ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Players Commands", string, "OK","");
	return 1;
}
CMD:acmds(playerid,params[])
{

    if(pInfo[playerid][AdminLevel] == 1)
	   		{
      			new string[952];
      			strcat(string, "/hide\n");
      			strcat(string, "/3dl\n");
      			strcat(string, "/spawn\n");
      			strcat(string, "/goto\n");
      			strcat(string, "/get\n");
      			strcat(string, "/givecar\n");
      			strcat(string, "/ocar\n");
      			strcat(string, "/ocar\n");
      			strcat(string, "/onrg\n");
      			strcat(string, "/jetpack\n");
      			strcat(string, "/flip\n");
      			strcat(string, "/nos\n");
      			strcat(string, "/asay\n");
      			strcat(string, "/spec\n");
      			strcat(string, "/specoff\n");
      			strcat(string, "Enjoy!\n");
      			ShowPlayerDialog(playerid, 101, DIALOG_STYLE_MSGBOX, "Trial Moderator[Level 1]", string, "OK","");
			}
	if(pInfo[playerid][AdminLevel] == 2)
			{
			    new string[952];
		     	strcat(string, "/hide			/eject  	\n");
      			strcat(string, "/3dl			/akill	    \n");
      			strcat(string, "/spawn			/sethp	    \n");
      			strcat(string, "/goto			/setarmour	\n");
      			strcat(string, "/get			/slap		\n");
      			strcat(string, "/givecar		/pgoto		\n");
      			strcat(string, "/ocar			/disarm		\n");
      			strcat(string, "/ocar			/announce	\n");
      			strcat(string, "/onrg			/mute		\n");
      			strcat(string, "/jetpack		/unmute		\n");
      			strcat(string, "/flip			/freeze		\n");
      			strcat(string, "/nos			/unfreeze	\n");
      			strcat(string, "/asay			/aflip	    \n");
      			strcat(string, "/spec			/specoff	\n");
      			ShowPlayerDialog(playerid, 102, DIALOG_STYLE_MSGBOX, "Moderator[Level 2]", string, "OK","");
			}
	if(pInfo[playerid][AdminLevel] == 3)
	        {
	            new string[952];
		     	strcat(string, "/hide			/eject								\n");
      			strcat(string, "/3dl			/akill	 	/ohydra	    			\n");
      			strcat(string, "/spawn			/sethp	   	/giveweapon	 			\n");
      			strcat(string, "/goto			/setarmour	/setpos					\n");
      			strcat(string, "/get			/slap		/destroyvehicle			\n");
      			strcat(string, "/givecar		/pgoto		/destoryvehicleid		\n");
      			strcat(string, "/ocar			/disarm		/setskin				\n");
      			strcat(string, "/ocar			/announce	/givemoney				\n");
      			strcat(string, "/onrg			/mute		/givescore				\n");
      			strcat(string, "/jetpack		/unmute		/ban					\n");
      			strcat(string, "/flip			/freeze		/pmute					\n");
      			strcat(string, "/nos			/unfreeze	/jail					\n");
      			strcat(string, "/asay			/aflip	    unjail					\n");
      			strcat(string, "/spec			/specoff							\n");
       			ShowPlayerDialog(playerid, 103, DIALOG_STYLE_MSGBOX, "Adminitstrator[Level 3]", string, "OK","");
			}
	if(pInfo[playerid][AdminLevel] == 4)
	        {
	            new string[952];
		     	strcat(string, "/hide		/explode	/givepack			/rheal		\n");
      			strcat(string, "/3dl    	/akill	 	/ohydra	    		/rgun		\n");
      			strcat(string, "/spawn		/sethp	   	/giveweapon	 		/setscore	\n");
      			strcat(string, "/goto		/setarmour	/setpos			  	/setmoney	\n");
      			strcat(string, "/get		/slap		/destroyvehicle	  	/eject		\n");
      			strcat(string, "/givecar	/pgoto		/destoryvehicleid 				\n");
      			strcat(string, "/ocar		/disarm		/setskin		  				\n");
      			strcat(string, "/ocar		/announce	/givemoney		  				\n");
      			strcat(string, "/onrg		/mute		/givescore		  				\n");
      			strcat(string, "/jetpack	/unmute		/ban							\n");
      			strcat(string, "/flip		/freeze		/pmute							\n");
      			strcat(string, "/nos		/unfreeze	/jail							\n");
      			strcat(string, "/asay		/aflip	    /unjail							\n");
      			strcat(string, "/spec		/specoff	/rarmour								\n");
       			ShowPlayerDialog(playerid, 104, DIALOG_STYLE_MSGBOX, "Server Manager[Level 4]", string, "OK","");
			}
	if(pInfo[playerid][AdminLevel] == 5)
	        {
	            new string[952];
		     	strcat(string, "/hide		/explode	/givepack			/rheal		\n");
      			strcat(string, "/3dl    	/akill	 	/ohydra	    		/rgun		\n");
      			strcat(string, "/spawn		/sethp	   	/giveweapon	 		/setscore	\n");
      			strcat(string, "/goto		/setarmour	/setpos			  	/setmoney	\n");
      			strcat(string, "/get		/slap		/destroyvehicle	  	/object		\n");
      			strcat(string, "/givecar	/pgoto		/destoryvehicleid 	/eject		\n");
      			strcat(string, "/ocar		/disarm		/setskin		  				\n");
      			strcat(string, "/ocar		/announce	/givemoney		  				\n");
      			strcat(string, "/onrg		/mute		/givescore		  				\n");
      			strcat(string, "/jetpack	/unmute		/ban			  				\n");
      			strcat(string, "/flip		/freeze		/pmute							\n");
      			strcat(string, "/nos		/unfreeze	/jail							\n");
      			strcat(string, "/asay		/aflip	    /unjail							\n");
      			strcat(string, "/spec		/specoff	/rarmour						\n");
       			ShowPlayerDialog(playerid, 105, DIALOG_STYLE_MSGBOX, "Co-Owner[Level 5]", string, "OK","");
			}
	if(pInfo[playerid][AdminLevel] >= 6 || IsPlayerAdmin(playerid))
	        {
	            new string[952];
      			strcat(string, "/3dl    	/akill	 		/ohydra	    	  	/hide			\n");
      			strcat(string, "/spawn		/sethp	   		/giveweapon	 	  	/explode		\n");
      			strcat(string, "/goto		/setarmour		/setpos			  	/givepack		\n");
      			strcat(string, "/get		/slap			/destroyvehicle	  	/rarmour		\n");
      			strcat(string, "/givecar	/pgoto			/destoryvehicleid 	/rheal			\n");
      			strcat(string, "/ocar		/disarm			/setskin		  	/rgun			\n");
      			strcat(string, "/ocar		/announce		/givemoney		  	/setscore		\n");
      			strcat(string, "/onrg		/mute			/givescore		  	/setmoney		\n");
      			strcat(string, "/jetpack	/unmute			/ban			  	/object			\n");
      			strcat(string, "/flip		/freeze			/pmute			  	/setlevel		\n");
      			strcat(string, "/nos		/unfreeze		/jail			  	/fakechat		\n");
      			strcat(string, "/asay		/aflip	    	/unjail			  	/fakecmd		\n");
      			strcat(string, "/spec		/specoff		/eject								\n");
       			ShowPlayerDialog(playerid, 106, DIALOG_STYLE_MSGBOX, "Owner[Level 6]", string, "OK","");
			}
	return 1;
}
CMD:eject(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 2) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new target;
	if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /Eject [PlayerID]");
    RemovePlayerFromVehicle(target);
    PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
	return 1;
}
CMD:ejectall(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 3) return SCM(playerid,red,"Error:You Can't Use This Command.");
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	if(IsPlayerInAnyVehicle(i))
	{
		RemovePlayerFromVehicle(i);
    	PlayerPlaySound(i,1190,0.0,0.0,0.0);
	}
	return 1;
 }
	
	
CMD:config(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 6) return SCM(playerid,red,"Error:You Can't Use This Command.");
	new File:ServerConfig= fopen("oAdmin/Config.ini");
	fseek(ServerConfig, 0, seek_start);
	new data[100],whole_data[500];
	while(fread(ServerConfig,data))
	{
		strcat(whole_data,data);
	}
	fclose(ServerConfig);
	ShowPlayerDialog(playerid,dialog,DIALOG_STYLE_MSGBOX,"{00FF00}Server Config...",whole_data,"OK","Close");
	new str[100];
	format(str,sizeof(str),"%s(%d) Is Now Looking Into /Config.",GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	AdminChat(Gray,str);
	return 1;
}
CMD:uconfig(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 6) return SCM(playerid,red,"Error:You Can't Use This Command.");
	UpdateConfig();
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	return 1;
}
CMD:lockserver(playerid,params[])
{
	ServerInfo[Locked]=1;
	SCMTA(red,"Rcon: Server Locked");
	new INI:file = INI_Open("oAdmin/Config.ini");
	INI_WriteInt(file, "Locked",ServerInfo[Locked]);
	INI_Close(file);
	
	return 1;
}
CMD:unlockserver(playerid,params[])
{
	ServerInfo[Locked]=0;
	SCMTA(red,"Rcon: Server UN-Locked");
	new INI:file = INI_Open("oAdmin/Config.ini");
	INI_WriteInt(file, "Locked",ServerInfo[Locked]);
	INI_Close(file);
	return 1;
}
////////////////////////////////////////////////Events///////////////
CMD:event(playerid, params[])
{
	new str[300],event[121];
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(sscanf(params, "s", event)) return SCM(playerid, red, "USAGE: /event <Event Mode>");
	format(str,sizeof(str), "~r~%s ~g~Event~y~?!", event);
	GameTextForAll(str,5000,3);
	return 1;
}
CMD:evstart(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]== 1) return SCM(playerid,red,"Error: There are an Event now ,Please Wait Till It End.");
	EventInfo[Current]=1;
    new str[200];
    InEvent[playerid]=1;
    GetPlayerPos(playerid,eventx,eventy,eventz);
    format(str,sizeof(str), "{FF9455}An Event Have Been Started By Adminintstrator {FF0081}%s. {006AFF}Use {FF0000}/Joinevent {006AFF}To Join",GetName(playerid));
    SCMTA(-1,str);
    format(str,sizeof(str), "{FF9455}An Event Have Been Started By Adminintstrator {FF0081}%s.",GetName(playerid));
	Log("Events",str);
    return 1;
}
CMD:evlog(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] >= 3)
	{
	    new File:Events= fopen("oAdmin/Logs/Events.txt");
		fseek(Events, 0, seek_start);
		new data[100],whole_data[500];
		while(fread(Events,data))
		{
			strcat(whole_data,data);
		}
		fclose(Events);
		if(isnull(whole_data)) return SendClientMessage(playerid,red,"Events.txt is empty ");
		ShowPlayerDialog(playerid,dialog,DIALOG_STYLE_MSGBOX,"{00FF00}Events:",whole_data,"OK","Close");
		new str[100];
		format(str,sizeof(str),"%s(%d) Is Now Looking Into /evlog.",GetName(playerid),playerid);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		AdminChat(Gray,str);
	}else SCM(playerid,red,"Error:You Can't Use This Command.");
	return 1;
}
CMD:cevlog(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error: You Can't Use This Command.");
	new str[233];
	Clear("Events");
	SCM(playerid,Green,"Events Log Cleared.");
	format(str,sizeof(str),"[Admin]:%s(%d) Cleared Events Log",GetName(playerid),playerid);
	SCMTA(Gray,str);
	AdminChat(Gray,str);
	format(str,sizeof(str), "Admin: %s[%d] Cleared Events Log. /cevlog", GetName(playerid),playerid);
	IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	return 1;
}
CMD:evlock(playerid,params[])
{
	new str[250];
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Locked]== 1) return SCM(playerid,red,"Error: Event Is Already Closed");
    if(EventInfo[Current]== 0) return SCM(playerid,red,"Error: There is no event in the server now.");
    EventInfo[Locked]=1;
    SCMTA(-1,"{FF0000}[Event]{BF339A}The Event Will be Start Shortly");
	format(str,sizeof(str),"Event Locked By %s",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evunlock(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Locked]== 0) return SCM(playerid,red,"Error: Event Is Not Locked");
    if(EventInfo[Current]== 0) return SCM(playerid,red,"Error: There is no event in the server now.");
    EventInfo[Locked]=1;
    SCMTA(-1,"{FF0000}[Event]{BF339A}The Event Will be Start Shortly");
    new str[250];
    format(str,sizeof(str),"Event Un-Locked By %s",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evblock(playerid,params[])
{
	new reason[30],target,str[111];
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid,red,"Error: There is no events for now.");
    if(sscanf(params, "us[30]", target,reason)) return SCM(playerid, red, "USAGE: /evblock <PlayerID> <Reason>");
	if(EventBlock[target]==1) return SCM(playerid,red,"Error: This Player Is Already Blocked From This Event.");
    EventBlock[target]=1;
    if(InEvent[target]==1) return SpawnPlayer(target);
    format(str,sizeof(str),"You Are Blocked From This Event | Reason :{A30000} %s",reason);
    SCM(target,red,str);
    format(str,sizeof(str),"Admin:{452820}%s Blocked Player %s From The Event | Reason: %s",GetName(playerid),GetName(target),reason);
	Log("Events",str);
	AdminChat(-1,str);
    return 1;
}
CMD:evunblock(playerid,params[])
{
	new target,str[111];
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid,red,"Error: There is no events for now.");
    if(sscanf(params, "u", target)) return SCM(playerid, red, "USAGE: /evblock <PlayerID>");
	if(EventBlock[target]==0) return SCM(playerid,red,"Error: This Player Is Not Blocked From This Event.");
    EventBlock[target]=0;
    format(str,sizeof(str),"Admin: %s Has Un-Blocked You From This Event | /joinevent",GetName(playerid));
    SCM(target,red,str);
    format(str,sizeof(str),"{D4FF00}Admin:{EB3D94}%s Has Un-Blocked %s From The Event.",GetName(playerid),GetName(target));
    Log("Events",str);
    AdminChat(-1,str);
    return 1;
}
CMD:joinevent(playerid,params[])
{
	new str[120];
	if(EventInfo[Current]==0) 	return SCM(playerid,red,"Error: There is no events for now.");
	if(EventBlock[playerid]==1) return SCM(playerid,red,"Error: You Are Blocked From This Event.");
	if(InEvent[playerid]==1) 	return SCM(playerid,red,"Error: You Already Into The Event.");
	if(EventInfo[Locked]==1)	return SCM(playerid,red,"Error: Event Started, /joinevent disabled.");
    format(str,sizeof(str),"{4596FF}%s(%d) has joined the event.",GetName(playerid),playerid);
	AdminChat(-1,str);
	Log("Events",str);
	SetPlayerPos(playerid,eventx,eventy,eventz);
	TogglePlayerControllable(playerid,0);
	InEvent[playerid] = 1;
	return 1;
}
CMD:endevent(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
	new winner[64];
	if (sscanf(params, "S(No Winners)[64]", winner))
		{
			return 1;
		}
    EventInfo[Locked] = 0;
	EventInfo[Current] = 0;
    for(new i = 0; i < MAX_PLAYERS; i ++)
    {
		if(InEvent[i]==1)return SpawnPlayer(i);
		if(EventBlock[i]==1) return EventBlock[1]=0;
	}
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
	    SetVehicleToRespawn(i);
	}
	new str[122];
	format(str,sizeof(str),"Event Has End | Winner: %s.",winner);
	Log("Events",str);
	SCMTA(0xFF69F0FF,str);
	return 1;
}
CMD:evgivegun(playerid,params[])
{
	new id;
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
	if(sscanf(params, "i", id)) return SCM(playerid, red, "USAGE: /evgivegun <WeaponID>");
    for(new i = 0; i < MAX_PLAYERS; i ++)
    if(InEvent[i]==1)
        {
            new str[200];
            format(str,sizeof(str),"Event: Event Admin has gave you Weapon ID : %d ",id);
            GivePlayerWeapon(i,id,99999);
			SCM(i,0xEBFF87FF,str);
		}
	new str[250];
	format(str,sizeof(str),"Admin %s gived all player in the event Weapon ID : %d",GetName(playerid),id);
	Log("Events",str);
	return 1;
}
CMD:evpack(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
    if(InEvent[i]==1)
        {
            GivePack(i);
			SCM(i,0xEBFF87FF,"Event: Event Admin has gave you Weapons Pack :(Ktana, M4, Deagle, Sawn-Off, UZI, Sniper)");
		}
	new str[250];
    format(str,sizeof(str),"Admin %s gived players in the event the Weapons Pack",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evderby(playerid,params[])
{
    new Vehmodle,count;
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(EventInfo[Locked]==0)	return SCM(playerid,red,"Error: Event Should be Locked To Use This Command.");
    if(sscanf(params, "i", Vehmodle)) return SCM(playerid, red, "USAGE: /evderby <VehicleModle>");
	for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
			count++;
			new Float:tx, Float:ty;
			GetRandomPointInCircle(eventx,eventy,50,tx,ty);
			VehID[count] = AddStaticVehicle(Vehmodle,tx,ty,eventz,0,0,0);
			SetPlayerPos(i,tx,ty,eventz);
			TogglePlayerControllable(i,0);
			SetCameraBehindPlayer(i);
			new Random = random(sizeof(evderbyAngle));
    		SetPlayerFacingAngle(playerid, evderbyAngle[Random][0]);
			EvDerby[i] = 1;
			PutPlayerInVehicle(playerid,VehID[count],0);
		}
    new str[250];
    format(str,sizeof(str),"Derby Event hosted by %s",GetName(playerid));
	Log("Events",str);
	SCMTA(0xEBFF87FF,"Derby Event Started!!");
	return 1;
}
CMD:evunfreeze(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(EventInfo[Locked]==0)	return SCM(playerid,red,"Error: Event Should be Locked To Use This Command.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
		    TogglePlayerControllable(i,1);
		    SCM(i,-1,"{FDBDFF}Event admin has unfreeze You to start the EVENT!!");
		}
    new str[250];
    format(str,sizeof(str),"Admin %s unfreezed all players in events",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evfreeze(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(EventInfo[Locked]==0)	return SCM(playerid,red,"Error: Event Should be Locked To Use This Command.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
		    TogglePlayerControllable(i,0);
		    SCM(i,-1,"{FDBDFF}Event admin has unfreeze You to start the EVENT!!");
		}
    new str[250];
	format(str,sizeof(str),"Admin %s freezed all players in event",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:eveject(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1 && IsPlayerInAnyVehicle(i))
	 	{
			RemovePlayerFromVehicle(i);
		    SCM(i,-1,"{FDBDFF}Event admin has ejected all from his vehicles !!");
		}
	new str[250];
	format(str,sizeof(str),"Admin %s ejected all players in event",GetName(playerid));
	Log("Events",str);
	return 1;
}
    
CMD:evcar(playerid,params[])
{
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    new vid;
    if(sscanf(params, "i", vid)) return SCM(playerid, red, "USAGE: /evcar <VehicleModle>");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    new Float:x, Float:y, Float:z, Float:f;
	 	    GetPlayerPos(i,Float:x,y,z);
			GetPlayerFacingAngle(i,f);
		    GiveVeh(i,vid,x,y,z,f);
		    SCM(i,-1,"{FDBDFF}Event admin has gave You a Vehicle for  the Event!!");
		}
    new str[250];
    format(str,sizeof(str),"Admin %s Gived vehicle ID : %d to all players in events",GetName(playerid),vid);
	Log("Events",str);
	return 1;
}
CMD:evdisarm(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    ResetPlayerWeapons(i);
		    SCM(i,-1,"{FF0000}[Event]{BF339A}Event Admin Have Disarmed All Event Players.");
		}
	new str[250];
    format(str,sizeof(str),"Admin %s disarmed all players in events",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evheal(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    SetPlayerHealth(i,100);
		    SCM(i,-1,"{FF0000}[Event]{BF339A}Event Admin Have Healed All Event Players.");
		}
    new str[250];
    format(str,sizeof(str),"Admin %s Healed all players in events",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evsethp(playerid,params[])
{
	new hp;
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(sscanf(params, "i", hp)) return SCM(playerid, red, "USAGE: /sethp <HP>");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    SetPlayerHealth(i,hp);
	 	    new stri[250];
	 	    format(stri,sizeof(stri),"{FF0000}[Event]{BF339A}Event Admin Have Set All Event Players HP = %d",hp);
		    SCM(i,-1,stri);
		}
    new str[250];
    format(str,sizeof(str),"Admin %s set all players health = %d",GetName(playerid),hp);
	Log("Events",str);
	return 1;
}
CMD:evarmour(playerid,params[])
{
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    SetPlayerArmour(i,100);
		    SCM(i,-1,"{FF0000}[Event]{BF339A}Event Admin Have Armoured All Event Players.");
		}
    new str[250];
    format(str,sizeof(str),"Admin %s armoured all players in events",GetName(playerid));
	Log("Events",str);
	return 1;
}
CMD:evsetarmour(playerid,params[])
{
	new armour;
	if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(sscanf(params, "i", armour)) return SCM(playerid, red, "USAGE: /setarmour <Armour>");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	 	    SetPlayerArmour(i,armour);
	 	    new stri[250];
	 	    format(stri,sizeof(stri),"{FF0000}[Event]{BF339A}Event Admin Have Set All Event Players Armour = %d",armour);
		    SCM(i,-1,stri);
		}
    new str[250];
    format(str,sizeof(str),"Admin %s set all players armour = %d",GetName(playerid),armour);
	Log("Events",str);
	return 1;
}
CMD:evann(playerid,params[])
{
	new msg[40];
    if(pInfo[playerid][AdminLevel] < 4) return SCM(playerid,red,"Error:You Can't Use This Command.");
    if(EventInfo[Current]==0) return SCM(playerid, red, "Error: There is no events for now.");
    if(sscanf(params, "s[40]", msg)) return SCM(playerid, red, "USAGE: /evann [Text]");
    for(new i = 0; i < MAX_PLAYERS; i ++)
 	if(InEvent[i]==1)
	 	{
	   		GameTextForPlayer(i,msg,5000,3);
		}
	new str[250];
    format(str,sizeof(str),"Admin %s used /evann : %s",GetName(playerid),msg);
	Log("Events",str);
	return 1;
}
CMD:ev(playerid,params[])
{
	new msg[40];
    if(sscanf(params, "s[40]", msg)) return SCM(playerid, red, "USAGE: /ev [msg]");
    if(InEvent[playerid]==1)
	 	{
	 	    new str[200];
			format(str,sizeof(str),"{FFC4B3}Event Chat: {FFDA99}%s(%d) :{CBA8FF} %s",GetName(playerid),playerid,msg);
			Log("Events",str);
			EvChat(-1,str);
		}
		else
		{
			SCM(playerid,red,"You Have To Be In Event To Use This Command To Chat With Event Players.");
		}
	return 1;
}
//Functions
GivePack(playerid)
{
    ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,8,1);      //Katana
	GivePlayerWeapon(playerid,31,99999); //M4
	GivePlayerWeapon(playerid,24,99999); //Deagle
	GivePlayerWeapon(playerid,26,99999); //Sawn-Off
	GivePlayerWeapon(playerid,28,99999); //Micro-SMG
	GivePlayerWeapon(playerid,34,99999); //Sniper
	return 1;
}
Log(filename[],text[])
{
	new File:oAdmin;
	new path[250], string[250], year,month,day,hour,minute,second;
	getdate(year,month,day);
	gettime(hour,minute,second);
	format(path,sizeof(path),"oAdmin/Logs/%s.txt",filename);
	oAdmin = fopen(path,io_append);
	format(string,sizeof(string),"[%d.%d.%d %d:%d:%d] %s\r\n",year,month,day,hour,minute,second,text);
	fwrite(oAdmin,string);
	fclose(oAdmin);
	return 1;
}
Clear(filename[])
{
	new path[222];
	format(path,sizeof(path),"oAdmin/Logs/%s.txt",filename);
	new File:fi= fopen(path,io_write);
	fclose(fi);
	return 1;
}
SaveStats(playerid)
{
	new INI:file = INI_Open(UserPath(playerid));
	INI_SetTag(file, "PlayerData");
	INI_WriteInt(file, "AdminLevel", pInfo[playerid][AdminLevel]);
	INI_WriteInt(file, "ReadPms", pInfo[playerid][ReadPms]);
	INI_WriteInt(file, "ReadCmds", pInfo[playerid][ReadCmds]);
	INI_WriteInt(file, "VIPLevel", pInfo[playerid][VIPLevel]);
	INI_WriteInt(file, "Money", pInfo[playerid][Money]);
	INI_WriteInt(file, "Score", pInfo[playerid][Score]);
	INI_WriteInt(file, "Kills", pInfo[playerid][Kills]);
	INI_WriteInt(file, "Deaths", pInfo[playerid][Deaths]);
	INI_WriteInt(file, "PremMute", pInfo[playerid][PremMute]);
	INI_WriteInt(file, "Banned", pInfo[playerid][Banned]);
	INI_WriteInt(file, "BannedTimes", pInfo[playerid][BannedTimes]);
	INI_WriteString(file, "Reason", pInfo[playerid][Reason]);
	INI_Close(file);
}
UserPath(playerid) {
    new
        str[36], 
        name[MAX_PLAYER_NAME]; 
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), USER_PATH, name); 
    return str;
}
GetName(playerid) {
    new szName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, szName, sizeof(szName));
    return szName;
}

AdminChat(COLOR,message[])
{
	for (new i, j = GetPlayerPoolSize(); i <= j; i++)
	if(pInfo[i][AdminLevel]<= 1 || IsPlayerAdmin(i))return SCM(i,COLOR,message);
    return 1;
}
EvChat(color,message[])
{
    for (new i, j = GetPlayerPoolSize(); i <= j; i++)
    if(InEvent[i]==1)
    {
        SCM(i,color,message);
	}
	return 1;
}
GiveVeh(playerid,vehiclemodle,Float:x,Float:y,Float:z,Float:f)
{
    new car = AddStaticVehicle(vehiclemodle,x,y,z,f,0,0);
	PutPlayerInVehicle(playerid,car,0);
	return 1;
}
UpdateConfig()
{
	new INI:file = INI_Open("oAdmin/Config.ini");
	INI_SetTag(file, "Server Info:");
	INI_WriteInt(file, "MaxPing", ServerInfo[MaxPing]);
	INI_WriteInt(file, "ReadPMs", ServerInfo[ReadPMs]);
	INI_WriteInt(file, "ReadCmds", ServerInfo[ReadCmds]);
	INI_WriteInt(file, "MaxAdminLevel", ServerInfo[MaxAdminLevel]);
	INI_WriteInt(file, "AdminSkin", ServerInfo[AdminSkin]);
	INI_WriteInt(file, "Locked", ServerInfo[Locked]);
	INI_Close(file);
	return 1;
}

/*UpdateConfig()
{
	new file[256];
	format(file,sizeof(file),"oAdmin/Config.ini");
	if(!dini_Exists(file))
	{
		dini_Create(file);
		dini_IntSet(file,"MaxPing",1200);
		dini_IntSet(file,"ReadPMs",1);
		dini_IntSet(file,"ReadCmds",1);
		dini_IntSet(file,"MaxAdminLevel",5);
		dini_IntSet(file,"AdminSkin",217);
		dini_IntSet(file,"Locked",0);
		print("\n\n >Configuration File Successfully Created");
		ServerInfo[MaxPing] = dini_Int(file,"MaxPing");
		ServerInfo[ReadPMs] = dini_Int(file,"ReadPMs");
		ServerInfo[ReadCmds] = dini_Int(file,"ReadCmds");
		ServerInfo[MaxAdminLevel] = dini_Int(file,"MaxAdminLevel");
		ServerInfo[AdminSkin] = dini_Int(file,"AdminSkin");
		ServerInfo[Locked] = dini_Int(file,"Locked");
		print("\n >Configuration Settings Loaded From File");
	}
	else if(dini_Exists(file))
	{
		ServerInfo[MaxPing] = dini_Int(file,"MaxPing");
		ServerInfo[ReadPMs] = dini_Int(file,"ReadPMs");
		ServerInfo[ReadCmds] = dini_Int(file,"ReadCmds");
		ServerInfo[MaxAdminLevel] = dini_Int(file,"MaxAdminLevel");
		ServerInfo[AdminSkin] = dini_Int(file,"AdminSkin");
		ServerInfo[Locked] = dini_Int(file,"Locked");
		print("\n >Configuration Settings Loaded From File");
	}
}*/

//////////////////////////IRC Connect//////////////////////////////////////////
public IRC_OnConnect(botid, ip[], port)
{
	printf("*** IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);
	// Join the channel
	if(botid == 1 || botid == 2)
	{
		IRC_JoinChannel(botid, IRC_CHANNEL);
		IRC_AddToGroup(groupID, botid);
	}
	if(botid == 3)
	{
	    IRC_JoinChannel(botid, IRC_AdminChannel);
	    IRC_AddToGroup(GAdmins, botid);
	}
	return 1;
}
public IRC_OnDisconnect(botid, ip[], port, reason[])
{
	printf("*** IRC_OnDisconnect: Bot ID %d disconnected from %s:%d (%s)", botid, ip, port, reason);
	// Remove the bot from the group
	IRC_RemoveFromGroup(groupID, botid);
	return 1;
}
public IRC_OnConnectAttempt(botid, ip[], port)
{
	printf("*** IRC_OnConnectAttempt: Bot ID %d attempting to connect to %s:%d...", botid, ip, port);
	return 1;
}
public IRC_OnConnectAttemptFail(botid, ip[], port, reason[])
{
	printf("*** IRC_OnConnectAttemptFail: Bot ID %d failed to connect to %s:%d (%s)", botid, ip, port, reason);
	return 1;
}
public IRC_OnJoinChannel(botid, channel[])
{
	printf("*** IRC_OnJoinChannel: Bot ID %d joined channel %s", botid, channel);
	return 1;
}
public IRC_OnLeaveChannel(botid, channel[], message[])
{
	printf("*** IRC_OnLeaveChannel: Bot ID %d left channel %s (%s)", botid, channel, message);
	return 1;
}
public IRC_OnInvitedToChannel(botid, channel[], invitinguser[], invitinghost[])
{
	printf("*** IRC_OnInvitedToChannel: Bot ID %d invited to channel %s by %s (%s)", botid, channel, invitinguser, invitinghost);
	return 1;
}
public IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnKickedFromChannel: Bot ID %d kicked by %s (%s) from channel %s (%s)", botid, oppeduser, oppedhost, channel, message);
	IRC_JoinChannel(botid, channel);
	return 1;
}
public IRC_OnUserDisconnect(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserDisconnect (Bot ID %d): User %s (%s) disconnected (%s)", botid, user, host, message);
	return 1;
}

public IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
	printf("*** IRC_OnUserJoinChannel (Bot ID %d): User %s (%s) joined channel %s", botid, user, host, channel);
	return 1;
}

public IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[])
{
	printf("*** IRC_OnUserLeaveChannel (Bot ID %d): User %s (%s) left channel %s (%s)", botid, user, host, channel, message);
	return 1;
}

public IRC_OnUserKickedFromChannel(botid, channel[], kickeduser[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnUserKickedFromChannel (Bot ID %d): User %s kicked by %s (%s) from channel %s (%s)", botid, kickeduser, oppeduser, oppedhost, channel, message);
}

public IRC_OnUserNickChange(botid, oldnick[], newnick[], host[])
{
	printf("*** IRC_OnUserNickChange (Bot ID %d): User %s (%s) changed his/her nick to %s", botid, oldnick, host, newnick);
	return 1;
}

public IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[])
{
	printf("*** IRC_OnUserSetChannelMode (Bot ID %d): User %s (%s) on %s set mode: %s", botid, user, host, channel, mode);
	return 1;
}

public IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[])
{
	printf("*** IRC_OnUserSetChannelTopic (Bot ID %d): User %s (%s) on %s set topic: %s", botid, user, host, channel, topic);
	return 1;
}

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	printf("*** IRC_OnUserSay (Bot ID %d): User %s (%s) sent message to %s: %s", botid, user, host, recipient, message);
	// Someone sent the bot a private message
	if (!strcmp(recipient, BOT_1_NICKNAME) || !strcmp(recipient, BOT_2_NICKNAME))
	{
		IRC_Say(botid, user, "You sent me a PM!");
	}
		else if(!strcmp(recipient, BOT_3_NICKNAME ))
	{
	    IRC_Say(botid, user, "You sent me a PM!");
	}
	return 1;
}
public IRC_OnUserNotice(botid, recipient[], user[], host[], message[])
{
	printf("*** IRC_OnUserNotice (Bot ID %d): User %s (%s) sent notice to %s: %s", botid, user, host, recipient, message);
	// Someone sent the bot a notice (probably a network service)
 	if (!strcmp(recipient, BOT_1_NICKNAME) || !strcmp(recipient, BOT_2_NICKNAME))
	{
		IRC_Notice(botid, user, "You sent me a notice!");
	}
		else if(!strcmp(recipient, BOT_3_NICKNAME ))
	{
	    IRC_Notice(botid, user, "You sent me a notice!");
	}

	return 1;
}

public IRC_OnUserRequestCTCP(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserRequestCTCP (Bot ID %d): User %s (%s) sent CTCP request: %s", botid, user, host, message);
	// Someone sent a CTCP VERSION request
	if (!strcmp(message, "VERSION"))
	{
		IRC_ReplyCTCP(botid, user, "VERSION SA-MP IRC Plugin v" #PLUGIN_VERSION "");
	}
	return 1;
}

public IRC_OnUserReplyCTCP(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserReplyCTCP (Bot ID %d): User %s (%s) sent CTCP reply: %s", botid, user, host, message);
	return 1;
}

public IRC_OnReceiveNumeric(botid, numeric, message[])
{
	// Check if the numeric is an error defined by RFC 1459/2812
	if (numeric < 400 && numeric <= 599)
	{
		const ERR_NICKNAMEINUSE = 433;
		if (numeric == ERR_NICKNAMEINUSE)
		{
			// Check if the nickname is already in use
			if (botid == botIDs[0])
			{
				IRC_ChangeNick(botid, BOT_1_NICKNAME);
			}
			else if (botid == botIDs[1])
			{
				IRC_ChangeNick(botid, BOT_2_NICKNAME);
			}
			else if (botid == botIDs[2])
			{
				IRC_ChangeNick(botid, BOT_3_NICKNAME);
			}
		}
		printf("*** IRC_OnReceiveNumeric (Bot ID %d): %d (%s)", botid, numeric, message);
	}
	return 1;
}
public IRC_OnReceiveRaw(botid, message[])
{
	new File:file;
	if (!fexist("oAdmin/Logs/irc_log.txt"))
	{
		file = fopen("oAdmin/Logs/irc_log.txt", io_write);
	}
	else
	{
		file = fopen("oAdmin/Logs/irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}
//////////////////////////////////////IRC Commands//////////////////
IRCCMD:msg(botid, channel[], user[], host[], params[])
{
if (IRC_IsOwner(botid, channel, user))
	{
	    if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** Owner %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			IRC_GroupSay(GAdmins, channel, msg);
			format(msg, sizeof(msg), "*** Owner %s on IRC: %s", user, params);
			SendClientMessageToAll(0xFF0080FF, msg);
		}
	}
    else if (IRC_IsAdmin(botid, channel, user))
	{
	    if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** Management %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			IRC_GroupSay(GAdmins, channel, msg);
			format(msg, sizeof(msg), "*** Management %s on IRC: %s", user, params);
			SendClientMessageToAll(0xFF0080FF, msg);
		}
	}
	else if (IRC_IsOp(botid, channel, user)) // back
	{
	    if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** Admin %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			IRC_GroupSay(GAdmins, channel, msg);
			format(msg, sizeof(msg), "*** Admin %s on IRC: %s", user, params);
			SendClientMessageToAll(0xFFB400FF, msg);
		}
	}
	else if (IRC_IsHalfop(botid, channel, user)) // back
	{
	    if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** Moderator %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			IRC_GroupSay(GAdmins, channel, msg);
			format(msg, sizeof(msg), "*** Moderator %s on IRC: %s", user, params);
			SendClientMessageToAll(0x09F7DFC8, msg);
		}
	}
	else if (IRC_IsVoice(botid, channel, user))
	{
		// Check if the user entered any text
		if (!isnull(params))
		{
			new msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02Guest %s on IRC: %s", user, params);
			IRC_GroupSay(groupID, channel, msg);
			IRC_GroupSay(GAdmins, channel, msg);
			format(msg, sizeof(msg), "Guest %s on IRC: %s", user, params);
			SendClientMessageToAll(0xFFB400FF, msg);
		}
	}
return 1;
}
IRCCMD:setlevel(botid, channel[], user[], host[], params[])
{
    if(IRC_IsAdmin(botid, channel, user))
    {
		new target;
		new lvl;
		if (sscanf(params, "ui",target,lvl))
			return IRC_GroupSay(groupID,channel, "4USAGE:setlevel <PlayerID> <Level>");
		if (!IsPlayerConnected(target))
			return IRC_GroupSay(groupID,channel, "4ERROR: Player isn't Connected.");
		if(pInfo[target][AdminLevel] == lvl)
			return IRC_GroupSay(groupID,channel, "4Error: This player already in this lvl");
		pInfo[target][AdminLevel] = lvl;
		// Save the level
        new INI:file = INI_Open(UserPath(target));
        INI_SetTag(file, "PlayerData");
        INI_WriteInt(file, "AdminLevel",lvl);
        INI_Close(file);
		new str[200];
		GameTextForPlayer(target,"Prometed!!",5000,4);
		format(str,sizeof(str),"Server Adminitstrator On IRC %s Has Promoted you to Admin Level %d | Congrats",user,lvl);
		SCM(target,Green,str);
		format(str,sizeof(str),"Admin %s On IRC has Set %s[%d]'s Admin Level to %d | Congrats",user,GetName(target),target,lvl);
		SCMTA(Green,str);
		format(str,sizeof(str), "8,2Adminintstrator On IRC %s Has Promoted %s[%d] to Admin Level %d | Congrats",user,GetName(target),target,lvl);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	} else IRC_GroupSay(groupID, channel, "4You Can't Use This Command.");
	return 1;
}
IRCCMD:clearchat(botid, channel[], user[], host[], params[])
{
	if(IRC_IsHalfop(botid, channel, user)) return IRC_GroupSay(GAdmins,channel, "You Cant Use This Command");
 	{
        for( new i = 0; i <= 100; i ++ ) SendClientMessageToAll(-1, "" );
        SendClientMessageToAll(0xD2691EAA, "Chat has Been Cleared by IRC Admin");
        new str[123];
        format(str,sizeof(str), "8,2Adminintstrator On IRC %s Has Cleared The Chat",user);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
  	}
   	return 1;
}
IRCCMD:admin(botid, channel[], user[], host[], params[])
{
        if (IRC_IsHalfop(botid, channel, user))
        {

                if (!isnull(params))
                {
                        new msg[128];

                        format(msg, sizeof(msg), "14Admin on IRC: %s", params);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "Admin on IRC: %s", params);
                        SendClientMessageToAll(0x10F441AA, msg);
                }
        }
        return 1;
}
IRCCMD:weapscheck(botid, channel[], user[], host[], params[])
{
    if (IRC_IsHalfop(botid, channel, user))
    {
        new playerid;
        if (sscanf(params, "dS", playerid))
        {
            return 1;
        }
        if (IsPlayerConnected(playerid))
        {
            new msg[128], szWeaponName[ 20 ];
            new weapons[13][2];
            format(msg, sizeof(msg), "03-Server- Player Weapons Used: ");
            for (new i = 0; i < 13; i++)
            {
                GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]); //added ', i' as you need the slot argument too - this wasn't here before
                GetWeaponName( weapons[ i ][ 0 ], szWeaponName, sizeof( szWeaponName ));
                format( msg, sizeof( msg ), "%s%s, ", msg, szWeaponName );
            }
            strdel( msg, strlen( msg ) - 2, strlen( msg )); //remove the last comma and space
            IRC_GroupSay(groupID, channel, msg);
        }
    }
    return 1;
}
IRCCMD:rcon(botid, channel[], user[], host[], params[])
{
	if (IRC_IsOwner(botid, channel, user))
	{
		if (!isnull(params))
		{
			new msg[128];
			format(msg, sizeof(msg), "RCON command %s has been executed.", params);
			IRC_GroupSay(groupID, channel, msg);
			SendRconCommand(params);
		}
	}
	return 1;
}
IRCCMD:explode(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        new player1;
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], pname[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, pname, sizeof(pname));
                        format(msg, sizeof(msg), "-Server- %s has been exploded by Admin %s on IRC for reason: %s", pname, user, reason);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "-Server- %s has been exploded by Admin %s on IRC for reason: %s", pname, user, reason);
                        SendClientMessageToAll(0x09F7DFC8, msg);
                        new Float:x, Float:y, Float:z;
                        GetPlayerPos(player1,x,y,z);
                        CreateExplosion(x, y, z, 0, 10.0);
                }
        }
        return 1;
}
IRCCMD:freeze(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], pname[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, pname, sizeof(pname));
                        format(msg, sizeof(msg), "-Server- %s has been Frozen by Admin %s on IRC for reason: %s", pname, user, reason);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "-Server- %s has been Frozen by Admin %s on IRC for reason: %s", pname, user, reason);
                        SendClientMessageToAll(0xFF0000C8, msg);
                        //Freeze.
                        TogglePlayerControllable(playerid, 0);
                }
        }
        return 1;
}

IRCCMD:unfreeze(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], pname[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, pname, sizeof(pname));
                        format(msg, sizeof(msg), "-Server- %s has been Unfrozen by Admin %s on IRC for reason: %s", pname, user, reason);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "-Server- %s has been Unfrozen by Admin %s on IRC for reason: %s", pname, user, reason);
                        SendClientMessageToAll(0x09F7DFC8, msg);
                        TogglePlayerControllable(playerid, 1);
                }
        }
        return 1;
}


IRCCMD:getid(botid, channel[], user[], host[], params[]) {
	if(isnull(params)) return IRC_GroupSay(groupID,IRC_CHANNEL,"3Usage: !getid [part of nick]");
	new found, string[128], playername[MAX_PLAYER_NAME];
	format(string,sizeof(string),"3Searched for: \"%s\"",params);
 	IRC_GroupSay(groupID,IRC_CHANNEL,string);
	for(new i=0; i <= MAX_PLAYERS; i++){
		if(IsPlayerConnected(i)){
	  		GetPlayerName(i, playername, MAX_PLAYER_NAME);
			new namelen = strlen(playername);
			new bool:searched=false;
	    	for(new pos=0; pos <= namelen; pos++){
				if(searched != true){
					if(strfind(playername,params,true) == pos){
		                found++;
						format(string,sizeof(string),"10>> Player whose name is %s 10has the ID: %d",playername,i);
						IRC_GroupSay(groupID,IRC_CHANNEL,string);
						searched = true;}}}}}
	if(found == 0) IRC_GroupSay(groupID,IRC_CHANNEL,"4No players have this name ");
	return 1;}

IRCCMD:credits(conn, channel[], user[], message[])
{
   #pragma unused message
   IRC_Say(conn, channel,"06Write your credits");
}

IRCCMD:warn(botid, channel[], user[], host[], params[])
{
	new playerid, reason[64];
	//Playerid
	if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
	{
		return 1;
	}
    if (IRC_IsHalfop(botid, channel, user))
	{
		if(IsPlayerConnected(playerid))
		{
			new msg[128], pname[MAX_PLAYER_NAME];
			GetPlayerName(playerid, pname, sizeof(pname));
			format(msg, sizeof(msg), "-Server- %s has been Warned by Admin %s on IRC for reason: %s", pname, user, reason);
			IRC_GroupSay(groupID, channel, msg);
			format(msg, sizeof(msg), "-Server- %s has been Warned by Admin %s on IRC for reason: %s", pname, user, reason);
			SendClientMessageToAll(0xFF0080FF, msg);
			//Simple warn by NoahF. :)
		}
	}
	return 1;
}
IRCCMD:giveinfernus(botid, channel[], user[], host[], params[])
{
	new playerid, reason[64];
	new Float:x;
	new Float:y;
	new Float:z;
	//Playerid
	if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
	if (sscanf(params, "d", playerid)) return IRC_GroupSay(groupID, channel, "Usage: !giveinfernus playerid");
    if (IRC_IsHalfop(botid, channel, user))
	{
		if(IsPlayerConnected(playerid))
		{
			new msg[128], pname[MAX_PLAYER_NAME];
			GetPlayerName(playerid, pname, sizeof(pname));
			GetPlayerPos(playerid, x, y, z);
			format(msg, sizeof(msg), "-Server- %s has been given a Infernus by Admin %s on IRC for reason: %s", pname, user, reason);
			IRC_GroupSay(groupID, channel, msg);
			format(msg, sizeof(msg), "-Server- %s has been given a Infernus by Admin %s on IRC for reason: %s", pname, user, reason);
			SendClientMessageToAll(0xFF0080FF, msg);
			CreateVehicle(411, x, y, z, 82.2873, 6, 3, 3000); //Change any of these if you want, don't forget to change the SendClientMessage if you change the car! :P
		}
	}
	return 1;
}
IRCCMD:disarm(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "-Server- %s has been Disarmed by Admin %s on IRC | Reason: %s", name, user, reason);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "-Server- %s has been Disarmed by Admin %s on IRC | Reason: %s", name, user, reason);
                        SendClientMessageToAll(0x09F7DFC8, msg);
                        ResetPlayerWeapons(playerid);
                }
        }
        return 1;
}

IRCCMD:spawn(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "-Server- %s Has been Spawned by Admin %s on IRC | Reason: %s", name, user, reason);
                        IRC_GroupSay(groupID, channel, msg);
                        format(msg, sizeof(msg), "-Server- %s Has been Spawned by Admin %s on IRC | Reason: %s", name, user, reason);
                        SendClientMessageToAll(0xD2691EAA, msg);
                        SpawnPlayer(playerid);
                }
        }
        return 1;
}

IRCCMD:playerlist( botid, channel[], user[], host[], params[] )
{
    new tempstr[128], string[200], count, name[24];
    for( new i ,slots = GetMaxPlayers(); i < slots; i++ )
    {
        if(IsPlayerConnected(i))
        {
            count++;
            GetPlayerName(i, name, sizeof(name));
            format(tempstr, sizeof(tempstr), "%s , %s", tempstr, name);
        }
    }
    if(count)
    {
        format(string, sizeof(string), "12-Server- Connected Players [%d/%d] :- 9 %s", count, GetMaxPlayers(), tempstr);
        IRC_Say(botid, channel, string);
        }
        else IRC_Say(botid, channel, "4No players are now online.");
    return 1;
}
IRCCMD:an( botid, channel[], user[], host[], params[])
{
        if(IRC_IsHalfop(botid,channel,user))
        {
            new text[128];
            if(sscanf(params,"s[120]",text)) return IRC_GroupNotice(groupID,user, "SX-Usage: !ann <text>");
            if( 0 > strlen(text) > 140 ) return IRC_GroupNotice(groupID,user,"SX-ERROR Message Size Invalid");
            new str[150];
            GameTextForAll(text,7600,3);
            format(str,64,"02-Server- Admin (%s) Success Announced: %s",text);
            IRC_GroupSay(groupID,IRC_CHANNEL,str);
        }
        return 1;
}
IRCCMD:getinfo(botid, channel[], user[], host[], params[])
{
        new playerid, pIP[128], Float:health, Float:armour, Float:money, Float:score;

        if (sscanf(params, "d", playerid))
        {
                return 1;
        }
        if(IsPlayerConnected(playerid))
        {
                new msg[128], name[MAX_PLAYER_NAME];
                GetPlayerName(playerid, name, sizeof(name));
                GetPlayerIp(playerid, pIP, 128);
                GetPlayerHealth(playerid, health);
                GetPlayerArmour(playerid, armour);
                money = GetPlayerMoney(playerid);
				score = GetPlayerScore(playerid);
                new ping;
                ping = GetPlayerPing(playerid);
                format(msg, sizeof(msg), "-Server- [ADMIN SPEC] %s's info: PLAYER-IP: %s | PLAYER-Health: %d | PLAYER-Armour: %d |PLAYER-Money: %d | PLAYER-Score: %d | PLAYER-Ping: %d  ", name, pIP, floatround(health), floatround(armour),floatround(money),floatround(score), ping);
                IRC_GroupSay(groupID, channel, msg);
        }
        return 1;
}
IRCCMD:slap(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        new player1;

        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "-Server- %s has been Slapped by Admin %s on IRC | Reason: %s", name, user, reason);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        format(msg, sizeof(msg), "-Server- %s Has been Slapped by Admin %s on IRC | Reason: %s", name, user, reason);
                        SendClientMessageToAll(0xFF9900AA, msg);
                        GameTextForPlayer(playerid,"~y~SLAPPED!", 2000, 3);

                        new Float:Health;
                        new Float:x, Float:y, Float:z;
                        GetPlayerHealth(player1,Health);
                        SetPlayerHealth(player1,Health-25);
                        GetPlayerPos(player1,x,y,z);
                        SetPlayerPos(player1,x,y,z+7);
                        PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
                        PlayerPlaySound(player1,1190,0.0,0.0,0.0);
                }
        }
        return 1;
}

IRCCMD:respawncars(botid, channel[], user[], host[], params[])
{
        new string1[128], string2[128];

        if (IRC_IsOp(botid, channel, user))
        {
                for(new i = 1; i <= MAX_VEHICLES; i++)
                {
                        SetVehicleToRespawn(i);
                }
                format(string1, 128, "-Server- Admin %s has Respawned all vehicles", user);
                format(string2, 128, "-Server- Admin %s has Respawned all vehicles", user);

                IRC_GroupSay(groupID, IRC_CHANNEL, string1);
                SendClientMessageToAll(0xD2691EAA, string2);
        }
        return 1;
}
IRCCMD:unbanip(botid, channel[], user[], host[], params[])
{

	if(IRC_IsOp(botid,channel,user))
	{
		new cmd[128];
		format(cmd,sizeof cmd,"unbanip %s",params);
		SendRconCommand(cmd);
        IRC_GroupSay(groupID, IRC_CHANNEL,"02 03-Server- 8,2 IRC Unban IP : This IP Has Been IP Unbanned.");

	}
	else IRC_GroupSay(groupID, IRC_CHANNEL,"4Error: You must be Op to use this command.");
	return 1;
}
IRCCMD:healall(botid, channel[], user[], host[], params[]) {

	if(IRC_IsHalfop(botid, channel, user)) {

		IRC_GroupSay(groupID,IRC_CHANNEL, "3-Server- You have healed all the players (100.0 hp).");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerHealth(i,100.0);}}
		return GameTextForAll("~green~Free Health!", 2000, 3);
	} else return IRC_GroupSay(groupID,IRC_CHANNEL, "4ERROR: You must have Half OP to use this command");}

IRCCMD:armourall(botid, channel[], user[], host[], params[]) {

	if(IRC_IsHalfop(botid, channel, user)) {

		IRC_GroupSay(groupID,IRC_CHANNEL, "3-Server- You have given all the players an Armour of 100.0.");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerArmour(i,100.0);}}
		return GameTextForAll("~green~Free Armour!", 2000, 3);
	} else return IRC_GroupSay(groupID,IRC_CHANNEL, "4ERROR: You must have Half OP to use this command");}

IRCCMD:fuck(botid, channel[], user[], host[], params[])
{
	new playerid, reason[64];
	//Playerid
	if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
	{
		return 1;
	}

	if(IRC_IsHalfop(botid, channel, user))
	{

		if(IsPlayerConnected(playerid))
		{
			new msg[128], pname[MAX_PLAYER_NAME];
			GetPlayerName(playerid, pname, sizeof(pname));
			format(msg, sizeof(msg), "13-Server- %s has been Fucked up by Admin %s on IRC for reason: %s", pname, user, reason);
			IRC_GroupSay(groupID, IRC_CHANNEL, msg);
			format(msg, sizeof(msg), "-Server- %s has been Fucked up by Admin %s on IRC for reason: %s", pname, user, reason);
			SendClientMessageToAll(0xFF0000C8, msg);
			SetPlayerDrunkLevel(playerid, 50000);
			SetPlayerColor(playerid, 0xFF00FFC8);
			SetPlayerHealth(playerid, 0.2);
			ResetPlayerWeapons(playerid);
			GivePlayerMoney(playerid, -10000);
			SetPlayerSkin(playerid, 77);
		}
	}
	return 1;
}
IRCCMD:sexplode(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        new player1;
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], pname[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, pname, sizeof(pname));
                        format(msg, sizeof(msg), "4-Server- Admin %s You have Silently Exploded %s : Reason : %s", user, pname, reason);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        new Float:x, Float:y, Float:z;
                        GetPlayerPos(player1,x,y,z);
                        CreateExplosion(x, y, z, 0, 10.0);
                }
        }
        return 1;
}
IRCCMD:heal(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "3-Server- Admin %s Has Healed %s", user, name);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        format(msg, sizeof(msg), "-Server- Admin %s Has Healed You", user, name);
                        SendClientMessage(playerid,0xD2691EAA, msg);
                        SetPlayerHealth(playerid,100);
                }
        }
        return 1;
}
IRCCMD:force(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "3-Server- Admin %s Has Forced %s to Class selection", user, name);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        format(msg, sizeof(msg), "-Server- Admin %s Has Forced You to Class selection", user, name);
                        SendClientMessage(playerid,0xFF9900AA, msg);
                        format(msg, sizeof(msg), "-Server- Admin %s Forced %s to Class selection (IRC)", user, name);
                        SendClientMessageToAll(0xD2691EAA, msg);
           		        SetPlayerHealth(playerid,0);
		                ForceClassSelection(playerid);
                }
        }
        return 1;
}
IRCCMD:armour(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsHalfop(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "13-Server- Admin %s Has given Armour to %s", user, name);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        format(msg, sizeof(msg), "-Server- Admin %s Has given You Armour", user, name);
                        SendClientMessage(playerid,0xD2691EAA, msg);
                        SetPlayerArmour(playerid,100);
                }
        }
        return 1;
}
IRCCMD:akill(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        //Playerid
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsOp(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[128], name[MAX_PLAYER_NAME];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "12-Server- Admin %s Killed %s on IRC", user, name);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        format(msg, sizeof(msg), "-Server- Admin %s Killed %s on IRC", user, name);
                        SendClientMessageToAll(0xD2691EAA, msg);
                        SetPlayerHealth(playerid,0);
                        SetPlayerArmour(playerid,0);
                }
        }
        return 1;
}
IRCCMD:skill(botid, channel[], user[], host[], params[])
{
        new playerid, reason[64];
        if (sscanf(params, "dS(No reason.)[64]", playerid, reason))
        {
                return 1;
        }
        if (IRC_IsOp(botid, channel, user))
        {
                if(IsPlayerConnected(playerid))
                {
                        new msg[121], name[20];
                        GetPlayerName(playerid, name, sizeof(name));
                        format(msg, sizeof(msg), "10-Server- Admin %s You Silently Killed %s on IRC", user, name);
                        IRC_GroupSay(groupID, IRC_CHANNEL, msg);
                        SetPlayerHealth(playerid,0);
                        SetPlayerArmour(playerid,0);
                }
        }
        return 1;
}

IRCCMD:pm(botid, channel[], user[], host[], params[])
{
	new msg[500],target,str[129],name[28];
	if(sscanf(params,"us",target,msg)) return IRC_GroupSay(groupID, IRC_CHANNEL ,"4Usge:PM [ID] [MSG]");
	if(!IsPlayerConnected(target)) return IRC_GroupSay(groupID, IRC_CHANNEL ,"4Player is not connected");
	GetPlayerName(target,name,28);
	format(str,sizeof(str),"[IRC PM] %s : %s",user,msg);
	SCM(target,0xFFFF00,str);
	format(str,sizeof(str),"2[IRC PM] From %s to %s(%d): %s",user,name,target,msg);
	IRC_GroupSay(groupID, IRC_CHANNEL ,str);
	format(str,sizeof(str), "IRC PM From: %s To %s(%d) : %s", user, GetName(target),target,msg);
	Log("Pms",str);
	return 1;
}
IRCCMD:ad(botid, channel[], user[], host[], params[])
{
	if(IRC_IsVoice(botid, channel, user))
	{
	    new msg[111];
	    if(sscanf(params,"s",msg)) return IRC_GroupSay(GAdmins,IRC_AdminChannel,"4Usge:Ad [MSG]");
		new string[128];
		format(string,sizeof(string),"Admin Chat: %s: %s",user,msg);
 		AdminChat(Green,string);
		format(string,sizeof(string),"13Admin Chat: 4%s:9 %s",user,msg);
		IRC_GroupSay(GAdmins, IRC_AdminChannel, string);
	}
	return 1;
}
IRCCMD:kick(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
	    new id,str[229],reason[100];
	    if(sscanf(params, "us",id,reason)) return IRC_GroupSay(groupID, channel, "4USAGE:Kick <PlayerID> <Reason>");
	    format(str,sizeof(str),"You Have Kicked By IRC Admin %s | Reason: %s",user,reason);
		SCM(id,Green,str);
		format(str,sizeof(str),"%s[%d] Has been Kicked By IRC Admin %s | Reason: %s",GetName(id),id,user,reason);
		SCMTA(Green,str);
		Log("Kick",str);
		GameTextForPlayer(id,"~r~Kicked",4000,2);
		format(str,sizeof(str), "8,2Adminintstrator %s Has Kicked %s[%d] From IRC| Reason : %s", user,GetName(id),id,reason);
 		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		SetTimerEx("KickHim",1000,false,"u",id);
		return 1;
	}
	return 1;
}
IRCCMD:jail(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
	    new str[500],id,JailTime,reason[128];
	    if (sscanf(params, "uis",id,JailTime,reason)) return IRC_GroupSay(groupID, channel, "4USAGE:jail <PlayerID> <Mins> <Reason>");
        if (Jail[id] == 1) return IRC_GroupSay(groupID, channel, "4Player Is Already In Jail");
	    Jail[id] = 1;
	    SetPlayerInterior(id,6);
	    SetPlayerPos(id,264.2532,77.4431,1001.0391);
	    TogglePlayerControllable(id,1);
	    format(str,sizeof(str),"You Have Jailed For %d Mins By Admin : %s From IRC [Reason: %s]",JailTime,user,reason);
    	SCM(id,Green,str);
		format(str,sizeof(str),"%s(%d) Has Jailed For %d Mins By Admin : %s From IRC [Reason: %s]",GetName(id),id,JailTime,user,reason);
		SCMTA(Green,str);
		SetTimer("jail",JailTime*60,false);
		format(str,sizeof(str), "4,11Adminintstrator From IRC: %s Has Jailed %s[%d] (%d Mins) | Reason : %s",user,GetName(id),id,JailTime,reason);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	}
	return 1;
}
IRCCMD:unjail(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
        new id;
        if (sscanf(params, "u",id)) return IRC_GroupSay(groupID, channel, "4USAGE:unjail <PlayerID> ");
        if (Jail[id] == 0) return IRC_GroupSay(groupID, channel, "4Player Isn't In Jail");
        Jail[id] = 0;
        SpawnPlayer(id);
        SCM(id,Green,"You have been Un-Jailed by IRC Admin.");
        new str[123];
		format(str,sizeof(str), "8,2Adminintstrator On IRC: %s Has Un-Jailed %s[%d] ", user,GetName(id),id);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		return 1;
	}
	return 1;
}
IRCCMD:mute(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
        new str[500],id,MuteTime,reason[128];
        if (sscanf(params, "uis",id,MuteTime,reason)) return IRC_GroupSay(groupID, channel, "4USAGE:Mute <PlayerID> <TimeSecs> <Reason>");
		if (Mute[id] == 1) return IRC_GroupSay(groupID, channel, "4Player Is Already Muted");
		Mute[id] = 1;
  		format(str,sizeof(str),"You Have Muted For %d Mins By IRC Admin : %s [Reason: %s]",MuteTime,user,reason);
	 	SCM(id,Green,str);
		format(str,sizeof(str),"%s(%d) Has Muted For %d Mins By IRC Admin : %s [Reason: %s]",GetName(id),id,MuteTime,user,reason);
		SCMTA(Green,str);
		SetTimer("mute",MuteTime*60,false);
		format(str,sizeof(str), "4,11Adminintstrator %s[%d] Has Muted %s[%d] (%d Mins) | Reason : %s", user,GetName(id),id,MuteTime,reason);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
        return 1;
	}
	return 1;
}
IRCCMD:unmute(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
        new a;
        if (sscanf(params, "u",a)) return IRC_GroupSay(groupID, channel, "4USAGE:Mute <PlayerID> ");
		if (Mute[a] == 0 && pInfo[a][PremMute] == 0 ) return IRC_GroupSay(groupID, channel, "4Player Isn't muted");
		Mute[a] = 0;
		pInfo[a][PremMute] = 0;
		IRC_GroupSay(groupID, channel, "13[INFO]: You have Unmuted the Enterd ID");
		SCM(a,Green,"You have been Unmuted by IRC Server Admin.");
		new str[123];
		format(str,sizeof(str), "8,2Adminintstrator On IRC: %s Has Unmuted %s[%d] ", user,GetName(a),a);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
        return 1;
	}
	return 1;
}
IRCCMD:aban(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
        new target,msg1[128],msg[128],reason[128];
    	if (sscanf(params, "us",target,reason)) return IRC_GroupSay(groupID, channel, "4USAGE:aban <PlayerID> <Reason>");
	    format(msg1,sizeof(msg1),"You Have banned By IRC Admin %s | Reason: %s",user,reason);
		SCM(target,Green,msg1);
		format(msg,sizeof(msg),"%s[%d] Has been Banned By IRC Admin %s | Reason: %s",GetName(target),target,user,reason);
		SCMTA(Green,msg);
		Log("Ban",msg);
		GameTextForPlayer(target,"~r~Banned",4000,2);
		new str[128];
		format(str,sizeof(str), "8,2IRC Adminintstrator %s Has Banned %s[%d] | Reason : %s", user,GetName(target),target,reason);
		IRC_GroupSay(groupID, IRC_CHANNEL, str);
		IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
		pInfo[target][Banned] = 1;
		pInfo[target][BannedTimes]++;
		new INI:file = INI_Open(UserPath(target));
	    INI_SetTag(file, "PlayerData");
	    INI_WriteInt(file, "Banned", pInfo[target][Banned]);
	    INI_WriteInt(file, "BannedTimes", pInfo[target][BannedTimes]);
		INI_WriteString(file,"Reason",reason);
	    INI_Close(file);
		SetTimerEx("KickHim",1000,false,"u",target);
	}
	return 1;
}
IRCCMD:aunban(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
	    new string[200],string1[111];
		new target[30],str[500];
	    if (sscanf(params, "s[30]",target)) return IRC_GroupSay(groupID, channel, "4USAGE:aunban <PlayerName>");
	    format(string,sizeof(string),USER_PATH,target);
	    if(fexist(string))
	    {
	        new INI:file = INI_Open(string);
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file,"Banned",0);
	        INI_WriteString(file,"Reason","");
	        INI_Close(file);
	        format(string1,sizeof(string1),"You have unbanned %s.",target);
	        IRC_GroupSay(groupID, channel,string1);
	        IRC_GroupSay(GAdmins, channel,string1);
			format(str,sizeof(str), "8,2IRC Adminintstrator %s Has unbanned %s", user,target);
			Log("Ban",str);
			IRC_GroupSay(groupID, IRC_CHANNEL, str);
			IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
			AdminChat(Green,str);
	    }else
		{
			IRC_GroupSay(groupID, channel,"Account not found");
			IRC_GroupSay(GAdmins, channel,"Account not found");
		}
	}
	return 1;
}
IRCCMD:nameban(botid, channel[], user[], host[], params[])
{
    if(IRC_IsHalfop(botid, channel, user))
	{
	    new string[200],string1[111];
		new target[30],reason[128],str[500];
	    if (sscanf(params, "s[30]s",target,reason)) return IRC_GroupSay(groupID, channel, "4USAGE:nameban <PlayerName> <Reason>"); IRC_GroupSay(GAdmins, channel, "4USAGE:nameban <PlayerName> <Reason>");
	    format(string,sizeof(string),USER_PATH,target);
	    if(fexist(string))
	    {
	        new INI:file = INI_Open(string);
	        INI_SetTag(file, "PlayerData");
	        INI_WriteInt(file,"Banned",1);
	        INI_WriteString(file,"Reason",reason);
	        INI_Close(file);
	        format(string1,sizeof(string1),"You have banned %s.|Reason: %s",target,reason);
	        IRC_GroupSay(GAdmins, channel,string1);
	        format(str,sizeof(str), "Adminintstrator %s Has banned %s |Reason: %s",user,target,reason);
	        Log("Ban",str);
			AdminChat(Green,str);
			format(str,sizeof(str), "8,2Adminintstrator %s Has Banned %s | Reason : %s", user,target,reason);
			IRC_GroupSay(groupID, IRC_CHANNEL, str);
			IRC_GroupSay(GAdmins,IRC_AdminChannel, str);
	    }else IRC_GroupSay(groupID, channel,"Account not found"); IRC_GroupSay(GAdmins, channel,"Account not found");
	}
	return 1;
}


IRCCMD:cmds(botid, channel[], user[], host[], params[])
{
    IRC_GroupSay(groupID, IRC_CHANNEL ,"2,3IRC Commands: !cmds");
    IRC_GroupSay(groupID, IRC_CHANNEL ,"13,4,playerlist,Pm,8,5msg,admin,ad,an,5,6force,fuck,akill,skill");
	IRC_GroupSay(groupID, IRC_CHANNEL ,"6,7armour,heal,7,8armourall,healall,8,9explode,sexplode");
    IRC_GroupSay(groupID, IRC_CHANNEL ,"11,12unbanip,unban,ban,kick12,13getid,Getinfo,13,2freeze,unfreeze,13,2disarm,spawn");
    IRC_GroupSay(groupID, IRC_CHANNEL ,"3,4respawncars,giveinfernus4,3jail,unjail7,8,mute,unmute");
    IRC_GroupSay(groupID, IRC_CHANNEL ,"8,9slap,weapscheck,clearchat9,10setlevel");
	return 1;
}
CMD:spec(playerid,params[])
{
		new id;
		//if(pInfo[playerid][AdminLevel] < 1) return SCM(playerid,red,"Error:You Can't Use This Command.");
		if(sscanf(params,"u", id))return SCM(playerid, red, "Usage: /spec [id]");
		if(id == playerid)return SendClientMessage(playerid,red,"You cannot spec yourself.");
		if(id == INVALID_PLAYER_ID)return SendClientMessage(playerid, red, "Player Is Not Connected");
		if(IsSpecing[playerid] == 1)return SendClientMessage(playerid,red,"You are already specing someone.");
		GetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
		Inter[playerid] = GetPlayerInterior(playerid);
		vWorld[playerid] = GetPlayerVirtualWorld(playerid);
		TogglePlayerSpectating(playerid, true);
		if(IsPlayerInAnyVehicle(id))
		{
		    if(GetPlayerInterior(id) > 0)
		    {
				SetPlayerInterior(playerid,GetPlayerInterior(id));
			}
			if(GetPlayerVirtualWorld(id) > 0)
			{
			    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
			}
		    PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
		}
		else
		{
		    if(GetPlayerInterior(id) > 0)
		    {
				SetPlayerInterior(playerid,GetPlayerInterior(id));
			}
			if(GetPlayerVirtualWorld(id) > 0)
			{
			    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
			}
		    PlayerSpectatePlayer(playerid,id);
		}

		format(Str11, sizeof(Str11),"You have started to spectate %s.",GetName(id));
		SendClientMessage(playerid,0x0080C0FF,Str11);
		IsSpecing[playerid] = 1;
		IsBeingSpeced[id] = 1;
		spectatorid[playerid] = id;
	 	return 1;
}
COMMAND:specoff(playerid, params[])
{
	//if(pInfo[playerid][AdminLevel]< 1)return SCM(playerid,red,"Error:You Can't Use This Command.");
	if(IsSpecing[playerid] == 0)return SendClientMessage(playerid,red,"You are not spectating anyone.");
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

//its workinggg
load_banned(name[])
{
	new filename[MAX_PLAYER_NAME+18],times,Value[20];
    format(filename, sizeof(filename), USER_PATH, name);
	new File:file = fopen(filename);
	fseek(file);
	new string[200],banned[20];
	
	while(fread(file, string))
 	{
		printf("inside while loop");
	    if(!sscanf(string, "p<=>s[20]s[20]", banned, Value))
		{
            
			
			if(!strcmp(banned,"BannedTimes "))
			{
               
                times = strval(Value);
				
			    break;
            }
        }
    }
	fclose(file);
	return times;

   }
