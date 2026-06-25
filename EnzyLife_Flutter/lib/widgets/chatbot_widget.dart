import 'package:flutter/material.dart';
import '../app_color.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  bool _isOpen = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Draggable & Snapping variables
  Offset? _position;
  bool _isDragging = false;
  bool _isSnappedToRight = true;

  static const List<String> _presets = [
    "Apa itu Eco Enzyme?",
    "Cara membuat Eco Enzyme?",
    "Manfaat Eco Enzyme?",
    "Ada produk apa saja?",
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Halo! Saya Enzy, asisten virtual EnzyLife. Ada yang bisa saya bantu seputar Eco Enzyme?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Panggil API chatbot
    final reply = await ApiService.sendChat(text);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: reply ?? "Maaf, terjadi masalah koneksi. Silakan periksa apakah server AI (FastAPI) sudah aktif.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    _sendMessage(text);
  }

  void _snapToEdge(double bodyWidth, double bodyHeight) {
    if (_position == null) return;

    double targetX;
    // Tentukan sisi terdekat untuk snap
    if (_position!.dx + 28 < bodyWidth / 2) {
      targetX = 16;
      _isSnappedToRight = false;
    } else {
      targetX = bodyWidth - 56 - 16;
      _isSnappedToRight = true;
    }

    // Batasi posisi Y agar tidak melewati batas atas dan bawah body
    double minY = 16.0;
    double maxY = bodyHeight - 56 - 16; // Tepat di atas bottom navbar
    double targetY = _position!.dy.clamp(minY, maxY);

    setState(() {
      _isDragging = false;
      _position = Offset(targetX, targetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double bodyWidth = constraints.maxWidth;
        final double bodyHeight = constraints.maxHeight;

        // Inisialisasi posisi awal (kanan bawah) berdasarkan ukuran body sesungguhnya
        _position ??= Offset(
          bodyWidth - 56 - 16,
          bodyHeight - 56 - 16,
        );

        // Ukuran window chat yang ramping dan tinggi
        const double chatWidth = 300.0;
        final double chatHeight = (bodyHeight - 32 < 500) ? (bodyHeight - 32) : 500.0;

        // Koordinat penempatan chat window
        final double chatLeft = _isSnappedToRight ? (bodyWidth - chatWidth - 16) : 16;
        final double chatTop = (_position!.dy - chatHeight + 56).clamp(16.0, bodyHeight - chatHeight - 16);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: _isOpen ? chatLeft : _position!.dx,
              top: _isOpen ? chatTop : _position!.dy,
              width: _isOpen ? chatWidth : 56,
              height: _isOpen ? chatHeight : 56,
              child: OverflowBox(
                alignment: _isSnappedToRight
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                minWidth: 0,
                maxWidth: _isOpen ? chatWidth : 56,
                minHeight: 0,
                maxHeight: _isOpen ? chatHeight : 56,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        alignment: _isSnappedToRight
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: child,
                      ),
                    );
                  },
                  child: _isOpen
                      ? _buildChatWindow(chatWidth, chatHeight,
                          key: const ValueKey('chat_window'))
                      : _buildFloatingButton(
                          key: const ValueKey('floating_button'),
                          bodyWidth: bodyWidth,
                          bodyHeight: bodyHeight),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingButton({required Key key, required double bodyWidth, required double bodyHeight}) {
    return GestureDetector(
      key: key,
      onPanStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          // Batasi posisi saat di-drag agar tombol tidak terkeluar dari area body
          double newX = (_position!.dx + details.delta.dx).clamp(0.0, bodyWidth - 56.0);
          double newY = (_position!.dy + details.delta.dy).clamp(0.0, bodyHeight - 56.0);
          _position = Offset(newX, newY);
        });
      },
      onPanEnd: (_) => _snapToEdge(bodyWidth, bodyHeight),
      onTap: () {
        setState(() {
          _isOpen = true;
        });
        _scrollToBottom();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.green500, width: 2),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/Ai-logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatWindow(double width, double height, {required Key key}) {
    return Container(
      key: key,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping) _buildTypingIndicator(),

            // Presets/Quick Replies
            _buildPresetsList(),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green500, AppColors.green700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 268,
          child: Row(
            children: [
              // Mini avatar
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Ai-logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tanya Enzy",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        // Pulsing online indicator
                        const _PulseOnlineDot(),
                        const SizedBox(width: 4),
                        const Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _isOpen = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(
          maxWidth: 220, // ~73% dari chatWidth 300
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.green500 : AppColors.green50,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : AppColors.text1,
                fontSize: 12.0,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: msg.isUser ? Colors.white60 : Colors.grey[500],
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BouncingDot(delay: 0),
            SizedBox(width: 4),
            BouncingDot(delay: 150),
            SizedBox(width: 4),
            BouncingDot(delay: 300),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsList() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _presets.length,
        itemBuilder: (context, index) {
          final text = _presets[index];
          return Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 4),
            child: ActionChip(
              onPressed: _isTyping ? null : () => _sendMessage(text),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: AppColors.bgPage,
              label: Text(
                text,
                style: const TextStyle(
                  color: AppColors.green700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              side: BorderSide(color: AppColors.green200.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _handleSend(),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: "Tanya sesuatu...",
                  hintStyle: TextStyle(color: AppColors.hint, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.green500,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

// Bouncing dots animation widget for typing indicator
class BouncingDot extends StatefulWidget {
  final int delay;
  const BouncingDot({super.key, required this.delay});

  @override
  State<BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<BouncingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.green500,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// Pulsing online dot animation widget
class _PulseOnlineDot extends StatefulWidget {
  const _PulseOnlineDot();

  @override
  State<_PulseOnlineDot> createState() => _PulseOnlineDotState();
}

class _PulseOnlineDotState extends State<_PulseOnlineDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
