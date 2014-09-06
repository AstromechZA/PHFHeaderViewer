// Generated by CoffeeScript 1.8.0
(function() {
  var Main, log2, viewport_height, viewport_width,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  viewport_width = 800;

  viewport_height = 600;

  log2 = function(x) {
    return Math.log(x) / Math.LN2;
  };

  Main = (function() {
    Main.prototype.margin = 0.05;

    Main.prototype.colours = [0x19ff00, 0x00ff65, 0x0098ff, 0x6500ff, 0xe500ff];

    Main.prototype.last_colour = 0;

    function Main(target, content) {
      this.render = __bind(this.render, this);
      this.animate = __bind(this.animate, this);
      var bd, bh, block, bw, fd, fh, first_block, fw, _i, _len;
      this.scene = new THREE.Scene();
      this.renderer = new THREE.WebGLRenderer();
      this.renderer.setClearColor(0xffffff, 1);
      this.renderer.setSize(viewport_width, viewport_height);
      first_block = content[0];
      fw = first_block.max_x - first_block.min_x;
      fh = first_block.max_y - first_block.min_y;
      fd = first_block.max_z - first_block.min_z;
      for (_i = 0, _len = content.length; _i < _len; _i++) {
        block = content[_i];
        bw = log2(fw / (block.max_x - block.min_x));
        bh = log2(fh / (block.max_y - block.min_y));
        bd = log2(fd / (block.max_z - block.min_z));
        this.add_block_by_bounds(block.min_x + bw * 2, block.min_y + bh * 2, block.min_z + bd * 2, block.max_x - bw * 2, block.max_y - bh * 2, block.max_z - bd * 2);
      }
      this.camera = new THREE.PerspectiveCamera(55, viewport_width / viewport_height, 0.1, 10000);
      this.camera.position.set(fw, fh, fd);
      this.camera.up = new THREE.Vector3(0, 0, 1);
      this.controls = new THREE.OrbitControls(this.camera);
      this.controls.damping = 0.2;
      this.controls.addEventListener('change', this.render);
      target.appendChild(this.renderer.domElement);
      this.animate();
      this.render();
    }

    Main.prototype.animate = function() {
      requestAnimationFrame(this.animate);
      return this.controls.update();
    };

    Main.prototype.render = function() {
      return this.renderer.render(this.scene, this.camera);
    };

    Main.prototype.next_colour = function() {
      this.last_colour = (this.last_colour + 1) % this.colours.length;
      return this.colours[this.last_colour];
    };

    Main.prototype.add_block = function(x, y, z, w, h, d) {
      var g1, g2, material, rcol, side1, side2, tmp;
      tmp = new THREE.BoxGeometry(w, h, d);
      rcol = this.next_colour();
      material = new THREE.LineBasicMaterial({
        color: rcol
      });
      g1 = new THREE.Geometry();
      g1.vertices.push(tmp.vertices[1]);
      g1.vertices.push(tmp.vertices[4]);
      g1.vertices.push(tmp.vertices[6]);
      g1.vertices.push(tmp.vertices[3]);
      g1.vertices.push(tmp.vertices[2]);
      g1.vertices.push(tmp.vertices[0]);
      g1.vertices.push(tmp.vertices[1]);
      g1.vertices.push(tmp.vertices[3]);
      side1 = new THREE.Line(g1, material);
      side1.position.set(x, y, z);
      this.scene.add(side1);
      g2 = new THREE.Geometry();
      g2.vertices.push(tmp.vertices[5]);
      g2.vertices.push(tmp.vertices[7]);
      g2.vertices.push(tmp.vertices[2]);
      g2.vertices.push(tmp.vertices[0]);
      g2.vertices.push(tmp.vertices[5]);
      g2.vertices.push(tmp.vertices[4]);
      g2.vertices.push(tmp.vertices[6]);
      g2.vertices.push(tmp.vertices[7]);
      side2 = new THREE.Line(g2, material);
      side2.position.set(x, y, z);
      return this.scene.add(side2);
    };

    Main.prototype.add_block_by_bounds = function(sx, sy, sz, ex, ey, ez) {
      return this.add_block((sx + ex) / 2, (sy + ey) / 2, (sz + ez) / 2, ex - sx, ey - sy, ez - sz);
    };

    return Main;

  })();

  $(function() {
    return $('#button1').click(function() {
      var main, o;
      o = JSON.parse($('#textarea1')[0].value);
      main = new Main(document.body, o);
      return $('#interface1').remove();
    });
  });

}).call(this);
