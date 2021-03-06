//setup vars
move = keyboard_check(ord("D")) - keyboard_check(ord("A"));
jump = keyboard_check(vk_space) || keyboard_check(ord("W"));
jump_pressed = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("W"));
onFloor = place_meeting(x,y+global.gravityDir,obj_wall)
wallgrab = keyboard_check(vk_lshift)
wallgrab_released=keyboard_check_released(vk_shift)

if global.orbUnlocked orb = mouse_check_button_pressed(mb_left)
if global.dashUnlocked dash = mouse_check_button_pressed(mb_right)
if global.slideUnlocked slide = keyboard_check(vk_lcontrol)

//set image xscale
if move!=0 image_xscale=move

//set image yscale
image_yscale=global.gravityDir

//visible toggle
if DEVELOPER_MODE
{
	var keycheck = keyboard_check_pressed(ord("V"))
	if keycheck drawself = !drawself
}

//orb
throw_orb()

//add fractions
hspd+=hspd_frac
vspd+=vspd_frac

//state
switch state
{
	case playerStates.moving:
		state_move()
		break
	case playerStates.wallriding:
		state_wallride()
		break
	case playerStates.jumping:
		state_jump()
		break
	case playerStates.falling:
		state_fall()
		break
	case playerStates.teleporting:
		state_teleport()
		break
	case playerStates.dying:
		state_die()
		break
}

//move self
move_self()

//orbwall
var inOrbwall=false

if !place_meeting(x,y,obj_wall)
{
	inOrbwall=place_meeting(x,y,obj_orbwall) 
	if inOrbwall!=lastInOrbwall audio_play_sound(sfx_slime,25,false)
}

//lastmove
lastMove=move
lastInOrbwall=inOrbwall