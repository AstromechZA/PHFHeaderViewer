
log2 = (x) ->
	Math.log(x) / Math.LN2

class Block 
	constructor: (src_object) ->
		@id = src_object.id
		@children = []
		@parent = null
		@num_faces = src_object.num_faces
		@num_vertices = src_object.num_vertices
		@min_x = src_object.min_x
		@min_y = src_object.min_y
		@min_z = src_object.min_z
		@max_x = src_object.max_x
		@max_y = src_object.max_y
		@max_z = src_object.max_z

class Main
	
	margin: 0.05
	colours: [0x19ff00, 0x00ff65, 0x0098ff, 0x6500ff, 0xe500ff]
	last_colour: 0

	constructor: (target, tree, options) ->
		@options = $.extend(
			{
				swap_yz: false
				random_colours: false
				margins: false
			}
			options || {}
		)
		@tree = tree
		@scene = new THREE.Scene()

		@target = $(target)
		viewport_width = @target.width()
		viewport_height = if viewport_width < 500 then viewport_width else 500

		@renderer = new THREE.WebGLRenderer {antialiasing: false}
		@renderer.setClearColor 0xffffff, 1
		@renderer.setSize viewport_width, viewport_height

		cam_pos = @build_scene()

		@camera = new THREE.PerspectiveCamera 55, viewport_width/viewport_height, 0.1, 10000
		@camera.position.x = cam_pos[0]
		@camera.position.y = cam_pos[1]
		@camera.position.z = cam_pos[2]
		@camera.up = new THREE.Vector3 0, 0, 1

		@controls = new THREE.OrbitControls @camera
		@controls.damping = 0.2
		@controls.addEventListener 'change', @render
		@target.append @renderer.domElement
		window.addEventListener 'resize', @window_resize, false

		@fill_stats()

		@animate()
		@render()

	animate: =>
		requestAnimationFrame @animate
		@controls.update()

	render: =>
		@renderer.render @scene, @camera

	window_resize: =>
		viewport_width = @target.width()
		viewport_height = if viewport_width < 500 then viewport_width else 500
		@camera.aspect = viewport_width / viewport_height
		@camera.updateProjectionMatrix()
		@renderer.setSize viewport_width, viewport_height
		@render()

	build_scene: ->

		gradient = [0xE50400,0xE10056,0xDD00AE,0xAF00D9,0x5500D5,0x0001D2,0x0055CE,0x00A5CA,0x00C699,0x00C247,0x07BF00]

		f = (node, depth) =>

			margin = if @options.margins then depth else 0

			sx = node.min_x + margin
			sy = node.min_y + margin
			sz = node.min_z + margin
			ex = node.max_x - margin
			ey = node.max_y - margin
			ez = node.max_z - margin

			if @options.swap_yz
				a = -ez
				b = -sz
				c = sy
				d = ey
				sy = a
				sz = c
				ey = b
				ez = d

			colour = if  @options.random_colours then @next_colour() else gradient[depth]

			@add_block_by_bounds(sx, sy, sz, ex, ey, ez, colour)

			for c in node.children
				f(c, depth+1)

		if @tree != null
			root = @tree
			fw = root.max_x - root.min_x
			fh = root.max_y - root.min_y
			fd = root.max_z - root.min_z
			f(root, 0)
			return [fw, fh, fd]
		return [1, 1, 1]

	next_colour: ->
		@last_colour = (@last_colour + 1) % @colours.length
		@colours[@last_colour]

	add_block: (x, y, z, w, h, d, color) ->
		tmp = new THREE.BoxGeometry w, h, d
		rcol = color || @next_colour()
		material = new THREE.LineBasicMaterial {color: rcol}

		g1 = new THREE.Geometry()
		g1.vertices.push tmp.vertices[1]
		g1.vertices.push tmp.vertices[4]
		g1.vertices.push tmp.vertices[6]
		g1.vertices.push tmp.vertices[3]
		g1.vertices.push tmp.vertices[2]
		g1.vertices.push tmp.vertices[0]
		g1.vertices.push tmp.vertices[1]
		g1.vertices.push tmp.vertices[3]

		side1 = new THREE.Line g1, material
		side1.position.set x, y, z
		@scene.add side1

		g2 = new THREE.Geometry()
		g2.vertices.push tmp.vertices[5]
		g2.vertices.push tmp.vertices[7]
		g2.vertices.push tmp.vertices[2]
		g2.vertices.push tmp.vertices[0]
		g2.vertices.push tmp.vertices[5]
		g2.vertices.push tmp.vertices[4]
		g2.vertices.push tmp.vertices[6]
		g2.vertices.push tmp.vertices[7]
		
		side2 = new THREE.Line g2, material
		side2.position.set x, y, z
		@scene.add side2

	add_block_by_bounds: (sx, sy, sz, ex, ey, ez, colour) ->
		@add_block(
			(sx + ex) / 2
			(sy + ey) / 2
			(sz + ez) / 2
			ex-sx
			ey-sy
			ez-sz
			colour
		)

	fill_stats: ->
		target = $('#stats_target')
		count = 0
		leaves = 0
		levels = 0
		smallest_leaf_size = 99999999999
		largest_leaf_size = 0

		f = (n, depth) =>
			count += 1
			if n.children.length > 0
				for c in n.children
					f(c, depth+1)
			else
				leaves += 1
				if depth > levels
					levels = depth
				if n.num_faces < smallest_leaf_size
					smallest_leaf_size = n.num_faces
				if n.num_faces > largest_leaf_size
					largest_leaf_size = n.num_faces

		f(@tree, 1)

		add_stat = (name, value) =>
			row = $ '<tr></tr>'
			row.append( $('<td></td>').html(name) )
			row.append( $('<td></td>').html(value) )
			target.append row

		add_stat 'Nodes', count
		add_stat 'Leaf Nodes', leaves
		add_stat 'Depth', levels
		add_stat 'Biggest leaf (#faces)', largest_leaf_size
		add_stat 'Smallest leaf (#faces)', smallest_leaf_size

build_tree = (obj_array) ->
	root = null
	blocks = {}
	for o in obj_array
		blocks[o.id] = new Block o

	for o in obj_array
		t = blocks[o.id]
		if o.parent_id == null
			root = t
		else
			p = blocks[o.parent_id]
			p.children.push(t)
			t.parent = p
	root

$ ->
	$('#button1').click ->
		o = JSON.parse $('#textarea1')[0].value
		tree = build_tree o
		t = $('#canvas_target')[0]
		$('.interface_2_row').css 'display', 'block'
		main = new Main t, tree, {
			swap_yz: ($('#checkbox1')[0]).checked
			random_colours: ($('#checkbox2')[0]).checked
			margins: ($('#checkbox3')[0]).checked
		}
		$('#interface1').remove()

	$('#button2').click ->
		$.ajax 'sample.json', 
			type: 'GET', 
			dataType: 'text',
			success: (data, textStatus, jqXHR) ->
				$('#textarea1')[0].value = data


