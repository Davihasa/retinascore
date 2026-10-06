// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_classifier_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QualidadeImagemAdapter extends TypeAdapter<QualidadeImagem> {
  @override
  final int typeId = 1;

  @override
  QualidadeImagem read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QualidadeImagem.boa;
      case 1:
        return QualidadeImagem.usavel;
      case 2:
        return QualidadeImagem.rejeitada;
      default:
        return QualidadeImagem.boa;
    }
  }

  @override
  void write(BinaryWriter writer, QualidadeImagem obj) {
    switch (obj) {
      case QualidadeImagem.boa:
        writer.writeByte(0);
        break;
      case QualidadeImagem.usavel:
        writer.writeByte(1);
        break;
      case QualidadeImagem.rejeitada:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualidadeImagemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoImagemAdapter extends TypeAdapter<TipoImagem> {
  @override
  final int typeId = 2;

  @override
  TipoImagem read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoImagem.olho;
      case 1:
        return TipoImagem.retina;
      case 2:
        return TipoImagem.retinaPB;
      case 3:
        return TipoImagem.noEye;
      default:
        return TipoImagem.olho;
    }
  }

  @override
  void write(BinaryWriter writer, TipoImagem obj) {
    switch (obj) {
      case TipoImagem.olho:
        writer.writeByte(0);
        break;
      case TipoImagem.retina:
        writer.writeByte(1);
        break;
      case TipoImagem.retinaPB:
        writer.writeByte(2);
        break;
      case TipoImagem.noEye:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoImagemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
