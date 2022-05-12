#pragma semicolon 1
#pragma newdecls required

#define VERSION	"0.1"

#include <sourcemod>
#include <sourcescramble> // https://github.com/nosoop/SMExt-SourceScramble

public Plugin myinfo =
{
	name = "L4D2 No steam logon patch",
	author = "fdxx",
	version = VERSION,
}

public void OnPluginStart()
{
	CreateConVar("l4d2_no_steam_logon_patch_version", VERSION, "Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);

	GameData hGameData = new GameData("l4d2_no_steam_logon_patch");
	if (hGameData == null)
		SetFailState("Failed to load \"l4d2_no_steam_logon_patch.txt\" gamedata.");

	MemoryPatch mPatch = MemoryPatch.CreateFromConf(hGameData, "CSteam3Server::OnValidateAuthTicketResponseHelper::BLanOnly");
	if (!mPatch.Validate())
		SetFailState("Verify patch failed.");
	if (!mPatch.Enable())
		SetFailState("Enable patch failed.");

	delete hGameData;
}
