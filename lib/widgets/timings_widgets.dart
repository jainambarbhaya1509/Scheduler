import 'package:flutter/material.dart';
import 'package:schedule/models/class_avalability_model.dart';


class DisplayTimings extends StatelessWidget {
  const DisplayTimings({super.key, required this.classAvalabilityModel});
  final ClassAvalabilityModel classAvalabilityModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(34, 193, 193, 193),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${classAvalabilityModel.className}\n",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                    TextSpan(
                      text:
                          classAvalabilityModel.timings,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Spacer(),
              // Text("3+ Users Applied")
            ],
          ),

          // const SizedBox(height: 5),
          // Text("This class is occupied by more 3 professors",
          //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //         fontWeight: FontWeight.w500,
          //         color: const Color.fromARGB(95, 28, 28, 28))),
          // const SizedBox(height: 10),
        ],
      ),
    );
  }
}
