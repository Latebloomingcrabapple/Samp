#include <a_samp>

main()
{
    print("OneCityRP: gamemode loaded.");
}

#define COLOR_SYSTEM        0x8ED6FFFF
#define COLOR_ERROR         0xFF6B6BFF
#define COLOR_SUCCESS       0x63E6BEFF
#define COLOR_POLICE        0x74C0FCFF
#define COLOR_MEDICAL       0xFF8787FF
#define COLOR_ADMIN         0xDA77F2FF
#define COLOR_GOVERNMENT    0xFFD43BFF

#define DIALOG_REGISTER     1000
#define DIALOG_LOGIN        1001
#define DIALOG_CHARACTER    1002

#define JOB_CIVILIAN        0
#define JOB_TAXI            1
#define JOB_TRUCKER         2
#define JOB_POLICE          3
#define JOB_ARMY            4
#define JOB_MEDIC           5

#define ITEM_PHONE          0
#define ITEM_MEDKIT         1
#define MAX_ITEMS           2
#define MAX_HOUSES          3
#define MAX_SERVER_VEHICLES 6
#define MODELS_DIRECTORY "models/"

#define SPAWN_X             1481.12
#define SPAWN_Y             -1771.75
#define SPAWN_Z             18.80
#define SPAWN_A             90.0

enum E_PLAYER_DATA
{
    pRegistered,
    pLoggedIn,
    pHasCharacter,
    pPassword[32],
    pCharacterName[32],
    pAge,
    pGender,
    pJob,
    pOnDuty,
    pBank,
    pWanted,
    pJailSeconds,
    pAdminLevel,
    pItems[MAX_ITEMS]
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

new HouseOwner[MAX_HOUSES];
new HousePrice[MAX_HOUSES] = {25000, 40000, 65000};
new Float:HouseX[MAX_HOUSES] = {1486.23, 1511.20, 1535.35};
new Float:HouseY[MAX_HOUSES] = {-1738.13, -1736.20, -1733.72};
new Float:HouseZ[MAX_HOUSES] = {13.55, 13.55, 13.55};
new ServerVehicles[MAX_SERVER_VEHICLES];

forward SaveAccount(playerid);
forward LoadAccount(playerid);
forward JailTimer();

public OnGameModeInit()
{
    SetGameModeText("OneCityRP");
    for (new houseid = 0; houseid < MAX_HOUSES; houseid++) HouseOwner[houseid] = INVALID_PLAYER_ID;
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    UsePlayerPedAnims();

    AddPlayerClass(60, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(280, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);

    CreatePickup(1239, 1, SPAWN_X, SPAWN_Y, SPAWN_Z);
    Create3DTextLabel("OneCityRP City Hall\nUse /help to get started", COLOR_SYSTEM, SPAWN_X, SPAWN_Y, SPAWN_Z + 0.6, 30.0, 0, 0);
    Create3DTextLabel("Los Santos Police Department\nGovernment job: /job 3", COLOR_POLICE, 1545.75, -1675.63, 13.56, 35.0, 0, 0);
    Create3DTextLabel("All Saints Hospital\nGovernment job: /job 5", COLOR_MEDICAL, 1177.87, -1337.80, 13.92, 35.0, 0, 0);

    ServerVehicles[0] = AddStaticVehicleEx(420, 1803.06, -1930.18, 13.30, 270.0, 6, 1, 120, 0);
    ServerVehicles[1] = AddStaticVehicleEx(420, 1803.06, -1925.18, 13.30, 270.0, 6, 1, 120, 0);
    ServerVehicles[2] = AddStaticVehicleEx(426, 1558.70, -1675.14, 5.61, 90.0, 0, 0, 120, 1);
    ServerVehicles[3] = AddStaticVehicleEx(433, 2798.10, -2408.30, 13.63, 0.0, 43, 0, 120, 0);
    ServerVehicles[4] = AddStaticVehicleEx(416, 1180.40, -1338.50, 13.62, 270.0, 1, 3, 120, 1);
    ServerVehicles[5] = AddStaticVehicleEx(551, 1488.20, -1730.20, 13.32, 90.0, 1, 1, 120, 0);

    SetTimer("JailTimer", 1000, 1);
    printf("OneCityRP: core systems initialized; model directory: %s", MODELS_DIRECTORY);
    return 1;
}

public OnGameModeExit()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (IsPlayerConnected(playerid) && PlayerData[playerid][pLoggedIn]) SaveAccount(playerid);
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPlayerData(playerid);
    LoadAccount(playerid);
    SendClientMessage(playerid, COLOR_SYSTEM, "Welcome to OneCityRP. This server uses roleplay rules.");
    if (PlayerData[playerid][pRegistered]) SendClientMessage(playerid, COLOR_SYSTEM, "Your account was found. Log in with /login [password].");
    else SendClientMessage(playerid, COLOR_SYSTEM, "Register with /register [password], then create a character with /char [name] [age] [gender].");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (PlayerData[playerid][pLoggedIn]) SaveAccount(playerid);
    ResetPlayerData(playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, SPAWN_A);
    SetPlayerCameraPos(playerid, 1493.0, -1771.75, 21.0);
    SetPlayerCameraLookAt(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    if (!PlayerData[playerid][pLoggedIn])
    {
        SendClientMessage(playerid, COLOR_ERROR, "You must log in before spawning. Use /login [password].");
        return 0;
    }
    if (!PlayerData[playerid][pHasCharacter])
    {
        SendClientMessage(playerid, COLOR_ERROR, "Create your roleplay character first: /char [name] [age] [gender].");
        return 0;
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetSpawnInfo(playerid, 0, GetJobSkin(PlayerData[playerid][pJob]), SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    SetPlayerSkin(playerid, GetJobSkin(PlayerData[playerid][pJob]));
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, 500);
    SendClientMessage(playerid, COLOR_SUCCESS, "You entered Los Santos. Stay in character and use /help for roleplay commands.");
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if (PlayerData[playerid][pWanted] > 0)
    {
        PlayerData[playerid][pJailSeconds] = PlayerData[playerid][pWanted] * 30;
        PlayerData[playerid][pWanted] = 0;
        SendClientMessage(playerid, COLOR_ERROR, "You were detained after your death. You will serve your jail time on spawn.");
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new command[32], arg1[64], arg2[32], arg3[32];
    SplitCommand(cmdtext, command, sizeof command, arg1, sizeof arg1, arg2, sizeof arg2, arg3, sizeof arg3);

    if (!strcmp(command, "/help", true)) return ShowHelp(playerid);
    if (!strcmp(command, "/register", true)) return CommandRegister(playerid, arg1);
    if (!strcmp(command, "/login", true)) return CommandLogin(playerid, arg1);
    if (!strcmp(command, "/char", true)) return CommandCharacter(playerid, arg1, arg2, arg3);
    if (!strcmp(command, "/id", true)) return CommandId(playerid);
    if (!strcmp(command, "/jobs", true)) return CommandJobs(playerid);
    if (!strcmp(command, "/job", true)) return CommandJob(playerid, arg1);
    if (!strcmp(command, "/duty", true)) return CommandDuty(playerid);
    if (!strcmp(command, "/bank", true)) return CommandBank(playerid, arg1, arg2);
    if (!strcmp(command, "/inventory", true)) return CommandInventory(playerid);
    if (!strcmp(command, "/buyitem", true)) return CommandBuyItem(playerid, arg1);
    if (!strcmp(command, "/wanted", true)) return CommandWanted(playerid);
    if (!strcmp(command, "/surrender", true)) return CommandSurrender(playerid);
    if (!strcmp(command, "/buyhouse", true)) return CommandBuyHouse(playerid);
    if (!strcmp(command, "/houses", true)) return CommandHouses(playerid);
    if (!strcmp(command, "/vehicles", true)) return CommandVehicles(playerid);
    if (!strcmp(command, "/admins", true)) return CommandAdmins(playerid);
    if (!strcmp(command, "/setwanted", true)) return CommandSetWanted(playerid, arg1, arg2);
    if (!strcmp(command, "/setjob", true)) return CommandSetJob(playerid, arg1, arg2);

    SendClientMessage(playerid, COLOR_ERROR, "Unknown command. Use /help.");
    return 1;
}

public JailTimer()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid) || PlayerData[playerid][pJailSeconds] <= 0) continue;
        PlayerData[playerid][pJailSeconds]--;
        if (PlayerData[playerid][pJailSeconds] == 0) SendClientMessage(playerid, COLOR_SUCCESS, "Your jail sentence has ended.");
    }
    return 1;
}

stock ResetPlayerData(playerid)
{
    for (new index = 0; index < E_PLAYER_DATA; index++) PlayerData[playerid][index] = 0;
    return 1;
}

stock bool:IsAuthenticated(playerid)
{
    if (!PlayerData[playerid][pLoggedIn])
    {
        SendClientMessage(playerid, COLOR_ERROR, "You need to log in first. Use /login [password].");
        return false;
    }
    return true;
}

stock ShowHelp(playerid)
{
    SendClientMessage(playerid, COLOR_SYSTEM, "Account: /register /login /char /id | Roleplay: /jobs /job /duty /wanted /surrender");
    SendClientMessage(playerid, COLOR_SYSTEM, "Economy: /bank [balance|deposit|withdraw] [amount] /inventory /buyitem [phone|medkit]");
    SendClientMessage(playerid, COLOR_SYSTEM, "World: /houses /buyhouse /vehicles | Staff: /admins");
    return 1;
}

stock CommandRegister(playerid, const password[])
{
    if (PlayerData[playerid][pRegistered]) return SendClientMessage(playerid, COLOR_ERROR, "This session is already registered. Use /login [password].");
    if (strlen(password) < 4 || strlen(password) > 30) return SendClientMessage(playerid, COLOR_ERROR, "Password must contain 4 to 30 characters.");
    format(PlayerData[playerid][pPassword], 32, "%s", password);
    PlayerData[playerid][pRegistered] = 1;
    SaveAccount(playerid);
    SendClientMessage(playerid, COLOR_SUCCESS, "Registration complete. Use /login with your password.");
    return 1;
}

stock CommandLogin(playerid, const password[])
{
    if (!PlayerData[playerid][pRegistered]) return SendClientMessage(playerid, COLOR_ERROR, "No account is registered in this session. Use /register [password].");
    if (PlayerData[playerid][pLoggedIn]) return SendClientMessage(playerid, COLOR_ERROR, "You are already logged in.");
    if (strcmp(password, PlayerData[playerid][pPassword], false)) return SendClientMessage(playerid, COLOR_ERROR, "Incorrect password.");
    PlayerData[playerid][pLoggedIn] = 1;
    SendClientMessage(playerid, COLOR_SUCCESS, "Login successful. Create your character with /char [name] [age] [male|female].");
    return 1;
}

stock CommandCharacter(playerid, const name[], const ageText[], const gender[])
{
    new age = strval(ageText);
    if (!IsAuthenticated(playerid)) return 1;
    if (strlen(name) < 3 || strlen(name) > 24 || age < 16 || age > 90) return SendClientMessage(playerid, COLOR_ERROR, "Usage: /char [name] [age 16-90] [male|female]");
    if (strcmp(gender, "male", true) && strcmp(gender, "female", true)) return SendClientMessage(playerid, COLOR_ERROR, "Gender must be male or female.");
    format(PlayerData[playerid][pCharacterName], 32, "%s", name);
    PlayerData[playerid][pAge] = age;
    PlayerData[playerid][pGender] = !strcmp(gender, "female", true);
    PlayerData[playerid][pHasCharacter] = 1;
    PlayerData[playerid][pJob] = JOB_CIVILIAN;
    PlayerData[playerid][pBank] = 1500;
    SendClientMessage(playerid, COLOR_SUCCESS, "Character created. Select spawn to enter OneCityRP.");
    return 1;
}

stock CommandId(playerid)
{
    new message[144], gender[8];
    if (!IsAuthenticated(playerid) || !PlayerData[playerid][pHasCharacter]) return 1;
    if (PlayerData[playerid][pGender]) format(gender, sizeof gender, "Female"); else format(gender, sizeof gender, "Male");
    format(message, sizeof message, "ID: %s | Age: %d | Gender: %s | Job: %s | Bank: $%d", PlayerData[playerid][pCharacterName], PlayerData[playerid][pAge], gender, GetJobName(PlayerData[playerid][pJob]), PlayerData[playerid][pBank]);
    SendClientMessage(playerid, COLOR_WHITE, message);
    return 1;
}

stock CommandJobs(playerid)
{
    SendClientMessage(playerid, COLOR_SYSTEM, "Jobs: 0 Civilian, 1 Taxi, 2 Trucker, 3 Police, 4 Army, 5 Medic.");
    SendClientMessage(playerid, COLOR_SYSTEM, "Use /job [id]. Government job access is intentionally controlled by administrators.");
    return 1;
}

stock CommandJob(playerid, const jobText[])
{
    new job = strval(jobText);
    if (!IsAuthenticated(playerid)) return 1;
    if (job < JOB_CIVILIAN || job > JOB_MEDIC) return SendClientMessage(playerid, COLOR_ERROR, "Invalid job. Use /jobs.");
    if (job >= JOB_POLICE && PlayerData[playerid][pAdminLevel] < 1) return SendClientMessage(playerid, COLOR_ERROR, "Government jobs require staff approval.");
    PlayerData[playerid][pJob] = job;
    PlayerData[playerid][pOnDuty] = 0;
    SetPlayerSkin(playerid, GetJobSkin(job));
    SendClientMessage(playerid, COLOR_SUCCESS, "Your job has been updated. Use /duty when appropriate.");
    return 1;
}

stock CommandDuty(playerid)
{
    if (!IsAuthenticated(playerid)) return 1;
    if (PlayerData[playerid][pJob] < JOB_POLICE) return SendClientMessage(playerid, COLOR_ERROR, "Only government jobs have a duty status.");
    PlayerData[playerid][pOnDuty] = !PlayerData[playerid][pOnDuty];
    SendClientMessage(playerid, COLOR_GOVERNMENT, PlayerData[playerid][pOnDuty] ? "You are now on duty." : "You are now off duty.");
    return 1;
}

stock CommandBank(playerid, const action[], const amountText[])
{
    new amount = strval(amountText), message[80];
    if (!IsAuthenticated(playerid)) return 1;
    if (!strcmp(action, "balance", true))
    {
        format(message, sizeof message, "Bank balance: $%d", PlayerData[playerid][pBank]);
        return SendClientMessage(playerid, COLOR_SUCCESS, message);
    }
    if (amount <= 0) return SendClientMessage(playerid, COLOR_ERROR, "Usage: /bank [balance|deposit|withdraw] [amount]");
    if (!strcmp(action, "deposit", true))
    {
        if (GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, COLOR_ERROR, "You do not have enough cash.");
        GivePlayerMoney(playerid, -amount); PlayerData[playerid][pBank] += amount;
    }
    else if (!strcmp(action, "withdraw", true))
    {
        if (PlayerData[playerid][pBank] < amount) return SendClientMessage(playerid, COLOR_ERROR, "You do not have enough money in the bank.");
        PlayerData[playerid][pBank] -= amount; GivePlayerMoney(playerid, amount);
    }
    else return SendClientMessage(playerid, COLOR_ERROR, "Usage: /bank [balance|deposit|withdraw] [amount]");
    SendClientMessage(playerid, COLOR_SUCCESS, "Bank transaction completed.");
    return 1;
}

stock CommandInventory(playerid)
{
    new message[96];
    if (!IsAuthenticated(playerid)) return 1;
    format(message, sizeof message, "Inventory: Phone x%d | Medkit x%d", PlayerData[playerid][pItems][ITEM_PHONE], PlayerData[playerid][pItems][ITEM_MEDKIT]);
    return SendClientMessage(playerid, COLOR_WHITE, message);
}

stock CommandBuyItem(playerid, const item[])
{
    new price;
    if (!IsAuthenticated(playerid)) return 1;
    if (!strcmp(item, "phone", true)) { price = 250; PlayerData[playerid][pItems][ITEM_PHONE]++; }
    else if (!strcmp(item, "medkit", true)) { price = 100; PlayerData[playerid][pItems][ITEM_MEDKIT]++; }
    else return SendClientMessage(playerid, COLOR_ERROR, "Usage: /buyitem [phone|medkit]");
    if (GetPlayerMoney(playerid) < price)
    {
        if (!strcmp(item, "phone", true)) PlayerData[playerid][pItems][ITEM_PHONE]--; else PlayerData[playerid][pItems][ITEM_MEDKIT]--;
        return SendClientMessage(playerid, COLOR_ERROR, "You do not have enough cash.");
    }
    GivePlayerMoney(playerid, -price);
    SendClientMessage(playerid, COLOR_SUCCESS, "Item purchased.");
    return 1;
}

stock CommandWanted(playerid)
{
    new message[64];
    if (!IsAuthenticated(playerid)) return 1;
    format(message, sizeof message, "Wanted level: %d | Jail time: %d seconds", PlayerData[playerid][pWanted], PlayerData[playerid][pJailSeconds]);
    return SendClientMessage(playerid, COLOR_ERROR, message);
}

stock CommandSurrender(playerid)
{
    if (!IsAuthenticated(playerid)) return 1;
    if (PlayerData[playerid][pWanted] <= 0) return SendClientMessage(playerid, COLOR_ERROR, "You are not wanted.");
    PlayerData[playerid][pJailSeconds] = PlayerData[playerid][pWanted] * 30;
    PlayerData[playerid][pWanted] = 0;
    SetPlayerPos(playerid, 264.63, 77.57, 1001.04);
    SetPlayerInterior(playerid, 6);
    SendClientMessage(playerid, COLOR_SUCCESS, "You surrendered and have been jailed.");
    return 1;
}

stock CommandHouses(playerid)
{
    SendClientMessage(playerid, COLOR_SYSTEM, "Houses are available near City Hall. Stand by a property and use /buyhouse.");
    return 1;
}

stock CommandBuyHouse(playerid)
{
    if (!IsAuthenticated(playerid)) return 1;
    for (new houseid = 0; houseid < MAX_HOUSES; houseid++)
    {
        if (GetPlayerDistanceFromPoint(playerid, HouseX[houseid], HouseY[houseid], HouseZ[houseid]) < 4.0)
        {
            if (HouseOwner[houseid] != INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_ERROR, "This house is already owned.");
            if (GetPlayerMoney(playerid) < HousePrice[houseid]) return SendClientMessage(playerid, COLOR_ERROR, "You do not have enough cash for this house.");
            HouseOwner[houseid] = playerid;
            GivePlayerMoney(playerid, -HousePrice[houseid]);
            SendClientMessage(playerid, COLOR_SUCCESS, "House purchased. Ownership is currently stored for this server session.");
            return 1;
        }
    }
    SendClientMessage(playerid, COLOR_ERROR, "You must stand next to an available house.");
    return 1;
}

stock CommandVehicles(playerid)
{
    SendClientMessage(playerid, COLOR_SYSTEM, "Public vehicles: taxis at Unity Station; government vehicles are restricted to roleplay duties.");
    return 1;
}

stock CommandAdmins(playerid)
{
    SendClientMessage(playerid, COLOR_ADMIN, "Administrator system: /setwanted [playerid] [level], /setjob [playerid] [job].");
    if (IsPlayerAdmin(playerid)) SendClientMessage(playerid, COLOR_ADMIN, "You are authenticated as an RCON administrator.");
    return 1;
}

stock CommandSetWanted(playerid, const targetText[], const levelText[])
{
    new targetid = strval(targetText), level = strval(levelText), message[80];
    if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_ERROR, "RCON administrator access is required.");
    if (!IsPlayerConnected(targetid) || level < 0 || level > 6) return SendClientMessage(playerid, COLOR_ERROR, "Usage: /setwanted [playerid] [level 0-6]");
    PlayerData[targetid][pWanted] = level;
    format(message, sizeof message, "Your wanted level was set to %d by an administrator.", level);
    SendClientMessage(targetid, COLOR_ADMIN, message);
    return 1;
}

stock CommandSetJob(playerid, const targetText[], const jobText[])
{
    new targetid = strval(targetText), job = strval(jobText);
    if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_ERROR, "RCON administrator access is required.");
    if (!IsPlayerConnected(targetid) || job < JOB_CIVILIAN || job > JOB_MEDIC) return SendClientMessage(playerid, COLOR_ERROR, "Usage: /setjob [playerid] [job 0-5]");
    PlayerData[targetid][pJob] = job;
    PlayerData[targetid][pOnDuty] = 0;
    SetPlayerSkin(targetid, GetJobSkin(job));
    SendClientMessage(targetid, COLOR_ADMIN, "An administrator updated your job.");
    return 1;
}

stock GetJobName(job)
{
    static name[16];
    switch (job)
    {
        case JOB_TAXI: format(name, sizeof name, "Taxi Driver");
        case JOB_TRUCKER: format(name, sizeof name, "Trucker");
        case JOB_POLICE: format(name, sizeof name, "Police");
        case JOB_ARMY: format(name, sizeof name, "Army");
        case JOB_MEDIC: format(name, sizeof name, "Medic");
        default: format(name, sizeof name, "Civilian");
    }
    return name;
}

stock GetJobSkin(job)
{
    switch (job)
    {
        case JOB_POLICE: return 280;
        case JOB_ARMY: return 287;
        case JOB_MEDIC: return 274;
        case JOB_TAXI: return 255;
    }
    return 60;
}

stock SaveAccount(playerid)
{
    new filename[64], name[MAX_PLAYER_NAME + 1], line[128];
    GetPlayerName(playerid, name, sizeof name);
    format(filename, sizeof filename, "scriptfiles/accounts/%s.ini", name);
    new File:file = fopen(filename, io_write);
    if (!file) return 0;
    format(line, sizeof line, "password=%s\r\nname=%s\r\nage=%d\r\ngender=%d\r\njob=%d\r\nbank=%d\r\n", PlayerData[playerid][pPassword], PlayerData[playerid][pCharacterName], PlayerData[playerid][pAge], PlayerData[playerid][pGender], PlayerData[playerid][pJob], PlayerData[playerid][pBank]);
    fwrite(file, line);
    fclose(file);
    return 1;
}

stock LoadAccount(playerid)
{
    new filename[64], name[MAX_PLAYER_NAME + 1], line[128], value[64];
    GetPlayerName(playerid, name, sizeof name);
    format(filename, sizeof filename, "scriptfiles/accounts/%s.ini", name);
    if (!fexist(filename)) return 0;
    new File:file = fopen(filename, io_read);
    if (!file) return 0;
    while (fread(file, line, sizeof line))
    {
        if (!GetConfigValue(line, value, sizeof value)) continue;
        if (!strncmp(line, "password=", 9)) format(PlayerData[playerid][pPassword], 32, "%s", value);
        else if (!strncmp(line, "name=", 5)) format(PlayerData[playerid][pCharacterName], 32, "%s", value);
        else if (!strncmp(line, "age=", 4)) PlayerData[playerid][pAge] = strval(value);
        else if (!strncmp(line, "gender=", 7)) PlayerData[playerid][pGender] = strval(value);
        else if (!strncmp(line, "job=", 4)) PlayerData[playerid][pJob] = strval(value);
        else if (!strncmp(line, "bank=", 5)) PlayerData[playerid][pBank] = strval(value);
    }
    fclose(file);
    PlayerData[playerid][pRegistered] = 1;
    if (strlen(PlayerData[playerid][pCharacterName]) > 0) PlayerData[playerid][pHasCharacter] = 1;
    return 1;
}

stock GetConfigValue(const line[], value[], valueSize)
{
    new sourceIndex, valueIndex;
    while (line[sourceIndex] != '=' && line[sourceIndex] != '\0') sourceIndex++;
    if (line[sourceIndex] != '=') return 0;
    sourceIndex++;
    while (line[sourceIndex] != '\0' && line[sourceIndex] != '\r' && line[sourceIndex] != '\n' && valueIndex < valueSize - 1)
    {
        value[valueIndex++] = line[sourceIndex++];
    }
    value[valueIndex] = '\0';
    return 1;
}

stock strncmp(const string1[], const string2[], length)
{
    for (new index = 0; index < length; index++)
    {
        if (string1[index] != string2[index]) return string1[index] - string2[index];
        if (string1[index] == '\0') return 0;
    }
    return 0;
}

stock SplitCommand(const source[], command[], commandSize, arg1[], arg1Size, arg2[], arg2Size, arg3[], arg3Size)
{
    new index, outputIndex, part;
    command[0] = '\0'; arg1[0] = '\0'; arg2[0] = '\0'; arg3[0] = '\0';
    while (source[index] == ' ') index++;
    while (source[index] != '\0')
    {
        outputIndex = 0;
        while (source[index] != ' ' && source[index] != '\0')
        {
            if (part == 0 && outputIndex < commandSize - 1) command[outputIndex++] = source[index];
            else if (part == 1 && outputIndex < arg1Size - 1) arg1[outputIndex++] = source[index];
            else if (part == 2 && outputIndex < arg2Size - 1) arg2[outputIndex++] = source[index];
            else if (part == 3 && outputIndex < arg3Size - 1) arg3[outputIndex++] = source[index];
            index++;
        }
        if (part == 0) command[outputIndex] = '\0';
        else if (part == 1) arg1[outputIndex] = '\0';
        else if (part == 2) arg2[outputIndex] = '\0';
        else arg3[outputIndex] = '\0';
        while (source[index] == ' ') index++;
        part++;
    }
    return 1;
}
