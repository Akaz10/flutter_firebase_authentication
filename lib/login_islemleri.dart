import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class LoginIslemleri extends StatefulWidget {
  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('Kullanıcı oturumu kapattı');
      } else {
        print('Kullanıcı oturumu açtı');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Islemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: _emailSifreKullaniciOlustur,
                child: Text("Email/Şifree User Create"),
                style: ElevatedButton.styleFrom(primary: Colors.blueAccent)),
            ElevatedButton(
                onPressed: _emailSifreKullaniciGirisYap,
                child: Text("Email/Şifree User Login"),
                style: ElevatedButton.styleFrom(primary: Colors.greenAccent)),
            ElevatedButton(
                onPressed: _resetPassword,
                child: Text("Şifremi Unuttum"),
                style: ElevatedButton.styleFrom(primary: Colors.redAccent)),
            ElevatedButton(
                onPressed: _updatePassword,
                child: Text("Şifremi Güncelle"),
                style: ElevatedButton.styleFrom(primary: Colors.purpleAccent)),
            ElevatedButton(
                onPressed: _updateEmail,
                child: Text("Emailimi Güncelle"),
                style: ElevatedButton.styleFrom(primary: Colors.brown)),
            ElevatedButton(
                onPressed: _googleIleGiris,
                child: Text("Gmail ile Giris"),
                style: ElevatedButton.styleFrom(primary: Colors.tealAccent)),
            ElevatedButton(
                onPressed: _cikisYap,
                child: Text("Çıkış Yap"),
                style: ElevatedButton.styleFrom(primary: Colors.yellowAccent))
          ],
        ),
      ),
    );
  }
  Future<UserCredential> _googleIleGiris() async {
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    }
    catch (e){
      debugPrint("gmail girisi hata $e");
    }

  }

  void _emailSifreKullaniciOlustur() async {
    String _email = "g.onur.ozdemir@gmail.com";
    String _password = "deneme";

    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      User _yeniUser = _credential.user;
      await _yeniUser.sendEmailVerification();
      if (_auth.currentUser != null) {
        debugPrint("Size bir mail attık lütfen onaylayın");
        await _auth.signOut();
        debugPrint("Kullanıcı Sistem atıldı");
      }
    } catch (e) {
      debugPrint("**************HATA VAR **********************");
      debugPrint(e.toString());
    }
  }

  void _emailSifreKullaniciGirisYap() async {
    String _email = "g.onur.ozdemir@gmail.com";
    String _password = "deneme";

    try {
      if (_auth.currentUser == null) {
        User _oturumAcanUser = (await _auth.signInWithEmailAndPassword(
                email: _email, password: _password))
            .user;

        if (_oturumAcanUser.emailVerified) {
          debugPrint("Mail Onaylı Anasayfaya Git");
        } else {
          debugPrint("Lütfen Mailinizi onaylayın ve tekrar giris yapin");
          _auth.signOut();
        }
      } else {
        debugPrint("Oturum açmış kullanıcı zaten var");
      }
    } catch (e) {
      debugPrint("**************HATA VAR **********************");
      debugPrint(e.toString());
    }
  }

  void _cikisYap() async {
    if (_auth.currentUser != null) {
      await _auth.signOut();
    } else {
      debugPrint("Oturum açmıs kullanıcı yok");
    }
  }

  void _resetPassword() async {
    String _email = "g.onur.ozdemir@gmail.com";

    try {
      await _auth.sendPasswordResetEmail(email: _email);
      debugPrint("Resetleme maili gönderildi");
    } catch (e) {
      debugPrint("Şifre resetlenirken hata oluştu $e");
    }
  }

  void _updatePassword() async {
    try {
      await _auth.currentUser.updatePassword("password2");
      debugPrint("Şifreniz Güncellendi");
    } catch (e) {

      try{
        String email = 'g.onur.ozdemir@gmail.com';
        String password = 'password2';


        AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

        await FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);

        debugPrint("Girilen eski mail sifre doğru");
        await _auth.currentUser.updatePassword("password2");
        debugPrint("Auth yeniden sağlandı, sifre de güncellendi");
      }
      catch(e){
        debugPrint("Hata çıktı $e");
      }

      debugPrint("Şifre güncellenirken hata çıktı $e");
    }
  }

  void _updateEmail() async {
    try {
      await _auth.currentUser.updateEmail("g.onur.ozdemir@hotmail.com");
      debugPrint("Emailiniz Güncellendi");
    } on FirebaseAuthException catch (e) {

      try{
        String email = 'g.onur.ozdemir@gmail.com';
        String password = 'password2';


        AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

        await FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);

        debugPrint("Girilen eski mail sifre doğru");
        await _auth.currentUser.updateEmail("g.onur.ozdemir@hotmail.com");
        debugPrint("Auth yeniden sağlandı, mail de güncellendi");
      }
      catch(e){
        debugPrint("Hata çıktı $e");
      }

      debugPrint("mail güncellenirken hata çıktı $e");
    }
  }
}
