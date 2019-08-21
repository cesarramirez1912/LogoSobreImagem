import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teste_app/rest/bloc.dart';

class PrincipalScreen extends StatelessWidget {
  BlocImagem _blocImagem = BlocImagem();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fundo Selecionado'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _moreButtom(context),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: _blocImagem.eventoMudarAlignStream,
              builder: (builder,snapshot){
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Select lot');
                  case ConnectionState.waiting:
                    return Text('Awaiting bids...');
                  case ConnectionState.active:
                    return  Stack(
                      alignment: snapshot.data,
                      children: <Widget>[
                        StreamBuilder(
                            stream: _blocImagem.imagemFundoStream,
                            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                              if (snapshot.data == null)
                                return Container(
                                  width: double.infinity,
                                  height: 300,
                                  color: Colors.black,
                                  child: Center(
                                    child: Text(
                                      'File is null',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Text('Select lot');
                                case ConnectionState.waiting:
                                  return Text('Awaiting bids...');
                                case ConnectionState.active:
                                  return Container(
                                    width: double.infinity,
                                    height: 300,
                                    child: ExtendedImage.file(
                                      snapshot.data,
                                      fit: BoxFit.contain,
                                      mode: ExtendedImageMode.Gesture,
                                      initGestureConfigHandler: (state) {
                                        return GestureConfig(
                                            minScale: 0.9,
                                            animationMinScale: 0.7,
                                            maxScale: 3.0,
                                            animationMaxScale: 3.5,
                                            speed: 1.0,
                                            cacheGesture: true,
                                            inertialSpeed: 100.0,
                                            initialScale: 1.0,
                                            inPageView: true);
                                      },
                                    ),
                                  );
                                case ConnectionState.done:
                                  return Text('\$${snapshot.data} (closed)');
                              }
                              return null;
                            }),
                        InkWell(
                            onDoubleTap: () {},
                            child: StreamBuilder(
                                stream: _blocImagem.imagemLogoStream,
                                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                                  if (snapshot.data == null)
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.blue,
                                    );
                                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Select lot');
                                    case ConnectionState.waiting:
                                      return Text('Awaiting bids...');
                                    case ConnectionState.active:
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            image: DecorationImage(image: FileImage(snapshot.data),
                                                fit: BoxFit.fill
                                            )
                                        ),
                                      );
                                    case ConnectionState.done:
                                      return Text('\$${snapshot.data} (closed)');
                                  }
                                  return null;
                                })
                        ),
                      ],
                    );
                  case ConnectionState.done:
                    return Text('\$${snapshot.data} (closed)');
                }
                return null;
              },
            ),
            FlatButton(
              color: Colors.red,
              onPressed: () {
                _blocImagem.funcaoMudarAlign();
              },
              child: Text('hueheu'),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _moreButtom(context) {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text('Logo'),
                onTap: () {
                  getLogo();
                  Navigator.of(context).pop();
                },
              ),
              new ListTile(
                leading: new Icon(Icons.photo),
                title: new Text('Fundo'),
                onTap: () {
                  getImage();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future getImage({String local}) async {
    File _image;
    if (local == 'camera') {
      _image = await ImagePicker.pickImage(source: ImageSource.camera);
      _blocImagem.imagemFundoSink.add(_image);
    } else {
      _image = await ImagePicker.pickImage(source: ImageSource.gallery);
      _blocImagem.imagemFundoSink.add(_image);
    }
  }

  Future getLogo() async {
    File _logoImage;
    {
      _logoImage = await ImagePicker.pickImage(source: ImageSource.gallery);
      _blocImagem.imagemLogoSink.add(_logoImage);
    }
  }

}
