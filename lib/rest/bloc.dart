import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class BlocImagem {

  List<AlignmentGeometry> _listaAlinhamentos = [
    Alignment.center,
    Alignment.centerLeft,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
    Alignment.topCenter,
  ];

  File _fundoImagem;
  File _logoImagem;
  int _contador = 0;

  final _imagemFundo = StreamController<File>();
  final _imagemLogo = StreamController<File>();
  final _mudarAlign = StreamController();

  Stream get eventoMudarAlignStream => _mudarAlign.stream;

  Stream<File> get imagemLogoStream => _imagemLogo.stream;
  StreamSink<File> get imagemLogoSink => _imagemLogo.sink;


  Stream<File> get imagemFundoStream => _imagemFundo.stream;
  StreamSink<File> get imagemFundoSink => _imagemFundo.sink;

  BlocImagem(){
    _mudarAlign.add(_listaAlinhamentos[_contador]);
    _imagemFundo.add(_fundoImagem);
    _imagemLogo.add(_logoImagem);
  }

  funcaoMudarAlign(){
    if(_contador>7){
      _contador = 0;
    }else{
      _contador++;
    }
    _mudarAlign.add(_listaAlinhamentos[_contador]);
  }

  dispose(){
    _mudarAlign.close();
    _imagemLogo.close();
    _imagemFundo.close();
  }
}