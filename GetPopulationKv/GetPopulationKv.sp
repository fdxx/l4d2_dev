#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

Handle g_hSDKKVGetName, g_hSDKKVGetString;
char g_sOutput[PLATFORM_MAX_PATH];
GameData g_hGameData;
int g_iGetFirstSubKeyOffset, g_iGetNextKeyOffset;

public void OnPluginStart()
{
	InitGameData();
	RegAdminCmd("sm_get_population_kv", Cmd_GetKv, ADMFLAG_ROOT);
}

void InitGameData()
{
	BuildPath(Path_SM, g_sOutput, sizeof(g_sOutput), "logs/output.cfg");

	g_hGameData = new GameData("GetPopulationKv");
	if (g_hGameData == null)
		SetFailState("Failed to load GetPopulationKv.txt file");

	g_iGetFirstSubKeyOffset = g_hGameData.GetOffset("KeyValues::GetFirstSubKey");
	if (g_iGetFirstSubKeyOffset == -1)
		SetFailState("Failed to load offset: KeyValues::GetFirstSubKey");

	g_iGetNextKeyOffset = g_hGameData.GetOffset("KeyValues::GetNextKey");
	if (g_iGetNextKeyOffset == -1)
		SetFailState("Failed to load offset: KeyValues::GetNextKey");

	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(g_hGameData, SDKConf_Signature, "KeyValues::GetName"))
		SetFailState("Failed to find signature: KeyValues::GetName");
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	g_hSDKKVGetName = EndPrepSDKCall();
	if (g_hSDKKVGetName == null)
		SetFailState("Failed to create SDKCall: KeyValues::GetName");

	StartPrepSDKCall(SDKCall_Raw);
	if (!PrepSDKCall_SetFromConf(g_hGameData, SDKConf_Signature, "KeyValues::GetString"))
		SetFailState("Failed to find signature: KeyValues::GetString");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	g_hSDKKVGetString = EndPrepSDKCall();
	if (g_hSDKKVGetString == null)
		SetFailState("Failed to create SDKCall: KeyValues::GetString");
}

Action Cmd_GetKv(int client, int args)
{
	Address kvRoot = g_hGameData.GetAddress("PopulationKv");

	Address kvType = kvRoot;
	if (GetFirstSubKey(kvType))
	{
		KeyValues smKv = new KeyValues("PopulationKv");
		char sType[128], sKey[128], sValue[128];

		do
		{
			GetKeyName(kvType, sType, sizeof(sType));

			smKv.Rewind();
			smKv.JumpToKey(sType, true);

			Address kvModel = kvType;
			if (GetFirstSubKey(kvModel))
			{
				do
				{
					GetKeyName(kvModel, sKey, sizeof(sKey));
					GetValueString(kvType, sKey, sValue, sizeof(sValue));
					smKv.SetString(sKey, sValue);
				}
				while (GetNextKey(kvModel));
			}
		}
		while (GetNextKey(kvType));

		smKv.Rewind();
		smKv.ExportToFile(g_sOutput);
		delete smKv;
	}
	
	return Plugin_Handled;
}

bool GetFirstSubKey(Address &kv)
{
	if (kv != Address_Null)
	{
		kv = LoadFromAddress(kv + view_as<Address>(g_iGetFirstSubKeyOffset * 4), NumberType_Int32);
		return kv != Address_Null;
	}
	return false;
}

bool GetNextKey(Address &kv)
{
	if (kv != Address_Null)
	{
		kv = LoadFromAddress(kv + view_as<Address>(g_iGetNextKeyOffset * 4), NumberType_Int32);
		return kv != Address_Null;
	}
	return false;
}

void GetKeyName(Address kv, char[] sKey, int iMaxLength)
{
	SDKCall(g_hSDKKVGetName, kv, sKey, iMaxLength);
}

void GetValueString(Address kv, const char[] sKey, char[] sValue, int iMaxLength, const char[] sDefault = "")
{
	SDKCall(g_hSDKKVGetString, kv, sValue, iMaxLength, sKey, sDefault);
}
