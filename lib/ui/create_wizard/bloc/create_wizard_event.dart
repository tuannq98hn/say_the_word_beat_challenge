import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class CreateWizardEvent extends Equatable {
  const CreateWizardEvent();

  @override
  List<Object> get props => [];
}

class CreateWizardInitialized extends CreateWizardEvent {
  const CreateWizardInitialized();
}

class ImagesSelected extends CreateWizardEvent {
  final List<Uint8List> imageBytes;
  final List<String> imagePaths;

  const ImagesSelected({
    required this.imageBytes,
    required this.imagePaths,
  });

  @override
  List<Object> get props => [imageBytes, imagePaths];
}

class ImageNameUpdated extends CreateWizardEvent {
  final String imageId;
  final String name;

  const ImageNameUpdated({
    required this.imageId,
    required this.name,
  });

  @override
  List<Object> get props => [imageId, name];
}

class ImageRemoved extends CreateWizardEvent {
  final String imageId;

  const ImageRemoved(this.imageId);

  @override
  List<Object> get props => [imageId];
}

class ModeSelected extends CreateWizardEvent {
  final bool isRandom;

  const ModeSelected(this.isRandom);

  @override
  List<Object> get props => [isRandom];
}

class LevelChanged extends CreateWizardEvent {
  final int level;

  const LevelChanged(this.level);

  @override
  List<Object> get props => [level];
}

class SlotSelected extends CreateWizardEvent {
  final int slotIndex;

  const SlotSelected(this.slotIndex);

  @override
  List<Object> get props => [slotIndex];
}

class ImageSelectedForSlot extends CreateWizardEvent {
  final String imageId;

  const ImageSelectedForSlot(this.imageId);

  @override
  List<Object> get props => [imageId];
}

class AutoFillLevel extends CreateWizardEvent {
  const AutoFillLevel();
}

class ClearLevel extends CreateWizardEvent {
  const ClearLevel();
}

class TopicNameUpdated extends CreateWizardEvent {
  final String topicName;

  const TopicNameUpdated(this.topicName);

  @override
  List<Object> get props => [topicName];
}

class FinishCreation extends CreateWizardEvent {
  const FinishCreation();
}

class StepChanged extends CreateWizardEvent {
  final String step;

  const StepChanged(this.step);

  @override
  List<Object> get props => [step];
}

class CancelCreation extends CreateWizardEvent {
  const CancelCreation();
}
