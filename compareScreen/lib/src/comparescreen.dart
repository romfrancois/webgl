part of comparescreen;

class ScreenShot extends ImageComparator {
  String fileName;
  CanvasElement _canvas;
  ImageElement _imageElement;
  CanvasRenderingContext2D _context;

  ImageElement get imageElement => _imageElement;
  CanvasRenderingContext2D get context => _context;
  set context(CanvasRenderingContext context) => _context = context;
  CanvasElement get canvas => _canvas;

  ScreenShot(CanvasElement canvas, [bool initContext = true]) {
    this.fileName = fileName;
    this._canvas = canvas;

    if (initContext != null) {
      _initContext();
    }
  }

  _initContext() {
    _context = canvas.context2D;
  }

  Future readFile({String fileName}) {
    if (fileName != null) {
      this.fileName = fileName;
    }

    Completer completer = new Completer();

    _imageElement = new ImageElement(src: fileName);
    _imageElement.onLoad.listen(
        (_) { _onData(_); completer.complete();},
        onError: _onError,
        onDone: _onDone,
        cancelOnError: true);

    return completer.future;
  }

  _onData(Event e) {
    print("Success loading the image");
    _context.drawImageScaled(_imageElement, 0, 0, _canvas.width, _canvas.height);
  }

  _onError(Event e) {
    print("Error: $e");
  }

  _onDone() {
    print("Done");
  }

  ImageData displayDifferences(List<Point> differences, [CanvasElement canvasResult]) {
    print('displayDifferences');

    if (canvasResult == null) {
      canvasResult = _canvas;
    }

    CanvasRenderingContext2D context = canvasResult.context2D;
    ImageData canvasData = context.getImageData(0, 0, canvasResult.width, canvasResult.height);

    print('_drawPixel');
    Color color = new Color(255, 0, 0, 255);
    differences.forEach((Point pixelDiff) {
      _drawPixel(pixelDiff, color, canvasData);
    });

    context.putImageData(canvasData, 0, 0);
    return canvasData;
  }

  _drawPixel (Point pixCoord, Color color, ImageData canvasData) {
    int index = (pixCoord.x + pixCoord.y * canvasData.width) * 4;

    canvasData.data[index] = color.r;
    canvasData.data[index + 1] = color.g;
    canvasData.data[index + 2] = color.b;
    canvasData.data[index + 3] = color.a;
  }
}

class CanvasResources implements Comparable {
  String fileName;
  CanvasElement canvas;
  ImageElement imageElement;
  CanvasRenderingContext2D context;

  CanvasResources({String fileName, CanvasElement canvas}) {
    this.fileName = fileName;
    this.canvas = canvas;

    context = canvas.context2D;

    if (fileName == null) {
      print('Init canvas!');

      context.clearRect(0, 0, canvas.width, canvas.height);
      context.fillStyle = 'rgb(' +
                            (255 * new Random().nextDouble()).floor().toString() + ',' +
                            (255 * new Random().nextDouble()).floor().toString() + ',' +
                            (255 * new Random().nextDouble()).floor().toString() +
                          ')';
      context.fillRect(0, 0, canvas.width, canvas.height);
    }
  }

  Future readFile() {
    Completer completer = new Completer();
    imageElement = new ImageElement(src: fileName);
    imageElement.onLoad.listen(
        (_) {onData(_); completer.complete();},
        onError: onError,
        onDone: onDone,
        cancelOnError: true);
    return completer.future;
  }

  onData(Event e) {
    print("Success loading the image");
    context.drawImageScaled(imageElement, 0, 0, canvas.width, canvas.height);
  }

  onError(Event e) {
    print("Error: $e");
  }

  onDone() {
    print("Done");
  }

  @override
  int compareTo(CanvasResources other) {
    print('compareTo');

    List<Point> differences = _compareCanvases(other);
    int nbDiff = differences.length;
    print('Differences: $nbDiff');

    _computeDifferences(differences);
    return (nbDiff > 0) ? -1 : 1;
  }

  _computeDifferences(List<Point> differences) {
    print('_computeDifferences');

//    CanvasElement canvasResult = querySelector("#canReference");
    CanvasElement canvasResult = querySelector("#canScreenShot");
//    CanvasElement canvasResult = querySelector("#canCompare");
    CanvasRenderingContext2D context = canvasResult.context2D;
    ImageData canvasData = context.getImageData(0, 0, canvasResult.width, canvasResult.height);

    print('_drawPixel');
    Color color = new Color(255, 0, 0, 255);
    differences.forEach((Point pixelDiff) {
      _drawPixel(pixelDiff, color, canvasData);
    });

    context.putImageData(canvasData, 0, 0);
  }

  _drawPixel (Point pixCoord, Color color, ImageData canvasData) {
    int index = (pixCoord.x + pixCoord.y * canvasData.width) * 4;

    canvasData.data[index] = color.r;
    canvasData.data[index + 1] = color.g;
    canvasData.data[index + 2] = color.b;
    canvasData.data[index + 3] = color.a;
  }

  List<Point> _compareCanvases(CanvasResources other) {
    print('_compareCanvases');

    int w = canvas.width;
    int h = canvas.height;

    ImageData pixelImageRef;
    ImageData pixelImageSS;

//    var source = context.getImageData(0, 0, canvas.width, canvas.height).data;
//    var dest = other.context.getImageData(0, 0, other.canvas.width, other.canvas.height).data;
//    var len = dest.length;
//    print(len);

    List<Point> differences = new List();
    for (int x = 0 ; x < w ; x++) {
      for (int y = 0 ; y < h ; y++) {
        pixelImageRef = context.getImageData(x, y, 1, 1);
        pixelImageSS = other.context.getImageData(x, y, 1, 1);

        if (pixelImageRef.data[0] != pixelImageSS.data[0]) {
          differences.add(new Point(x, y));
        }
      }
    }

    return differences;

//    for (int i = 0; i < len; i+=4) {
//      if (source[i+3] > 0 && dest[i+3] > 0) {
//        return true;
//      }
//    }
//    return false;
  }
}
