import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  //TODO: Insert Web client ID
  static const webClientId = "91048714819-s43ik7e3adq1d7eeg6hb54k4blk5pnhv.apps.googleusercontent.com";

  static Future<Map<String, String>?> authenticate() async {
    final googleSignin = GoogleSignIn(
      clientId: kIsWeb ? webClientId : null,
      // //TODO: Insert scopes
      scopes: ["https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/spreadsheets"],
    );

    try {
      var auth = await googleSignin.signIn();

      if (auth == null) {
        return null;
      } else {
        final headers = await auth.authHeaders;

        return headers;
      }
    } catch (e) {
      debugPrint("AN ERROR OCCURRED ======== $e");
    }
    return null;
  }
}
