import 'package:denta_koas/src/features/authentication/presentasion/signin/signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController {
  static OnBoardingController get instance => Get.find();

  // Variable
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index When Page Scroll
  void updatePageIndicator(index) {
    pageController.addListener(() {
      currentPageIndex.value = pageController.page!.round();
    });
  }

  // Jump to the specific dot selected page
  void dotNavigationsClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Update current index & jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      Get.offAll(const SigninScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration:
            const Duration(milliseconds: 300), // Adjust the duration as needed
        curve: Curves.easeInOut, // Adjust the animation curve if desired
      );
    }
  }

  // Update current index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }
}