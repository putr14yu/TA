import 'package:denta_koas/src/cores/data/repositories/notifications.repository/notification_repository.dart';
import 'package:denta_koas/src/cores/data/repositories/user.repository/user_repository.dart';
import 'package:denta_koas/src/features/appointment/data/model/notifications_model.dart';
import 'package:denta_koas/src/features/personalization/controller/user_controller.dart';
import 'package:denta_koas/src/features/personalization/model/koas_profile.dart';
import 'package:denta_koas/src/features/personalization/model/user_model.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:denta_koas/src/utils/helpers/network_manager.dart';
import 'package:denta_koas/src/utils/popups/full_screen_loader.dart';
import 'package:denta_koas/src/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class SchedulesController extends GetxController {
  static SchedulesController get instance => Get.find();

  RxList<UserModel> allSchedules = <UserModel>[].obs;
  RxList<UserModel> cancelSchedules = <UserModel>[].obs;
  RxList<UserModel> pendingSchedules = <UserModel>[].obs;
  RxList<UserModel> upcomingSchedules = <UserModel>[].obs;
  RxList<UserModel> ongoingSchedules = <UserModel>[].obs;
  RxList<UserModel> completedSchedules = <UserModel>[].obs;

  final RxList<UserModel> featuredKoas = <UserModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeVerificationKoas();
  }

  Future<void> initializeVerificationKoas() async {
    try {
      isLoading.value = true;
      final fetchedSchedules =
          await UserRepository.instance.fetchUsersByRole('Koas');
      allSchedules.assignAll(fetchedSchedules);

      final facilitatorUniversity =
          UserController.instance.user.value.profile.university;

      // Filter data berdasarkan status
      pendingSchedules.assignAll(
        allSchedules
            .where((koas) =>
                koas.koasProfile?.status == 'Pending' &&
                koas.koasProfile?.university == facilitatorUniversity)
            .toList(),
      );

      cancelSchedules.assignAll(
        allSchedules
            .where((koas) =>
                koas.koasProfile?.status == 'Rejected' &&
                koas.koasProfile?.university == facilitatorUniversity)
            .toList(),
      );

      ongoingSchedules.assignAll(
        allSchedules
            .where((koas) =>
                koas.koasProfile?.status == 'Approved' &&
                koas.koasProfile?.university == facilitatorUniversity)
            .toList(),
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void rejectKoas(String userKoasId, String koasId) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Proceccing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Initialize the update
      final updateKoasProfile = UserModel(
        koasProfile: KoasProfileModel(
          status: 'Rejected',
        ),
      );

      final updateNotification = NotificationsModel(
        senderId: UserController.instance.user.value.id,
        userId: userKoasId,
        koasId: koasId,
        title: 'Koas Application Rejected',
        message:
            'Your Koas application has been rejected. Please contact the facilitator for more information',
        status: 'Read',
      );

      // Update the status of koas
      await UserRepository.instance.updateKoasProfile(
        userKoasId,
        updateKoasProfile,
      );

      // Send notification
      await NotificationRepository.instance
          .createNotification(updateNotification);

      // Close loading
      TFullScreenLoader.stopLoading();

      // Success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Koas has been rejected',
      );

      // Refresh the data
      update();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  void approveKoas(String userKoasId, String koasId) async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'Proceccing your action....', TImages.loadingHealth);

      // Check connection
      final isConected = await NetworkManager.instance.isConnected();
      if (!isConected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      Logger().e("User Id: $userKoasId");
      Logger().e("Koas Id: $koasId");

      // Initialize the update
      final updateKoasProfile = UserModel(
        koasProfile: KoasProfileModel(
          status: 'Approved',
        ),
      );

      final updateNotification = NotificationsModel(
        senderId: UserController.instance.user.value.id,
        userId: userKoasId,
        koasId: koasId,
        title: 'Welcome to Denta Koas',
        message:
            'Your Koas application has been approved. You can now start your Post Event',
        status: 'Read',
      );

      // Update the status of koas
      await UserRepository.instance.updateKoasProfile(
        userKoasId,
        updateKoasProfile,
      );

      // Send notification
      await NotificationRepository.instance
          .createNotification(updateNotification);

      // Close loading
      TFullScreenLoader.stopLoading();

      // Success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Koas has been approved',
      );

      // Refresh the data
      update();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  String formatKoasDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown date';
    }
    // Formatting the date (e.g., "Monday, 5 January")
    return DateFormat('EEEE, d MMMM').format(dateTime);
  }

  String formatKoasTimestamp(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown';
    }

    // Formatting the timestamp (e.g., "10:00 AM")
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // Pop up confirmation
  void approveConfirmation(String userKoasId, String koasId) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Approve Koas',
      middleText: 'Are you sure you want to approve this koas?',
      confirm: ElevatedButton(
        onPressed: () => approveKoas(userKoasId, koasId),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          side: const BorderSide(color: TColors.primary),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Approve'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  void rejectConfirmation(String userKoasId, String koasId) {
    Get.defaultDialog(
      backgroundColor: TColors.white,
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Reject Koas',
      middleText: 'Are you sure you want to reject this koas?',
      confirm: ElevatedButton(
        onPressed: () => rejectKoas(userKoasId, koasId),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.error,
          side: const BorderSide(color: TColors.error),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Reject'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }
}