import 'package:chart_animation/secure_storage.dart';
import 'package:googleapis/sheets/v4.dart' as ss;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const _clientId = "4721566565-uqufslehsn8ko05id4nbvld2hu0730rq.apps.googleusercontent.com";
const _clientSecret = "2ckbMt-yyOYdpWk2MGiSEbfA";
const _scopes = [ss.SheetsApi.SpreadsheetsScope];

class GoogleSheets {
  final storage = SecureStorage();
  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    //Get Credentials
    var credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) {
        //Open Url in Browser
        launch(url);
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken);
      return authClient;
    } else {
      print(credentials["expiry"]);
      //Already authenticated
      return authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.tryParse(credentials["expiry"])),
              credentials["refreshToken"],
              _scopes));
    }
  }

  // Read Data from Google Sheets
  Future readData(String spreadsheetId, String range) async {
    var client = await getHttpClient();
    print("Reading Spreadsheet");
    var response = await ss.SheetsApi(client).spreadsheets.get(
      spreadsheetId,
//      ranges: [range],
    );
    print("Result: ${response.sheets.isEmpty}");

  }
}