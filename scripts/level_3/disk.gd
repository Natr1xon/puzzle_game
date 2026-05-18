extends Panel

var disk_size: int
var colors = [
	Color(0.95, 0.3, 0.3),
	Color(0.3, 0.95, 0.3), 
	Color(0.95, 0.95, 0.3), 
	Color(0.3, 0.5, 0.95),
	Color(0.95, 0.6, 0.3)  
]

var tween: Tween
var is_animating = false
var default_style: StyleBoxFlat
var is_highlighted = false

func setup(s: int):
	disk_size = s
	var width = 20 * s
	var height = 20
	self.size = Vector2(width, height)
	
	apply_style(false)

func apply_style(is_highlight: bool):
	var style = StyleBoxFlat.new()
	style.bg_color = colors[disk_size - 1]
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.anti_aliasing = false  
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	style.shadow_color = Color(0, 0, 0, 0.3)
	
	if is_highlight:
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = Color.WHITE
		style.shadow_size = 0
	
	add_theme_stylebox_override("panel", style)

func highlight(enabled: bool):
	is_highlighted = enabled
	apply_style(enabled)

func reset_style():
	add_theme_stylebox_override("panel", default_style.duplicate())

func animate_move_to(new_position: Vector2, duration: float = 0.15):
	if is_animating:
		return
	
	var had_highlight = is_highlighted
	if had_highlight:
		apply_style(false)
	
	is_animating = true

	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "position", new_position, duration)

	var original_scale = scale
	tween.parallel().tween_property(self, "scale", Vector2(1.05, 0.95), duration * 0.3)
	tween.tween_property(self, "scale", original_scale, duration * 0.7)
	
	await tween.finished

	if had_highlight:
		apply_style(true)
	
	is_animating = false
