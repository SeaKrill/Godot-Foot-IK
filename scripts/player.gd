extends CharacterBody3D

@onready var spring_arm_pivot := $SpringArmPivot
@onready var spring_arm := $SpringArmPivot/SpringArm3D
@onready var anim_tree := $AnimationTree
@onready var model := $mixamo
@onready var skeleton := $mixamo/Armature/Skeleton3D

const JUMP_VELOCITY = 4.5

var mouse_sensitivity = 0.15
var look_speed = 7.0
var jump_strength = 10
var acceleration = 0.15

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var turn_motion := Vector3.ZERO
var walk_motion := Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	velocity.y -= gravity
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(raw_input.x, 0, raw_input.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y) * quaternion
	
	if direction:
		turn_motion = lerp(turn_motion, direction, acceleration)

		model.rotation.y = lerp_angle(model.rotation.y, atan2(turn_motion.x, turn_motion.z), delta * look_speed)

	else:
		turn_motion = lerp(turn_motion, Vector3.ZERO, acceleration)
		
	walk_motion = walk_motion.lerp(direction, acceleration)
	anim_tree.set("parameters/Movement/blend_position", walk_motion.length())
	
	var current_rotation = model.get_quaternion() * quaternion
	var v = current_rotation * anim_tree.get_root_motion_position() / delta
	
	_ik_interp($mixamo/Armature/Skeleton3D/IK_R, "mixamorig_RightFoot")
	_ik_interp($mixamo/Armature/Skeleton3D/IK_L, "mixamorig_LeftFoot")
	
	velocity.x = v.x
	velocity.z = v.z
	
	move_and_slide()

func _ik_interp(foot:SkeletonIK3D, bone:String):
	var r = skeleton.get_bone_pose_rotation(skeleton.find_bone(bone)).get_euler()
	var c = 1 if snappedf(r.x, 0.1) > 1 else 0
	foot.interpolation = lerpf(foot.interpolation, c, 0.15)
	
