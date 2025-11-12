import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final String? message;
  const NoDataWidget({super.key,this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: 250,
                width: 250,
                child:Image.asset("assets/images/noData.png")
            ),
            message == null? SizedBox() : Text(message??"",style: Theme.of(context).textTheme.bodyMedium),
          ],
        ));
  }
}
