@abstract
extends InputImplementation
class_name BalloonImplementation

## Base balloon implementation. Extending classes tweak the chosen candidate
## point

## Why oh why doesn't Godot have tuples ;-;
class Candidate:
	const UNDEFINED_SCORE = -1

	func _init(node: Control, point: Vector2, score: float = UNDEFINED_SCORE) -> void:
		self.node = node
		self.point = point
		self.score = score

	var node : Control
	var point : Vector2
	var score : float

	func print_score():
		node.text = "*" if score == UNDEFINED_SCORE else "%.2f" % score

	func is_higher(other: Candidate) -> bool:
		if score == UNDEFINED_SCORE and other.score != UNDEFINED_SCORE:
			return true
		if score != UNDEFINED_SCORE and other.score == UNDEFINED_SCORE:
			return false
		return other.score > score

# Given a starting point, a direction, and the candidate's global rect, return the intersection point to consider for calculations.
@abstract func calculate_candidate_point(starting_point: Vector2, input_dir: Vector2, candidate_rect: Rect2) -> Vector2

func _begin() -> void:
	pass

func _end() -> void:
	pass

func _input(input_dir: Vector2, nodes: Array[Control], current_node: Control) -> Control:
	# Following the algorithm:
	
	# 1. Compute the starting point.
	#    (we will assume bounding boxes to facilitate math)
	var control_rect := current_node.get_global_rect()
	var starting_point := intersect_rect_with_dir(control_rect, control_rect.get_center(), input_dir)
	add_draw_point(starting_point, Color.GREEN)
	
	# 2. Calculate score iteratively, storing a pair of <controlNode, score> for the lowest score
	var candidate = Candidate.new(current_node, starting_point)
	if _print_scores: candidate.print_score()
	for node in nodes:
		var node_point = calculate_candidate_point(starting_point, input_dir, node.get_global_rect())
		add_draw_point(node_point, Color.AQUA)
		var node_distance =  node_point - starting_point
		var other_candidate = Candidate.new(
			node,
			node_point,
			input_dir.dot(node_distance) / node_distance.length_squared()
		)
		if _print_scores: other_candidate.print_score()
		if candidate.is_higher(other_candidate):
			candidate = other_candidate
	
	# 3. Return the candidate node only if the score is positive;
	#    otherwise, maintain focus on current node
	if candidate.score > 0:
		add_draw_circle(starting_point, candidate.point, Color.DARK_CYAN)
	return candidate.node if candidate.score > 0 else current_node
