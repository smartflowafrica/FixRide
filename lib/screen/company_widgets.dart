import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/Colors.dart';
import '../utils/fontfameli_model.dart';
import '../utils/Dark_lightmode.dart';
import 'company/company_login.dart';

/// Widget to add "Login as Car Owner" option to the login screen
class CompanyLoginOption extends StatelessWidget {
  final ColorNotifire notifire;
  
  const CompanyLoginOption({super.key, required this.notifire});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: onbordingBlue.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => const CompanyLoginScreen());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, color: onbordingBlue, size: 22),
            const SizedBox(width: 10),
            Text(
              "Login as Car Owner".tr,
              style: TextStyle(
                fontFamily: FontFamily.europaBold,
                color: onbordingBlue,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward_ios, color: onbordingBlue, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Widget to display company badge on car cards
class CompanyBadge extends StatelessWidget {
  final String? companyName;
  final String? companyLogo;
  final bool isVerified;
  final double size;

  const CompanyBadge({
    super.key,
    this.companyName,
    this.companyLogo,
    this.isVerified = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (companyName == null || companyName!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (companyLogo != null && companyLogo!.isNotEmpty)
            ClipOval(
              child: Image.network(
                companyLogo!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitial(),
              ),
            )
          else
            _buildInitial(),
          const SizedBox(width: 6),
          Text(
            companyName!.length > 12 ? '${companyName!.substring(0, 12)}...' : companyName!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onbordingBlue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        companyName![0].toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: onbordingBlue,
        ),
      ),
    );
  }
}

/// Widget to display company info on car details screen
class CompanyInfoCard extends StatelessWidget {
  final String companyName;
  final String? companyLogo;
  final String? companyRating;
  final int? totalCars;
  final bool isVerified;
  final ColorNotifire notifire;

  const CompanyInfoCard({
    super.key,
    required this.companyName,
    required this.notifire,
    this.companyLogo,
    this.companyRating,
    this.totalCars,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getborderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Company Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: onbordingBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: companyLogo != null && companyLogo!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      companyLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
                    ),
                  )
                : _buildLogoPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Company Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontFamily: FontFamily.europaBold,
                        fontSize: 16,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: greyColor),
                    const SizedBox(width: 4),
                    Text(
                      "Car Rental Company".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.europaWoff,
                        fontSize: 12,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Rating & Cars
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (companyRating != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      companyRating!,
                      style: TextStyle(
                        fontFamily: FontFamily.europaBold,
                        fontSize: 14,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                  ],
                ),
              ],
              if (totalCars != null) ...[
                const SizedBox(height: 4),
                Text(
                  "$totalCars ${'cars'.tr}",
                  style: TextStyle(
                    fontFamily: FontFamily.europaWoff,
                    fontSize: 12,
                    color: greyColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Text(
        companyName[0].toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: onbordingBlue,
        ),
      ),
    );
  }
}
