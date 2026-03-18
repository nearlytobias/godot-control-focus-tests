extends BalloonImplementation

## Balloon edge implementation. This variant calculates the true edge point from
## a "growing balloon" metaphor.

## Algorithm author: @runevision (https://gist.github.com/runevision/970445fa11280def3e8be241fd3dc720)

func friendly_name() -> String:
	return "Balloon (with edge points)"

func calculate_candidate_point(starting_point: Vector2, input_dir: Vector2, candidate_rect: Rect2, candidate_transform: Transform2D) -> Vector2:
	var score := -1e10
	var touch := Vector2.ZERO
	

	# The four corners of the rect
	var PA : Vector2 = candidate_transform * candidate_rect.position
	var PB : Vector2 = candidate_transform * Vector2(candidate_rect.end.x, candidate_rect.position.y)
	var PC : Vector2 = candidate_transform * candidate_rect.end
	var PD : Vector2 = candidate_transform * Vector2(candidate_rect.position.x, candidate_rect.end.y)

	# Iterative version of original lambda based algorithm, because
	# Godot lambdas apparently can't modify variables
	# in function scope (aka are akin to C++ by-value)
	var sides = [
		[PA, PB],
		[PB, PC],
		[PC, PD],
		[PD, PA]
	]

	for side in sides:
		var p1 = side[0]
		var p2 = side[1]

		var new_touch = balloon_score_line_segment(starting_point, input_dir, p1, p2)
		var new_score = balloon_score_point(starting_point, input_dir, new_touch)

		if new_score > score:
			score = new_score
			touch = new_touch
	return touch

func balloon_score_point(start: Vector2, dir: Vector2, point: Vector2) -> float:
	var vec := point - start
	return dir.dot(vec) / vec.length_squared()

func balloon_score_line_segment(start: Vector2, dir: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	var lineVec := p2 - p1 
	var normal := Vector2(-lineVec.y, lineVec.x).normalized()
	var intersectDir := (dir + normal)
	var touch = intersect(start, start + intersectDir, p1, p2)
	if ((touch - p2).dot(p1 - p2) < 0):
		touch = p2
	if ((touch - p1).dot(p2 - p1) < 0):
		touch = p1
	return touch

func intersect(line1A: Vector2, line1B: Vector2, line2A: Vector2, line2B: Vector2):
	# Line 1
	var A1 : float = line1B.y - line1A.y
	var B1 : float = line1A.x - line1B.x
	var C1 : float = A1 * line1A.x + B1 * line1A.y

	# Line 2
	var A2 : float = line2B.y - line2A.y
	var B2 : float = line2A.x - line2B.x
	var C2 : float = A2 * line2A.x + B2 * line2A.y

	var det : float = A1 * B2 - A2 * B1
	if is_zero_approx(det):
		# Parallel lines
		return Vector2.INF
	
	var x : float = (B2 * C1 - B1 * C2) / det
	var y : float = (A1 * C2 - A2 * C1) / det
	return Vector2(x, y)
