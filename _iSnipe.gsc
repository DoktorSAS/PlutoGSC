#include common_scripts\utility;
#include maps\mp\_utility;

init()
{	
    if(getDvar("sv_gamemode") != "is")
        return;
    create_dvar( "sv_antiHardScope", 1 );
	level thread onPlayerConnect();
    level waittill("prematch_over");
    level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;
}

isSniper( weapon )
{
    return ( 
        isSubstr( weapon, "iw5_dragunov_mp") 
        ||  isSubstr( weapon, "iw5_msr_mp" ) 
        ||  isSubstr( weapon, "iw5_barrett_mp" ) 
        ||  isSubstr( weapon, "iw5_barrett_mp" ) 
        ||  isSubstr( weapon, "iw5_rsass_mp" ) 
        ||  isSubstr( weapon, "iw5_as50_mp" ) 
        ||  isSubstr( weapon, "iw5_l96a1_mp")
        ||  isSubstr( weapon, "iw5_cheytac_mp")
    );
}

CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");
    eAttacker iPrintLn( isSniper( eAttacker.__vars["already_fired"] ) );
    if(sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" ||sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_FALLING" )
	{
        [[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
        return;
    }		
    if( isSniper( sWeapon ) )
    {
        if(eAttacker.__vars["already_fired"])
            iDamage = 0;
        else 
            iDamage = 999;  
    }
    else 
        iDamage = 0;

        
     if( sMeansOfDeath == "MOD_MELEE")
        iDamage = 0;
    
	[[level.prevCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
        player thread onPlayerSpawned();
	}
}

isnipe_AntyFireSpam_SecondBullet()
{
    self endon("SecondBullet");
    self waittill( "weapon_fired" );
    self thread isnipe_SendRule("Do ^1not ^7spam bullets", 5);
}

isnipe_AntyFireSpam()
{
    for(;;)
    {
        self waittill( "weapon_fired" );
        self thread isnipe_AntyFireSpam_SecondBullet();
        wait 0.8;
        self notify("SecondBullet");
        self.__vars["already_fired"] = 0;
    }
}

isnipe_AntiHardScope()
{
    if ( getDvarInt( "sv_antihardscope" ) != 1) return;
    level endon( "game_ended" );
    self endon ( "disconnect" );

    self.check_ads_cycle = 0;
    for ( ;; )
    {
        wait( .2 );
        if ( !IsAlive( self ) ) continue;

        ads = self PlayerADS();
        adsCycles = self.myadscycle;

        if( ads == 1 )
          adsCycles++;
        else
          adsCycles = 0;

        if ( adsCycles >= 2)
        {
            self allowAds( false );
            self thread isnipe_SendRule("Hardscoping is ^1not allowed", 5);
        }

        if ( self adsButtonPressed() && ads == 0 )
        {
            self allowAds( true );
        }

        self.myadscycle = adsCycles;
    }
}

onPlayerSpawned()
{
    self.__vars["message"] = 0;
    self.__vars["already_fired"] = 0;
    self thread isnipe_AntiKinfe();
    self thread isnipe_AntiHardScope();
    self thread isnipe_AntyFireSpam();
    once = 0;
    for(;;)
    {
        self waittill("spawned_player");
        if(!once)
        {
           self iPrintLnBold("Welcome to ^6iSnipe ^7Server");
           once = 0; 
        }
    }
}
	
isnipe_SendRule( message, duration )
{
    if( !self.__vars["message"] )
    {
        self.__vars["message"] = 1;
        self setLowerMessage( "rule", message, 5 );
        wait ( duration );
	    self clearLowerMessage( "rule" );
        self.__vars["message"] = 0;
    }   
}

isnipe_AntiKinfe()
{
    self notifyOnPlayerCommand("melee","+melee_zoom");
    for(;;)
    {
        self waittill("melee");
        self thread isnipe_SendRule("Knife is ^1not ^7enable on this server", 5);
    }
}
