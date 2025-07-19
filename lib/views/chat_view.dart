import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../helpers/event_bus.dart';
import '../provider/main_provider.dart';
import '../services/chat_service.dart';
import '../utils/platform_utils.dart';
import '../widgets/dialogs.dart';
import '../widgets/drop_menu.dart';
import 'settings.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ImagePicker _picker = ImagePicker();
  List<types.Message> _messages = [];
  List _questions = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _answerer =
      const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ad');
  String? _selectedImage;
  bool _showWait = false;
  bool _isProcessed = false;
  late final ChatService _chatService;

  //--------------------------------------------------------------------------//
  @override
  void initState() {
    super.initState();
    _initEventConnector();
    _init();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }

  //--------------------------------------------------------------------------//
  Future<void> _init() async {
    _chatService = ChatService(
        context: context,
        questions: _questions,
        messages: _messages,
        answerer: _answerer,
        user: _user,
        setState: () => setState(() {}),
        onMessageUpdate: _handleMessageUpdate);

    final rightMenu = [
      IconButton(onPressed: _newNote, icon: const Icon(Icons.add)),
      DropMenu(_reloadServerModel, _newNote, _shareAll, _showSettings)
    ];
    MyEventBus().fire(ChangeTitleEvent(tr("l_offGPT"), rightMenu));
  }

  //--------------------------------------------------------------------------//
  void _showSettings() {
    final provider = context.read<MainProvider>();
    final oldServerUrl = provider.baseUrl;

    if (isDesktopOrTablet()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final size = MediaQuery.of(context).size;
          return Dialog(
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(tr("l_settings"),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();

                          // 설정 창이 닫힐 때 서버 주소 변경 확인
                          final newServerUrl = provider.baseUrl;
                          if (oldServerUrl != newServerUrl) {
                            // 서버 주소가 변경되었으면 모델 리로드
                            MyEventBus().fire(ReloadModelEvent());
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: MySettings(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MySettings()),
      ).then((_) {
        final newServerUrl = provider.baseUrl;
        if (oldServerUrl != newServerUrl) {
          MyEventBus().fire(ReloadModelEvent());
        }
      });
    }
  }

  //--------------------------------------------------------------------------//
  void _initEventConnector() async {
    MyEventBus().on<LoadHistoryGroupListEvent>().listen((event) {
      _loadHistoryChats();
    });
    MyEventBus().on<NewChatBeginEvent>().listen((event) {
      _newNote();
    });
    MyEventBus().on<ChatDoneEvent>().listen((event) {
      _loadHistoryChats();
      _isProcessed = false;
      setState(() {});
    });
  }

  //--------------------------------------------------------------------------//
  void _reloadServerModel() async {
    final result = await context.read<MainProvider>().checkServerConnection();
    MyEventBus().fire(ReloadModelEvent());
    setState(() {});

    if (result) {
      showToast(tr("l_success"),
          context: context, position: StyledToastPosition.center);
    } else {
      showToast(tr("l_error_url"),
          context: context, position: StyledToastPosition.center);
    }
  }

  //--------------------------------------------------------------------------//
  void _loadHistoryChats() async {
    _showWait = true;
    setState(() {});

    _messages = [];
    _questions = await context
        .read<MainProvider>()
        .qdb
        .getDetails(context.read<MainProvider>().curGroupId);
    _questions.reversed.forEach((item) {
      if (item["image"] != null) {
        _makeImageMessageAdd(item["image"]);
      }
      int qtime = DateTime.parse(item["created"]).millisecondsSinceEpoch;
      _makeMessageAdd(_user, item["question"], Uuid().v4(), qtime, item["id"]);

      String answer = item["answer"];
      _makeMessageAdd(_answerer, answer, Uuid().v4(), qtime, item["id"]);
    });

    _showWait = false;
    if (mounted) setState(() {});
  }

  //--------------------------------------------------------------------------//
  void _makeMessageAdd(types.User user, String text, String unique, int time,
      [int? id = null]) async {
    final msg = types.TextMessage(
      author: user,
      createdAt: time,
      id: unique,
      text: text,
      metadata: {'id': id},
    );

    _messages.insert(0, msg);
    if (mounted) setState(() {});
  }

  //--------------------------------------------------------------------------//
  void _shareAll() {
    String sharedData = "";
    if (_questions.isEmpty) return;

    _questions.forEach((item) {
      sharedData += item["question"] +
          "\n\n" +
          item["answer"] +
          "\n\n" +
          item["engine"] +
          "\n" +
          item["created"] +
          "\n\n";
    });
    Share.share(sharedData);
  }

  //--------------------------------------------------------------------------//
  void _newNote([String? question]) {
    final provider = context.read<MainProvider>();

    provider.curGroupId = Uuid().v4();
    _messages = [];
    _questions = [];

    setState(() {});
  }

  //--------------------------------------------------------------------------//
  void _handleMessageUpdate(String content) {
    if (_messages.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    if (_messages[0].author.id != _answerer.id) {
      return;
    }

    final currentText = (_messages[0] as types.TextMessage).text;
    if (currentText == content) {
      return;
    }

    setState(() {
      _messages[0] =
          (_messages[0] as types.TextMessage).copyWith(text: content);
    });
  }

  //--------------------------------------------------------------------------//
  void _beginAsking(types.PartialText message) async {
    FocusScope.of(context).unfocus();

    final provider = context.read<MainProvider>();
    String question = message.text;

    if (question.isEmpty) return;

    if (_isProcessed) {
      return;
    }

    types.TextMessage ask = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: question,
    );

    setState(() {
      _messages.insert(0, ask);
      _isProcessed = true;
    });

    String? modelToUse = provider.selectedModel;

    if (modelToUse == null && provider.modelList!.isNotEmpty) {
      modelToUse = provider.modelList!.first.model;
      if (modelToUse != null) {
        provider.setSelectedModel(modelToUse);
      } else {
        setState(() {
          _isProcessed = false;
        });
        showToast(tr("l_error_no_models"),
            context: context, position: StyledToastPosition.center);
        return;
      }
    }

    if (mounted) {
      _chatService.selectedImage = _selectedImage;

      try {
        types.TextMessage ansMessage = types.TextMessage(
          author: _answerer,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: "...",
        );

        setState(() {
          _messages.insert(0, ansMessage);
        });

        await _chatService.startGeneration(
          question: question,
          modelName: modelToUse!,
          onMessageUpdate: (content) {
            _handleMessageUpdate(content);
          },
          onError: (error) {
            if (_messages.isNotEmpty &&
                _messages[0].author.id == _answerer.id) {
              setState(() {
                _messages[0] = (_messages[0] as types.TextMessage).copyWith(
                  text: "오류: $error",
                );
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            setState(() {
              _isProcessed = false;
            });
          },
          onComplete: () {
            setState(() {
              _isProcessed = false;
            });
          },
        );
      } catch (e) {
        // 오류 메시지로 UI 업데이트
        if (_messages.isNotEmpty && _messages[0].author.id == _answerer.id) {
          setState(() {
            _messages[0] = (_messages[0] as types.TextMessage).copyWith(
              text: "오류: $e",
            );
          });
        }

        setState(() {
          _isProcessed = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류: $e")),
        );
      }
    }
  }

  //--------------------------------------------------------------------------//
  void _handleAttachmentPressed() async {
    XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500);
    if (image != null) {
      File file = File(image.path);
      List<int> imageBytes = file.readAsBytesSync();
      _selectedImage = base64Encode(imageBytes);
      _makeImageMessageAdd(_selectedImage!);
    }
  }

  //--------------------------------------------------------------------------//
  void _handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  //--------------------------------------------------------------------------//
  void _makeImageMessageAdd(String base64image) {
    final msg = types.CustomMessage(
      author: _answerer,
      id: const Uuid().v4(),
      metadata: {'data': base64image, 'type': 'image'},
    );

    _messages.insert(0, msg);
    if (mounted) setState(() {});
  }

  //--------------------------------------------------------------------------//
  Widget _customMessageBuilder(types.CustomMessage message,
      {required int messageWidth}) {
    if (message.metadata!['type'] == 'image') {
      return RepaintBoundary(
        child: Image.memory(
          base64Decode(message.metadata!['data']),
          fit: BoxFit.contain,
        ),
      );
    }
    return const SizedBox();
  }

  //--------------------------------------------------------------------------//
  void _menuRunner(int number, types.TextMessage message) async {
    final provider = context.read<MainProvider>();

    final id = message.metadata!['id'];
    final record = await provider.qdb.getDetailsById(id);
    if (record.isNotEmpty) {
      final question = record[0]["question"];
      final answer = record[0]["answer"];
      final created = record[0]["created"];
      final model = record[0]["engine"];
      final sharedData = "$question\n\n$answer\n\n$model\n$created";

      if (number == 0) {
        _newNote();
      } else if (number == 1) {
        Clipboard.setData(ClipboardData(text: sharedData));
        showToast(tr("l_copyed"),
            context: context, position: StyledToastPosition.center);
      } else if (number == 2) {
        Share.share(sharedData);
      } else if (number == 3) {
        final result = await AskDialog.show(context,
            title: tr("l_delete"), message: tr("l_delete_question"));
        if (result == true) {
          await provider.qdb.deleteRecord(id);
          // check is last data?
          provider.qdb
              .getDetails(context.read<MainProvider>().curGroupId)
              .then((value) {
            if (value.isEmpty) {
              MyEventBus().fire(RefreshMainListEvent());
              _newNote();
            } else {
              _loadHistoryChats();
            }
          });
        }
      }
    }
  }

  //--------------------------------------------------------------------------//
  Widget _messageMenu(types.TextMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF09090B).withValues(alpha: 0.95)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuButton(
            icon: Icons.open_in_new_rounded,
            onTap: () => _menuRunner(0, message),
            isDark: isDark,
          ),
          _buildMenuButton(
            icon: Icons.copy_rounded,
            onTap: () => _menuRunner(1, message),
            isDark: isDark,
          ),
          _buildMenuButton(
            icon: Icons.share_rounded,
            onTap: () => _menuRunner(2, message),
            isDark: isDark,
          ),
          _buildMenuButton(
            icon: Icons.delete_outline_rounded,
            onTap: () => _menuRunner(3, message),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: isDark
            ? const Color(0xFF27272A).withValues(alpha: 0.5)
            : const Color(0xFFE4E4E7).withValues(alpha: 0.5),
        highlightColor: isDark
            ? const Color(0xFF27272A).withValues(alpha: 0.3)
            : const Color(0xFFE4E4E7).withValues(alpha: 0.3),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark
                ? const Color(0xFFA1A1AA) // Zinc-400
                : const Color(0xFF71717A), // Zinc-500
            size: 14,
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------//
  Widget _textMessageBuilder(types.TextMessage message,
      {required int messageWidth, bool? showName}) {
    final isAnswer = message.author.id == _answerer.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: MarkdownBody(
            data: message.text,
            selectable: true,
            onTapLink: (text, href, title) {
              launchUrl(Uri.parse(href!));
            },
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFFF4F4F5)
                        : const Color(0xFF18181B))
                    : const Color(0xFFF8FAFC),
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
              h1: TextStyle(
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFFF4F4F5)
                        : const Color(0xFF0F172A))
                    : const Color(0xFFF8FAFC),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: -0.3,
              ),
              h2: TextStyle(
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFFF4F4F5)
                        : const Color(0xFF0F172A))
                    : const Color(0xFFF8FAFC),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: -0.2,
              ),
              h3: TextStyle(
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFFF4F4F5)
                        : const Color(0xFF0F172A))
                    : const Color(0xFFF8FAFC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: -0.1,
              ),
              code: TextStyle(
                backgroundColor: isAnswer
                    ? (isDark
                        ? const Color(0xFF18181B)
                        : const Color(0xFFF1F5F9))
                    : Colors.white.withValues(alpha: 0.15),
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFFE4E4E7)
                        : const Color(0xFF334155))
                    : const Color(0xFFF1F5F9),
                fontSize: 13,
                fontFamily: 'SF Mono',
                fontWeight: FontWeight.w500,
              ),
              codeblockDecoration: BoxDecoration(
                color: isAnswer
                    ? (isDark
                        ? const Color(0xFF18181B)
                        : const Color(0xFFF8FAFC))
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAnswer
                      ? (isDark
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE2E8F0))
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        if (isAnswer && !_isProcessed)
          Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      isDark
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE4E4E7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _messageMenu(message),
                ),
              ),
              const SizedBox(height: 8),
            ],
          )
      ],
    );
  }

  //--------------------------------------------------------------------------//
  Widget _chatUI() {
    final provider = context.read<MainProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Chat(
            theme: DefaultChatTheme(
              // Modern shadcn-inspired input field styling
              inputTextDecoration: InputDecoration(
                hintText: tr("l_input_question"),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF71717A) // Zinc-500
                      : const Color(0xFF71717A), // Zinc-500
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
                filled: false,
              ),

              // Modern message bubble styling - shadcn inspired
              bubbleMargin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),

              // Message bubble border radius - clean and modern
              messageBorderRadius: 16,
              messageInsetsHorizontal: 16,
              messageInsetsVertical: 12,

              // Message width constraint
              messageMaxWidth: MediaQuery.of(context).size.width * 0.80,

              // Modern shadcn-inspired color palette
              primaryColor: const Color(0xFF0F172A), // Slate-900
              secondaryColor: isDark
                  ? const Color(0xFF18181B) // Zinc-900
                  : const Color(0xFFF8FAFC), // Slate-50
              backgroundColor: isDark
                  ? const Color(0xFF0A0A0A) // Near black
                  : const Color(0xFFFFFFFF), // Pure white

              // Modern input styling - shadcn inspired
              inputBackgroundColor: Colors.transparent,
              inputTextCursorColor: isDark
                  ? const Color(0xFFF4F4F5) // Zinc-100
                  : const Color(0xFF09090B), // Zinc-950
              inputTextColor: isDark
                  ? const Color(0xFFF4F4F5) // Zinc-100
                  : const Color(0xFF09090B), // Zinc-950
              inputBorderRadius: BorderRadius.circular(16),

              // Modern input margins - shadcn style
              inputMargin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              inputPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),

              // Clean shadcn text styling
              inputTextStyle: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFFF4F4F5) // Zinc-100
                    : const Color(0xFF09090B), // Zinc-950
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: -0.1,
              ),

              // Message text styles - Clean and readable
              receivedMessageBodyTextStyle: TextStyle(
                color: isDark
                    ? const Color(0xFFF4F4F5) // Zinc-100
                    : const Color(0xFF18181B), // Zinc-900
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.6,
                letterSpacing: -0.1,
              ),
              sentMessageBodyTextStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF18181B) // Zinc-900
                    : const Color(0xFFF8FAFC), // Slate-50
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.6,
                letterSpacing: -0.1,
              ),

              // Modern shadcn-inspired icons
              attachmentButtonIcon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.attach_file_rounded,
                  color: isDark
                      ? const Color(0xFF71717A) // Zinc-500
                      : const Color(0xFF71717A), // Zinc-500
                  size: 16,
                ),
              ),
              sendButtonIcon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFF4F4F5) // Zinc-100
                      : const Color(0xFF09090B), // Zinc-950
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF27272A) // Zinc-800
                        : const Color(0xFFE4E4E7), // Zinc-200
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: isDark
                      ? const Color(0xFF09090B) // Zinc-950
                      : const Color(0xFFF4F4F5), // Zinc-100
                  size: 16,
                ),
              ),

              // Button margins for clean spacing
              attachmentButtonMargin: const EdgeInsets.only(left: 6),
              sendButtonMargin: const EdgeInsets.only(right: 6),

              // Modern input container - shadcn inspired
              inputContainerDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark
                    ? const Color(0xFF09090B) // Zinc-950
                    : const Color(0xFFFFFFFF), // Pure white
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF27272A) // Zinc-800
                      : const Color(0xFFE4E4E7), // Zinc-200
                  width: 1,
                ),
                boxShadow: [
                  // Subtle shadow for depth
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  // Very subtle outer glow
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),

              // Modern empty chat placeholder
              emptyChatPlaceholderTextStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF71717A) // Zinc-500
                    : const Color(0xFF64748B), // Slate-500
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: -0.1,
              ),

              // Clean date divider
              dateDividerTextStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF52525B) // Zinc-600
                    : const Color(0xFF94A3B8), // Slate-400
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: 0.1,
              ),
              dateDividerMargin: const EdgeInsets.symmetric(vertical: 16),
            ),
            messages: _messages,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed:
                _beginAsking, // Enable the built-in send functionality
            user: _user,
            l10n: ChatL10nEn(
                inputPlaceholder: tr("l_input_question"),
                emptyChatPlaceholder: provider.serveConnected
                    ? tr("l_no_conversation")
                    : tr("l_no_server")),
            showUserAvatars: false,
            showUserNames: false,
            customMessageBuilder: _customMessageBuilder,
            textMessageBuilder: (message,
                    {required messageWidth, required showName}) =>
                _textMessageBuilder(message,
                    messageWidth: messageWidth, showName: showName),
            disableImageGallery: false,
            onAttachmentPressed: _handleAttachmentPressed,
            inputOptions: const InputOptions(
              enabled: true, // Enable the default input
              sendButtonVisibilityMode: SendButtonVisibilityMode.editing,
            ),
          ),
        ),
      ],
    );
  }

  //--------------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: _chatUI(),
          ),
          _showWait
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox()
        ],
      ),
    );
  }
}
