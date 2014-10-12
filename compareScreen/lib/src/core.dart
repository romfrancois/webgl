part of comparescreen;

/**
 * Basic class to handle a rgba color only using int.
 * No controls are made to check each int < 255.
 */
class Color {
  final int r, g, b, a;

  Color(this.r, this.g, this.b, this.a);
}

/**
 * Compare 2 images loaded into 2 canvas.
 */
class ImageComparator implements Comparable {
  List<Point> _differences = new List();

  List<Point> get differences => _differences;

  @override
  int compareTo(ScreenShot other) {
    print('compareTo');

    _differences = _compareScreens(this, other);
    int nbDiff = _differences.length;
    print('Differences: $nbDiff');

    return (nbDiff > 0) ? 1 : -1;
  }

  /**
   * The simplest way to compare 2 images is to check if their pixels are equals.
   * For the sake of this sample I only check the red pixel (data[0]).
   * Result is the list of all pixels that are differents b/w 2 images.
   */
  List<Point> _compareScreens(ScreenShot screen1, ScreenShot screen2) {
    print('_compareScreens');

    final CanvasElement canvas1 = screen1.canvas;
    final CanvasElement canvas2 = screen2.canvas;

    final CanvasRenderingContext2D context1 = screen1.context;
    final CanvasRenderingContext2D context2 = screen2.context;

    final int w = min(canvas1.width, canvas2.width);
    final int h = min(canvas1.height, canvas2.height);

    ImageData pixelImageRef;
    ImageData pixelImageSS;

    List<Point> differences = new List();
    for (int x = 0 ; x < w ; x++) {
      for (int y = 0 ; y < h ; y++) {
        pixelImageRef = context1.getImageData(x, y, 1, 1); // to only get info for a single one pixel
        pixelImageSS = context2.getImageData(x, y, 1, 1);

        if (pixelImageRef.data[0] != pixelImageSS.data[0]) {
          differences.add(new Point(x, y));
        }
      }
    }

    return differences;
  }
}