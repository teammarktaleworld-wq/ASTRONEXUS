import 'dart:io';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:astro_tale/core/widgets/animated_app_background.dart';
import 'package:astro_tale/core/widgets/themed_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/API/APIservice.dart';
import '../../../../services/api_services/chatbot/profile_services.dart';
import '../Widget/Menu_section.dart';
import '../Widget/Profile_header.dart';
import '../Widget/logOut_button.dart';
import '../Widget/stats_row.dart';

class CosmicProfileScreen extends StatefulWidget {
  const CosmicProfileScreen({super.key});

  @override
  State<CosmicProfileScreen> createState() => _CosmicProfileScreenState();
}

class _CosmicProfileScreenState extends State<CosmicProfileScreen> {
  bool isUploadingImage = false;
  bool isLoadingProfile = true;

  // User info
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String zodiacSign = "";
  String userAvatar = "";
  String localAvatarPath = "";
  // User info

  String _normalizeAvatarUrl(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) {
      return "";
    }
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }
    return value.startsWith("/") ? "$baseurl$value" : "$baseurl/$value";
  }

  @override
  void initState() {
    super.initState();
    _loadCachedUserData();
    _refreshUserData();
  }

  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      userName = prefs.getString("userName") ?? "Guest";
      userEmail = prefs.getString("email") ?? "";
      userPhone = prefs.getString("phone") ?? "";
      zodiacSign = prefs.getString("zodiacSign") ?? "";
      userAvatar = _normalizeAvatarUrl(prefs.getString("userAvatar") ?? "");
      isLoadingProfile = false;
    });
  }

  /// Refresh profile in background without blocking screen open.
  Future<void> _refreshUserData() async {
    try {
      await ProfileService.fetchMyProfile();
      await _loadCachedUserData();
    } catch (e) {
      debugPrint("Profile refresh error: $e");
    }
  }

  /// Pick and upload profile image
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (picked == null || !mounted) {
        return;
      }

      // Keep upload working even if cropper fails on some devices.
      var uploadPath = picked.path;
      try {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: <PlatformUiSettings>[
            AndroidUiSettings(
              toolbarTitle: "Crop profile photo",
              toolbarColor: const Color(0xFF111A34),
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: false,
              initAspectRatio: CropAspectRatioPreset.square,
              cropStyle: CropStyle.circle,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: "Crop profile photo",
              aspectRatioLockEnabled: false,
              resetAspectRatioEnabled: true,
              rotateButtonsHidden: false,
            ),
          ],
        );
        if (cropped == null || !mounted) {
          return;
        }
        uploadPath = cropped.path;
      } catch (cropError) {
        debugPrint("Cropper failed, using original image: $cropError");
      }

      setState(() {
        localAvatarPath = uploadPath;
        isUploadingImage = true;
      });

      final imageUrl = await ProfileService.uploadProfileImage(
        File(uploadPath),
      );
      if (!mounted) {
        return;
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() => userAvatar = _normalizeAvatarUrl(imageUrl));
      }

      await _refreshUserData();
      if (!mounted) {
        return;
      }
      if (userAvatar.isNotEmpty) {
        setState(() => localAvatarPath = "");
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile photo updated")));
    } on PlatformException catch (e) {
      debugPrint("Image permission/picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo permission denied. Please allow and retry."),
          ),
        );
      }
    } catch (e) {
      debugPrint("Image selection/upload failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Could not upload photo. Check internet/login and retry.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  Future<void> _showAvatarActions() async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colors.primary,
                  ),
                  title: Text(l10n.tr("choosePhoto")),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickAndUploadImage();
                  },
                ),
                if (userAvatar.trim().isNotEmpty || localAvatarPath.isNotEmpty)
                  ListTile(
                    leading: Icon(
                      Icons.account_circle_outlined,
                      color: colors.primary,
                    ),
                    title: Text(l10n.tr("viewPhoto")),
                    onTap: () {
                      Navigator.pop(ctx);
                      showDialog<void>(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(
                            child: localAvatarPath.isNotEmpty
                                ? Image.file(
                                    File(localAvatarPath),
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    userAvatar,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ListTile(
                  leading: Icon(
                    Icons.close,
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                  title: Text(l10n.tr("cancel")),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedAppBackground(
        child: SafeArea(
          child: isLoadingProfile
              ? _loadingSkeleton()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ProfileHeaderCard(
                      userName: userName,
                      email: userEmail,
                      phone: userPhone,
                      zodiacSign: zodiacSign,
                      userAvatar: userAvatar,
                      localAvatarPath: localAvatarPath,
                      isUploading: isUploadingImage,
                      onAvatarTap: _showAvatarActions,
                      choosePhotoLabel: l10n.tr("choosePhoto"),
                    ),
                    const SizedBox(height: 20),
                    const StatsRow(),
                    const SizedBox(height: 24),
                    const MenuSection(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 30),
                    const LogoutButton(),
                    const SizedBox(height: 120),
                  ],
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.lightContainerAlt
          : AppColors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        context.l10n.tr("profile"),
        style: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _loadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ThemedShimmerCard(height: 240),
        SizedBox(height: 18),
        ThemedShimmerCard(height: 120),
        SizedBox(height: 18),
        ThemedShimmerCard(height: 340),
      ],
    );
  }
}
