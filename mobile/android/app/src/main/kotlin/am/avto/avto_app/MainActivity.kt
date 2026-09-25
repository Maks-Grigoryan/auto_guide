package am.avto.avto_app

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Must run before super.onCreate: the call swaps LaunchTheme for
        // postSplashScreenTheme, and doing it afterwards leaves the activity
        // wearing the splash theme for the rest of its life.
        //
        // Nothing here decides how long the splash lasts. Android keeps it up
        // until the first frame is drawn and then removes it, so its length is
        // exactly the app's real startup time — no timer to tune, and no pause
        // invented for the user.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
