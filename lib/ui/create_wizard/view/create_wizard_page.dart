import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

import '../bloc/create_wizard_bloc.dart';
import '../bloc/create_wizard_event.dart';
import '../bloc/create_wizard_state.dart';

class CreateWizardPage extends StatefulWidget {
  final Function()? onCancel;
  final Function()? onFinish;

  const CreateWizardPage({super.key, this.onCancel, this.onFinish});

  @override
  State<CreateWizardPage> createState() => _CreateWizardPageState();
}

class _CreateWizardPageState extends State<CreateWizardPage> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, TextEditingController> _imageNameControllers = {};

  TextEditingController _getImageNameController(UploadedImage img) {
    return _imageNameControllers.putIfAbsent(
      img.id,
      () => TextEditingController(text: img.name),
    );
  }

  void _syncAndCleanupImageNameControllers(List<UploadedImage> images) {
    final currentIds = images.map((e) => e.id).toSet();

    // Dispose controllers for images that were removed.
    final removedIds = _imageNameControllers.keys
        .where((id) => !currentIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _imageNameControllers.remove(id)?.dispose();
    }
  }

  void _removeImageNameController(String imageId) {
    _imageNameControllers.remove(imageId)?.dispose();
  }

  @override
  void dispose() {
    for (final c in _imageNameControllers.values) {
      c.dispose();
    }
    _imageNameControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreateWizardBloc()..add(const CreateWizardInitialized()),
      child: BlocListener<CreateWizardBloc, CreateWizardState>(
        listener: (context, state) {
          if (state.createdChallenge != null) {
            if (widget.onFinish != null) {
              widget.onFinish!();
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: BlocBuilder<CreateWizardBloc, CreateWizardState>(
          builder: (context, state) {
            if (state.step == 'UPLOAD') {
              return _buildUploadStep(context, state);
            } else if (state.step == 'MODE') {
              return _buildModeStep(context, state);
            } else if (state.step == 'MANUAL') {
              return _buildManualStep(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildUploadStep(BuildContext context, CreateWizardState state) {
    // Keep TextEditingControllers stable to avoid cursor/IME glitches.
    _syncAndCleanupImageNameControllers(state.images);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                    ).createShader(bounds),
                    child: const Text(
                      'UPLOAD PHOTOS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Anton',
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _pickImages(context),
                    child: Container(
                      width: double.infinity,
                      height: 128,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade900.withOpacity(0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+',
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SELECT PHOTOS (2-4)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 4,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...state.images.map((img) {
                    return Container(
                      key: ValueKey('image_${img.id}'),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: img.name.trim().isEmpty
                              ? Colors.red.shade500.withOpacity(0.5)
                              : Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              img.bytes,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  img.name.trim().isEmpty
                                      ? 'NAME REQUIRED'
                                      : 'WORD NAME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: img.name.trim().isEmpty
                                        ? Colors.red.shade400
                                        : Colors.grey.shade500,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                TextField(
                                  key: ValueKey('name_${img.id}'),
                                  controller: _getImageNameController(img),
                                  onChanged: (value) {
                                    context.read<CreateWizardBloc>().add(
                                      ImageNameUpdated(
                                        imageId: img.id,
                                        name: value,
                                      ),
                                    );
                                  },
                                  maxLength: 10,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Anton',
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'ENTER NAME',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.yellow.shade400,
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _removeImageNameController(img.id);
                              context.read<CreateWizardBloc>().add(
                                ImageRemoved(img.id),
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red.shade500.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.shade500.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Column(
                    spacing: 8,
                    children: [
                      if (RemoteConfigService.instance.configAdsDataByScreen(
                            "CreateWizardPageUpload",
                          ) !=
                          null)
                        RemoteConfigService.instance.configAdsByScreen(
                          "CreateWizardPageUpload",
                        )!,
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed:
                                    widget.onCancel ??
                                    () => Navigator.of(context).pop(),
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!state.canProceedFromUpload &&
                                      state.images.isNotEmpty)
                                    Text(
                                      'NAME ALL IMAGES TO PROCEED',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    onPressed: state.canProceedFromUpload
                                        ? () {
                                            context
                                                .read<CreateWizardBloc>()
                                                .add(const StepChanged('MODE'));
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          state.canProceedFromUpload
                                          ? Colors.yellow.shade400
                                          : Colors.grey.shade800,
                                      foregroundColor:
                                          state.canProceedFromUpload
                                          ? Colors.black
                                          : Colors.grey.shade600,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text(
                                      'NEXT STEP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⏳', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text(
                      'SAVING DECK...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeStep(BuildContext context, CreateWizardState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'HOW TO ARRANGE?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  context.read<CreateWizardBloc>().add(
                    const ModeSelected(true),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🎲', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      const Text(
                        'AUTO RANDOM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'INSTANT FUN • SMART MIX',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade200,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '- OR -',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade600,
                  letterSpacing: 4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context.read<CreateWizardBloc>().add(
                    const StepChanged('MANUAL'),
                  );
                  context.read<CreateWizardBloc>().add(
                    const ModeSelected(false),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade700, width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text('🖐️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'MANUAL SORT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.grey.shade300,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CUSTOMIZE BEATS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (RemoteConfigService.instance.configAdsDataByScreen(
                    "CreateWizardPageMode",
                  ) !=
                  null)
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: RemoteConfigService.instance.configAdsByScreen(
                    "CreateWizardPageMode",
                  )!,
                )
              else
                const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  context.read<CreateWizardBloc>().add(
                    const StepChanged('UPLOAD'),
                  );
                },
                child: Text(
                  'BACK TO UPLOAD',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontSize: 10,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualStep(BuildContext context, CreateWizardState state) {
    final currentLevelData = state.levels.length > state.currentLevel
        ? state.levels[state.currentLevel]
        : List<String?>.filled(8, null);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHALLENGE TOPIC NAME (REQUIRED)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            context.read<CreateWizardBloc>().add(
                              TopicNameUpdated(value),
                            );
                          },
                          maxLength: 20,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Anton',
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. My Funny Mix',
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.yellow.shade400,
                              ),
                            ),
                            counterText: '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEVEL ${state.currentLevel + 1}/5',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.yellow.shade400,
                          letterSpacing: 1,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.read<CreateWizardBloc>().add(
                                const ClearLevel(),
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red.shade500.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.shade500.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.read<CreateWizardBloc>().add(
                                const AutoFillLevel(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade700),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '⚡',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AUTO FILL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade400,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final imgId = currentLevelData[index];
                      final img = imgId != null
                          ? state.images.firstWhere(
                              (i) => i.id == imgId,
                              orElse: () => state.images[0],
                            )
                          : null;
                      final isSelected = state.selectedSlot == index;

                      return GestureDetector(
                        onTap: () {
                          context.read<CreateWizardBloc>().add(
                            SlotSelected(index),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.yellow.shade400
                                  : Colors.grey.shade800,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.shade400.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          transform: Matrix4.identity()
                            ..scale(isSelected ? 1.05 : 1.0),
                          child: img != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          img.bytes,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        child: Text(
                                          img.name,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Inter',
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey.shade700,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: state.selectedSlot != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: state.selectedSlot != null
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'SELECT IMAGE FOR BEAT ${state.selectedSlot! + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<CreateWizardBloc>().add(
                                          const SlotSelected(-1),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: state.images.map((img) {
                                      return GestureDetector(
                                        onTap: () {
                                          context.read<CreateWizardBloc>().add(
                                            ImageSelectedForSlot(img.id),
                                          );
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Stack(
                                              children: [
                                                Image.memory(
                                                  img.bytes,
                                                  fit: BoxFit.cover,
                                                  width: 80,
                                                  height: 80,
                                                ),
                                                Positioned(
                                                  bottom: 4,
                                                  left: 4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      img.name,
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontFamily: 'Inter',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                  if (RemoteConfigService.instance.configAdsDataByScreen(
                        "CreateWizardPageManual",
                      ) !=
                      null)
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                      child: RemoteConfigService.instance.configAdsByScreen(
                        "CreateWizardPageManual",
                      )!,
                    )
                  else
                    const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade800, width: 1),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (state.currentLevel > 0)
                              TextButton(
                                onPressed: () {
                                  context.read<CreateWizardBloc>().add(
                                    LevelChanged(state.currentLevel - 1),
                                  );
                                },
                                child: Text(
                                  '← BACK',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  context.read<CreateWizardBloc>().add(
                                    const CreateWizardInitialized(),
                                  );
                                },
                                child: Text(
                                  'RESTART',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            if (state.currentLevel < 4)
                              ElevatedButton(
                                onPressed: () {
                                  context.read<CreateWizardBloc>().add(
                                    LevelChanged(state.currentLevel + 1),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'NEXT LEVEL →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: state.canFinish
                                    ? () {
                                        _handleShowInter(
                                          onDone: () {
                                            context
                                                .read<CreateWizardBloc>()
                                                .add(const FinishCreation());
                                          },
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: state.canFinish
                                      ? Colors.green.shade500
                                      : Colors.grey.shade800,
                                  foregroundColor: state.canFinish
                                      ? Colors.black
                                      : Colors.grey.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: state.canFinish ? 8 : 0,
                                ),
                                child: const Text(
                                  'FINISH & SAVE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⏳', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text(
                      'SAVING DECK...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final state = context.read<CreateWizardBloc>().state;
    final remainingSlots = 4 - state.images.length;
    if (remainingSlots <= 0) return;

    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);

      if (images.isEmpty) return;

      final imageBytes = <Uint8List>[];
      final imagePaths = <String>[];

      for (final image in images.take(remainingSlots)) {
        final bytes = await image.readAsBytes();
        imageBytes.add(bytes);
        imagePaths.add(image.path);
      }

      if (context.mounted) {
        context.read<CreateWizardBloc>().add(
          ImagesSelected(imageBytes: imageBytes, imagePaths: imagePaths),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleShowInter({required void Function() onDone}) async {
    final origin_onInterstitialClosed = InterstitialAds.onInterstitialClosed;
    final origin_onInterstitialFailed = InterstitialAds.onInterstitialFailed;
    final origin_onInterstitialShown = InterstitialAds.onInterstitialShown;
    InterstitialAds.onInterstitialClosed = () {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      onDone();
    };
    InterstitialAds.onInterstitialFailed = (_) {
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      onDone();
    };
    InterstitialAds.onInterstitialShown = () {
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      // todo show native full screen ==> check policy
    };
    if (!await InterstitialAdsController.instance.showInterstitialAd(
      screenClass: 'CreateWizardPage',
      callerFunction: 'CreateWizardPage._handleShowInter',
    )) {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      onDone();
    }
  }
}
