import 'package:denta_koas/src/utils/constants/colors.dart';
import 'package:denta_koas/src/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FooterSection extends StatelessWidget {
  final String dateStart, dateEnd;
  final void Function()? onPressed;

  const FooterSection({
    super.key,
    required this.dateStart,
    required this.dateEnd,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          const Icon(Iconsax.calendar_1, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$dateStart - $dateEnd',
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: TColors.primary,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Join',
                  style: TextStyle(
                      fontSize: TSizes.fontSizeMd, color: TColors.white)),
              SizedBox(width: 4),
              Icon(CupertinoIcons.arrow_right_square,
                  size: TSizes.iconMd, color: TColors.white),
            ],
          ),
        ),
      ],
    );
  }
}
