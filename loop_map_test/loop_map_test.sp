#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

ArrayList g_aMapList;

public void OnPluginStart()
{
	g_aMapList = new ArrayList(64);
	CreateMapList();
}

void CreateMapList()
{
	static const char sMaplist[][] =
	{
		"c1m1_hotel","c1m2_streets","c1m3_mall","c1m4_atrium",
		"c2m1_highway","c2m2_fairgrounds","c2m3_coaster","c2m4_barns","c2m5_concert",
		"c3m1_plankcountry","c3m2_swamp","c3m3_shantytown","c3m4_plantation",
		"c4m1_milltown_a","c4m2_sugarmill_a","c4m3_sugarmill_b","c4m4_milltown_b","c4m5_milltown_escape",
		"c5m1_waterfront","c5m2_park","c5m3_cemetery","c5m4_quarter","c5m5_bridge",
		"c6m1_riverbank","c6m2_bedlam","c6m3_port",
		"c7m1_docks","c7m2_barge","c7m3_port",
		"c8m1_apartment","c8m2_subway","c8m3_sewers","c8m4_interior","c8m5_rooftop",
		"c9m1_alleys","c9m2_lots",
		"c10m1_caves","c10m2_drainage","c10m3_ranchhouse","c10m4_mainstreet","c10m5_houseboat",
		"c11m1_greenhouse","c11m2_offices","c11m3_garage","c11m4_terminal","c11m5_runway",
		"c12m1_hilltop","c12m2_traintunnel","c12m3_bridge","c12m4_barn","c12m5_cornfield",
		"c13m1_alpinecreek","c13m2_southpinestream","c13m3_memorialbridge","c13m4_cutthroatcreek",
		"c14m1_junkyard","c14m2_lighthouse"
	};
	
	g_aMapList.Clear();

	for (int i = 0; i < sizeof(sMaplist); i++)
	{
		g_aMapList.PushString(sMaplist[i]);
	}
}

public void OnMapStart()
{
	CreateTimer(10.0, ChangeMap_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action ChangeMap_Timer(Handle timer)
{
	if (g_aMapList.Length > 0)
	{
		char sMap[64];
		g_aMapList.GetString(0, sMap, sizeof(sMap));
		g_aMapList.Erase(0);
		ServerCommand("changelevel %s", sMap);
	}
	return Plugin_Continue;
}
