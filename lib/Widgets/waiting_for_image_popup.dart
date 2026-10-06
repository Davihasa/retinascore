import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retinoscore/Styles/colors.dart';
import 'package:retinoscore/Widgets/message_bubble.dart';
import 'package:retinoscore/Widgets/pop_up_overlay.dart';

class WaitingForImagePopup extends StatefulWidget {
  final Future<void> Function(OverlayVisualState) resizeOverlay;
  final String? message;
  final bool overlayReady;
  final bool showedMessageOnce;
  final VoidCallback onMessageShown;

  const WaitingForImagePopup({
    super.key,
    required this.resizeOverlay,
    this.message = "Aguardando novas imagens",
    required this.overlayReady,
    required this.showedMessageOnce,
    required this.onMessageShown,
  });

  @override
  State<WaitingForImagePopup> createState() => _WaitingForImagePopupState();
}

class _WaitingForImagePopupState extends State<WaitingForImagePopup> {
  bool _showMessage = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.message != null &&
          widget.overlayReady &&
          !widget.showedMessageOnce) {
        await _startMessageTimer();
      }
    });
  }

  @override
  void didUpdateWidget(covariant WaitingForImagePopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a mensagem mudou de nulo para um valor, ou para um valor diferente,
    // reinicie o timer.
    if (widget.message != null &&
        widget.overlayReady &&
        !widget.showedMessageOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _startMessageTimer();
      });
    }
    // Se a mensagem se tornou nula, garante que não está mostrando.
    if (widget.message == null && oldWidget.message != null) {
      setState(() {
        _showMessage = false;
      });
    }
  }

  // Função para iniciar o temporizador da mensagem
  Future<void> _startMessageTimer() async {
    debugPrint("Iniciando timer da mensagem");
    _timer?.cancel(); // Cancela qualquer timer anterior
    await widget.resizeOverlay(OverlayVisualState.expanded);
    // Mostra a mensagem imediatamente com um pequeno delay para garantir o rebuild
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
      widget.onMessageShown();
      await widget.resizeOverlay(OverlayVisualState.compact);
      debugPrint("Finalizando timer da mensagem");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definimos o raio do Avatar
    const double avatarRadius = 30.0;

    return Material(
      color: Colors.transparent,
      // Usamos Align para fixar o Widget no canto direito, como o overlay principal
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          // Usamos Row para alinhar a mensagem (esquerda) e a bolha (direita)
          mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
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
                                  "Aguardando novas imagens...",
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
                      : const SizedBox.shrink(), 
            ),

            CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              radius: avatarRadius,
              child: IconButton(
                icon: const Icon(
                  Icons.image_search_rounded,
                  color: Colors.white,
                ),
                onPressed: () async {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
