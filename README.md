# Remodel AR

**Remodel AR** is a module that enables you to quickly and easily convert any ARSCNView into a virtual home remodeling visualization tool. This package currently contains all of the following features.

- AR assisted virtual room painting
  - Lidar approach (includes object occlusion, multiple wall painting)
  - User placed geometry approach (multiple wall painting)
  - Color manipulation approach (inclused object occlusion, single wall painting)
- Defect recognition and analysis
- Surface area measurement

<img src="Resources/PaintARScreenshot.png" alt="PaintAR Screenshot" />

## Usage
To use **Remodel AR**, you will need to add the XCFramework to your project and import **RemodelAR**, then add an ARSCNView to your UIViewController and initialize an ARController instance.

For in-depth documentation for both SwiftUI and UIKit, see the wiki page.
