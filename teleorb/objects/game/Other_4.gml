#macro TILE_SIZE 16

#region INDEX LEVEL
var room_name=room_get_name(room)
music_index=mus_spacetrivia

var digits=string_digits(room_name)
global.inLevel=(string_length(digits)==3)

if global.inLevel
{
	global.currentLevel=string_char_at(room_name,10)
	global.currentLevel=real(global.currentLevel)
	global.currentBranch=string_char_at(room_name,12)
	global.currentBranch=real(global.currentBranch)
	global.currentRoom=string_char_at(room_name,14)
	global.currentRoom=real(global.currentRoom)
	#endregion

	var layid=layer_get_id("ts_collision")
	layer_set_visible(layid,global.debug_mode)
	layid=layer_get_id("lay_collision")
	layer_set_visible(layid,global.debug_mode)

	#region SETUP LEVEL
	if string_char_at(room_name,4)=="l"
	{	
		//audio
		switch global.currentLevel
		{
			case 1:
				music_index=mus_spacetrivia
				break
			case 2:
				music_index=mus_astrorace
				break
			default:
				music_index=mus_synth
				break
		}
		
		ambient_index=amb_cave
		
		//for special levels
		branch_3_start()
		
		//play music
		if !audio_is_playing(music_index)
		{
			audio_stop_all()
			audio_play_sound(music_index,25,true)
		}
		
		//play ambient
		if !audio_is_playing(ambient_index)
		{
			audio_play_sound(ambient_index, 13, true)
		}
	
		//get colmap
		var layid=layer_get_id("ts_collision")
		global.collisionMap=layer_tilemap_get_id(layid)
		layer_set_visible(layid,global.debug_mode)

		//place walls
		doPlatformChecking=false
		layid=layer_get_id("lay_collision")
		if layer_exists(layid)
		{
			var width=room_width div TILE_SIZE
			var height=room_height div TILE_SIZE
	
			var row=0
			var column=0
			var xx,yy,tile,inst
	
			while row!=height
			{
				if column>=width
				{
					row++
					column=0
				}
		
				xx=column*TILE_SIZE
				yy=row*TILE_SIZE
		
				tile=tilemap_get_at_pixel(global.collisionMap,xx,yy)
		
				//set tile
				switch tile
				{
					case 0: //nothing
						break
					case 1: //wall - sprite should be a generic wall
						instance_create_layer(xx,yy,"lay_collision",obj_wall)
						break
					case 2: //orbwall - only blocks orbs, doesn't kill them on impact
						instance_create_layer(xx,yy,"lay_collision",obj_orbwall)
						break
					case 3: //playerwall - only blocks player, orbs go through
						instance_create_layer(xx,yy,"lay_collision",obj_playerwall)
						break
					case 4: //platform
						instance_create_layer(xx,yy,"lay_collision",obj_platform)
						doPlatformChecking=true
						break
					case 5: //nothing
						break
					default: //spikes
						if tile>=6 && tile!=21
						{
							inst=instance_create_layer(xx,yy,"lay_collision",obj_kill)
							inst.image_index=tile-6
						}
						break
				
				}
		
				column++
			}
		}

		//place player
		if instance_exists(obj_playerSpawn)
		{
			var xx,yy
			with obj_playerSpawn
			{
				if spawnpoint==global.spawnpoint
				{
					xx=x
					yy=y
					global.gravityDir = image_yscale
				}
				instance_destroy()
			}
		
			instance_create_layer(xx,yy,"lay_player",obj_player)
		}
		
		//make gravity correct
		with obj_gravity_switcher
		{
			image_angle+=180
		}
	}
}
else
{
	music_index  = -1
	ambient_index = -1
}
#endregion