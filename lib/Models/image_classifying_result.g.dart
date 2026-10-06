// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_classifying_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageClassifyingResultAdapter
    extends TypeAdapter<ImageClassifyingResult> {
  @override
  final int typeId = 0;

  @override
  ImageClassifyingResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageClassifyingResult(
      qualidadeImagem: fields[1] as QualidadeImagem?,
      tipoImagem: fields[0] as TipoImagem,
      paciente: fields[2] as String,
      caminhoImagem: fields[3] as String,
      caminhoImagemMelhorada: fields[4] as String?,
      dataClassificacao: fields[6] as DateTime,
      qualidadeImagemMelhorada: fields[5] as QualidadeImagem?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageClassifyingResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tipoImagem)
      ..writeByte(1)
      ..write(obj.qualidadeImagem)
      ..writeByte(2)
      ..write(obj.paciente)
      ..writeByte(3)
      ..write(obj.caminhoImagem)
      ..writeByte(4)
      ..write(obj.caminhoImagemMelhorada)
      ..writeByte(5)
      ..write(obj.qualidadeImagemMelhorada)
      ..writeByte(6)
      ..write(obj.dataClassificacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageClassifyingResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
