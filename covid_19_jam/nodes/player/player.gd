extends KinematicBody
export var MOVE_SPEED=3
const JUMP_FORCE=30
const gravity=.98
const max_fall_speed=30
const M_LOOK_SENS=0.5
const V_look_sens=1
onready var y_vel=0
var jumped
var scale_factor=.03
var scale_mult=0
var sanitizer_use=true 
onready var cam=$cam
onready var ray=$cam/RayCast
onready var hintbar=$Control/HintBar
onready var statsbar=$Control/HintBar2
var move_vec=Vector3(0, 0, 0)


func _ready():
	var pdata=SimulationEngine.get_node("PlayerData")
	if pdata.isWearingMask:
		$cam/mask.show()

func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_look_sens
		cam.rotation_degrees.x =clamp(cam.rotation_degrees.x,-65,90)
		rotation_degrees.y -= event.relative.x * M_LOOK_SENS
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		

func usr_input():
	
	move_vec = Vector3()
	# Take in put from user
	if Input.is_action_pressed("move_forward"):
		move_vec.z-=1
	if Input.is_action_pressed("move_backward"):
		move_vec.z+=1
	if Input.is_action_pressed("move_right"):
		move_vec.x+=1
	if Input.is_action_pressed("move_left"):
		move_vec.x-=1
	if Input.is_action_pressed("crouch"):
		scale_mult=-1
	if Input.is_action_just_released("crouch"):
		scale_mult=+1
func sight():
	var l_o_s = ray.get_collider()
	if ray.is_colliding():
#		print(l_o_s.name)
		match l_o_s.name:
			"door":
#				print("door detected")
				hintbar.show_hint("go to work?")
				if Input.is_action_just_pressed("interact"):
					$Control/fade/fades.play("fade_out")
				
				
			"sanitiser":
				if sanitizer_use:
					hintbar.show_hint("use sanitizer?")
				else:
					statsbar.show_hint("used sanitizer,risk lowered , use again in a while")
				if Input.is_action_just_pressed("interact"):
					sanitizer_use=false
					SimulationEngine.get_node("PlayerData").cleanliness+=.15
			"mask":
				print("mask detected")
				if $cam/mask.visible==false:
					hintbar.show_hint("wear mask?")
					if Input.is_action_just_pressed("interact"):
						$cam/mask.visible=true
						SimulationEngine.get_node("PlayerData").isWearingMask=true
				else:
					hintbar.show_hint("remove mask?")
					if Input.is_action_just_pressed("interact"):
						print("no")
						$cam/mask.visible=false
						SimulationEngine.get_node("PlayerData").isWearingMask=false
			"bed":
#				print("bed detected")
				hintbar.show_hint("call it a day?")
				if Input.is_action_just_pressed("interact"):
					SimulationEngine.get_node("PlayerData").health+=.1
					statsbar.show_hint("health recovered")
			"computer":
#				print("computer detected")
				hintbar.show_hint("take a leave?")
				if Input.is_action_just_pressed("interact"):
					SimulationEngine.get_node("PlayerData").health+=.3
					statsbar.show_hint("health recovered")
			"microscope":
				hintbar.show_hint("research cure?")
				if Input.is_action_just_pressed("interact"):
					SimulationEngine.get_node("PlayerData").health-=.05
					SimulationEngine.get_node("PlayerData").workdone+=1
					statsbar.show_hint("cure progressed")
			"clock":
				hintbar.show_hint("the time is time_var")
			"lab door":
				hintbar.show_hint("go home?")
				if Input.is_action_just_pressed("interact"):
					$Control/fade/fades.play("fade_out")
			"lab computer":
				hintbar.show_hint("cure progress"+str(SimulationEngine.get_node("PlayerData").workLoad*10))
			"testubes":
				hintbar.show_hint("change sample?")
				#by changing samples possibility for next work to give double result
			"StaticBody":
				hintbar.reset()
				statsbar.reset()
	else:
		statsbar.reset()
		hintbar.reset()
func _physics_process(delta):
	
	usr_input()
	crouch()
	
	move_vec= move_vec.normalized()
	move_vec=move_vec.rotated(Vector3(0,1,0),rotation.y)
	move_vec*= MOVE_SPEED
	move_vec.y = y_vel
	move_and_slide(move_vec,Vector3(0,1,0))
	sight()
	
#	var grounded = is_on_floor()
#	if !grounded:
#		y_vel-=gravity
#	if grounded and Input.is_action_just_pressed("jump"):
#		y_vel= JUMP_FORCE
	
	#if y_vel < -max_fall_speed:
	#	y_vel= -max_fall_speed
func crouch():
	scale.y+=scale_factor*scale_mult
	scale.y=clamp(scale.y,.3,.6)
	if scale.y==.6:
		scale_mult=0
	if scale.y==.3:
		scale_mult=0


func _on_fades_animation_finished(anim_name):
	if anim_name =="fade_out":
		if get_parent().name=="doc_room":
			Loader.goto_scene("res://scenes/map/indoors/lab.tscn")
		if get_parent().name=="Laboratory":
			Loader.goto_scene("res://scenes/map/indoors/bed_room.tscn")


func _on_sanitizer_cooldown_timeout():
	sanitizer_use=true
