viewport_width = 800
viewport_height = 600

class Main
	
	margin: 0.05
	colours: [0x19ff00, 0x00ff65, 0x0098ff, 0x6500ff, 0xe500ff]
	last_colour: 0

	constructor: (target) ->
		@scene = new THREE.Scene()
		
		@camera = new THREE.PerspectiveCamera 75, viewport_width/viewport_height, 0.1, 1000
		@camera.position.z = 5

		@renderer = new THREE.WebGLRenderer()
		@renderer.setSize viewport_width, viewport_height

		@controls = new THREE.OrbitControls @camera
		@controls.damping = 0.2
		@controls.addEventListener 'change', @render

		@build_scene()

		target.appendChild @renderer.domElement

		@animate()
		@render()

	build_scene: ->
		@add_block_with_padding(0, 0, 0, 4, 4, 4, 0)
		@add_block_with_padding(1, 1, 1, 2, 2, 2, 0.1)
		@add_block_with_padding(1, 1, -1, 2, 2, 2, 0.1)
		@add_block_with_padding(1, -1, 1, 2, 2, 2, 0.1)
		@add_block_with_padding(1, -1, -1, 2, 2, 2, 0.1)

		@add_block_with_padding(-1, 1, 1, 2, 2, 2, 0.1)
		@add_block_with_padding(-1, 1, -1, 2, 2, 2, 0.1)
		@add_block_with_padding(-1, -1, 1, 2, 2, 2, 0.1)
		@add_block_with_padding(-1, -1, -1, 2, 2, 2, 0.1)

	animate: =>
		requestAnimationFrame @animate
		@controls.update()

	render: =>
		@renderer.render @scene, @camera

	next_colour: ->
		@last_colour = (@last_colour + 1) % @colours.length
		@colours[@last_colour]

	add_block: (x, y, z, w, h, d) ->
		@add_block_with_padding(x, y, z, w, h, d, 0)

	add_block_with_padding: (x, y, z, w, h, d, p) ->

		tmp = new THREE.BoxGeometry w-p, h-p, d-p
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
	main = new Main(document.body)

