import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _serialnumberController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String? _selectedDescription; // To store the selected value for the dropdown
  File? _imageFile;
  CameraController? _cameraController;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please capture an image using the camera or select from gallery'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'userId': _userIdController.text,
      'firstname': _firstnameController.text,
      'lastname': _lastnameController.text,
      'serialnumber': _serialnumberController.text,
      'brand': _brandController.text,
      'description': _selectedDescription,
      'image': _imageFile?.path ?? '', // Image path as a placeholder
      // 'image':"khkhhasdhfa.png",
    };

    try{
      final response = await http.post(
        Uri.parse('https://9645-196-188-51-240.ngrok-free.app/news/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print(response.statusCode);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed!'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to connect to the internet $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    // Ensure that plugin services are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Retrieve the list of available cameras
    final cameras = await availableCameras();

    // Get the first camera from the list
    final firstCamera = cameras.first;

    // Initialize the camera controller
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();

    final file = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(cameraController: _cameraController!),
      ),
    );

    if (file != null) {
      setState(() {
        _imageFile = File(file.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image. Please try again.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _userIdController,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'User ID is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _serialnumberController,
                      decoration: InputDecoration(
                        labelText: 'Serial Number (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        return null; // Serial Number is optional
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Brand is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDescription,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      items: ['Student', 'Staff', 'Guest'].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDescription = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _imageFile != null
                            ? Image.file(
                                _imageFile!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: Icon(Icons.camera_alt, color: Colors.grey[700]),
                              ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: _pickImageFromCamera,
                        ),
                        IconButton(
                          icon: Icon(Icons.photo_library),
                          onPressed: _pickImageFromGallery,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;

  CameraPreviewScreen({required this.cameraController});

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
      ),
      body: Center(
        child: CameraPreview(widget.cameraController),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile file = await widget.cameraController.takePicture();
          Navigator.pop(context, file);
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}

