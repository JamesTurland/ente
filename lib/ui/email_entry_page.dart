import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/models/billing_plan.dart';
import 'package:photos/services/billing_service.dart';
import 'package:photos/services/user_service.dart';
import 'package:photos/ui/common/fabCreateAccount.dart';
//import 'package:photos/ui/common/report_bug_popup.dart';
//import 'package:photos/ui/common_elements.dart';
import 'package:photos/ui/loading_widget.dart';
import 'package:photos/ui/web_page.dart';
import 'package:photos/utils/data_util.dart';
//import 'package:photos/utils/dialog_util.dart';
//import 'package:photos/utils/email_util.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class EmailEntryPage extends StatefulWidget {
  EmailEntryPage({Key key}) : super(key: key);

  @override
  _EmailEntryPageState createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends State<EmailEntryPage> {
  static const kPasswordStrengthThreshold = 0.4;

  final _config = Configuration.instance;
  final _passwordController1 = TextEditingController(),
      _passwordController2 = TextEditingController();

  String _email;
  String _password = null;
  String _passwordInInputBox = '';
  bool _emailIsValid = false;
  bool _hasAgreedToTOS = true;
  bool _hasAgreedToE2E = false;
  bool _password1Visible = false;
  bool _password2Visible = false;
  bool _passwordsMatch = false;
  final _password1FocusNode = FocusNode();
  final _password2FocusNode = FocusNode();
  bool _password1InFocus = false;
  bool _password2InFocus = false;
  bool _passwordIsValid = false;

  bool _capitalLetterIsPresent = false;
  bool _lenghtIsValid = false; //variables for checking password strength
  bool _specialCharIsPresent = false;

  Color _cnfPasswordInputFieldColor = null;
  Color _emailInputFieldColor = null; //is this okay?
  Color _passwordInputFieldColor = null;

  @override
  void initState() {
    _email = _config.getEmail();
    _password1FocusNode.addListener(() {
      setState(() {
        _password1InFocus = _password1FocusNode.hasFocus;
      });
    });
    _password2FocusNode.addListener(() {
      setState(() {
        _password2InFocus = _password2FocusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isKeypadOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    // Widget fab() {
    //   if (isKeypadOpen) {
    //     return Container(
    //       decoration: BoxDecoration(boxShadow: [
    //         BoxShadow(
    //           color: Theme.of(context).backgroundColor,
    //           spreadRadius: 200,
    //           blurRadius: 100,
    //           offset: Offset(0, 230),
    //         )
    //       ]),
    //       width: double.infinity,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.end,
    //         children: [
    //           FloatingActionButton(
    //               //mini: true,
    //               backgroundColor:
    //                   Theme.of(context).colorScheme.fabBackgroundColor,
    //               foregroundColor:
    //                   Theme.of(context).colorScheme.fabTextOrIconColor,
    //               child: Transform.rotate(
    //                 angle: _isFormValid() ? 0 : math.pi / 2,
    //                 child: Icon(
    //                   Icons.chevron_right,
    //                   size: 36,
    //                 ),
    //               ),
    //               onPressed: _isFormValid()
    //                   ? () {
    //                       _config
    //                           .setVolatilePassword(_passwordController1.text);
    //                       _config.setEmail(_email);
    //                       UserService.instance.getOtt(context, _email);
    //                     }
    //                   : () {
    //                       FocusScope.of(context).unfocus();
    //                     } //keypad down here
    //               ),
    //         ],
    //       ),
    //     );
    //   } else {
    //     return Container(
    //       width: double.infinity,
    //       height: 56,
    //       padding: EdgeInsets.symmetric(horizontal: 20),
    //       child: OutlinedButton(
    //         //style: Theme.of(context).elevatedButtonTheme.style,
    //         onPressed: _isFormValid()
    //             ? () {
    //                 _config.setVolatilePassword(_passwordController1.text);
    //                 _config.setEmail(_email);
    //                 UserService.instance.getOtt(context, _email);
    //               }
    //             : null,
    //         child: Text(
    //           'Create Account',
    //         ),
    //       ),
    //     );
    //   }
    // }

    FloatingActionButtonLocation fabLocation() {
      if (isKeypadOpen) {
        return null;
      } else {
        return FloatingActionButtonLocation.centerFloat;
      }
    }

    final appBar = AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Theme.of(context).iconTheme.color,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Hero(
        tag: "sign_up",
        child: Material(
            type: MaterialType.transparency,
            child: StepProgressIndicator(
              totalSteps: 4,
              currentStep: 1,
              selectedColor: Theme.of(context).buttonColor,
              roundedEdges: Radius.circular(10),
              unselectedColor: Theme.of(context).bottomAppBarColor,
            )),
      ),
    );
    return Scaffold(
        appBar: appBar,
        body: _getBody(),
        floatingActionButton: FABCreateAccount(
          isKeypadOpen: isKeypadOpen,
          isFormValid: _isFormValid(),
          buttonText: 'Create Account',
          onPressedFunction: () {
            _config.setVolatilePassword(_passwordController1.text);
            _config.setEmail(_email);
            UserService.instance.getOtt(context, _email);
          },
        ),
        floatingActionButtonLocation: fabLocation()
        // resizeToAvoidBottomInset: false,
        );
  }

  Widget _getBody() {
    return Column(
      children: [
        Expanded(
          child: AutofillGroup(
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text('Create new account',
                      style: Theme.of(context).textTheme.headline4),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    style: Theme.of(context).textTheme.subtitle1,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                      fillColor: _emailInputFieldColor,
                      filled: true,
                      hintText: 'email',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(6)),
                      suffixIcon: _emailIsValid
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder
                                  .borderSide
                                  .color,
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value.trim();
                        _emailIsValid = EmailValidator.validate(_email);
                        if (_emailIsValid) {
                          _emailInputFieldColor =
                              Color.fromRGBO(45, 194, 98, 0.2);
                        } else {
                          _emailInputFieldColor = null;
                        }
                      });
                    },
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    //initialValue: _email,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _passwordController1,
                    obscureText: !_password1Visible,
                    enableSuggestions: true,
                    autofillHints: [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      fillColor: _passwordInputFieldColor,
                      filled: true,
                      hintText: "password",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      suffixIcon: _password1InFocus
                          ? IconButton(
                              icon: Icon(
                                _password1Visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _password1Visible = !_password1Visible;
                                });
                              },
                            )
                          : _passwordIsValid
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder
                                      .borderSide
                                      .color,
                                )
                              : null,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    focusNode: _password1FocusNode,
                    onChanged: (password) {
                      setState(() {
                        _passwordInInputBox = password;
                        validatePassword(password);
                        if (_passwordIsValid) {
                          _passwordInputFieldColor =
                              Color.fromRGBO(45, 194, 98, 0.2);
                        } else {
                          _passwordInputFieldColor = null;
                        }
                      });
                    },
                    onEditingComplete: () {
                      _password1FocusNode.unfocus();
                      _password2FocusNode.requestFocus();
                      TextInput.finishAutofillContext();
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController2,
                        obscureText: !_password2Visible,
                        autofillHints: [AutofillHints.newPassword],
                        onEditingComplete: () =>
                            TextInput.finishAutofillContext(),
                        decoration: InputDecoration(
                          fillColor: _cnfPasswordInputFieldColor,
                          filled: true,
                          hintText: "confirm password",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          suffixIcon: _password2InFocus
                              ? IconButton(
                                  icon: Icon(
                                    _password2Visible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).iconTheme.color,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _password2Visible = !_password2Visible;
                                    });
                                  },
                                )
                              : _passwordsMatch
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .focusedBorder
                                          .borderSide
                                          .color,
                                    )
                                  : null,
                          border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        focusNode: _password2FocusNode,
                        onChanged: (cnfPassword) {
                          setState(() {
                            if (_password != null) {
                              if (_password == cnfPassword) {
                                _cnfPasswordInputFieldColor =
                                    Color.fromRGBO(45, 194, 98, 0.2);
                                _passwordsMatch = true;
                              } else {
                                _cnfPasswordInputFieldColor = null;
                              }
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Divider(
                        thickness: 1.5,
                      ),
                    ),
                    Visibility(
                      visible:
                          (!_passwordIsValid && (_passwordInInputBox != '')),
                      child: Positioned(
                          bottom: -48,
                          child: Row(
                            children: [
                              // SizedBox(
                              //   width: 20, //hardcoded
                              // ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context).hintColor,
                                          width: 0.5),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.zero,
                                        topRight: Radius.zero,
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                      color: Theme.of(context)
                                          .dialogTheme
                                          .backgroundColor,
                                    ),
                                    //width: MediaQuery.of(context).size.width,
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                4.0, 8, 4.0, 4.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 8, 0),
                                                    child: _lenghtIsValid
                                                        ? Icon(
                                                            Icons.check,
                                                            color:
                                                                CupertinoColors
                                                                    .systemGrey2,
                                                          )
                                                        : Icon(
                                                            Icons.check,
                                                            color: Theme.of(
                                                                    context)
                                                                .dialogTheme
                                                                .backgroundColor,
                                                          )),
                                                Text(
                                                    'Must be minimum 9 characters long',
                                                    style: _lenghtIsValid
                                                        ? TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color:
                                                                CupertinoColors
                                                                    .systemGrey)
                                                        : TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    241,
                                                                    118,
                                                                    109)))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 8, 0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      child:
                                                          _specialCharIsPresent
                                                              ? Icon(
                                                                  Icons.check,
                                                                  color: CupertinoColors
                                                                      .systemGrey2,
                                                                )
                                                              : Icon(
                                                                  Icons.check,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dialogTheme
                                                                      .backgroundColor,
                                                                )),
                                                  Text(
                                                      '  Must have special characters',
                                                      style: _specialCharIsPresent
                                                          ? TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              color:
                                                                  CupertinoColors
                                                                      .systemGrey)
                                                          : TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      241,
                                                                      118,
                                                                      109)))
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                4, 4, 4, 8),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 8, 0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      child:
                                                          _capitalLetterIsPresent
                                                              ? Icon(
                                                                  Icons.check,
                                                                  color: CupertinoColors
                                                                      .systemGrey2,
                                                                )
                                                              : Icon(
                                                                  Icons.check,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dialogTheme
                                                                      .backgroundColor,
                                                                )),
                                                  Text(
                                                      '  Must have a capital letter',
                                                      style: _capitalLetterIsPresent
                                                          ? TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              color:
                                                                  CupertinoColors
                                                                      .systemGrey)
                                                          : TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      241,
                                                                      118,
                                                                      109)))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          )),
                    ),
                  ],
                  clipBehavior: Clip.none,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                ),
                _getAgreement(),
                Padding(padding: EdgeInsets.all(20)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _getAgreement() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          _getTOSAgreement(),
          _getPasswordAgreement(),
        ],
      ),
    );
  }

  Widget _getTOSAgreement() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasAgreedToTOS = !_hasAgreedToTOS;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          Checkbox(
              value: _hasAgreedToTOS,
              side: CheckboxTheme.of(context).side,
              onChanged: (value) {
                setState(() {
                  _hasAgreedToTOS = value;
                });
              }),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "I agree to the ",
                  ),
                  TextSpan(
                    text: "terms of service",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return WebPage("terms", "https://ente.io/terms");
                            },
                          ),
                        );
                      },
                  ),
                  TextSpan(text: " and "),
                  TextSpan(
                    text: "privacy policy",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return WebPage(
                                  "privacy", "https://ente.io/privacy");
                            },
                          ),
                        );
                      },
                  ),
                ],
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 12),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPasswordAgreement() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _hasAgreedToE2E = !_hasAgreedToE2E;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          Checkbox(
            value: _hasAgreedToE2E,
            side: CheckboxTheme.of(context).side,
            onChanged: (value) {
              setState(() {
                _hasAgreedToE2E = value;
              });
            },
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "I understand that if I lose my password, I may lose my data since my data is ",
                  ),
                  TextSpan(
                    text: "end-to-end encrypted",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return WebPage(
                                  "encryption", "https://ente.io/architecture");
                            },
                          ),
                        );
                      },
                  ),
                  TextSpan(text: " with ente"),
                ],
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 12),
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // bool _isFormValid() {
  //   return _email != null &&
  //       _email.isNotEmpty &&
  //       _passwordController1.text.isNotEmpty &&
  //       _passwordController2.text.isNotEmpty &&
  //       _hasAgreedToTOS &&
  //       _hasAgreedToE2E;
  // }

  bool _isFormValid() {
    return _emailIsValid &&
        _passwordsMatch &&
        _hasAgreedToTOS &&
        _hasAgreedToE2E;
  }

  void validatePassword(String password) {
    var len = password.length;
    _lenghtIsValid = true;
    _specialCharIsPresent = true;
    _capitalLetterIsPresent = true;
    _passwordIsValid = true;
    if (len < 9) {
      _passwordIsValid = false;
      _lenghtIsValid = false;
    }
    if (!RegExp(r"[!@#$%^&*()_+\-=\[\]{};':\\|,.<>\/?]+").hasMatch(password)) {
      _specialCharIsPresent = false;
      _passwordIsValid = false;
    }
    if (!RegExp(r"(.*[A-Z].*)").hasMatch(password)) {
      _capitalLetterIsPresent = false;
      _passwordIsValid = false;
    }
    if (_passwordIsValid) {
      _password = password;
    } else {
      _password = null;
    }
  }
}

class PricingWidget extends StatelessWidget {
  const PricingWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BillingPlans>(
      future: BillingService.instance.getBillingPlans(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _buildPlans(context, snapshot.data);
        } else if (snapshot.hasError) {
          return Text("Oops, something went wrong.");
        }
        return loadWidget;
      },
    );
  }

  Container _buildPlans(BuildContext context, BillingPlans plans) {
    final planWidgets = <BillingPlanWidget>[];
    for (final plan in plans.plans) {
      final productID = Platform.isAndroid ? plan.androidID : plan.iosID;
      if (productID != null && productID.isNotEmpty) {
        planWidgets.add(BillingPlanWidget(plan));
      }
    }
    final freePlan = plans.freePlan;
    return Container(
      height: 280,
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "pricing",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: planWidgets,
            ),
          ),
          Text("we offer a free trial of " +
              convertBytesToReadableFormat(freePlan.storage) +
              " for " +
              freePlan.duration.toString() +
              " " +
              freePlan.period),
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white38,
                ),
                Padding(padding: EdgeInsets.all(1)),
                Text(
                  "close",
                  style: TextStyle(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            onTap: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}

class BillingPlanWidget extends StatelessWidget {
  final BillingPlan plan;

  const BillingPlanWidget(
    this.plan, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.black.withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Column(
            children: [
              Text(
                convertBytesToGBs(plan.storage, precision: 0).toString() +
                    " GB",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4),
              ),
              Text(
                plan.price + " / " + plan.period,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
