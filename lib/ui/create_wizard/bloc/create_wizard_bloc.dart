import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/challenge.dart';
import '../../../data/model/round.dart';
import '../../../data/model/challenge_item.dart';
import '../../../data/local/database_service.dart';
import '../../../services/storage_service.dart';
import 'create_wizard_event.dart';
import 'create_wizard_state.dart';

class CreateWizardBloc extends BaseBloc<CreateWizardEvent, CreateWizardState> {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final Random _random = Random();

  CreateWizardBloc() : super(const CreateWizardState()) {
    on<CreateWizardInitialized>(_onInitialized);
    on<ImagesSelected>(_onImagesSelected);
    on<ImageNameUpdated>(_onImageNameUpdated);
    on<ImageRemoved>(_onImageRemoved);
    on<StepChanged>(_onStepChanged);
    on<ModeSelected>(_onModeSelected);
    on<LevelChanged>(_onLevelChanged);
    on<SlotSelected>(_onSlotSelected);
    on<ImageSelectedForSlot>(_onImageSelectedForSlot);
    on<AutoFillLevel>(_onAutoFillLevel);
    on<ClearLevel>(_onClearLevel);
    on<TopicNameUpdated>(_onTopicNameUpdated);
    on<FinishCreation>(_onFinishCreation);
    on<CancelCreation>(_onCancelCreation);
  }

  Future<void> _onInitialized(
    CreateWizardInitialized event,
    Emitter<CreateWizardState> emit,
  ) async {
    emit(state.copyWith(
      step: 'UPLOAD',
      images: [],
      topicName: '',
      currentLevel: 0,
      levels: [],
      selectedSlot: null,
    ));
  }

  void _onImagesSelected(
    ImagesSelected event,
    Emitter<CreateWizardState> emit,
  ) {
    final newImages = event.imageBytes.asMap().entries.map((entry) {
      final index = entry.key;
      final bytes = entry.value;
      return UploadedImage(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        bytes: bytes,
        path: event.imagePaths[index],
        name: '',
      );
    }).toList();

    final combined = [...state.images, ...newImages].take(4).toList();
    emit(state.copyWith(images: combined));
  }

  void _onImageNameUpdated(
    ImageNameUpdated event,
    Emitter<CreateWizardState> emit,
  ) {
    final updatedImages = state.images.map((img) {
      if (img.id == event.imageId) {
        return UploadedImage(
          id: img.id,
          bytes: img.bytes,
          path: img.path,
          name: event.name,
          compressedBase64: img.compressedBase64,
        );
      }
      return img;
    }).toList();

    emit(state.copyWith(images: updatedImages));
  }

  void _onImageRemoved(
    ImageRemoved event,
    Emitter<CreateWizardState> emit,
  ) {
    final updatedImages =
        state.images.where((img) => img.id != event.imageId).toList();
    emit(state.copyWith(images: updatedImages));
  }

  void _onStepChanged(
    StepChanged event,
    Emitter<CreateWizardState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  void _onModeSelected(
    ModeSelected event,
    Emitter<CreateWizardState> emit,
  ) {
    if (event.isRandom) {
      _generateRandomLevels(emit);
    } else {
      final emptyLevels = List.generate(5, (_) => List<String?>.filled(8, null));
      emit(state.copyWith(levels: emptyLevels));
    }
    emit(state.copyWith(step: 'MANUAL'));
  }

  void _generateRandomLevels(Emitter<CreateWizardState> emit) {
    final generatedLevels = <List<String?>>[];
    const beatPattern = [0, 1, 2, 0, 2, 1, 0, 1];
    const maxLevels = 5;

    for (int i = 0; i < maxLevels; i++) {
      int attempts = 0;
      List<String?>? levelPattern;
      bool isUnique = false;

      while (!isUnique && attempts < 20) {
        int subsetSize = state.images.length;
        if (state.images.length >= 3) {
          if (i == 0) {
            subsetSize = 2;
          } else if (i == 1) {
            subsetSize = 3;
          }
        }

        final shuffledImages = List<UploadedImage>.from(state.images)
          ..shuffle(_random);
        final activeSubset = shuffledImages.take(subsetSize).toList();

        levelPattern = beatPattern.map((beatIdx) {
          return activeSubset[beatIdx % activeSubset.length].id;
        }).toList();

        final currentPatternStr = levelPattern.join(',');
        final isDuplicate = generatedLevels.any(
          (lvl) => lvl.join(',') == currentPatternStr,
        );

        if (!isDuplicate) {
          isUnique = true;
        }
        attempts++;
      }

      generatedLevels.add(levelPattern ?? List.filled(8, null));
    }

    emit(state.copyWith(levels: generatedLevels));
  }

  void _onLevelChanged(
    LevelChanged event,
    Emitter<CreateWizardState> emit,
  ) {
    emit(state.copyWith(
      currentLevel: event.level,
      selectedSlot: null,
    ));
  }

  void _onSlotSelected(
    SlotSelected event,
    Emitter<CreateWizardState> emit,
  ) {
    emit(state.copyWith(selectedSlot: event.slotIndex));
  }

  void _onImageSelectedForSlot(
    ImageSelectedForSlot event,
    Emitter<CreateWizardState> emit,
  ) {
    if (state.selectedSlot == null) return;

    final newLevels = state.levels.map((level) => List<String?>.from(level)).toList();
    if (newLevels.length <= state.currentLevel) {
      while (newLevels.length <= state.currentLevel) {
        newLevels.add(List.filled(8, null));
      }
    }

    newLevels[state.currentLevel][state.selectedSlot!] = event.imageId;
    emit(state.copyWith(
      levels: newLevels,
      selectedSlot: null,
    ));
  }

  void _onAutoFillLevel(
    AutoFillLevel event,
    Emitter<CreateWizardState> emit,
  ) {
    final newLevels = state.levels.map((level) => List<String?>.from(level)).toList();
    if (newLevels.length <= state.currentLevel) {
      while (newLevels.length <= state.currentLevel) {
        newLevels.add(List.filled(8, null));
      }
    }

    final shuffled = List<UploadedImage>.from(state.images)..shuffle(_random);
    const patternIndices = [0, 1, 2, 0, 2, 1, 0, 1];
    final filled = patternIndices
        .map((i) => shuffled[i % shuffled.length].id)
        .toList();

    newLevels[state.currentLevel] = filled;
    emit(state.copyWith(levels: newLevels));
  }

  void _onClearLevel(
    ClearLevel event,
    Emitter<CreateWizardState> emit,
  ) {
    final newLevels = state.levels.map((level) => List<String?>.from(level)).toList();
    if (newLevels.length <= state.currentLevel) {
      while (newLevels.length <= state.currentLevel) {
        newLevels.add(List.filled(8, null));
      }
    }

    newLevels[state.currentLevel] = List.filled(8, null);
    emit(state.copyWith(levels: newLevels));
  }

  void _onTopicNameUpdated(
    TopicNameUpdated event,
    Emitter<CreateWizardState> emit,
  ) {
    emit(state.copyWith(topicName: event.topicName));
  }

  Future<void> _onFinishCreation(
    FinishCreation event,
    Emitter<CreateWizardState> emit,
  ) async {
    if (!state.canFinish || state.images.isEmpty) return;

    setLoading(true);
    try {
      final processedImages = await Future.wait(
        state.images.map((img) async {
          final compressedBase64 = await _storageService.compressImage(img.bytes);
          return {
            'id': img.id,
            'name': img.name,
            'base64': compressedBase64,
          };
        }),
      );

      final safeLevels = state.levels.map((lvl) {
        return lvl.map((id) => id ?? state.images[0].id).toList();
      }).toList();

      final rounds = safeLevels.asMap().entries.map((entry) {
        final levelIndex = entry.key;
        final levelIds = entry.value;
        return Round(
          id: levelIndex + 1,
          items: levelIds.map((imgId) {
            final imgData = processedImages.firstWhere(
              (p) => p['id'] == imgId,
              orElse: () => processedImages[0],
            );
            return ChallengeItem(
              word: imgData['name'] as String,
              emoji: '📷',
              image: imgData['base64'] as String,
            );
          }).toList(),
        );
      }).toList();

      final challenge = Challenge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: state.topicName.trim(),
        icon: '📷',
        rounds: rounds,
        isCustom: true,
      );

      await _databaseService.saveChallenge(challenge);
      emit(state.copyWith(
        createdChallenge: challenge,
        isLoading: false,
      ));
    } catch (e) {
      setError(e.toString());
    }
  }

  void _onCancelCreation(
    CancelCreation event,
    Emitter<CreateWizardState> emit,
  ) {
    emit(const CreateWizardState());
  }
}
