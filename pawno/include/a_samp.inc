/* SA-MP 0.3.DL-R1 compatible subset of the official a_samp API. */
#if defined _a_samp_included
    #endinput
#endif
#define _a_samp_included

#define MAX_PLAYERS          (500)
#define MAX_PLAYER_NAME      (24)
#define INVALID_PLAYER_ID    (0xFFFF)
#define INVALID_VEHICLE_ID   (0xFFFF)
#define PLAYER_STATE_NONE    (0)
#define PLAYER_STATE_ONFOOT  (1)
#define PLAYER_STATE_DRIVER  (2)
#define PLAYER_STATE_PASSENGER (3)
#define PLAYER_MARKERS_MODE_GLOBAL (0)
#define DIALOG_STYLE_MSGBOX  (0)
#define DIALOG_STYLE_INPUT   (1)
#define DIALOG_STYLE_LIST    (2)
#define DIALOG_STYLE_PASSWORD (3)
#define COLOR_WHITE          (0xFFFFFFFF)

tag File;
enum filemode { io_read = 1, io_write, io_readwrite, io_append }
native print(const string[]);
native printf(const format[], {Float,_}:...);
native SendClientMessage(playerid, color, const message[]);
native SendClientMessageToAll(color, const message[]);
native SetGameModeText(const string[]);
native ShowPlayerMarkers(mode);
native UsePlayerPedAnims();
native ShowPlayerDialog(playerid, dialogid, style, const caption[], const info[], const button1[], const button2[]);
native AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
native SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
native SpawnPlayer(playerid);
native SetPlayerPos(playerid, Float:x, Float:y, Float:z);
native SetPlayerFacingAngle(playerid, Float:angle);
native SetPlayerCameraPos(playerid, Float:x, Float:y, Float:z);
native SetPlayerCameraLookAt(playerid, Float:x, Float:y, Float:z, cut = 0);
native SetPlayerInterior(playerid, interiorid);
native SetPlayerVirtualWorld(playerid, worldid);
native SetPlayerColor(playerid, color);
native SetPlayerSkin(playerid, skinid);
native SetPlayerHealth(playerid, Float:health);
native SetPlayerArmour(playerid, Float:armour);
native GivePlayerMoney(playerid, money);
native ResetPlayerMoney(playerid);
native GetPlayerMoney(playerid);
native GetPlayerName(playerid, name[], len);
native GetPlayerState(playerid);
native GetPlayerVehicleID(playerid);
native GetPlayerIp(playerid, ip[], len);
native IsPlayerConnected(playerid);
native IsPlayerAdmin(playerid);
native CreateVehicle(vehicletype, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1, color2, respawn_delay, addsiren = 0);
native SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
native AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1, color2, respawn_delay, addsiren = 0);
native CreatePickup(model, type, Float:X, Float:Y, Float:Z, virtualworld = 0);
native Create3DTextLabel(const text[], color, Float:X, Float:Y, Float:Z, Float:DrawDistance, virtualworld, testLOS = 0);
native CreateObject(modelid, Float:X, Float:Y, Float:Z, Float:RotX, Float:RotY, Float:RotZ, drawdistance = 0.0);
native SetTimer(const funcname[], interval, repeating);
native KillTimer(timerid);
native Float:GetPlayerDistanceFromPoint(playerid, Float:X, Float:Y, Float:Z);
native File:fopen(const filename[], filemode:mode = io_readwrite);
native fclose(File:handle);
native fwrite(File:handle, const string[]);
native fread(File:handle, string[], size = sizeof string, bool:pack = false);
native fexist(const filename[]);
native strval(const string[]);
native strlen(const string[]);
native strcmp(const string1[], const string2[], ignorecase = false, length = 0);
native format(output[], len, const format[], {Float,_}:...);
