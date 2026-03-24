import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductStorageService {
  ProductStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProductImage({
    required String productId,
    required XFile imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final extension = _extensionFromPath(imageFile.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final ref = _storage.ref().child('products/$productId/$fileName');
    final metadata = SettableMetadata(
      contentType: imageFile.mimeType ?? 'image/jpeg',
    );
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  String _extensionFromPath(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1 || index == path.length - 1) return '';
    return path.substring(index);
  }
}
