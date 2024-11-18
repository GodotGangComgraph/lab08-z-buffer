extends Control


var edge_length = 100

var spatials = []
var spatial_index = 0
var colors = []
var available_colors = [Color.RED, Color.GREEN, Color.BLUE, Color.AQUAMARINE, Color.BLUE_VIOLET]
var color_names = ["RED", "GREEN", "BLUE", "AQUAMARINE", "BLUE VIOLET"]
var spatial_names = ["CUBE", "TETRAHEDRON"]
var axis = F.Axis.new()

var c = 100
var projection_matrix = F.AffineMatrices.get_perspective_matrix(c)
var view_vector: Vector3 = Vector3.ZERO

var is_auto_rotating = false

var frame_count = 0

var hue_shift = 0.2
var color_speed = 0.1

var point_start: Array

## Translation values
@onready var translate_dx: LineEdit = %Menu/Translate/dx
@onready var translate_dy: LineEdit = %Menu/Translate/dy
@onready var translate_dz: LineEdit = %Menu/Translate/dz

## Rotation values (don't forget deg_to_rad)
@onready var rotate_ox: LineEdit = %Menu/Rotate/ox
@onready var rotate_oy: LineEdit = %Menu/Rotate/oy
@onready var rotate_oz: LineEdit = %Menu/Rotate/oz

## Scale values
@onready var scale_mx: LineEdit = %Menu/Scale/mx
@onready var scale_my: LineEdit = %Menu/Scale/my
@onready var scale_mz: LineEdit = %Menu/Scale/mz

var world_center: Vector3 = Vector3(400, 400, 100)

var camera_position = Vector3(100, 100, 100)
var camera_target = Vector3(0, 0, 0)
var camera_speed = 40

var z_buffer = []


func reset_z_buffer():
	z_buffer.clear()
	for y in range(get_window().size.y):
		var row = []
		for x in range(get_window().size.x):
			row.append(-INF)
		z_buffer.append(row)

func _ready():
	axis.translate(world_center.x, world_center.y, world_center.z)
	
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	pass
	

func _draw() -> void:
	reset_z_buffer()
	view_vector = (camera_target - camera_position).normalized()
	draw_axes()
	for i in range(spatials.size()):
		spatials[i].calculate_normals()
		spatials[i].remove_back_faces(view_vector)
		draw_by_faces(spatials[i], colors[i])

func draw_by_faces(obj: F.Spatial, color: Color):
	for face in obj.visible_faces:
		var points = []
		var zarray = []
		var colors = []
		for point in face:
			var to_insert = obj.points[point].duplicate()
			zarray.append(to_insert.z)
			to_insert.apply_matrix(F.AffineMatrices.get_mvp_matrix(world_center, camera_position, camera_target, c))
			points.append(to_insert.get_vec2d())
			colors.append(Color(randf(), randf(), randf()))
		rasterize(points, colors, zarray)

func rasterize(points, colors, zarray):
	var min_x = 0
	var min_y = 0
	var max_x = get_window().size.x
	var max_y = get_window().size.y
	
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var p = Vector2(x, y)
			
			var lambda1 = ((points[1].y - points[2].y) * (p.x - points[2].x) \
			+ (points[2].x - points[1].x) * (p.y - points[2].y)) / ((points[1].y - points[2].y) \
			* (points[0].x - points[2].x) + (points[2].x - points[1].x) * (points[0].y - points[2].y))
			
			var lambda2 = ((points[2].y - points[0].y) * (p.x - points[2].x) \
			+ (points[0].x - points[2].x) * (p.y - points[2].y)) / ((points[1].y - points[2].y) \
			* (points[0].x - points[2].x) + (points[2].x - points[1].x) * (points[0].y - points[2].y))
			
			var lambda3 = 1.0 - lambda1 - lambda2
			
			if lambda1 >= 0.0 and lambda2 >= 0.0 and lambda3 >= 0.0:
				var interpolated_color = colors[0] * lambda1 + colors[1] * lambda2 + colors[2] * lambda3
				
				var interpolated_z = zarray[0] * lambda1 + zarray[1] * lambda2 + zarray[2] * lambda3
				
				#var depth = view_vector.dot(Vector3(x, y, interpolated_z)-camera_position)
				if 1e-6 < interpolated_z - z_buffer[y][x]:
					z_buffer[y][x] = interpolated_z
					draw_primitive([p], [interpolated_color], [Vector2(0, 0)])



func _process(delta: float) -> void:
	pass

func draw_axes():
	var colors_axes = [Color.RED, Color.GREEN, Color.BLUE]
	for i in range(3):
		var p1: F.Point = axis.points[axis.faces[i][0]].duplicate()
		var p2: F.Point = axis.points[axis.faces[i][1]].duplicate()
		p1.apply_matrix(F.AffineMatrices.get_mvp_matrix(world_center, camera_position, camera_target, c))
		p2.apply_matrix(F.AffineMatrices.get_mvp_matrix(world_center, camera_position, camera_target, c))
		draw_line(p1.get_vec2d(), p2.get_vec2d(), colors_axes[i], 0.5, true)
		draw_line(p1.get_vec2d(), p1.get_vec2d()-(p2.get_vec2d() - p1.get_vec2d()), colors_axes[i], 0.5, true)
		
func _on_clear_pressed() -> void:
	get_tree().reload_current_scene()

func _on_apply_trans_pressed() -> void:
	spatials[spatial_index].translate(float(translate_dx.text), float(translate_dy.text), float(translate_dz.text))
	queue_redraw()

func _on_apply_rot_pressed() -> void:
	spatials[spatial_index].rotation_about_x(float(rotate_ox.text))
	spatials[spatial_index].rotation_about_y(float(rotate_oy.text))
	spatials[spatial_index].rotation_about_z(float(rotate_oz.text))
	queue_redraw()

func _on_apply_rot_center_pressed() -> void:
	var vec = spatials[spatial_index].get_middle()
	spatials[spatial_index].rotation_about_center(vec, float(rotate_ox.text), float(rotate_oy.text), float(rotate_oz.text))
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
	
	spatials[spatial_index].translate(-world_center.x, -world_center.y, -world_center.z)
	spatials[spatial_index].scale_(mx, my, mz)
	spatials[spatial_index].translate(world_center.x, world_center.y, world_center.z)
	queue_redraw()


func _on_apply_scale_center_pressed() -> void:
	var vec3 = read_scale()
	var mx: float = vec3.x
	var my: float = vec3.y
	var mz: float = vec3.z
	var vec = spatials[spatial_index].get_middle()
	spatials[spatial_index].scale_about_center(vec, mx, my, mz)
	queue_redraw()

@onready var object_list: OptionButton = %ObjectList

func _on_create_pressed() -> void:
	var r = randi_range(0, 1)
	if r == 0:
		spatials.append(F.Cube.new())
	else:
		spatials.append(F.Tetrahedron.new())
	spatials[spatials.size() -1].translate(world_center.x, world_center.y,world_center.z) 
	var color_index = randi() % available_colors.size()
	colors.append(available_colors[color_index])
	object_list.add_item(spatial_names[r] + ' ' + color_names[color_index])
	
	queue_redraw()


func _on_object_list_item_selected(index: int) -> void:
	spatial_index = index
