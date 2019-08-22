import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teste_app/rest/bloc.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'dart:async';

class PrincipalScreen extends StatelessWidget {
  BlocImagem _blocImagem = BlocImagem();

  Offset position = Offset(0.0, 20.0);
  double width = 100.0, height = 100.0;
  double dimensao;
  File imagemLogo;

  @override
  Widget build(BuildContext context) {
    double _larguraTela = MediaQuery.of(context).size.width;
    double _alturaTela = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Logo sobre imagem'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _moreButtom(context),
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              StreamFundoImagem(_alturaTela),
              StreamLogoImagem(),
            ],
          ),
          Container(
            width: _larguraTela,
            height: _alturaTela - 380,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamDxDy(),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Tamanho Logo'),
                  ),
                  LinhaSlider(120, tamanho: 'tm'),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Transparencia Logo'),
                  ),
                  LinhaSlider(10)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinhaSlider(double tamanhoSlider, {String tamanho}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: FlutterSlider(
            values: [tamanhoSlider / 2],
            max: tamanhoSlider,
            min: 0,
            onDragging: (handlerIndex, lowerValue, upperValue) {
              if (tamanho != null) {
                _blocImagem.tamanhoLogoSink.add(lowerValue);
              } else {
                _blocImagem.transparenciaLogoSink.add((lowerValue) / 10);
              }
            },
          ),
        ),
      ],
    );
  }

  StreamDxDy() {
    return StreamBuilder<Offset>(
        stream: _blocImagem.posicaoLogoStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            position = snapshot.data;
            return Padding(
              padding: const EdgeInsets.only(top: 3, right: 24, left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('X:'),
                      Botao(
                          Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.blue,
                          ),
                          position.dx,
                          position.dy - 1),
                      Text(position.dy.floor().toString()),
                      Botao(Icon(Icons.keyboard_arrow_down, color: Colors.blue), position.dx, position.dy + 1),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Y:'),
                      Botao(
                          Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.blue,
                          ),
                          position.dx - 1,
                          position.dy),
                      Text((position.dx.floor().toString())),
                      Botao(Icon(Icons.keyboard_arrow_right, color: Colors.blue), position.dx + 1, position.dy),
                    ],
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget Botao(Icon icone, double dx, double dy, {Color cor = Colors.blue}) {
    return IconButton(
      icon: icone,
      onPressed: () {
        _blocImagem.posicaoLogoSink.add(Offset(dx, dy));
      },
    );
  }

  StreamLogoImagem() {
    return StreamBuilder(
        stream: _blocImagem.imagemLogoStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            imagemLogo = snapshot.data;
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Select lot');
              case ConnectionState.waiting:
                return Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
                return StreamBuilder(
                  stream: _blocImagem.posicaoLogoStream,
                  builder: (context, snapshot) {
                    position = snapshot.data;
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('Select lot');
                      case ConnectionState.waiting:
                        return Text('Awaiting bids...');
                      case ConnectionState.active:
                        return StreamBuilder(
                          stream: _blocImagem.tamanhoLogoStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return Text('Select lot');
                              case ConnectionState.waiting:
                                return Text('Awaiting bids...');
                              case ConnectionState.active:
                                dimensao = snapshot.data;
                                return StreamTransparencia();
                              case ConnectionState.done:
                                return Text('\$${snapshot.data} (closed)');
                            }
                            return Container();
                          },
                        );
                      case ConnectionState.done:
                        return Text('\$${snapshot.data} (closed)');
                    }
                    return null;
                  },
                );
              case ConnectionState.done:
                return Text('\$${snapshot.data} (closed)');
            }
            return Container();
          }
        });
  }

  StreamTransparencia() {
    return StreamBuilder(
        stream: _blocImagem.transparenciaLogoStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Select lot');
            case ConnectionState.waiting:
              return Text('Awaiting bids...');
            case ConnectionState.active:
              return Positioned(
                left: position.dx,
                top: position.dy - 100 + 20,
                child: Draggable(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(imagemLogo),
                      colorFilter: new ColorFilter.mode(Colors.white.withOpacity(snapshot.data), BlendMode.dstATop),
                    )),
                    width: dimensao,
                    height: dimensao,
                  ),
                  feedback: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(imagemLogo),
                      colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstATop),
                    )),
                    width: dimensao,
                    height: dimensao,
                  ),
                  onDraggableCanceled: (Velocity velocity, Offset offset) {
                    position = offset;
                    _blocImagem.posicaoLogoSink.add(offset);
                  },
                ),
              );
            case ConnectionState.done:
              return Text('\$${snapshot.data} (closed)');
          }
          return null;
        });
  }

  StreamFundoImagem(double altura) {
    return StreamBuilder(
        stream: _blocImagem.imagemFundoStream,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.data == null)
            return Container(
              width: double.infinity,
              height: 300,
              color: Colors.black,
              child: Center(
                child: Text(
                  'Nenhuma imagem selecionada',
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
        });
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
                leading: new Text('Logo'),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: () {},
                    ),
                  ],
                ),
                onTap: () {
                  getLogo();
                  Navigator.of(context).pop();
                },
              ),
              new ListTile(
                leading: new Text('Fundo'),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.photo),
                          onPressed: () {
                            getImage();
                            Navigator.of(context).pop();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () {
                            getImage(local: 'camera');
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                ),
                onTap: () {
                  getImage();
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                onPressed: (){
                  print('Salvar Imagem');
                },
                child: Text('Salvar Imagem',style: TextStyle(color: Colors.white),),
                color: Colors.green,
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
