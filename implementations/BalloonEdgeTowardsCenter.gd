extends BalloonImplementation

## Balloon edge-towards-center implementation. This variant calculates an edge position in direction to the
## candidate's center, being an approximation to a true edge algorithm.

func friendly_name() -> String:
	return "Balloon (with edge-toward-center points)"

func calculate_candidate_point(starting_point: Vector2, input_dir: Vector2, candidate_rect: Rect2, candidate_transform: Transform2D) -> Vector2:
	candidate_rect.position += candidate_transform.origin
	
	var center = candidate_rect.get_center()
	var node_dir = starting_point - center
	var candidate_point = intersect_rect_with_dir(candidate_rect, center, node_dir)
	candidate_point -= candidate_transform.origin
	candidate_point = candidate_transform * candidate_point
	return candidate_point
