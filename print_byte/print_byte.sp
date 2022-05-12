#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>

public void OnPluginStart()
{
	RegAdminCmd("sm_print_byte", Cmd_PrintByte, ADMFLAG_ROOT);
}

Action Cmd_PrintByte(int client, int args)
{
	if (args != 4)
	{
		ReplyToCommand(client, "sm_print_byte <GameDataFileName> <SigName> <Offset> <ByteCount>");
		return Plugin_Handled;
	}

	char sFileName[256], sSigName[256];
	int iOffset, iByteCount;

	GetCmdArg(1, sFileName, sizeof(sFileName));
	GetCmdArg(2, sSigName, sizeof(sSigName));
	iOffset = GetCmdArgInt(3);
	iByteCount = GetCmdArgInt(4);

	GameData hGameData = new GameData(sFileName);
	if (hGameData != null)
	{
		Address pSig = hGameData.GetMemSig(sSigName);
		if (pSig != Address_Null)
		{
			int iValue;
			for (int i = 0; i < iByteCount; i++)
			{
				iValue = LoadFromAddress(pSig + view_as<Address>(iOffset) + view_as<Address>(i), NumberType_Int8);
				ReplyToCommand(client, "0x%02X", iValue);
			}
		}
		else LogError("\"%s\" Address == Null", sSigName);
	}
	else LogError("Failed to load \"%s\" gamedata.", sFileName);

	delete hGameData;
	return Plugin_Handled;
}
