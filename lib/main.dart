import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  final GlobalKey globalKey=new GlobalKey();
    String headertext="";
    String footertext="";
    File _image;
    File _imageFile;
    bool imageSelected=false;

    Random rng= new Random();

    Future getIamge() async {
    var image;
    try{
     image= await ImagePicker.pickImage(source : ImageSource.gallery);
    }catch(PlatformException){
      print("not allowing"+PlatformException);
    }
    setState(() {
      if(image!=null){
        imageSelected=true;
      }
      _image=image;
    });
    new Directory('storage/emulated' + 'memer').create(recursive: true);
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:SingleChildScrollView(
          child: Container(
          child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Image.asset(
              "assets/images/memer.png",
                height: 70,
            ),
            SizedBox(
              height: 14,
            ),
            RepaintBoundary(
              key: globalKey,
             child: Stack(
              
              children: <Widget>[
                _image != null?Image.file(
                  _image,
                  height: 300,
                  width: 800,
                 fit: BoxFit.cover,
                 ):Container(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical:8),
                        child: Text(
                          headertext.toUpperCase(), 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 26
                      ),),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(vertical:8),
                        child: Text(
                        footertext.toUpperCase(), 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 26
                      ),),)
                  ],
                ),
                ),
              ],
              ),
            ),
            SizedBox(height:20.0),
            imageSelected ?Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
             child: Column(
              children: <Widget>[
                TextField(
                onChanged: (val){
                  setState(() {
                   headertext=val; 
                  });
                  
                },
                decoration: InputDecoration(
                hintText: "Header text"
                ),
              ),
               SizedBox(height:12.0),
               TextField(
                onChanged: (val){
                  setState(() {
                    footertext=val;
                  });
                  
                },
                decoration: InputDecoration(
                hintText: "Footer text"
                ),
              ),
              SizedBox(height:20),
              RaisedButton(onPressed: (){
         
                takeScreenShot();
              },
               child:Text("Save"),
               )
              ],
              ),
            ):Container(
             child: Center(
               child: Text("Select image to get started"),
             ), 
            )  ,
            _imageFile != null? Image.file(_imageFile):Container(),
          ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          getIamge();
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
   takeScreenShot() async{
     RenderRepaintBoundary boundary=
     globalKey.currentContext.findRenderObject();
     ui.Image image= await boundary.toImage();
     final directory = (await getApplicationDocumentsDirectory()).path;
     ByteData byteData=await image.toByteData(format:ui.ImageByteFormat.png);
     Uint8List pngBytes= byteData.buffer.asUint8List();
     print(pngBytes);
     File imgFile = new File('$directory/screenshot${rng.nextInt(200)}.png');
     setState(() {
       _imageFile=imgFile;
     });
     _saveFile(_imageFile);
     //save file local
     imgFile.writeAsBytes(pngBytes);
   }  

   _saveFile(File file) async{
    await _askPermission();
    final result= await ImageGallerySaver.saveImage(
      Uint8List.fromList(await file.readAsBytes()));
      print(result);
   }

   _askPermission() async{
    // Map<PermissionGroup, PermissionStatus> permission=
     await PermissionHandler().requestPermissions([PermissionGroup.photos]);
   }
}
