extends CharacterBody3D




enum States{
	patrol,
	chasing,
	hunting,
	waiting
}



@onready var navigationAgent := $NavigationAgent3D
@onready var patrolTimer := $PatrolTimer
@onready var player = get_tree().get_nodes_in_group("Player")[0]

@export var waypoints : Array
@export var chaseSpeed = 3
@export var patrolSpeed = 2


var currentState : States
var waypointIndex : int

var playerInEarshotFar : bool
var playerInEarshotClose : bool
var playerInSightFar : bool
var playerInSightClose : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = States.patrol
	waypoints = get_tree().get_nodes_in_group("EnemyWaypoint")
	navigationAgent.set_target_position(waypoints[0].global_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(currentState):
		States.patrol:
			if(navigationAgent.is_navigation_finished()):
				currentState = States.waiting
				patrolTimer.start()
				return
			MoveTowardsPoint(delta, patrolSpeed)

		States.chasing:
			if(navigationAgent.is_navigation_finished()):
				patrolTimer.start()
				currentState = States.waiting
			navigationAgent.set_target_positon(player.global_positon)
			MoveTowardsPoint(delta,chaseSpeed)

		States.hunting:
			if(navigationAgent.is_navigation_finished()):
				patrolTimer.start()
				currentState = States.waiting
			
			MoveTowardsPoint(delta,patrolSpeed)
		States.waiting:
			pass

func MoveTowardsPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()
	if(playerInEarshotFar):
		CheckForPlayer()

func CheckForPlayer():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, player.get_node("Camera3D").global_position, 1, [self]))
	if result.size() > 0:
		if(result["collider"].is_in_group("Player")):
			

			if(playerInEarshotClose):
				if(result["collider"].crouched == false):
					currentState = States.chasing
					
			if(playerInEarshotFar):
				if(result["collider"].crouched == false):
					currentState = States.hunting
					navigationAgent.set_target_positon(player.global_positon)
					
			if(playerInSightClose):
				currentState = States.chasing
				
			if(playerInSightFar):
				if(result["collider"].crouched == false):
					currentState = States.hunting
					navigationAgent.set_target_positon(player.global_positon)

func faceDirection(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y,direction.z),Vector3.UP)

func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	if waypointIndex > waypoints.size() - 1:
		waypointIndex = 0
	navigationAgent.set_target_position(waypoints[waypointIndex].global_position)


func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"):
		playerInEarshotFar = true
		print("The Player Has Entered Far Earshot")
	pass # Replace with function body.


func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"):
		playerInEarshotFar = false
		print("The Player Has Exited Far Earshot")
	pass # Replace with function body.


func _on_hearing_close_body_entered(body):
	if body.is_in_group("Player"):
		playerInEarshotClose = true
		print("The Player Has Entered Close Earshot")
	pass # Replace with function body.

func _on_hearing_close_body_exited(body):
	if body.is_in_group("Player"):
		playerInEarshotClose = false
		print("The Player Has Exited Close Earshot")
	pass # Replace with function body.


func _on_sight_far_body_entered(body):
	if body.is_in_group("Player"):
		playerInSightFar = true
		print("The Player Has Entered Far Sight")
	pass # Replace with function body.


func _on_sight_far_body_exited(body):
	if body.is_in_group("Player"):
		playerInSightFar = false
		print("The Player Has Exited Far Sight")
	pass # Replace with function body.


func _on_sight_close_body_entered(body):
	if body.is_in_group("Player"):
		playerInSightClose = true
		print("The Player Has Entered Close Sight")
	pass # Replace with function body.


func _on_sight_close_body_exited(body):
	if body.is_in_group("Player"):
		playerInSightClose = false
		print("The Player Has Exited Close Sight")
	pass # Replace with function body.
