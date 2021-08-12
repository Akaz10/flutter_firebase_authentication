import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class FireStoreIslemleri extends StatefulWidget {
  const FireStoreIslemleri({Key key}) : super(key: key);

  @override
  _FireStoreIslemleriState createState() => _FireStoreIslemleriState();
}

class _FireStoreIslemleriState extends State<FireStoreIslemleri> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PickedFile _secilenResim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore Islemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _veriEkle,
              child: Text("Veri Ekleme"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: _transactionEkle,
              child: Text("Transaction Ekle"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
            ElevatedButton(
              onPressed: _veriSil,
              child: Text("Veri Sil"),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: _veriOku,
              child: Text("Veri Oku"),
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
              ),
            ),
            ElevatedButton(
              onPressed: _veriSorgula,
              child: Text("Veri Sorgula"),
              style: ElevatedButton.styleFrom(
                primary: Colors.brown,
              ),
            ),
            ElevatedButton(
              onPressed: _galeriResimUpload,
              child: Text("Galeriden Storage'a Resim"),
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
              ),
            ),
            ElevatedButton(
              onPressed: _kameraResimUpload,
              child: Text("Kameradan Storage'a Resim"),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
              ),
            ),
            Expanded(child: _secilenResim == null ? Text("RESİM YOK ") :
              Image.file(File(_secilenResim.path)),)
          ],
        ),
      ),
    );
  }

  void _veriEkle() {
    Map<String, dynamic> onurEkle = Map();
    onurEkle['ad'] = "onur updated";
    onurEkle['lisans_mezunu'] = true;
    onurEkle['lisans_mezunu2'] = true;
    onurEkle['lisans_mezunu3'] = true;
    onurEkle['okul'] = true;
    onurEkle['para'] = 900;

    _firestore
        .collection("users")
        .doc("onur_ozdemir")
        .set(onurEkle, SetOptions(merge: true))
        .then((v) => debugPrint("onur eklendi"));

    _firestore
        .collection("users")
        .doc("ali_ahmet")
        .set({'ad': 'Ali', 'cinsiyet': 'erkek', 'para': 300}).whenComplete(
            () => debugPrint("Ali eklendi"));

    _firestore.doc("/users/ayse").set({'ad': 'ayse'});

    _firestore.collection("users").add({
      'ad': 'can',
      'yas': 35,
    });

    String yeniKullaniciID = _firestore
        .collection("users")
        .doc()
        .id;
    debugPrint("yeni doc id: $yeniKullaniciID");

    _firestore
        .doc("users/$yeniKullaniciID")
        .set({'yas': 30, 'userID': '$yeniKullaniciID'});

    _firestore.doc("users/onur_ozdemir").update({
      'okul': false,
      'yas': 23,
      'eklenme': FieldValue.serverTimestamp(),
      'beğeni sayisi': FieldValue.increment(10)
    }).then((value) {
      debugPrint("Onur güncellendi");
    });
  }

  void _transactionEkle() {
    final DocumentReference onurRef = _firestore.doc("users/onur_ozdemir");

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot onurData = await onurRef.get();

      if (onurData.exists) {
        var onurunParasi = onurData.data()['para'];

        if (onurData.data()['para'] > 100) {
          await transaction.update(onurRef, {'para': onurunParasi - 100});
          await transaction.update(_firestore.doc("users/ali_ahmet"),
              {'para': FieldValue.increment(100)});
        } else {
          debugPrint("Yetersiz Bakiye");
        }
      } else {
        debugPrint("Onur dökümanı yok");
      }
    });
  }

  void _veriSil() {
    _firestore.doc("users/ayse").delete().then((value) {
      debugPrint("ayse silindi");
    }).catchError((e) => debugPrint("Silerken hata çıktı" + e.toString()));

    _firestore
        .doc("users/ali_ahmet")
        .update({'cinsiyet': FieldValue.delete()}).then((value) {
      debugPrint("cinsiyet silindi ");
    }).catchError((e) => debugPrint("Silerken hata çıktı" + e.toString()));
  }

  Future _veriOku() async {
    //tek bir dökünmanın okunması
    DocumentSnapshot documentSnapshot =
    await _firestore.doc("users/onur_ozdemir").get();
    debugPrint("Döküman id:" + documentSnapshot.id);
    debugPrint("Döküman var mı: " + documentSnapshot.exists.toString());
    debugPrint("Döküman stringi: " + documentSnapshot.toString());
    debugPrint("Bekleyen yazma var mı:" +
        documentSnapshot.metadata.hasPendingWrites.toString());
    debugPrint("Cacheden mi geldi:" +
        documentSnapshot.metadata.isFromCache.toString());
    debugPrint("--: " + documentSnapshot.data().toString());
    debugPrint("Ad: " + documentSnapshot.data()['ad']);
    debugPrint("Para: " + documentSnapshot.data()['para'].toString());
    documentSnapshot.data().forEach((key, value) {
      debugPrint("key : $key deger : $value");
    });

    //koleksiyonun okunması
    _firestore.collection("users").get().then((querySnapshots) {
      debugPrint("user koleksiyonundaki eleman sayısı" +
          querySnapshots.docs.length.toString());

      for (int i = 0; i < querySnapshots.docs.length; i++) {
        debugPrint(querySnapshots.docs[i].data().toString());
      }
      //anlık değişikliklerin dinlenmesi
      var ref = _firestore.collection("users").doc("onur_ozdemir");
      ref.snapshots().listen((degisenVeri) {
        debugPrint("anlık" + degisenVeri.data().toString());
      });

      _firestore.collection("users").snapshots().listen((snap) {
        debugPrint(snap.docs.length.toString());
      });
    });
  }

  Future<void> _veriSorgula() async {
    var dokumanlar = await _firestore
        .collection("users")
        .where("email", isEqualTo: 'ali@ahmet.com')
        .get();
    for (var dokuman in dokumanlar.docs) {
      debugPrint(dokuman.data().toString());
    }
//limitli okuma
    var limitliGetir = await _firestore.collection("users").limit(2).get();
    for (var dokuman in limitliGetir.docs) {
      debugPrint("Limiyli getirilenler" + dokuman.data().toString());
    }

    var diziSorgula = await _firestore
        .collection("users")
        .where("dizi", arrayContains: 'breaking bad')
        .get();
    for (var dokuman in diziSorgula.docs) {
      debugPrint("Dizi şartı ile getirenler" + dokuman.data().toString());
    }

    var stringSorgula = await _firestore.collection("users")
        .orderBy("email")
        .get();
    for (var dokuman in stringSorgula.docs) {
      debugPrint("String Sorgu ile gelenler" + dokuman.data().toString());
    }

    _firestore.collection("users").doc("onur_ozdemir").get().then((docSnap) {
      debugPrint("onurun verileri" + docSnap.data().toString());

      _firestore.collection("users").orderBy("begeni").startAt([
          docSnap.data()['begeni']]).get().then((querySnap) {
        if (querySnap.docs.length > 0) {
          for (var bb in querySnap.docs) {
            debugPrint(
                "onurun beğenisinden fazla olan user" + bb.data().toString());
          }
        }
      });
    });
  }

  Future<void> _galeriResimUpload() async {

    var resim = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _secilenResim = resim ;
    });
    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("emre")
        .child("profil.png");
    var uploadTask = await ref.putFile(File(_secilenResim.path));

    var url = await (await ref.getDownloadURL()).toString();
    debugPrint("upload edilen resmin urlsi: "+url);


  }

  Future<void> _kameraResimUpload() async {

    var resim = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _secilenResim = resim ;
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("hasan")
        .child("profil.png");
    var uploadTask = await ref.putFile(File(_secilenResim.path));

    var url = await (await ref.getDownloadURL()).toString();
    debugPrint("upload edilen resmin urlsi: "+url);
  }
}
