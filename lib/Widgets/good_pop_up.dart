import 'dart:async';

import 'package:flutter/material.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/message_bubble.dart';
import 'package:retinoscore/Widgets/pop_up_overlay.dart';

class GoodPopUp extends StatefulWidget {
  final Future<void> Function(OverlayVisualState) resizeOverlay;
  final String? message;
  final bool overlayReady;
  const GoodPopUp({
    super.key,
    required this.resizeOverlay,
    this.message = "Imagem possui boa qualidade",
    required this.overlayReady,
  });

  @override
  State<GoodPopUp> createState() => _GoodPopUpState();
}

class _GoodPopUpState extends State<GoodPopUp> {
  bool _showMessage = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.message != null && widget.overlayReady) {
        await _startMessageTimer();
      }
    });
  }

  // função para iniciar o temporizador da mensagem
  Future<void> _startMessageTimer() async {
    debugPrint("Iniciando timer da mensagem");
    _timer?.cancel(); // cancela qualquer timer anterior
    await widget.resizeOverlay(OverlayVisualState.expanded);
    // mostra a mensagem imediatamente com um pequeno delay para garantir o rebuild
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          _showMessage = true;
        });
      }
    });

    // Define o tempo que a mensagem ficará visível (ex: 3 segundos)
    _timer = Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        setState(() {
          _showMessage = false; // Esconde a mensagem
        });
      }
      await widget.resizeOverlay(OverlayVisualState.compact);
      debugPrint("Finalizando timer da mensagem");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definindo o raio do Avatar
    const double avatarRadius = 30.0;

    return Material(
      color: Colors.transparent,
      // usando Align para fixar o Widget no canto direito, como o overlay principal
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          // usando Row para alinhar a mensagem (esquerda) e a bolha (direita)
          mainAxisSize: MainAxisSize.min, // ocupa o mínimo de espaço
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _showMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child:
                  _showMessage
                      ? Padding(
                        padding: const EdgeInsets.only(
                          right: 2.0,
                        ), // Diminuído para aproximar a ponta
                        child: CustomPaint(
                          painter: BubblePainter(Colors.white),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              12.0,
                              8.0,
                              22.0,
                              8.0,
                            ), // Padding extra na direita para o texto não subir na ponta
                            constraints: const BoxConstraints(maxWidth: 190),
                            child: Text(
                              widget.message ??
                                  "Imagem possui boa qualidade.",
                              maxLines: 3,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(), // não ocupa espaço quando invisível
            ),

            // overlay Principal
            CircleAvatar(
              backgroundColor: AppColors.goodColor,
              radius: avatarRadius,
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () async {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
