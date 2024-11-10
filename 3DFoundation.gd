class_name F extends Control

class AffineMatrices:

	static func get_perspective_matrix(c: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)
		m.set_element(2, 2, 0)
		m.set_element(2, 3, -1.0/c)
		return m

	static func get_axonometric_matrix(phi_deg: float, psi_deg: float) -> DenseMatrix:
		var phi = deg_to_rad(phi_deg)
		var psi = deg_to_rad(psi_deg)
		var m = DenseMatrix.zero(4)
		m.set_element(0, 0, cos(psi))
		m.set_element(0, 1, sin(psi) * cos(phi))
		m.set_element(1, 1, cos(phi))
		m.set_element(2, 0, sin(psi))
		m.set_element(2, 1, -sin(phi) * cos(psi))
		m.set_element(3, 3, 1)
		return m


	static func get_translation_matrix(tx: float, ty: float, tz: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)
		m.set_element(3, 0, tx)
		m.set_element(3, 1, ty)
		m.set_element(3, 2, tz)
		return m

	static func get_rotation_matrix_about_x(ox: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)

		var rot_deg_x = deg_to_rad(ox)
		var sin_x = sin(rot_deg_x)
		var cos_x = cos(rot_deg_x)

		m.set_element(1, 1, cos_x)
		m.set_element(1, 2, sin_x)
		m.set_element(2, 1, -sin_x)
		m.set_element(2, 2, cos_x)
		return m

	static func get_rotation_x_by_sin_cos(sin_x: float, cos_x: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)
		m.set_element(1, 1, cos_x)
		m.set_element(1, 2, sin_x)
		m.set_element(2, 1, -sin_x)
		m.set_element(2, 2, cos_x)
		return m

	static func get_rotation_y_by_sin_cos(sin_y: float, cos_y: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)
		m.set_element(0, 0, cos_y)
		m.set_element(0, 2, -sin_y)
		m.set_element(2, 0, sin_y)
		m.set_element(2, 2, cos_y)
		return m

	static func get_rotation_matrix_about_y(oy: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)

		var rot_deg_y = deg_to_rad(oy)
		var sin_y = sin(rot_deg_y)
		var cos_y = cos(rot_deg_y)

		m.set_element(0, 0, cos_y)
		m.set_element(0, 2, -sin_y)
		m.set_element(2, 0, sin_y)
		m.set_element(2, 2, cos_y)
		return m

	static func get_rotation_matrix_about_z(oz: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)

		var rot_deg_z = deg_to_rad(oz)
		var sin_z = sin(rot_deg_z)
		var cos_z = cos(rot_deg_z)

		m.set_element(0, 0, cos_z)
		m.set_element(0, 1, sin_z)
		m.set_element(1, 0, -sin_z)
		m.set_element(1, 1, cos_z)
		return m

	static func get_scale_matrix(mx: float, my: float, mz: float) -> DenseMatrix:
		var m = DenseMatrix.identity(4)

		if mx == 0:
			m.set_element(0, 0, 1)
		else:
			m.set_element(0, 0, mx)

		if my == 0:
			m.set_element(1, 1, 1)
		else:
			m.set_element(1, 1, my)

		if mz == 0:
			m.set_element(2, 2, 1)
		else:
			m.set_element(2, 2, mz)

		return m

	static func get_line_rotate_matrix(l, m, n, sin_phi, cos_phi) -> DenseMatrix:
		var matr = DenseMatrix.identity(4)
		matr.set_element(0, 0, l*l+cos_phi*(1-l*l))
		matr.set_element(0, 1, l*(1-cos_phi)*m+n*sin_phi)
		matr.set_element(0, 2, l*(1-cos_phi)*n-m*sin_phi)
		matr.set_element(1, 0, l*(1-cos_phi)*m-n*sin_phi)
		matr.set_element(1, 1, m*m+cos_phi*(1-m*m))
		matr.set_element(1, 2, m*(1-cos_phi)*n+l*sin_phi)
		matr.set_element(2, 0, l*(1-cos_phi)*n+m*sin_phi)
		matr.set_element(2, 1, m*(1-cos_phi)*n-l*sin_phi)
		matr.set_element(2, 2, n*n+cos_phi*(1-n*n))
		return matr


class Point:
	var x: float
	var y: float
	var z: float
	var w: float

	func _init(_x: float, _y: float, _z: float) -> void:
		x = _x
		y = _y
		z = _z
		w = 1

	static func from_vec3d(_p: Vector3) -> Point:
		var p = Point.new(0,0,0)
		return p

	func duplicate() -> Point:
		var p = Point.new(0, 0, 0)
		p.x = x
		p.y = y
		p.z = z
		p.w = w
		return p

	func apply_matrix(matrix: DenseMatrix):
		var v = get_vector()
		var vnew = v.multiply_dense(matrix)
		x = vnew.get_element(0, 0)
		y = vnew.get_element(0, 1)
		z = vnew.get_element(0, 2)
		w = vnew.get_element(0, 3)

	func translate(tx: float, ty: float, tz: float):
		var matrix = AffineMatrices.get_translation_matrix(tx, ty, tz)
		apply_matrix(matrix)

	func rotate_ox(ox: float):
		var matrix = AffineMatrices.get_rotation_matrix_about_x(ox)
		apply_matrix(matrix)

	func rotate_oy(oy: float):
		var matrix = AffineMatrices.get_rotation_matrix_about_y(oy)
		apply_matrix(matrix)

	func rotate_oz(oz: float):
		var matrix = AffineMatrices.get_rotation_matrix_about_z(oz)
		apply_matrix(matrix)

	func get_vector() -> DenseMatrix:
		return DenseMatrix.from_packed_array([x, y, z, w], 1, 4)

	func get_vec2d():
		return Vector2(x/w, y/w)

	func get_vec3d():
		return Vector3(x/w, y/w, z/w)

	
					


class Spatial:
	var points: Array[Point]
	var edges: Array[Vector2i]
	var mid_point: Point = Point.new(0, 0, 0)
	var faces #Array[Array[int]]
	func _init() -> void:
		points = []
		edges = []
		faces = []
	func add_point(p: Point):
		points.append(p)

	func add_points(arr: Array[Point]):
		points += arr

	func add_face(arr: Array):
		faces.append(arr)

	func add_faces(arr):
		faces += arr

	func add_edge(p1: Point, p2: Point):
		points.append(p1)
		points.append(p2)
		edges.append(Vector2i(points.size() - 2, points.size() - 1))

	func clear():
		points.clear()
		edges.clear()
		faces.clear()
	
	func get_middle():
		return mid_point.duplicate()

	func apply_matrix(matrix: DenseMatrix):
		for i in range(points.size()):
			points[i].apply_matrix(matrix)
		mid_point.apply_matrix(matrix)

	func translate(tx: float, ty: float, tz: float):
		var matrix: DenseMatrix = AffineMatrices.get_translation_matrix(tx, ty, tz)
		apply_matrix(matrix)

	func rotation_about_x(ox: float):
		var matrix: DenseMatrix = AffineMatrices.get_rotation_matrix_about_x(ox)
		apply_matrix(matrix)

	func rotation_about_y(oy: float):
		var matrix: DenseMatrix = AffineMatrices.get_rotation_matrix_about_y(oy)
		apply_matrix(matrix)

	func rotation_about_z(oz: float):
		var matrix: DenseMatrix = AffineMatrices.get_rotation_matrix_about_z(oz)
		apply_matrix(matrix)

	func rotation_about_center(p: Point, ox: float, oy: float, oz: float):
		translate(-p.x, -p.y, -p.z)
		rotation_about_x(float(ox))
		rotation_about_y(float(oy))
		rotation_about_z(float(oz))
		translate(p.x, p.y, p.z)

	func rotation_about_line(p: Point, vec: Vector3, deg: float):
		deg = deg_to_rad(deg)
		vec = vec.normalized()
		
		var n = vec.z
		var m = vec.y
		var l = vec.x
		var d = sqrt(m * m + n * n)
		var matrix = AffineMatrices.get_line_rotate_matrix(l, m, n, sin(deg), cos(deg))
		apply_matrix(matrix)

	func scale_about_center(p: Point, ox: float, oy: float, oz: float):
		translate(-p.x, -p.y, -p.z)
		scale_(ox, oy, oz)
		translate(p.x, p.y, p.z)

	func scale_(mx: float, my: float, mz: float):
		var matrix: DenseMatrix = AffineMatrices.get_scale_matrix(mx, my, mz)
		apply_matrix(matrix)

	func miror(mx: float, my: float, mz: float):
		var matrix = DenseMatrix.identity(4)
		matrix.set_element(0, 0, mx)
		matrix.set_element(1, 1, my)
		matrix.set_element(2, 2, mz)
		apply_matrix(matrix)

	func load_from_obj(file_path: String):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			return
			
		while file.get_position() < file.get_length():
			var line = file.get_line().strip_edges()
			if line.begins_with("v "):
				var parts = line.split(" ")
				if parts.size() >= 4:
					var x = parts[1].to_float()
					var y = -parts[2].to_float()
					var z = -parts[3].to_float()
					add_point(Point.new(x,y,z))
			elif line.begins_with("f "):
				var parts = line.split(" ")
				var face_indices = []
				for i in range(1, parts.size()):
					var vertex_index = parts[i].split("/")[0].to_int() - 1
					face_indices.append(vertex_index)
				add_face(face_indices)
		file.close()

	func save_from_obj(file_path: String):
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file == null:
			return
			
		for point in points:
			var line = "v %f %f %f\n" % [point.x, -point.y, -point.z]
			file.store_string(line)
			
		for face in faces:
			var line = "f"
			for vertex_index in face:
				line += " %d" % (vertex_index + 1)
			line += "\n"
			file.store_string(line)
			
		file.close()


class Axis extends Spatial:
	func _init():
		var l = 500

		## THIS IS POINTS FROM SPATIAL
		points = [
			Point.new(0, 0, 0),
			Point.new(l, 0, 0),
			Point.new(0, l, 0),
			Point.new(0, 0, l),
		]
		
		faces = [
			[0, 1],
			[0, 2],
			[0, 3]
		]

class RotationSpatial extends Spatial:
	var num_segments = 10
	
	var fun = func(angle): return AffineMatrices.get_rotation_matrix_about_x(angle)
	
	var world_center = Vector3.ZERO
	
	var points_start = [
		Point.new(-50, 0, 0),
		Point.new(0, 50, 0),
	]
	
	func _init():
		create()
	
	func create():
		var rotation_angle = 360.0 / num_segments
		faces = []
	
		var all_points = []
	
		for i in range(num_segments):
			var angle = i * rotation_angle
			var rotation_matrix = fun.call(angle)
	
			for point in points_start:
				var new_point = point.duplicate()
				new_point.translate(-world_center.x, -world_center.y, -world_center.z)
				new_point.apply_matrix(rotation_matrix)
				new_point.translate(world_center.x, world_center.y, world_center.z)
				add_point(new_point)
				all_points.append(new_point)

			var base_index = (i-1) * len(points_start)
			for j in range(len(points_start) - 1):
				add_face([base_index + j, base_index + j + 1, base_index + j + len(points_start) + 1, base_index + j + len(points_start)])
	
		var last_base_index = (num_segments - 1) * len(points_start)
		for j in range(len(points_start) - 1):
			add_face([last_base_index + j, last_base_index + j + 1, j + 1, j])

class FunctionSurface extends Spatial:
	func _init() -> void:
		pass
	func create(x0, x1, y0, y1, step, G):
		faces = []
		mid_point = Point.new(0,0,0)
		var cnt_x = floor((x1 - x0) / step)
		var cnt_y = floor((y1 - y0) / step)
		# cnt of faces by x = (cnt_x - 1)
		# cnt of faces by y = (cnt_y - 1)
		for x_i in range(cnt_x):
			for y_i in range(cnt_y):
				var x = x0 + step * x_i
				var y = y0 + step * y_i
				var z = G.call(x, y)
				points.append(Point.new(x*15, z*15, y*15))
		for i in range(cnt_y-1):
			for j in range(cnt_x-1):
				var top_left = i * cnt_x + j
				var top_right = i * cnt_x + (j + 1)
				var bottom_left = (i + 1) * cnt_x + j
				var bottom_right = (i + 1) * cnt_x + (j + 1)
				faces.append([top_left, top_right, bottom_left, bottom_right])
