// Example Usage:
//
//     if Platform.isSimulator {
//       takeFakeCameraShot()
//     } else {
//       takeRealCameraShot()
//     }
//
// Lifted from http://stackoverflow.com/a/35618585/353178

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}
