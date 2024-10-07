import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

class StorageService with ChangeNotifier{
  final firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrls = []; // images are stored in firebase as Download URLs
  bool _isLoading = false; // loading status
  bool _isUploading = false; // uploading status

  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  Future<void> fetchImages() async {
    _isLoading = true;

    final ListResult result = await firebaseStorage.ref('annotateImage/').listAll();

    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _imageUrls = urls;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteImages(String imageUrl) async{
    try{
      _imageUrls.remove(imageUrl);

      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    }catch(e){
      print('Error deleting image:$e');
    }
    notifyListeners();
  }

  String extractPathFromUrl(String url){
    Uri uri = Uri.parse(url);

    String encodePath = uri.pathSegments.last;

    return Uri.decodeComponent(encodePath);
  }

  Future<String> uploadImage() async {
    _isUploading = true;
    notifyListeners();
    String downloadUrl = '';

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image == null)
      return downloadUrl;

    File file = File(image.path);

    try{
      String filePath = 'annotateImage/${DateTime.now()}.png';

      await firebaseStorage.ref(filePath).putFile(file);

      downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      _imageUrls.add(downloadUrl);
      notifyListeners();
    }catch(e){
      print('Error uploading..$e');
    }finally{
      _isUploading = false;
      notifyListeners();
      return downloadUrl;
    }
  }
}