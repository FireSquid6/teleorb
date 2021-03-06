function state_wallride()
{	
	//wallriding
	vspd+=wallrideGrv * global.gravityDir
	air_friction()
	if wallgrab vspd=0
	if wallgrab_released vspd=1
	
	//FALL
	if !check_wallride() 
	{
		moveto_fall()
		walljumpBufferFrames=maxWalljumpBufferFrames
	}
	
	//JUMP
	if jump_pressed
	{
		walljump()
	}
	
	//MOVE
	if onFloor moveto_move()
}

function moveto_wallride()
{
	image_index=0
	image_speed=0
	sprite_index=spr_player_wallsliding
	lastState=state
	state=playerStates.wallriding
	if vspd>0 vspd=0
	cyoteFrames=0
}

function check_wallride()
{
	var i=sign(hspd)
	if place_meeting(x+i,y,obj_wall) && move!=0
	{
		wallrideDir=i
		return true
	}
	
	return false
}

function walljump()
{
	airFrictionCancelFrames=maxAirFrctionCancelFrames
	hspd=wallrideJumpSpd*wallrideDir
	vspd=0
	vspd_frac=0
	moveto_jump()
}