import 'package:denta_koas/src/commons/widgets/layouts/grid_layout.dart';
import 'package:denta_koas/src/features/appointment/screen/schedules/widgets/schedule_card.dart';
import 'package:denta_koas/src/utils/constants/image_strings.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TabUpcomingSchedules extends StatelessWidget {
  const TabUpcomingSchedules({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            children: [
              DGridLayout(
                itemCount: 10,
                crossAxisCount: 1,
                mainAxisExtent: 230,
                itemBuilder: (_, index) => ScheduleCard(
                  onTap: () {},
                  imgUrl: TImages.user,
                  name: 'Dr. John Doe',
                  category: 'Scaling',
                  date: 'Sunday, 12 June',
                  timestamp: '10:00 - 11:00 AM',
                  primaryBtnText: 'Cancel',
                  secondaryBtnText: 'Reschedule',
                  showSecondaryBtn: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}