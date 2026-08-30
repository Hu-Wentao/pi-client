import 'package:flutter/material.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';

Widget componentTestApp(Widget child) => MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
  ),
  home: Scaffold(body: child),
);

PiSessionSummary testSession(
  String id, {
  String? title,
  String? workingDirectory,
  bool isRunning = false,
  bool hasUnread = false,
}) {
  final createdAt = DateTime.utc(2026, 1, 1, 12);
  return PiSessionSummary(
    id: PiSessionId(id),
    title: title ?? 'Session $id',
    workingDirectory: workingDirectory ?? '/safe/project/$id',
    createdAt: createdAt,
    updatedAt: createdAt.add(const Duration(minutes: 5)),
    isRunning: isRunning,
    hasUnread: hasUnread,
  );
}

PiMessage testMessage(
  String id, {
  PiMessageRole role = PiMessageRole.assistant,
  String? text,
  bool isStreaming = false,
}) => PiMessage(
  id: PiMessageId(id),
  role: role,
  text: text ?? 'Message $id',
  createdAt: DateTime.utc(2026, 1, 1, 12, 5),
  isStreaming: isStreaming,
);
