@tool

extends Marker3D

@onready var raycast := $RayCast3D

@onready var skeleton : Skeleton3D = owner.get_node("mixamo/Armature/Skeleton3D")
@export var bone_name: String
@export var ik : SkeletonIK3D

func _ready():
	raycast.add_exception(owner)
	ik.start()

func _physics_process(_delta):
	var bone = skeleton.find_bone(bone_name)
	var pose = skeleton.get_bone_global_pose_no_override(bone)
	var global_pose = skeleton.to_global(pose.origin)

	global_position.x = global_pose.x
	global_position.z = global_pose.z

	var hit_point = raycast.get_collision_point()
	if hit_point:
		global_position.y = hit_point.y
