part of comparescreen;

class ScreenShotGL {

  List<ScreenShot> screens2D;

  ScreenShotGL(this.screens2D);

  void renderImage3D(CanvasElement canvas) {
    List<ImageElement> images = new List();
    for (ScreenShot screen2D in screens2D) {
      images.add(screen2D.imageElement);
    }
    _renderImage3D(canvas, images);
  }
}