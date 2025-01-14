import 'package:denta_koas/src/commons/widgets/cards/post_card.dart';
import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/commons/widgets/partnert/partner_showcase.dart';
import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/explore.controller/explore_post_controller.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/post_detail/post_detail.dart';
import 'package:denta_koas/src/features/appointment/screen/posts/posts.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class TabPost extends StatelessWidget {
  const TabPost({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExplorePostController());
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Partners showcase
              const CardShowcase(
                title: 'Last Chance',
                subtitle: 'Find the best koas in your area',
                images: [
                  TImages.userProfileImage4,
                  TImages.userProfileImage4,
                  TImages.userProfileImage4,
                ],
              ),
              const CardShowcase(
                title: 'Newest Posts',
                subtitle: 'Find the newest koas in your area',
                images: [
                  TImages.userProfileImage4,
                  TImages.userProfileImage4,
                  TImages.userProfileImage4,
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Posts
              SectionHeading(
                  title: 'You might interest',
                  onPressed: () => Get.to(() => const AllPostScreen())),
              const SizedBox(height: TSizes.spaceBtwItems),

              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.posts.isEmpty) {
                  return const Center(child: Text('No data'));
                }
                return DGridLayout(
                  itemCount: 2,
                  crossAxisCount: 1,
                  mainAxisExtent: 400,
                  itemBuilder: (_, index) {
                    final post = controller.posts[index];
                    return PostCard(
                      postId: post.id,
                      name: post.user.fullName,
                      university: post.user.koasProfile!.university!,
                      image: TImages.userProfileImage4,
                      timePosted: timeago.format(post.updateAt),
                      title: post.title,
                      description: post.desc,
                      category: post.treatment.alias,
                      participantCount: post.totalCurrentParticipants,
                      requiredParticipant: post.requiredParticipant,
                      dateStart: post.schedule.isNotEmpty
                          ? DateFormat('dd').format(post.schedule[0].dateStart)
                          : 'N/A',
                      dateEnd: post.schedule.isNotEmpty
                          ? DateFormat('dd MMM yyyy')
                              .format(post.schedule[0].dateEnd)
                          : 'N/A',
                      likesCount: post.likeCount ?? 0,
                      onTap: () => Get.to(
                        () => const PostDetailScreen(),
                        arguments: post,
                      ),
                      onPressed: () => Get.to(
                        () => const PostDetailScreen(),
                        arguments: post,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
