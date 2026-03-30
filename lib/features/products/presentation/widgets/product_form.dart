import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormData {
  ProductFormData({
    required this.name,
    required this.brand,
    required this.barcode,
    required this.qrCodeValue,
    required this.category,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.allergens,
    required this.extraNutrients,
    required this.imageUrl,
    required this.imageFile,
    required this.removeImage,
    required this.isActive,
  });

  final String name;
  final String brand;
  final String? barcode;
  final String? qrCodeValue;
  final String category;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String ingredients;
  final String allergens;
  final List<ExtraNutrientInput> extraNutrients;
  final String? imageUrl;
  final XFile? imageFile;
  final bool removeImage;
  final bool isActive;
}

class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    required this.onSubmit,
    this.initialData,
    this.submitLabel = 'Enregistrer',
    this.showQrCodeField = false,
  });

  final ProductFormData? initialData;
  final String submitLabel;
  final bool showQrCodeField;
  final ValueChanged<ProductFormData> onSubmit;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _qrController;
  late final TextEditingController _categoryController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _allergensController;
  bool _isActive = true;
  XFile? _pickedImage;
  Uint8List? _pickedBytes;
  bool _removeImage = false;
  final List<_NutrientRow> _extraRows = [];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.name ?? '');
    _brandController = TextEditingController(text: data?.brand ?? '');
    _barcodeController = TextEditingController(text: data?.barcode ?? '');
    _qrController = TextEditingController(text: data?.qrCodeValue ?? '');
    _categoryController = TextEditingController(text: data?.category ?? '');
    _caloriesController =
        TextEditingController(text: data?.calories.toString() ?? '0');
    _proteinsController =
        TextEditingController(text: data?.proteins.toString() ?? '0');
    _carbsController =
        TextEditingController(text: data?.carbs.toString() ?? '0');
    _fatsController =
        TextEditingController(text: data?.fats.toString() ?? '0');
    _ingredientsController =
        TextEditingController(text: data?.ingredients ?? '');
    _allergensController =
        TextEditingController(text: data?.allergens ?? '');
    _isActive = data?.isActive ?? true;
    _removeImage = false;
    final extras = data?.extraNutrients ?? [];
    for (final item in extras) {
      _extraRows.add(
        _NutrientRow(
          label: TextEditingController(text: item.label),
          value: TextEditingController(text: item.value),
          unit: TextEditingController(text: item.unit),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _qrController.dispose();
    _categoryController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _ingredientsController.dispose();
    _allergensController.dispose();
    for (final row in _extraRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _textField(_nameController, 'Nom', required: true),
          _textField(_brandController, 'Marque', required: true),
          _textField(_barcodeController, 'Code-barres'),
          if (widget.showQrCodeField)
            _textField(_qrController, 'QR interne'),
          _textField(_categoryController, 'Categorie', required: true),
          _numberField(_caloriesController, 'Calories', required: true),
          _numberField(_proteinsController, 'Proteines', required: true),
          _numberField(_carbsController, 'Glucides', required: true),
          _numberField(_fatsController, 'Lipides', required: true),
          _textField(_ingredientsController, 'Ingredients'),
          _textField(_allergensController, 'Allergenes'),
          _extraNutrientsSection(),
          _buildImagePicker(),
          SwitchListTile(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            title: const Text('Actif'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label requis';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label requis';
          }
          if (value != null && value.trim().isNotEmpty) {
            final parsed = double.tryParse(value);
            if (parsed == null) return '$label invalide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    final existingUrl = widget.initialData?.imageUrl;
    final hasExisting = !_removeImage &&
        existingUrl != null &&
        existingUrl.trim().isNotEmpty;
    final hasPicked = _pickedBytes != null;

    Widget preview;
    if (hasPicked) {
      preview = Image.memory(
        _pickedBytes!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      );
    } else if (hasExisting) {
      preview = Image.network(
        existingUrl!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      );
    } else {
      preview = Container(
        width: double.infinity,
        height: 160,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image, size: 48),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image du produit',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: preview,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _pickImageFromFiles,
                icon: const Icon(Icons.photo_library),
                label: const Text('Importer (fichier)'),
              ),
              if (hasExisting || hasPicked)
                TextButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final path = picked.path;
    XFile image;
    Uint8List bytes;
    if (path == null || path.isEmpty) {
      if (picked.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fichier non supporte.')),
          );
        }
        return;
      }
      bytes = picked.bytes!;
      image = XFile.fromData(
        bytes,
        name: picked.name,
        mimeType: picked.extension != null
            ? 'image/${picked.extension}'
            : 'image/jpeg',
      );
    } else {
      image = XFile(path);
      bytes = await image.readAsBytes();
    }
    if (!mounted) return;
    setState(() {
      _pickedImage = image;
      _pickedBytes = bytes;
      _removeImage = false;
    });
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _pickedBytes = null;
      _removeImage = true;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final extras = _extraRows
        .map((row) => row.toInput())
        .where((e) => e.label.isNotEmpty)
        .toList();
    final data = ProductFormData(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      qrCodeValue: _qrController.text.trim().isEmpty
          ? null
          : _qrController.text.trim(),
      category: _categoryController.text.trim(),
      calories: double.parse(_caloriesController.text.trim()),
      proteins: double.parse(_proteinsController.text.trim()),
      carbs: double.parse(_carbsController.text.trim()),
      fats: double.parse(_fatsController.text.trim()),
      ingredients: _ingredientsController.text.trim(),
      allergens: _allergensController.text.trim(),
      extraNutrients: extras,
      imageUrl: widget.initialData?.imageUrl,
      imageFile: _pickedImage,
      removeImage: _removeImage,
      isActive: _isActive,
    );
    widget.onSubmit(data);
  }

  Widget _extraNutrientsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nutriments supplementaires',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: _addExtraRow,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          if (_extraRows.isEmpty)
            Text(
              'Aucun nutriment ajoute.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          ..._extraRows.map(_buildExtraRow),
        ],
      ),
    );
  }

  Widget _buildExtraRow(_NutrientRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row.label,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.value,
              decoration: const InputDecoration(labelText: 'Valeur'),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.unit,
              decoration: const InputDecoration(labelText: 'Unite'),
            ),
          ),
          IconButton(
            onPressed: () => _removeExtraRow(row),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  void _addExtraRow() {
    setState(() {
      _extraRows.add(
        _NutrientRow(
          label: TextEditingController(),
          value: TextEditingController(),
          unit: TextEditingController(text: 'g'),
        ),
      );
    });
  }

  void _removeExtraRow(_NutrientRow row) {
    setState(() {
      row.dispose();
      _extraRows.remove(row);
    });
  }
}

class ExtraNutrientInput {
  ExtraNutrientInput({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

class _NutrientRow {
  _NutrientRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  final TextEditingController label;
  final TextEditingController value;
  final TextEditingController unit;

  ExtraNutrientInput toInput() {
    return ExtraNutrientInput(
      label: label.text.trim(),
      value: value.text.trim(),
      unit: unit.text.trim().isEmpty ? 'g' : unit.text.trim(),
    );
  }

  void dispose() {
    label.dispose();
    value.dispose();
    unit.dispose();
  }
}
