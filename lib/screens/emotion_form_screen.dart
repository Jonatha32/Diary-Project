import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/emotion_entry.dart';
import '../utils/storage_manager.dart';

class EmotionFormScreen extends StatefulWidget {
  final EmotionEntry? emotion;

  const EmotionFormScreen({super.key, this.emotion});

  @override
  State<EmotionFormScreen> createState() => _EmotionFormScreenState();
}

class _EmotionFormScreenState extends State<EmotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedEmotion = 'Feliz';
  bool _isLoading = false;
  final _uuid = const Uuid();
  
  // Para imagen
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  // Mapeo de emociones a valores numéricos
  final Map<String, int> _emotionValues = {
    'Feliz': 5,
    'Tranquilo': 4,
    'Neutral': 3,
    'Ansioso': 2,
    'Triste': 1,
    'Enojado': 1,
  };

  final List<String> _emotions = [
    'Feliz',
    'Triste',
    'Enojado',
    'Ansioso',
    'Tranquilo',
    'Neutral'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.emotion != null) {
      _descriptionController.text = widget.emotion!.description;
      _selectedEmotion = widget.emotion!.emotion;
    }
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.storage.request();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<String?> _saveImageLocally() async {
    if (_selectedImage == null) return null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await _selectedImage!.copy('${imagesDir.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar imagen: $e')),
      );
      return null;
    }
  }

  Future<void> _saveEmotion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar imagen localmente si existe
      final String? imagePath = await _saveImageLocally();
      
      // Cargar emociones existentes
      final emotions = await StorageManager.loadEmotions();

      // Crear nueva emoción
      final newEmotion = EmotionEntry(
        id: widget.emotion?.id ?? _uuid.v4(),
        date: DateTime.now(),
        emotion: _selectedEmotion,
        description: _descriptionController.text.trim(),
        imageUrl: imagePath ?? widget.emotion?.imageUrl,
        emotionValue: _emotionValues[_selectedEmotion] ?? 3,
      );

      // Añadir o actualizar
      if (widget.emotion != null) {
        final index = emotions.indexWhere((e) => e.id == widget.emotion!.id);
        if (index >= 0) {
          emotions[index] = newEmotion;
        } else {
          emotions.add(newEmotion);
        }
      } else {
        emotions.add(newEmotion);
      }

      // Guardar
      await StorageManager.saveEmotions(emotions);

      // Volver a la pantalla anterior
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.emotion == null ? 'Nueva emoción' : 'Editar emoción'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Cómo te sientes hoy?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmotionSelector(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Describe cómo te sientes',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor describe cómo te sientes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildMediaSection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEmotion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmotionSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _emotions.map((emotion) {
        final isSelected = _selectedEmotion == emotion;
        
        IconData iconData;
        Color color;
        
        switch (emotion.toLowerCase()) {
          case 'feliz':
            iconData = Icons.sentiment_very_satisfied;
            color = Colors.green;
            break;
          case 'triste':
            iconData = Icons.sentiment_very_dissatisfied;
            color = Colors.blue;
            break;
          case 'enojado':
            iconData = Icons.sentiment_very_dissatisfied;
            color = Colors.red;
            break;
          case 'ansioso':
            iconData = Icons.sentiment_dissatisfied;
            color = Colors.orange;
            break;
          case 'tranquilo':
            iconData = Icons.sentiment_satisfied;
            color = Colors.teal;
            break;
          default:
            iconData = Icons.sentiment_neutral;
            color = Colors.grey;
        }
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedEmotion = emotion;
            });
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  iconData,
                  color: isSelected ? color : Colors.grey,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emotion,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Sección de imagen
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            ),
          ],
        ),
        
        if (_selectedImage != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ] else if (widget.emotion?.imageUrl != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(widget.emotion!.imageUrl!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}