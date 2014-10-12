part of comparescreen;

/**
 * A very simple & basic way to handle 3D using WebGL.
 * It basically loads info from shaders from the html file.
 */

WebGL.Program createProgram(WebGL.RenderingContext gl, [List<WebGL.Shader> shaders]) {
  // Create program
  var program = gl.createProgram();

  // Iterate the shaders list
  if (shaders is List<WebGL.Shader>) {
    shaders.forEach((var shader) => gl.attachShader(program, shader));
  }

  // Link the shader to program
  gl.linkProgram(program);

  // Check the linked status
  var linked = gl.getProgramParameter(program, WebGL.RenderingContext.LINK_STATUS);
  if (!linked) {
    throw "Not able to link shader(s) ${shaders}";
  }

  return program;
}

WebGL.Shader loadShader(WebGL.RenderingContext gl, String shaderSource, int shaderType) {
  // Create the shader object
  var shader = gl.createShader(shaderType);

  // Load the shader source
  gl.shaderSource(shader, shaderSource);

  // Compile the shader
  gl.compileShader(shader);

  // Check the compile status
  // NOTE: getShaderParameter maybe borken in minfrog or frog compiler.
  var compiled = gl.getShaderParameter(shader, WebGL.RenderingContext.COMPILE_STATUS);
  if (!compiled) {
    throw "Not able to compile shader $shaderSource";
  }

  return shader;
}

WebGL.Shader createShaderFromScriptElement(WebGL.RenderingContext gl, String id) {
  ScriptElement shaderScript = querySelector(id);
  String shaderSource = shaderScript.text;
  int shaderType;
  if (shaderScript.type == "x-shader/x-vertex") {
    shaderType = WebGL.RenderingContext.VERTEX_SHADER;
  } else if (shaderScript.type == "x-shader/x-fragment") {
    shaderType = WebGL.RenderingContext.FRAGMENT_SHADER;
  } else {
    throw new Exception('*** Error: unknown shader type');
  }

  return loadShader(gl, shaderSource, shaderType);
}

WebGL.RenderingContext getWebGLContext(CanvasElement canvas) {
  return canvas.getContext3d(); //("experimental-webgl");
}

// misc functions
void setRectangle(gl, x, y, width, height) {
  var x1 = x;
  var x2 = x + width;
  var y1 = y;
  var y2 = y + height;
  var vertices = [x1, y1,
                  x2, y1,
                  x1, y2,
                  x1, y2,
                  x2, y1,
                  x2, y2];
  gl.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), WebGL.RenderingContext.STATIC_DRAW);
}

/**
 * From a @CanvasElement gets its 3D rendering.
 */
WebGL.RenderingContext initGL(CanvasElement canvas) {
  WebGL.RenderingContext gl = getWebGLContext(canvas);

  if (canvas is! CanvasElement || gl is! WebGL.RenderingContext) {
    print("Failed to load the 3D context :(");
    return null;
  }
  return gl;
}

/**Given a list of images, render them into a 'destination' Canvas
 *
 */
void _renderImage3D(CanvasElement canvas, List<ImageElement> images) {
// Get a WebGL context
  WebGL.RenderingContext gl = initGL(canvas);

  if (gl == null)
    return;

  // setup GLSL program
  var vertexShader = createShaderFromScriptElement(gl, "#vertex-shader");
  var fragmentShader = createShaderFromScriptElement(gl, "#fragment-shader");
  var program = createProgram(gl, [vertexShader, fragmentShader]);
  gl.useProgram(program);

  // look up where the vertex data needs to go.
  var positionLocation = gl.getAttribLocation(program, "a_position");
  var texCoordLocation = gl.getAttribLocation(program, "a_texCoord");

  // provide texture coordinates for the rectangle.
  var texCoordBuffer = gl.createBuffer();
  gl.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, texCoordBuffer);
  var vertices = [0.0,  0.0,
                  1.0,  0.0,
                  0.0,  1.0,
                  0.0,  1.0,
                  1.0,  0.0,
                  1.0,  1.0];
  gl.bufferDataTyped(WebGL.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), WebGL.RenderingContext.STATIC_DRAW);
  gl.enableVertexAttribArray(texCoordLocation);
  gl.vertexAttribPointer(texCoordLocation, 2, WebGL.RenderingContext.FLOAT, false, 0, 0);


  // VIDEO 0
  for (int i = 0; i < images.length; i++) {
    // Create a texture.
    var texture = gl.createTexture();

    int textureUnit = WebGL.TEXTURE0 + i;
    gl.activeTexture(textureUnit);
    gl.bindTexture(WebGL.RenderingContext.TEXTURE_2D, texture);

    // Set the parameters so we can render any size image.
    gl.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_WRAP_S, WebGL.RenderingContext.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_WRAP_T, WebGL.RenderingContext.CLAMP_TO_EDGE);
    gl.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MIN_FILTER, WebGL.RenderingContext.NEAREST);
    gl.texParameteri(WebGL.RenderingContext.TEXTURE_2D, WebGL.RenderingContext.TEXTURE_MAG_FILTER, WebGL.RenderingContext.NEAREST);

    // Upload the image into the texture.
    gl.texImage2DImage(WebGL.RenderingContext.TEXTURE_2D, 0, WebGL.RenderingContext.RGBA, WebGL.RenderingContext.RGBA, WebGL.RenderingContext.UNSIGNED_BYTE, images[i]);

    gl.uniform1i(gl.getUniformLocation(program, "u_image${i + 1}"), i);
  }

  // lookup uniforms
  var resolutionLocation = gl.getUniformLocation(program, "u_resolution");

  // set the resolution
  gl.uniform2f(resolutionLocation, canvas.width, canvas.height);

  // Create a buffer for the position of the rectangle corners.
  var positionBuffer = gl.createBuffer();
  gl.bindBuffer(WebGL.RenderingContext.ARRAY_BUFFER, positionBuffer);
  gl.enableVertexAttribArray(positionLocation);
  gl.vertexAttribPointer(positionLocation, 2, WebGL.RenderingContext.FLOAT, false, 0, 0);

  // Set a rectangle the same size as the image.
  setRectangle(gl, 0.0, 0.0, canvas.width.toDouble(), canvas.height.toDouble());

  // Draw the rectangle
  gl.drawArrays(WebGL.RenderingContext.TRIANGLES, 0, 6);
}