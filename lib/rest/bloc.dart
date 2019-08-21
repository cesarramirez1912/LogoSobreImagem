import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class BlocImagem {



  File _fundoImagem;
  File _logoImagem;
  Offset position = Offset(0.0, 100.0-20);
  double _logoTamanho = 60.0;
  double _logoTransparencia = 0.5;

  final _imagemFundo = StreamController<File>();
  final _imagemLogo = StreamController<File>();
  final _posicaoLogo = StreamController<Offset>();
  final _tamanhoLogo = StreamController<double>();
  final _transparenciaLogo = StreamController<double>();

  Stream get transparenciaLogoStream => _transparenciaLogo.stream;
  StreamSink get transparenciaLogoSink => _transparenciaLogo.sink;

  Stream get tamanhoLogoStream => _tamanhoLogo.stream;
  StreamSink get tamanhoLogoSink => _tamanhoLogo.sink;

  Stream get posicaoLogoStream => _posicaoLogo.stream;
  StreamSink get posicaoLogoSink => _posicaoLogo.sink;

  Stream<File> get imagemLogoStream => _imagemLogo.stream;
  StreamSink<File> get imagemLogoSink => _imagemLogo.sink;


  Stream<File> get imagemFundoStream => _imagemFundo.stream;
  StreamSink<File> get imagemFundoSink => _imagemFundo.sink;

  BlocImagem(){
    _transparenciaLogo.add(_logoTransparencia);
    _tamanhoLogo.add(_logoTamanho);
    _posicaoLogo.add(position);
    _imagemFundo.add(_fundoImagem);
    _imagemLogo.add(_logoImagem);
  }

  dispose(){
    _tamanhoLogo.close();
    _transparenciaLogo.close();
    _posicaoLogo.close();
    _imagemLogo.close();
    _imagemFundo.close();
  }
}