import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  Product({
    required this.id,
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
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.nutriScore,
    this.novaGroup,
    this.ecoScore,
    this.quantity,
    this.countries,
    this.labels,
    this.packaging,
  });

  final String id;
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
  final List<NutrientEntry> extraNutrients;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? nutriScore;
  final int? novaGroup;
  final String? ecoScore;
  final String? quantity;
  final String? countries;
  final String? labels;
  final String? packaging;

  Product copyWith({
    String? name,
    String? brand,
    String? barcode,
    String? qrCodeValue,
    String? category,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    String? ingredients,
    String? allergens,
    List<NutrientEntry>? extraNutrients,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? nutriScore,
    int? novaGroup,
    String? ecoScore,
    String? quantity,
    String? countries,
    String? labels,
    String? packaging,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      qrCodeValue: qrCodeValue ?? this.qrCodeValue,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      extraNutrients: extraNutrients ?? this.extraNutrients,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      nutriScore: nutriScore ?? this.nutriScore,
      novaGroup: novaGroup ?? this.novaGroup,
      ecoScore: ecoScore ?? this.ecoScore,
      quantity: quantity ?? this.quantity,
      countries: countries ?? this.countries,
      labels: labels ?? this.labels,
      packaging: packaging ?? this.packaging,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'barcode': barcode,
      'qrCodeValue': qrCodeValue,
      'category': category,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'ingredients': ingredients,
      'allergens': allergens,
      'extraNutrients': extraNutrients.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'nutriScore': nutriScore,
      'novaGroup': novaGroup,
      'ecoScore': ecoScore,
      'quantity': quantity,
      'countries': countries,
      'labels': labels,
      'packaging': packaging,
    };
  }

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtTs = data['createdAt'] as Timestamp?;
    final updatedAtTs = data['updatedAt'] as Timestamp?;

    final extras = (data['extraNutrients'] as List<dynamic>?)
            ?.map((e) => NutrientEntry.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList() ??
        <NutrientEntry>[];

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      barcode: data['barcode'] as String?,
      qrCodeValue: data['qrCodeValue'] as String?,
      category: data['category'] as String? ?? '',
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      proteins: (data['proteins'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
      fats: (data['fats'] as num?)?.toDouble() ?? 0,
      ingredients: data['ingredients'] as String? ?? '',
      allergens: data['allergens'] as String? ?? '',
      extraNutrients: extras,
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAtTs?.toDate() ?? DateTime.now(),
      updatedAt: updatedAtTs?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      nutriScore: data['nutriScore'] as String?,
      novaGroup: (data['novaGroup'] as num?)?.toInt(),
      ecoScore: data['ecoScore'] as String?,
      quantity: data['quantity'] as String?,
      countries: data['countries'] as String?,
      labels: data['labels'] as String?,
      packaging: data['packaging'] as String?,
    );
  }
}

class NutrientEntry {
  NutrientEntry({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
      'unit': unit,
    };
  }

  factory NutrientEntry.fromMap(Map<String, dynamic> map) {
    return NutrientEntry(
      label: map['label'] as String? ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'g',
    );
  }
}

