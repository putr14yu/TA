import 'package:denta_koas/src/commons/widgets/text/section_heading.dart';
import 'package:denta_koas/src/features/appointment/controller/post_controller';
import 'package:denta_koas/src/features/appointment/screen/posts/create_post/widget/dropdown.dart';
import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TimeSlotWidget extends StatelessWidget {
  const TimeSlotWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return const Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RequiredParticipantSection(),
          SizedBox(height: TSizes.spaceBtwSections),
          DurationSection(),
          SizedBox(height: TSizes.spaceBtwSections),
          TimeSlotSelection()
        ],
      ),
    );
  }
}

class RequiredParticipantSection extends StatelessWidget {
  const RequiredParticipantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    int requiredParticipant = 5;

    controller.timeController.requiredParticipants.value = requiredParticipant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Required Participant',
          showActionButton: false,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.group),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          initialValue: requiredParticipant.toString(),
          enabled: false,
        ),
      ],
    );
  }
}

class DurationSection extends StatelessWidget {

  const DurationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostController());
    final durationItems = [
      '1 Jam',
      '2 Jam',
      '3 Jam',
      '4 Jam',
      '5 Jam',
      '6 Jam'
    ];
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Duration', showActionButton: false),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
          () => DDropdownMenu(
            selectedItem:
                "${controller.timeController.sessionDuration.value.inHours}  Jam",
            items: durationItems,
            onChanged: (value) {
              if (value != null) {
                controller.timeController
                    .updateSessionDuration(int.parse(value.split(' ')[0]));
              }
            },
            hintText: 'Select Session Duration...',
            prefixIcon: Iconsax.clock,
          ),
        ),
      ],
    );
  }
}

class TimeSlotSelection extends StatefulWidget {
  const TimeSlotSelection({super.key});

  @override
  State<TimeSlotSelection> createState() => _TimeSlotSelectionState();
}

class _TimeSlotSelectionState extends State<TimeSlotSelection> {
  final controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Time Slots',
          isSuffixIcon: true,
          suffixIcon: Icons.more_vert,
          onPressed: () {},
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
          () {
            return Column(
              children: controller.timeController.timeSlots.entries.map(
                (entry) {
                  return _buildSection(context, entry.key, entry.value);
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> slots) {
    int totalMaxParticipants = controller.timeController.totalMaxParticipants;
    int requiredParticipants =
        controller.timeController.requiredParticipants.value;
    final totalAvailableTimeSlots =
        controller.timeController.totalAvailableTimeSlots;
    int totalSlots = controller.timeController.calculateTotalSlots();

    bool isAvailable = totalMaxParticipants < requiredParticipants &&
        totalSlots < requiredParticipants;

    print('Total maxparticipants: $totalMaxParticipants');
    print('Required Participants: $requiredParticipants');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          triggerMode: isAvailable ? TooltipTriggerMode.tap : null,
          message: 'Max participants reached',
          child: SectionHeading(
            title: title,
            isSuffixIcon: true,
            suffixIcon: Icons.add,
            color: isAvailable ? TColors.black : TColors.grey,
            onPressed: isAvailable ? () => _showTimePicker(title) : () {},
          ),
        ),
        Column(
          children: slots.map((slot) {
            // Create a unique GlobalKey for each slot dynamically
            final tooltipKey = GlobalKey<TooltipState>();

            return Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TColors.grey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '$slot (${DateTime.now().timeZoneName})',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: TColors.textPrimary,
                              fontWeightDelta: 2,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Tooltip(
                        key: tooltipKey,
                        message: 'Set Max Participants for Slot',
                        triggerMode: TooltipTriggerMode.manual,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.chevron_left),
                                iconSize: TSizes.iconBase,
                                onPressed: () {
                                  if (controller.timeController
                                          .maxParticipantsForSlot(title, slot) >
                                      1) {
                                    controller.timeController
                                        .decrementMaxParticipantsForSlot(
                                            title, slot);
                                  }
                                }),
                            Obx(() {
                              return Text(
                                controller.timeController
                                    .maxParticipantsForSlot(title, slot)
                                    .toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            }),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              iconSize: TSizes.iconBase,
                              onPressed: () {
                                if (totalMaxParticipants <
                                    requiredParticipants) {
                                  controller.timeController
                                      .incrementMaxParticipantsForSlot(
                                          title, slot);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: TSizes.iconSm,
                        onPressed: () => controller.timeController
                            .removeTimeSlot(title, slot),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _showTimePicker(String section) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: section == 'Pagi'
          ? const TimeOfDay(hour: 6, minute: 0)
          : section == 'Siang'
              ? const TimeOfDay(hour: 12, minute: 0)
              : const TimeOfDay(hour: 18, minute: 0),
    );

    if (pickedTime != null) {
      controller.timeController.addTimeSlot(section, pickedTime);
      if (controller.timeController.tooltipShown == false) {
        await _showAndCloseTooltip();
        controller.timeController.tooltipShown = true;
      }
    }
  }

  Future _showAndCloseTooltip() async {
    await Future.delayed(const Duration(milliseconds: 10));
    final tooltipKey = GlobalKey<TooltipState>();
    final tooltip = tooltipKey.currentState;
    tooltip?.ensureTooltipVisible();
    await Future.delayed(const Duration(seconds: 4));
    tooltip?.deactivate();
  }
}