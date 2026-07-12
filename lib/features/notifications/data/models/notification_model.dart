import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String recipientId;
  final String senderId;
  final String title;
  final String message;
  final String type;
  final String referenceId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.title,
    required this.message,
    required this.type,
    required this.referenceId,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final rawCreatedAt = data['createdAt'];

    return AppNotification(
      id: document.id,
      recipientId: data['recipientId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      referenceId: data['referenceId'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        senderId,
        title,
        message,
        type,
        referenceId,
        isRead,
        createdAt,
      ];
}