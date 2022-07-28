import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _UpperBox(),
          _HeaderIcon(),
          this.child,
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.055),
      child: Image.asset(
        'assets/app_icon_transparent.png',
        width: 110,
        height: 110,
      ),
    );
  }
}

class _UpperBox extends StatefulWidget {
  @override
  State<_UpperBox> createState() => _UpperBoxState();
}

class _UpperBoxState extends State<_UpperBox> {
  List<Color> colorList = [
    Color.fromRGBO(1, 29, 69, 1),
    Color.fromRGBO(44, 181, 110, 1),
    Color.fromRGBO(1, 29, 69, 1),
  ];

  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];

  int index = 0;
  Color bottomColor = Color.fromRGBO(1, 29, 69, 1);
  Color topColor = Color.fromRGBO(44, 181, 110, 1);
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        bottomColor = Color.fromRGBO(44, 181, 110, 1);
      });
    });

    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      width: double.infinity,
      height: size.height * 0.4,
      duration: Duration(seconds: 2),
      onEnd: () {
        setState(() {
          index = index + 1;
          bottomColor = colorList[index % colorList.length];
          topColor = colorList[(index + 1) % colorList.length];
          begin = alignmentList[index % alignmentList.length];
          end = alignmentList[(index + 2) % alignmentList.length];
        });
      },
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: begin, end: end, colors: [bottomColor, topColor])),
    );
  }

  BoxDecoration _ColorLoginBackground() => BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromRGBO(2, 31, 70, 1),
        Color.fromRGBO(44, 179, 110, 1),
      ]));
}
