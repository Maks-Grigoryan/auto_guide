/// Who said it.
enum ChatRole {
  /// Typed by the person using the app.
  user,

  /// Written by the assistant.
  assistant,
}

/// One message in the assistant conversation.
///
/// Deliberately thin while the backend does not exist: text and a side. Part
/// cards, tool results and photo attachments all hang off a message once there
/// is a server to produce them, and each will arrive as its own field rather
/// than as markup smuggled inside [text].
class ChatMessage {
  const ChatMessage({required this.role, required this.text});

  const ChatMessage.user(this.text) : role = ChatRole.user;

  const ChatMessage.assistant(this.text) : role = ChatRole.assistant;

  final ChatRole role;
  final String text;

  bool get isUser => role == ChatRole.user;
}
