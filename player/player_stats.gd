extends Resource
class_name PlayerStats

@export_group("Ground Movement")
@export var max_walk_speed: float 
@export var stopping_acceleration: float
@export var walking_acceleration: float

@export_group("Air Movement")
@export var airstrafing_acceleration: float
@export var airstopping_acceleration: float

@export_group("Jumping")

@export var jump_speed: float
@export var jump_time: float
@export var coyote_time: float

@export_group("Walljump")
@export var walljump_horizontal_speed: float
@export var walljump_vertical_speed: float
@export var walljump_cancel_time: float

@export_group("Gravity")
@export var fall_gravity: float
@export var jump_gravity: float

@export_group("Orb") 
@export var orb_speed: float
@export var orb_lifespan: float
