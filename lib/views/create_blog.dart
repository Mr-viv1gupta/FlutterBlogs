import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blogs/services/crud_method.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({Key? key}) : super(key: key);

  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  XFile? selectedImageFile;
  bool imageTaken = false;
  bool isUploading = false;
  String selectedImage64 = "";
  final _createBlogFormKey = GlobalKey<FormState>();
  CrudMethods crudMethods = new CrudMethods();

  //Loading Image from Camera or Gallery
  Future getImage() async {
    selectedImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageTaken = true;
    selectedImage64 =
        base64Encode(File(selectedImageFile!.path).readAsBytesSync());
    setState(() {
      if (selectedImageFile != null) {
        print('You have selected image: ' + selectedImageFile!.path);
      } else {
        print('No Image Selected');
      }
    });
  }

  Future<void> uploadBlog() async {
    if (selectedImageFile != null &&
        _createBlogFormKey.currentState!.validate()) {
      setState(() {
        isUploading = true;
      });
      // await Firebase.initializeApp();${randomAlphaNumeric(9)}
      Reference firebaseStoreRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("defaultImage.jpg");

      // print(firebaseStoreRef.getBucket())
      final UploadTask task =
          firebaseStoreRef.putFile(File(selectedImageFile!.path));
      var imageUrl;
      await task.whenComplete(() async {
        try {
          imageUrl = await firebaseStoreRef.getDownloadURL();
        } catch (onError) {
          print('Error occured while uploading :');
        }

        print(imageUrl);
      });

      Map<String, dynamic> blogData = {
        "imgUrl": imageUrl,
        "author": authorController.text,
        "title": titleController.text,
        "desc": descController.text
      };

      crudMethods.addData(blogData).then((value) {
        setState(() {
          isUploading = false;
        });
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Please fix the errors before Uploading',
        style: TextStyle(color: Colors.redAccent),
      )));
    }
  }

  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController authorController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Blog',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
        ),
        // elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: () {
              print('Upload Button Clicked');
              uploadBlog();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.file_upload_outlined),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _createBlogFormKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: (imageTaken)
                      ? Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(vertical: 24),
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(selectedImageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w300,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      hintText: 'Enter Blog Title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Title for Blog';
                      } else if (value.length > 100) {
                        return "Title Name can't be more than 100 characters";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Blog Content',
                      labelStyle: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w300,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      hintText: 'Enter description/Content of Blog',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Blog Content';
                      } else if (value.length < 10) {
                        return "Blog Content is too less";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: TextFormField(
                    controller: authorController,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      labelStyle: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w300,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)),
                      hintText: 'Blog Author name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Author Name';
                      } else if (value.length > 50) {
                        return "Author Name can't be more than 50 characters";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
