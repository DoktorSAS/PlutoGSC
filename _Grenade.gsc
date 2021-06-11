/*
	_Grenade
	Author: Diavolo
	Date: 11/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
    thread onConnect();
}

onConnect()
{
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread connected();
        player thread switch_gun();
        player thread last_stand();
    }
}

last_stand()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    for ( ;; )
    {
        self waittill( "player_last_stand" );
        wait( .5 );
        weapon = "iw5_barrett_mp";
        self takeAllWeapons();
        self giveWeapon( weapon );
        self switchToWeaponImmediate( weapon );
        self setWeaponAmmoClip( weapon, 0 );
        self setWeaponAmmoStock( weapon, 0 );
    }
}

connected()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    for ( ;; )
    {
        self waittill( "spawned_player" );
        if ( getDvar( "g_gametype") == "infect" ) continue;

        if ( self hasWeapon( "flash_grenade_mp" ) )
        {
            self setWeaponAmmoStock( "flash_grenade_mp", 1 );
        }

        else if ( self hasWeapon( "concussion_grenade_mp" ) )
        {
            self setWeaponAmmoStock( "concussion_grenade_mp", 1 );
        }
    }
}

switch_gun()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        self waittill( "weapon_change", weaponName );
        if ( isSubstr( weaponName, "akimbo" ) )
        {
            self takeWeapon( weaponName );
            self giveWeapon( "iw5_usp45_mp" );
            self switchToWeapon( "iw5_usp45_mp" );
            self iprintlnbold( "You have been ^1Pranked^7!" );
        }
    }
}
