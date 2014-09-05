viewport_width = 800
viewport_height = 600

class Main
	
	margin: 0.05
	colours: [0x19ff00, 0x00ff65, 0x0098ff, 0x6500ff, 0xe500ff]
	last_colour: 0

	constructor: (target, content) ->
		@scene = new THREE.Scene()
		
		@camera = new THREE.PerspectiveCamera 55, viewport_width/viewport_height, 0.1, 10000
		@camera.position.z = 5

		@renderer = new THREE.WebGLRenderer()
		@renderer.setClearColor 0xffffff, 1
		@renderer.setSize viewport_width, viewport_height

		@controls = new THREE.OrbitControls @camera
		@controls.damping = 0.2
		@controls.addEventListener 'change', @render

		for block in content
			@add_block_by_bounds(
				block.min_x
				block.min_z
				block.min_y
				block.max_x
				block.max_z
				block.max_y
			)

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

