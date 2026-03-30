import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../products/data/models/product_model.dart';

/// Client OpenFoodFacts (REST) utilisé côté Flutter.
///
/// Note: `openfoodfacts-python` est une librairie Python, mais l'app Flutter
/// n'exécute pas Python. Ici on appelle directement les endpoints OpenFoodFacts
/// que la librairie utilise en dessous.
class OpenFoodFactsService {
  OpenFoodFactsService({
    http.Client? client,
    String baseProductUrl = 'https://world.openfoodfacts.net/api/v2/product',
    String baseSearchUrl = 'https://world.openfoodfacts.net/api/v2/search',
  })  : _client = client ?? http.Client(),
        _baseProductUrl = baseProductUrl,
        _baseSearchUrl = baseSearchUrl;

  final http.Client _client;
  final String _baseProductUrl;
  final String _baseSearchUrl;

  Future<Product?> getProductByBarcode(String barcode) async {
    final cleaned = barcode.trim();
    if (cleaned.isEmpty) return null;

    final uri = Uri.parse(
      '$_baseProductUrl/${Uri.encodeComponent(cleaned)}',
    ).replace(
      queryParameters: const {
        // On limite les champs pour réduire la taille de la réponse.
        'fields':
            'product_name,brands,categories,image_front_url,image_url,ingredients_text,allergens_tags,nutriments,nutriscore_grade,nova_group,ecoscore_grade,quantity,countries,labels,packaging',
      },
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;

    // `status` = 0 signifie "product not found"
    final status = decoded['status'];
    if (status is int && status == 0) return null;

    final productJson = decoded['product'];
    if (productJson is! Map<String, dynamic>) return null;

    final nutrimentsJson =
        productJson['nutriments'] as Map<String, dynamic>?; // peut être null

    final calories = _readNutri(nutrimentsJson, 'energy-kcal_100g') ?? 0;
    final proteins = _readNutri(nutrimentsJson, 'proteins_100g') ?? 0;
    final carbs =
        _readNutri(nutrimentsJson, 'carbohydrates_100g') ?? 0; // g
    final fats = _readNutri(nutrimentsJson, 'fat_100g') ?? 0;

    final name = (productJson['product_name'] as String?)?.trim() ?? '';
    final brand = (productJson['brands'] as String?)?.trim() ?? '';
    final category = (productJson['categories'] as String?)?.trim() ?? '';

    final ingredients =
        (productJson['ingredients_text'] as String?)?.trim() ?? '';

    final allergensTags = productJson['allergens_tags'];
    final allergens = allergensTags is List
        ? allergensTags.map((e) => e.toString()).join(', ')
        : (productJson['allergens'] as String?)?.trim() ?? '';

    final imageUrl = (_firstNonEmptyString(productJson['image_front_url']) ??
            _firstNonEmptyString(productJson['image_url']));

    final nutriScore =
        (productJson['nutriscore_grade'] as String?)?.trim().toUpperCase();
    final novaGroup = (productJson['nova_group'] as num?)?.toInt();
    final ecoScore =
        (productJson['ecoscore_grade'] as String?)?.trim().toUpperCase();
    final quantity = (productJson['quantity'] as String?)?.trim();
    final countries = (productJson['countries'] as String?)?.trim();
    final labels = (productJson['labels'] as String?)?.trim();
    final packaging = (productJson['packaging'] as String?)?.trim();

    final extraNutrients = _buildExtraNutrients(
      nutrimentsJson,
      caloriesKey: 'energy-kcal_100g',
      proteinsKey: 'proteins_100g',
      carbsKey: 'carbohydrates_100g',
      fatsKey: 'fat_100g',
    );

    return Product(
      id: cleaned,
      name: name.isEmpty ? 'Produit inconnu' : name,
      brand: brand.isEmpty ? '—' : brand,
      barcode: cleaned,
      qrCodeValue: null,
      category: category.isEmpty ? '—' : category,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      ingredients: ingredients,
      allergens: allergens,
      extraNutrients: extraNutrients,
      imageUrl: imageUrl,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'openfoodfacts',
      nutriScore: nutriScore,
      novaGroup: novaGroup,
      ecoScore: ecoScore,
      quantity: quantity,
      countries: countries,
      labels: labels,
      packaging: packaging,
    );
  }

  Future<List<Product>> searchProductsByQuery(
    String query, {
    int limit = 10,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return <Product>[];

    final uri = Uri.parse(_baseSearchUrl).replace(
      queryParameters: {
        'search_terms': q,
        'fields':
            'code,product_name,brands,categories,image_front_url,image_url,ingredients_text,allergens_tags,nutriments,nutriscore_grade,nova_group,ecoscore_grade,quantity,countries,labels,packaging',
        'page_size': limit.toString(),
      },
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return <Product>[];

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return <Product>[];

    final productsJson = decoded['products'];
    if (productsJson is! List) return <Product>[];

    final results = <Product>[];
    for (final item in productsJson) {
      if (item is! Map<String, dynamic>) continue;

      final code = (item['code'] as String?)?.trim() ?? '';
      if (code.isEmpty) continue;

      final nutrimentsJson =
          item['nutriments'] as Map<String, dynamic>?; // peut être null

      final calories = _readNutri(nutrimentsJson, 'energy-kcal_100g') ?? 0;
      final proteins = _readNutri(nutrimentsJson, 'proteins_100g') ?? 0;
      final carbs =
          _readNutri(nutrimentsJson, 'carbohydrates_100g') ?? 0;
      final fats = _readNutri(nutrimentsJson, 'fat_100g') ?? 0;

      final name = (item['product_name'] as String?)?.trim() ?? '';
      final brand = (item['brands'] as String?)?.trim() ?? '';
      final category = (item['categories'] as String?)?.trim() ?? '';

      final ingredients =
          (item['ingredients_text'] as String?)?.trim() ?? '';

      final allergensTags = item['allergens_tags'];
      final allergens = allergensTags is List
          ? allergensTags.map((e) => e.toString()).join(', ')
          : (item['allergens'] as String?)?.trim() ?? '';

      final imageUrl = (_firstNonEmptyString(item['image_front_url']) ??
          _firstNonEmptyString(item['image_url']));

      final nutriScore =
          (item['nutriscore_grade'] as String?)?.trim().toUpperCase();
      final novaGroup = (item['nova_group'] as num?)?.toInt();
      final ecoScore =
          (item['ecoscore_grade'] as String?)?.trim().toUpperCase();
      final quantity = (item['quantity'] as String?)?.trim();
      final countries = (item['countries'] as String?)?.trim();
      final labels = (item['labels'] as String?)?.trim();
      final packaging = (item['packaging'] as String?)?.trim();

      final extraNutrients = _buildExtraNutrients(
        nutrimentsJson,
        caloriesKey: 'energy-kcal_100g',
        proteinsKey: 'proteins_100g',
        carbsKey: 'carbohydrates_100g',
        fatsKey: 'fat_100g',
      );

      results.add(
        Product(
          id: code,
          name: name.isEmpty ? 'Produit inconnu' : name,
          brand: brand.isEmpty ? '—' : brand,
          barcode: code,
          qrCodeValue: null,
          category: category.isEmpty ? '—' : category,
          calories: calories,
          proteins: proteins,
          carbs: carbs,
          fats: fats,
          ingredients: ingredients,
          allergens: allergens,
          extraNutrients: extraNutrients,
          imageUrl: imageUrl,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'openfoodfacts',
          nutriScore: nutriScore,
          novaGroup: novaGroup,
          ecoScore: ecoScore,
          quantity: quantity,
          countries: countries,
          labels: labels,
          packaging: packaging,
        ),
      );
    }

    return results;
  }

  double? _readNutri(Map<String, dynamic>? nutriments, String key) {
    if (nutriments == null) return null;
    final raw = nutriments[key];
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString().trim());
  }

  String? _firstNonEmptyString(dynamic value) {
    if (value is String) {
      final s = value.trim();
      return s.isEmpty ? null : s;
    }
    return null;
  }

  List<NutrientEntry> _buildExtraNutrients(
    Map<String, dynamic>? nutriments, {
    required String caloriesKey,
    required String proteinsKey,
    required String carbsKey,
    required String fatsKey,
  }) {
    if (nutriments == null) return <NutrientEntry>[];

    // Liste prioritaire pour un tableau clair.
    const priorityKeys = <String>[
      'sugars_100g',
      'salt_100g',
      'sodium_100g',
      'fiber_100g',
      'fibre_100g',
      'saturated-fat_100g',
      'monounsaturated-fat_100g',
      'polyunsaturated-fat_100g',
      'cholesterol_100g',
      'starch_100g',
      'trans-fat_100g',
    ];

    final entries = <NutrientEntry>[];
    for (final key in priorityKeys) {
      if (!nutriments.containsKey(key)) continue;
      final value = _readNutri(nutriments, key);
      if (value == null) continue;
      if (value == 0) continue;
      entries.add(
        NutrientEntry(
          label: _nutriLabel(key),
          value: value,
          unit: _nutriUnit(key),
        ),
      );
    }

    // Si rien n'a été trouvé, on ajoute quelques nutriments `_100g` de façon générique.
    if (entries.isEmpty) {
      const fallbackMax = 10;
      final ignored = {caloriesKey, proteinsKey, carbsKey, fatsKey};
      final candidates = nutriments.entries
          .where((e) => e.key.endsWith('_100g') && !ignored.contains(e.key))
          .take(30);
      for (final e in candidates) {
        final value = _readNutri(nutriments, e.key);
        if (value == null || value == 0) continue;
        entries.add(
          NutrientEntry(
            label: _nutriLabel(e.key),
            value: value,
            unit: _nutriUnit(e.key),
          ),
        );
        if (entries.length >= fallbackMax) break;
      }
    }

    return entries;
  }

  String _nutriLabel(String key) {
    switch (key) {
      case 'energy-kcal_100g':
        return 'Energie';
      case 'proteins_100g':
        return 'Protéines';
      case 'carbohydrates_100g':
        return 'Glucides';
      case 'fat_100g':
        return 'Lipides';
      case 'sugars_100g':
        return 'Sucres';
      case 'salt_100g':
        return 'Sel';
      case 'sodium_100g':
        return 'Sodium';
      case 'fiber_100g':
      case 'fibre_100g':
        return 'Fibres';
      case 'saturated-fat_100g':
        return 'Lipides saturés';
      case 'monounsaturated-fat_100g':
        return 'Lipides mono-insaturés';
      case 'polyunsaturated-fat_100g':
        return 'Lipides poly-insaturés';
      case 'cholesterol_100g':
        return 'Cholestérol';
      case 'starch_100g':
        return 'Amidon';
      case 'trans-fat_100g':
        return 'Trans';
      default:
        // Exemple: "sugars_100g" => "sugars"
        final base = key.replaceAll('_100g', '');
        final pretty = base.replaceAll('-', ' ').replaceAll('_', ' ').trim();
        if (pretty.isEmpty) return pretty;
        return pretty[0].toUpperCase() + pretty.substring(1);
    }
  }

  String _nutriUnit(String key) {
    // OpenFoodFacts ne fournit pas toujours explicitement l'unité dans les champs,
    // donc on l'infère par convention pour les clés principales.
    switch (key) {
      case 'energy-kcal_100g':
        return 'kcal';
      case 'proteins_100g':
      case 'carbohydrates_100g':
      case 'fat_100g':
      case 'sugars_100g':
      case 'salt_100g':
      case 'fiber_100g':
      case 'fibre_100g':
      case 'saturated-fat_100g':
      case 'monounsaturated-fat_100g':
      case 'polyunsaturated-fat_100g':
      case 'starch_100g':
      case 'trans-fat_100g':
        return 'g';
      case 'sodium_100g':
      case 'cholesterol_100g':
        return 'mg';
      default:
        return 'g';
    }
  }
}

