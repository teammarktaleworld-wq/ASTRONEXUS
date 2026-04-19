import "dart:io";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:astro_tale/core/theme/app_gradients.dart";

class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String email;
  final String phone;
  final String zodiacSign;
  final String userAvatar;
  final String localAvatarPath;
  final VoidCallback onAvatarTap;
  final bool isUploading;
  final String choosePhotoLabel;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.email,
    required this.phone,
    required this.zodiacSign,
    required this.userAvatar,
    this.localAvatarPath = "",
    required this.onAvatarTap,
    required this.choosePhotoLabel,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final previewProvider = localAvatarPath.isNotEmpty
        ? FileImage(File(localAvatarPath)) as ImageProvider<Object>
        : (userAvatar.trim().isNotEmpty ? NetworkImage(userAvatar) : null);
    final titleColor = Colors.white;
    final mutedColor = Colors.white70;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              InkWell(
                borderRadius: BorderRadius.circular(52),
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: previewProvider,
                  child: previewProvider == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isUploading)
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAvatarTap,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(choosePhotoLabel),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
              foregroundColor: titleColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          if (userName.isNotEmpty)
            Text(
              userName,
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (userName.isEmpty)
            Text(
              "Guest",
              style: GoogleFonts.dmSans(
                color: mutedColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                email,
                style: GoogleFonts.dmSans(color: mutedColor, fontSize: 14),
              ),
            ),
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                phone,
                style: GoogleFonts.dmSans(color: mutedColor, fontSize: 14),
              ),
            ),
          if (zodiacSign.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _infoChip(
                "Rashi: ${zodiacSign.toUpperCase()}",
                theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                theme.brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.black12,
                titleColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(
    String text,
    Color bgColor,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
