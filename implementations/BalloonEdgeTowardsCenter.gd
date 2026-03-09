extends BalloonImplementation

## Balloon edge-towards-center implementation. This variant calculates an edge position in direction to the
## candidate's center, being an approximation to a true edge algorithm.

func friendly_name() -> String:
	return "Balloon (with edge-toward-center points)"

func calculate_candidate_point(starting_point: Vector2, input_dir: Vector2, candidate_rect: Rect2) -> Vector2:
	var node_dir = starting_point - candidate_rect.get_center()
	return intersect_rect_with_dir(candidate_rect, candidate_rect.get_center(), node_dir)
