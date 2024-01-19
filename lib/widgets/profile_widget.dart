import 'dart:io';
import 'package:flutter/material.dart';

import '../Utils/color_resources.dart';

class ProfileWidget extends StatelessWidget {
  var image;
  final bool isEdit;
  final Function()? onClicked;
  final double size;

  ProfileWidget({
    Key? key,
    this.image,
    this.size = 120,
    this.isEdit = false,
    this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          imageWidget(),
          if (isEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor:ColorResources.primaryColor,
                radius: 15,
                child: IconButton(
                  onPressed: onClicked,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget imageWidget() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image == null
              ? const AssetImage("assets/images/logo.png")
              : (image is File)
                  ? Image.file(image).image
                  : NetworkImage(image as String),
          fit: BoxFit.cover,
          width: size,
          height: size,
          child: InkWell(onTap: isEdit ? null : onClicked),
        ),
      ),
    );
  }
}
