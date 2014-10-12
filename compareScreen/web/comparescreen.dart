import '../lib/comparescreen.dart';

import 'dart:html';
import 'dart:async';

void main() {
  /* Canvas to load images into */
  CanvasElement canvasReference = querySelector("#canReference");
  CanvasElement canvasScreenShot = querySelector("#canScreenShot");

  /* Canvas to load the comparison image done using WebGL */
  CanvasElement canvasResult3D = querySelector("#canCompare3D");

  ScreenShot screenReference = new ScreenShot(canvasReference);
  ScreenShot screenCaptured = new ScreenShot(canvasScreenShot);

  Future.wait([screenReference.readFile(fileName: "../resources/musique.png"),  screenCaptured.readFile(fileName: "../resources/musique2.png")]).then((_) {
    /* Part to handle the diff using WebGL */
    List<ScreenShot> images = [screenReference, screenCaptured];
    ScreenShotGL screenReference3D = new ScreenShotGL(images);
    screenReference3D.renderImage3D(canvasResult3D);

    /* This is where the diff thing is happening */
    if (screenReference.compareTo(screenCaptured) == 1) {
      List<Point> differences = screenReference.differences;
      screenCaptured.displayDifferences(differences);
    }
  });
}