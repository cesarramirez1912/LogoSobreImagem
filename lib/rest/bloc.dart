import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class BlocImagem {



  File _fundoImagem;
  File _logoImagem;
  Offset position = Offset(0.0, 100.0-20);

  final _imagemFundo = StreamController<File>();
  final _imagemLogo = StreamController<File>();
  final _posicaoLogo = StreamController<Offset>();



  Stream get posicaoLogoStream => _posicaoLogo.stream;
  StreamSink get posicaoLogoSink => _posicaoLogo.sink;

  Stream<File> get imagemLogoStream => _imagemLogo.stream;
  StreamSink<File> get imagemLogoSink => _imagemLogo.sink;


  Stream<File> get imagemFundoStream => _imagemFundo.stream;
  StreamSink<File> get imagemFundoSink => _imagemFundo.sink;

  BlocImagem(){
    _posicaoLogo.add(position);
    _imagemFundo.add(_fundoImagem);
    _imagemLogo.add(_logoImagem);
  }

  dispose(){
    _posicaoLogo.close();
    _imagemLogo.close();
    _imagemFundo.close();
  }
}