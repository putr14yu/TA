import 'package:denta_koas/src/commons/widgets/appbar/appbar.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/commons/widgets/text/title_with_verified.dart';
import 'package:denta_koas/src/features/appointment/screen/home/widgets/cards/doctor_card.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/koas_reviews.dart';
import 'package:denta_koas/src/features/appointment/screen/koas_reviews/widgets/user_reviews_card.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/koas_post/post_with_specific_koas.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/enums.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';

class KoasDetailScreen extends StatelessWidget {
  const KoasDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: DAppBar(
          showBackArrow: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              // Koas profile
              KoasProfileSection(
                imageUrl: TImages.userProfileImage3,
                name: 'Dr. Bellamy Nicholas',
                university: 'London Bridge Hospital',
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Doctor stats
              DoctorStatsSection(),
              SizedBox(height: TSizes.spaceBtwSections),

              // Doctor description
              DoctorDescriptionSection(
                bio:
                    'Dr. Bellamy Nicholas is a highly experienced doctor with over 10 years of experience in the field. He has treated over 1000 patients and has a rating of 4.5. He is available for consultation from Monday to Saturday between 8:30 AM and 9:00 PM.',
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Working time
              PersonalInformationSection(),
              SizedBox(height: TSizes.spaceBtwSections),

              // Koas upcoming event

              UserReviewSection(),
              
              BookAppointmentButton(),
            ],
          ),
        )
    );
  }
}

class KoasProfileSection extends StatelessWidget {
  const KoasProfileSection({
    super.key,
    this.isNetworkImage = false,
    required this.imageUrl,
    required this.name,
    required this.university,
  });

  final bool isNetworkImage;
  final String imageUrl, name, university;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: isNetworkImage
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl), // Replace with real image URL
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: TColors.textPrimary,
              ),
        ),
        TitleWithVerified(
          title: university,
          textSizes: TextSizes.base,
          textColor: TColors.textSecondary,
        ),
      ],
    );
  }
}

class DoctorStatsSection extends StatelessWidget {
  const DoctorStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'Patients',
        'value': '1000+',
        'icon': Icons.groups,
        'color': Colors.blue
      },
      {
        'label': 'Experience',
        'value': '10 Yrs',
        'icon': Icons.workspace_premium,
        'color': Colors.pink
      },
      {
        'label': 'Ratings',
        'value': '4.5',
        'icon': Icons.star_rate,
        'color': Colors.amber
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats.map((stat) {
          return Expanded(
            child: Card(
              color: TColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          (stat['color'] as Color).withOpacity(0.2),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      stat['value'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DoctorDescriptionSection extends StatelessWidget {
  const DoctorDescriptionSection({super.key, required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'About Doctor',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ReadMoreText(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
            ),
            textAlign: TextAlign.justify,
            trimLines: 5,
            trimMode: TrimMode.Line,
            trimExpandedText: ' Show less ',
            trimCollapsedText: ' Show more ',
            moreStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
            lessStyle: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalInformationSection extends StatelessWidget {
  const PersonalInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final personalInfo = [
      {'label': 'Koas Number', 'value': '12345'},
      {'label': 'Faculty', 'value': 'Dental Information'},
      {'label': 'Location', 'value': 'Jember'},
      {'label': 'Age', 'value': '23'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Personal Information',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          ...personalInfo.map((info) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    info['label'] as String,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    info['value'] as String,
                    style: const TextStyle(
                        fontSize: 14, color: TColors.textPrimary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Location',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.200000, 106.816666),
                  zoom: 14,
                ),
                markers: {
                  const Marker(
                    markerId: MarkerId('doctorLocation'),
                    position: LatLng(-6.200000, 106.816666),
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserReviewSection extends StatelessWidget {
  const UserReviewSection({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: 'Rating & Review',
            onPressed: () => Get.to(() => const KoasReviewsScreen()),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return const UserReviewsCard();
            },
          ),
        ],
      ),
    );
  }
}

class KoasUpcomingEvent extends StatelessWidget {
  const KoasUpcomingEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: 'Upcoming Event',
            onPressed: () => Get.to(() => const KoasReviewsScreen()),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return const KoasCard(
                name: 'Dr. John Doe',
                university: 'Dentist',
                distance: '2 km',
                rating: 4.5,
                totalReviews: 120,
                image: TImages.userProfileImage4,
              );
            },
          ),
           
        ],
      ),
    );
  }
}

class BookAppointmentButton extends StatelessWidget {
  const BookAppointmentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Get.to(() => const PostWithSpecificKoas()),
          child: const Text(
            'Book Appointment',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
