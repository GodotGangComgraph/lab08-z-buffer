extends Control


var edge_length = 100

var spatial
var axis = F.Axis.new()

var axonometric_matrix = F.AffineMatrices.get_axonometric_matrix(35.26, 45)
var perspective_matrix = F.AffineMatrices.get_perspective_matrix(-300)
var projection_matrix = axonometric_matrix

var is_auto_rotating = false

var frame_count = 0

var hue_shift = 0.2
var color_speed = 0.1

var point_start: Array

## Translation values
@onready var translate_dx: LineEdit = $HBox/MarginContainer/Menu/Translate/dx
@onready var translate_dy: LineEdit = $HBox/MarginContainer/Menu/Translate/dy
@onready var translate_dz: LineEdit = $HBox/MarginContainer/Menu/Translate/dz

## Rotation values (don't forget deg_to_rad)
@onready var rotate_ox: LineEdit = $HBox/MarginContainer/Menu/Rotate/ox
@onready var rotate_oy: LineEdit = $HBox/MarginContainer/Menu/Rotate/oy
@onready var rotate_oz: LineEdit = $HBox/MarginContainer/Menu/Rotate/oz

## Rotation Line values
@onready var rotate_line_x_1: LineEdit = $HBox/MarginContainer/Menu/RotateLine/x1
@onready var rotate_line_y_1: LineEdit = $HBox/MarginContainer/Menu/RotateLine/y1
@onready var rotate_line_z_1: LineEdit = $HBox/MarginContainer/Menu/RotateLine/z1
@onready var rotate_line_x_2: LineEdit = $HBox/MarginContainer/Menu/RotateLine/x2
@onready var rotate_line_y_2: LineEdit = $HBox/MarginContainer/Menu/RotateLine/y2
@onready var rotate_line_z_2: LineEdit = $HBox/MarginContainer/Menu/RotateLine/z2
@onready var deg: LineEdit = $HBox/MarginContainer/Menu/RotateLine/deg

## Scale values
@onready var scale_mx: LineEdit = $HBox/MarginContainer/Menu/Scale/mx
@onready var scale_my: LineEdit = $HBox/MarginContainer/Menu/Scale/my
@onready var scale_mz: LineEdit = $HBox/MarginContainer/Menu/Scale/mz

var world_center: Vector3 = Vector3(450, 300, 0)

func _ready():
	spatial = F.Spatial.new()
	#point_start = spatial.points_start
	spatial.translate(world_center.x, world_center.y, world_center.z)
	axis.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()
	
@onready var check_box: CheckBox = $HBox/MarginContainer/Menu2/Point/CheckBox

func _unhandled_input(event: InputEvent) -> void:
	if not check_box.button_pressed:
		return
	
	if event is InputEventMouse:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.is_pressed():
			var mouse_pos = event.global_position
			print(mouse_pos)
			point_start.append(F.Point.new(mouse_pos.x, mouse_pos.y, 0))
			queue_redraw()

func _draw() -> void:
	draw_by_faces(spatial)
	draw_axes()
	draw_line(p1_line.get_vec2d(), p2_line.get_vec2d(), Color.BLUE)
	draw_points()

func draw_points():
	for point in point_start:
		var p = point.duplicate()
		#p.translate(world_center.x, world_center.y, world_center.z)
		p.apply_matrix(projection_matrix)
		draw_circle(p.get_vec2d(), 3, Color.AQUAMARINE)

func draw_by_faces(obj: F.Spatial):
	for face in obj.faces:
		var old_point = obj.points[face[0]].duplicate()
		old_point.apply_matrix(projection_matrix)
		
		var face_color = get_edge_color()
		
		for index in face.slice(1, face.size()):
			var p = obj.points[index].duplicate()
			p.apply_matrix(projection_matrix)
			draw_line(old_point.get_vec2d(), p.get_vec2d(), face_color, 0.5, true)
			old_point = p
		var first_point = obj.points[face[0]].duplicate()
		first_point.apply_matrix(projection_matrix)
		draw_line(first_point.get_vec2d(), old_point.get_vec2d(), face_color, 0.5, true)

func get_edge_color() -> Color:
	var dynamic_color = Color.from_hsv(hue_shift, 0.8, 0.9)
	return dynamic_color

func _process(delta: float) -> void:
	if not is_auto_rotating:
		return
	
	hue_shift += color_speed * delta
	hue_shift = fmod(hue_shift, 1.0)
	
	var vec = spatial.get_middle()
	spatial.rotation_about_center(vec, 0.5, 0.5, 0.5)
	
	queue_redraw()

func draw_axes():
	var colors = [Color.RED, Color.GREEN, Color.BLUE]
	for i in range(3):
		var p1: F.Point = axis.points[axis.faces[i][0]].duplicate()
		var p2: F.Point = axis.points[axis.faces[i][1]].duplicate()
		p1.apply_matrix(projection_matrix)
		p2.apply_matrix(projection_matrix)
		draw_line(p1.get_vec2d(), p2.get_vec2d(), colors[i], 0.5, true)
		draw_line(p1.get_vec2d(), p1.get_vec2d()-(p2.get_vec2d() - p1.get_vec2d()), colors[i], 0.5, true)

var p1_line: F.Point = F.Point.new(0, 0, 0)
var p2_line: F.Point = F.Point.new(0, 0, 0)

func _on_clear_pressed() -> void:
	get_tree().reload_current_scene()


func _on_mirror_ox_pressed() -> void:
	spatial.translate(-world_center.x, -world_center.y, -world_center.z)
	spatial.miror(1, 1, -1)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


func _on_mirror_oy_pressed() -> void:
	spatial.translate(-world_center.x, -world_center.y, -world_center.z)
	spatial.miror(1, -1, 1)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


func _on_mirror_oz_pressed() -> void:
	spatial.translate(-world_center.x, -world_center.y, -world_center.z)
	spatial.miror(-1, 1, 1)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


func _on_apply_trans_pressed() -> void:
	spatial.translate(float(translate_dx.text), float(translate_dy.text), float(translate_dz.text))
	queue_redraw()


func _on_apply_rot_pressed() -> void:
	spatial.rotation_about_x(float(rotate_ox.text))
	spatial.rotation_about_y(float(rotate_oy.text))
	spatial.rotation_about_z(float(rotate_oz.text))
	queue_redraw()

func _on_apply_rot_center_pressed() -> void:
	var vec = spatial.get_middle()
	spatial.rotation_about_center(vec, float(rotate_ox.text), float(rotate_oy.text), float(rotate_oz.text))
	queue_redraw()


func read_scale() -> Vector3:
	var mx: float = 0
	var my: float = 0
	var mz: float = 0
	if scale_mx.text == "":
		mx = 1
	else:
		mx = float(scale_mx.text)
	if scale_my.text == "":
		my = 1
	else:
		my = float(scale_my.text)
	if scale_mz.text == "":
		mz = 1
	else:
		mz = float(scale_mz.text)
	return Vector3(mx, my, mz)

func _on_apply_scale_pressed() -> void:
	var vec3 = read_scale()
	var mx: float = vec3.x
	var my: float = vec3.y
	var mz: float = vec3.z
	
	spatial.translate(-world_center.x, -world_center.y, -world_center.z)
	spatial.scale_(mx, my, mz)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


func _on_apply_scale_center_pressed() -> void:
	var vec3 = read_scale()
	var mx: float = vec3.x
	var my: float = vec3.y
	var mz: float = vec3.z
	var vec = spatial.get_middle()
	spatial.scale_about_center(vec, mx, my, mz)
	queue_redraw()


func _on_apply_rotate_line_pressed() -> void:
	var x1 = float(rotate_line_x_1.text)
	var y1 = float(rotate_line_y_1.text)
	var z1 = float(rotate_line_z_1.text)
	var x2 = float(rotate_line_x_2.text)
	var y2 = float(rotate_line_y_2.text)
	var z2 = float(rotate_line_z_2.text)
	
	var line: Vector3 = Vector3(x2-x1, y2-y1, z2-z1)
	var p: F.Point = F.Point.new(x1, y1, z1)
	p.translate(world_center.x, world_center.y, world_center.z)
	spatial.rotation_about_line(p, line, float(deg.text))
	
	p1_line = F.Point.new(x1, y1, z1)
	p2_line= F.Point.new(x2, y2, z2)
	p1_line.translate(world_center.x, world_center.y, world_center.z)
	p2_line.translate(world_center.x, world_center.y, world_center.z)
	
	var matrix = F.AffineMatrices.get_axonometric_matrix(35.26, 45)
	p1_line.apply_matrix(matrix)
	p2_line.apply_matrix(matrix)
	
	queue_redraw()


func _on_option_button_2_item_selected(index: int) -> void:
	match index:
		0: 
			projection_matrix = axonometric_matrix
			#world_center = world_center_axonometric
		1: 
			projection_matrix = perspective_matrix
			#world_center = world_center_perspective
	queue_redraw()


func _on_check_box_toggled(toggled_on: bool) -> void:
	is_auto_rotating = toggled_on

@onready var divisions: LineEdit = $HBox/MarginContainer/Menu2/HBoxContainer/Divisions
@onready var option_button: OptionButton = $HBox/MarginContainer/Menu2/OptionButton

func _on_create_pressed() -> void:
	spatial = F.RotationSpatial.new()
	spatial.clear()
	spatial.num_segments = divisions.value
	spatial.mid_point = F.Point.new(0,0,0)
	spatial.mid_point.translate(world_center.x, world_center.y, world_center.z)
	spatial.world_center = world_center
	
	match option_button.selected:
		0:
			spatial.fun = func(angle): return F.AffineMatrices.get_rotation_matrix_about_x(angle)
		1:
			spatial.fun = func(angle): return F.AffineMatrices.get_rotation_matrix_about_y(angle)
		2:
			spatial.fun = func(angle): return F.AffineMatrices.get_rotation_matrix_about_z(angle)
	
	spatial.points_start = point_start
	
	spatial.create()
	#spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


@onready var menus = [
	$HBox/MarginContainer/Menu2,
	$HBox/MarginContainer/Menu3,
	$HBox/MarginContainer/Menu,
]

func _on_change_item_selected(index: int) -> void:
	for i in range(3):
		menus[i].visible = false
	menus[index].visible = true
	
@onready var x_0: LineEdit = $HBox/MarginContainer/Menu3/HBoxContainer/Point/x0
@onready var x_1: LineEdit = $HBox/MarginContainer/Menu3/HBoxContainer/Point/x1
@onready var y_0: LineEdit = $HBox/MarginContainer/Menu3/HBoxContainer/Point/y0
@onready var y_1: LineEdit = $HBox/MarginContainer/Menu3/HBoxContainer/Point/y1
@onready var step: LineEdit = $HBox/MarginContainer/Menu3/HBoxContainer/Step

var possible_funcs = [
	func(x, y): return cos(x + y),
	func(x, y): return cos(x*x+y*y)/(x*x+y*y+1)
]
var selected_func = possible_funcs[0]

func _on_create_f_pressed() -> void:
	spatial = F.FunctionSurface.new()
	spatial.create(x_0.value, x_1.value, y_0.value, y_1.value, step.value, selected_func)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()
	
func _on_function_button_item_selected(index: int) -> void:
	selected_func = possible_funcs[index]

@onready var save_file_dialog: FileDialog = $HBox/MarginContainer2/VBoxContainer/SaveFileDialog


func _on_save_pressed() -> void:
	save_file_dialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	spatial.translate(-world_center.x, -world_center.y, -world_center.z)
	spatial.save_from_obj(path)


@onready var load_file_dialog: FileDialog = $HBox/MarginContainer2/VBoxContainer/LoadFileDialog

func _on_load_pressed() -> void:
	load_file_dialog.show()


func _on_load_file_dialog_file_selected(path: String) -> void:
	spatial = F.Spatial.new()
	spatial.load_from_obj(path)
	spatial.translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()
