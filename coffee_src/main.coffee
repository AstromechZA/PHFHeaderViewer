viewport_width = 800
viewport_height = 600

log2 = (x) ->
	Math.log(x) / Math.LN2

class Main
	
	margin: 0.05
	colours: [0x19ff00, 0x00ff65, 0x0098ff, 0x6500ff, 0xe500ff]
	last_colour: 0

	constructor: (target, content) ->
		@scene = new THREE.Scene()

		@renderer = new THREE.WebGLRenderer()
		@renderer.setClearColor 0xffffff, 1
		@renderer.setSize viewport_width, viewport_height

		first_block = content[0]
		fw = first_block.max_x-first_block.min_x
		fh = first_block.max_y-first_block.min_y
		fd = first_block.max_z-first_block.min_z

		for block in content
			bw = log2 fw / (block.max_x - block.min_x)
			bh = log2 fh / (block.max_y - block.min_y)
			bd = log2 fd / (block.max_z - block.min_z)

			@add_block_by_bounds(
				block.min_x + bw * 2
				block.min_y + bh * 2
				block.min_z + bd * 2
				block.max_x - bw * 2
				block.max_y - bh * 2
				block.max_z - bd * 2
			)

		@camera = new THREE.PerspectiveCamera 55, viewport_width/viewport_height, 0.1, 10000
		@camera.position.set fw, fh, fd
		@camera.up = new THREE.Vector3 0, 0, 1

		@controls = new THREE.OrbitControls @camera
		@controls.damping = 0.2
		@controls.addEventListener 'change', @render

		target.appendChild @renderer.domElement

		@animate()
		@render()

	animate: =>
		requestAnimationFrame @animate
		@controls.update()

	render: =>
		@renderer.render @scene, @camera

	next_colour: ->
		@last_colour = (@last_colour + 1) % @colours.length
		@colours[@last_colour]

	add_block: (x, y, z, w, h, d) ->
		tmp = new THREE.BoxGeometry w, h, d
		rcol = @next_colour()

		g = new THREE.Geometry()
		g.vertices.push tmp.vertices[1]
		g.vertices.push tmp.vertices[4]
		g.vertices.push tmp.vertices[6]
		g.vertices.push tmp.vertices[3]
		g.vertices.push tmp.vertices[2]
		g.vertices.push tmp.vertices[0]
		g.vertices.push tmp.vertices[1]
		g.vertices.push tmp.vertices[3]

		side1 = new THREE.Line g, new THREE.LineBasicMaterial {color: rcol}
		side1.position.x = x
		side1.position.y = y
		side1.position.z = z
		@scene.add side1

		g = new THREE.Geometry()
		g.vertices.push tmp.vertices[5]
		g.vertices.push tmp.vertices[7]
		g.vertices.push tmp.vertices[2]
		g.vertices.push tmp.vertices[0]
		g.vertices.push tmp.vertices[5]
		g.vertices.push tmp.vertices[4]
		g.vertices.push tmp.vertices[6]
		g.vertices.push tmp.vertices[7]
		
		side2 = new THREE.Line g, new THREE.LineBasicMaterial {color: rcol}
		side2.position.x = x
		side2.position.y = y
		side2.position.z = z
		@scene.add side2

	add_block_by_bounds: (sx, sy, sz, ex, ey, ez) ->
		@add_block(
			(sx+ex)/2
			(sy+ey)/2
			(sz+ez)/2
			ex-sx
			ey-sy
			ez-sz
		)

$ ->
	text_area_1 = $('#textarea1')[0]
	button_1 = $('#button1')[0]
	$(button_1).click ->
		o = JSON.parse text_area_1.value
		main = new Main(document.body, o)
		$(button_1).remove()
		$(text_area_1).remove()

