import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController{
  Rx<File> image = File('').obs;

  Future pickIMage() async{

    try{

    final imagePick = await ImagePicker().pickImage(source: ImageSource.gallery);
 if (imagePick == null){
  return;
 }
 final imageTemp = File(imagePick.path);
 image.value = imageTemp;
    } on PlatformException catch(e) {
      return e;
    }
  }
Rx<String> networkImage = ''.obs;
 
  Future<String> uploadImageToFirebase ()async{
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
try{
  Reference reference = FirebaseStorage.instance.ref().child('mypicture/$fileName.png');
  await reference.putFile(image.value);

  String downloadURL = await reference.getDownloadURL();
  networkImage.value = downloadURL;
  return downloadURL;
} catch (e){
  return '';
}

  }

}