extends BalloonImplementation

## Balloon center implementation. This variant uses the center positions of other control nodes

func friendly_name() -> String:
	return "Balloon (with center points)"

func calculate_candidate_point(starting_point: Vector2, input_dir: Vector2, candidate_rect: Rect2, candidate_transform: Transform2D) -> Vector2:
	return candidate_transform * candidate_rect.get_center()
