import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
/*  Custom Widgets  */
import 'package:mobile_app/Components/bmi/gender_widget.dart';
import 'package:mobile_app/Components/bmi/score_screen.dart';
import 'package:mobile_app/Services/userInforManagement.dart';
import 'package:mobile_app/Theme/theme_info.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class BmiCalcView extends StatefulWidget {
  const BmiCalcView({Key? key}) : super(key: key);

  @override
  State<BmiCalcView> createState() => BmiCalcViewState();
}

class BmiCalcViewState extends State<BmiCalcView> {
  userInfor usr = userInfor();

  int _gender = 2;
  double _height = 150;
  int _age = 30.obs.toInt();
  double _weight = 50;

  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  bool _isFinished = false;
  double _bmiScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            //Lets create widget for gender selection
            GenderWidget(
              onChange: (genderVal) {
                _gender = genderVal;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Enter Your Height in cm',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType: TextInputType.number,
              // add controller
              controller: heightController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Your Height (cm)",
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Enter Your Weight (kg)',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType: TextInputType.number,
              // add controller
              controller: weightController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Your Weight (kg)",
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(
              'Your Age : $_age',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // pick the age
            NumberPicker(
              itemHeight: 50,
              haptics: true,
              textStyle: const TextStyle(fontSize: 20),
              value: _age,
              axis: Axis.horizontal,
              minValue: 0,
              maxValue: 100,
              onChanged: (value) => setState(() => _age = value),
            ),

            const SizedBox(
              height: 15,
            ),

            ElevatedButton(
                onPressed: () {
                  // update user details
                  usr.setHeightToFirebase(heightController.value.text);
                  usr.setWeightToFirebase(weightController.value.text);

                  if (_gender == 1) {
                    usr.setGenderToFirebase('Male');
                  } else if (_gender == 2) {
                    usr.setGenderToFirebase('Female');
                  }

                  // dialogue box
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Closed'),
                        )
                      ],
                      title: const Text('Update Alert'),
                      contentPadding: const EdgeInsets.all(50.0),
                      content: const Text('User Details Updated!'),
                    ),
                  );
                },
                child: const Text(
                  'Update User Details',
                  style: TextStyle(fontSize: 19),
                )),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
              child: SwipeableButtonView(
                  isFinished: _isFinished,
                  onFinish: () async {
                    await Navigator.push(
                        context,
                        PageTransition(
                            child: ScoreScreen(
                              bmiScore: _bmiScore,
                              age: _age,
                            ),
                            type: PageTransitionType.fade));

                    setState(() {
                      _isFinished = false;
                    });
                  },
                  onWaitingProcess: () {
                    //Calculate BMI here
                    _height = double.parse(heightController.value.text);
                    _weight = double.parse(weightController.value.text);
                    calculateBmi(_height, _weight);

                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        _isFinished = true;
                      });
                    });
                  },
                  activeColor: ThemeInfo.primaryColor,
                  buttonWidget: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black,
                  ),
                  buttonText: 'CALCULATE'),
            ),
          ],
        ),
      ),
    ));
  }

  double calculateBmi(height, weight) {
    _bmiScore = weight / pow(height / 100, 2);
    return _bmiScore;
  }
}