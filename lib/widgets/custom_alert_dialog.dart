import 'package:flutter/material.dart';

class CustomDialogBox extends StatelessWidget {
  final String? title, descriptions, textRight, textLeft;
  final void Function()? leftFunc, rightFunc;
  final Icon? icon;

  const CustomDialogBox(
      {required Key key,
      this.title,
      this.descriptions,
      this.textRight,
      this.textLeft,
      this.leftFunc,
      this.rightFunc,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: 20, top: 45.0 + 20.0, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFF2d3447),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 1), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title ?? "",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                descriptions ?? "",
                style: const TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: leftFunc ??
                          () {
                            Navigator.of(context).pop();
                          },
                      child: Text(
                        textLeft ?? "",
                        style: const TextStyle(fontSize: 18),
                      )),
                  TextButton(
                      onPressed: rightFunc ??
                          () {
                            Navigator.of(context).pop();
                          },
                      child: Text(
                        textRight ?? "",
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ))
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(45)),
                child: icon),
          ),
        ),
      ],
    );
  }
}
