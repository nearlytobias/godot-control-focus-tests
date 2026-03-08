@abstract
extends RefCounted
class_name InputImplementation

class DrawPoint:
	func _init(position: Vector2, color: Color) -> void:
		self.position = position
		self.color = color

	var position: Vector2
	var color: Color

class DrawCircle extends DrawPoint:
	func _init(position: Vector2, color: Color, radius: float) -> void:
		super._init(position, color)
		self.radius = radius
	
	var radius: float

var _debug_draw_points : Array[DrawPoint]
var _print_scores := false

func add_draw_point(position: Vector2, color: Color):
	var point := DrawPoint.new(position, color)
	_debug_draw_points.push_back(point)
	
func add_draw_circle(position_from: Vector2, position_to, color: Color):
	var center = lerp(position_from, position_to, 0.5)
	var radius = (position_from - position_to).length() / 2.0
	var circle := DrawCircle.new(center, color, radius)
	_debug_draw_points.push_back(circle)

## Friendly name to be shown on UI
@abstract func friendly_name() -> String

## Called when object is constructed
@abstract func _begin() -> void

## Called when object is destructed
@abstract func _end() -> void

## Called with a normalized input direction, a node array of all Controls in the scene, and the
## currently focused Control node.
## Should return a Control node to be focused. If no candidate was found, then it should
## return the currently focused Control, or `null` to default to native Godot behavior
@abstract func _input(input_dir: Vector2, nodes: Array[Control], current_node: Control) -> Control


func intersect_rect_with_dir(rect: Rect2, start: Vector2, dir: Vector2) -> Vector2:
	## Note: AI generated util function 
	
	# Normalizamos a direção para garantir consistência no cálculo de 't'
	var d = dir.normalized()
	
	# Usamos uma constante pequena para evitar divisão por zero
	var tx_min = (rect.position.x - start.x) / (d.x if d.x != 0 else 1e-10)
	var tx_max = (rect.end.x - start.x) / (d.x if d.x != 0 else 1e-10)
	var ty_min = (rect.position.y - start.y) / (d.y if d.y != 0 else 1e-10)
	var ty_max = (rect.end.y - start.y) / (d.y if d.y != 0 else 1e-10)

	# No Godot, como Y é invertido, garantimos que min é o menor e max o maior
	var t_near = max(min(tx_min, tx_max), min(ty_min, ty_max))
	var t_far = min(max(tx_min, tx_max), max(ty_min, ty_max))

	# Se t_far < 0, o retângulo está atrás de nós
	# Se t_near > t_far, o raio falha o retângulo completamente
	if t_far < 0 or t_near > t_far:
		return Vector2.ZERO 

	# Se t_near < 0, estamos dentro do rect; o próximo ponto de impacto é t_far (a saída)
	var t_hit = t_near if t_near >= 0 else t_far
	
	return start + d * t_hit
