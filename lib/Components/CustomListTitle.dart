import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Image leadingIcon;
  final String heading;
  final String subheading;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  CustomListTile({
    required this.leadingIcon,
    required this.heading,
    required this.subheading,
    required this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xffF86851),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: onTap,
          leading: Padding(padding: EdgeInsets.all(12.0), child: leadingIcon),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5,),
              Text(
                subheading,
                style: TextStyle(color: Colors.white,fontSize: 12),
              ),
            ],
          ),
          trailing: Icon(
            trailingIcon,
            size: 35,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}