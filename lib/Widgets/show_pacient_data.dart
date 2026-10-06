import 'package:flutter/material.dart';
import 'package:retinoscore/Models/image_classifying_result.dart';
import 'package:retinoscore/Screens/acquisitions_from_pacient.dart';
import 'package:retinoscore/Styles/colors.dart';

class ShowPacientData extends StatelessWidget {
  final String paciente;
  final List<ImageClassifyingResult> imagensClassificadas;

  const ShowPacientData({
    super.key,
    required this.paciente,
    required this.imagensClassificadas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryColor.withAlpha(77),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AcquisitionsFromPacient(
                imagensClassificadas: imagensClassificadas,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.primaryColor,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paciente,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${imagensClassificadas.length} exame(s)",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
