import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Avatar Upload Service
/// Handles image picking and uploading to Cloudinary
class AvatarUploadService {
  late final CloudinaryPublic _cloudinary;
  final ImagePicker _imagePicker;

  AvatarUploadService({
    CloudinaryPublic? cloudinary,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker() {
    if (cloudinary != null) {
      _cloudinary = cloudinary;
    } else {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      debugPrint('Initializing Cloudinary with cloud name: $cloudName');

      if (cloudName == null || cloudName.isEmpty) {
        throw Exception('CLOUDINARY_CLOUD_NAME not found in .env file');
      }

      _cloudinary = CloudinaryPublic(
        cloudName,
        'avatars',
        cache: false,
      );
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error taking photo from camera: $e');
      throw Exception('Failed to take photo from camera: $e');
    }
  }

  /// Upload avatar to Cloudinary
  /// Returns the download URL
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      debugPrint('Starting upload to Cloudinary...');
      debugPrint('Cloud name: ${dotenv.env['CLOUDINARY_CLOUD_NAME']}');
      debugPrint('Upload preset: avatars');
      debugPrint('File path: ${imageFile.path}');

      // Upload to Cloudinary with transformation
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'avatars/users/$userId',
          publicId: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      debugPrint('Upload successful! URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e, stackTrace) {
      debugPrint('Error uploading avatar to Cloudinary: $e');
      debugPrint('Stack trace: $stackTrace');

      // Provide helpful error messages
      if (e.toString().contains('400')) {
        throw Exception(
          'Failed to upload avatar: Bad Request (400)\n'
          'Possible causes:\n'
          '1. Upload preset "avatars" does not exist in Cloudinary\n'
          '2. Upload preset is set to "Signed" instead of "Unsigned"\n'
          '3. Cloud name is incorrect\n\n'
          'Please verify:\n'
          '- Go to Cloudinary Console → Settings → Upload\n'
          '- Create an "Unsigned" upload preset named "avatars"\n'
          '- Or use an existing unsigned preset'
        );
      }

      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Delete old avatar from Cloudinary
  /// Note: Cloudinary free tier doesn't support deletion via API
  /// You can delete images manually from Cloudinary dashboard
  /// Or upgrade to a paid plan to enable deletion API
  Future<void> deleteOldAvatar(String avatarUrl) async {
    try {
      if (avatarUrl.isEmpty) return;

      // Extract public ID from Cloudinary URL
      final uri = Uri.parse(avatarUrl);
      if (!uri.host.contains('cloudinary')) return;

      debugPrint('Old avatar URL: $avatarUrl');
      debugPrint('Note: Cloudinary free tier does not support deletion via API');
      debugPrint('Please delete old images manually from Cloudinary dashboard if needed');

      // For paid plans, you would use Cloudinary Admin API here
      // This requires the API secret and is not recommended for client-side code
    } catch (e) {
      debugPrint('Error deleting old avatar: $e');
      // Don't throw error, just log it
    }
  }

  /// Get optimized avatar URL with transformations
  /// This allows you to request different sizes/formats without re-uploading
  String getOptimizedAvatarUrl(
    String originalUrl, {
    int width = 200,
    int height = 200,
    String format = 'auto',
    String quality = 'auto',
  }) {
    try {
      if (!originalUrl.contains('cloudinary')) return originalUrl;

      // Extract the base URL and public ID
      final uri = Uri.parse(originalUrl);
      final parts = uri.path.split('/upload/');

      if (parts.length != 2) return originalUrl;

      // Build transformation string
      final transformation = 'w_$width,h_$height,c_fill,f_$format,q_$quality';

      // Reconstruct URL with transformation
      final optimizedUrl = '${parts[0]}/upload/$transformation/${parts[1]}';

      return '${uri.scheme}://${uri.host}$optimizedUrl';
    } catch (e) {
      debugPrint('Error creating optimized URL: $e');
      return originalUrl;
    }
  }
}
