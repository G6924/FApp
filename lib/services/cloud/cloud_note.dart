import 'package:flutter/foundation.dart';
import 'package:project/services/cloud/cloud_storage_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String text;
  final String imageUrl;
  final String videoUrl;  // Add this line

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text,
    required this.imageUrl,
    required this.videoUrl,  // Add this line
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String,
        imageUrl = snapshot.data()[imageUrlFieldName] as String,
        videoUrl = snapshot.data()[videoUrlFieldName] as String;  // Add this line
}
