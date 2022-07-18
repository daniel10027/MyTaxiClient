import 'package:flutter/material.dart';
import '../brand_colors.dart';

class TaxiButton extends StatelessWidget {
  late final String title;
  late final Color color;
  final VoidCallback onPressed;

  // ignore: non_constant_identifier_names
  TaxiButton({
    required this.title,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(color: BrandColors.colorGreen))),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return BrandColors.colorGreen;
              return BrandColors.colorGreen;
            },
          ),
        ),
        child: Container(
          height: 50,
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
            ),
          ),
        ),
        onPressed: onPressed);
  }
}
