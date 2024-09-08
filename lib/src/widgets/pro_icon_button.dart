import 'package:flutter/material.dart';

class ProIconButton extends StatefulWidget {
  final Function() onTap;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color iconColor;
  final EdgeInsetsGeometry? margin;
  final IconData icon;
  final double? iconSize;
  const ProIconButton(
      {super.key,
      required this.onTap,
      this.padding = const EdgeInsets.all(16),
      this.backgroundColor = Colors.white70,
      this.iconColor = Colors.black,
      this.margin,
      this.iconSize,
      this.icon = Icons.filter});

  @override
  State<ProIconButton> createState() => _ProIconButtonState();
}

class _ProIconButtonState extends State<ProIconButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
                color: widget.backgroundColor, shape: BoxShape.circle),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.iconSize ?? 22,
            ),
          ),
        ),
      ),
    );
  }
}
