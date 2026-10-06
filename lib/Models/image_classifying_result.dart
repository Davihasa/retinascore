import 'package:hive/hive.dart';
import 'package:retinoscore/Services/image_classifier_service.dart';

part 'image_classifying_result.g.dart';

@HiveType(typeId: 0)
class ImageClassifyingResult extends HiveObject {
  @HiveField(0)
  TipoImagem tipoImagem;

  @HiveField(1)
  QualidadeImagem? qualidadeImagem;

  @HiveField(2)
  String paciente;

  @HiveField(3)
  String caminhoImagem;

  @HiveField(4)
  String? caminhoImagemMelhorada;

  @HiveField(5)
  QualidadeImagem? qualidadeImagemMelhorada;

  @HiveField(6)
  DateTime dataClassificacao;

  ImageClassifyingResult({
    required this.qualidadeImagem,
    required this.tipoImagem,
    required this.paciente,
    required this.caminhoImagem,
    required this.caminhoImagemMelhorada,
    required this.dataClassificacao,
    required this.qualidadeImagemMelhorada,
  });
}
