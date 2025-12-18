import 'dart:typed_data';
import '../../../base/base_bloc_state.dart';
import '../../../data/model/challenge.dart';

class UploadedImage {
  final String id;
  final Uint8List bytes;
  final String path;
  String name;
  String? compressedBase64;

  UploadedImage({
    required this.id,
    required this.bytes,
    required this.path,
    required this.name,
    this.compressedBase64,
  });
}

class CreateWizardState extends BaseBlocState {
  final String step;
  final List<UploadedImage> images;
  final String topicName;
  final int currentLevel;
  final List<List<String?>> levels;
  final int? selectedSlot;
  final Challenge? createdChallenge;

  const CreateWizardState({
    super.isLoading = false,
    super.error,
    this.step = 'UPLOAD',
    this.images = const [],
    this.topicName = '',
    this.currentLevel = 0,
    this.levels = const [],
    this.selectedSlot,
    this.createdChallenge,
  });

  bool get canProceedFromUpload {
    return images.length >= 2 &&
        images.every((img) => img.name.trim().isNotEmpty);
  }

  bool get canFinish {
    return topicName.trim().isNotEmpty &&
        levels.every((level) => level.every((id) => id != null));
  }

  @override
  CreateWizardState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    String? step,
    List<UploadedImage>? images,
    String? topicName,
    int? currentLevel,
    List<List<String?>>? levels,
    int? selectedSlot,
    Challenge? createdChallenge,
  }) {
    return CreateWizardState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      step: step ?? this.step,
      images: images ?? this.images,
      topicName: topicName ?? this.topicName,
      currentLevel: currentLevel ?? this.currentLevel,
      levels: levels ?? this.levels,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      createdChallenge: createdChallenge ?? this.createdChallenge,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        step,
        images,
        topicName,
        currentLevel,
        levels,
        selectedSlot,
        createdChallenge,
      ];
}
