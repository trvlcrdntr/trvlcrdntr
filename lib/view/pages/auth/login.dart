import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '/../application_state/app_values/app_constants.dart';
import '/../application_state/app_values/app_supported_countries.dart';
import '/../application_state/auth/auth_cubit.dart';
import '/../application_state/auth/phone_number_sign_in_cubit.dart';
import '/../injection.dart';
import '/../view/pages/auth/phone_number_sign_in/widgets/jumping_dots_loading_indicator.dart';
import '/../view/routes/app_router.gr.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController _phoneNumberController =
      TextEditingController(text: "");
  TextEditingController controller = TextEditingController(text: "");
  bool hasError = false;
  String _countryCode = "";
  String _countryName = "";
  bool enableContinueButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countryCode.isEmpty && _countryName.isEmpty) {
      _countryCode = supportedCountriesMap.values.first;
      _countryName = supportedCountriesMap.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocProvider(
        create: (context) => getIt<PhoneNumberSignInCubit>(),
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(
              listenWhen: (p, c) =>
                  (p.isLoggedIn != c.isLoggedIn) && c.isLoggedIn,
              listener: (context, state) {
                AutoRouter.of(context).replace(
                  const AppHomeRoute(),
                );
              },
            ),
            BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
              listenWhen: (p, c) => p.failureOption != c.failureOption,
              listener: (context, state) {
                state.failureOption.fold(() {}, (failure) {
                  BotToast.showText(
                    text: failure.when(
                        serverError: () => "Server Error",
                        invalidPhoneNumber: () => "Invalid Phone Number",
                        tooManyRequests: () => "Too Many Requests",
                        deviceNotSupported: () => "Device Not Supported",
                        smsTimeout: () => "Sms Timeout",
                        sessionExpired: () => "Session Expired",
                        invalidVerificationCode: () =>
                            "Invalid Verification Code"),
                  );

                  context.read<PhoneNumberSignInCubit>().reset();
                });
              },
            ),
            BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
              listenWhen: (p, c) =>
                  p.smsCode != c.smsCode &&
                  c.smsCode.length == PhoneNumberSignInCubit.smsCodeLength,
              listener: (context, state) {
                context.read<PhoneNumberSignInCubit>().verifySmsCode();
              },
            ),
          ],
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                icon: Icon(
                  Icons.clear,
                  //size: 48,
                  color: Colors.black,
                ),
              ),
            ),
            body: SafeArea(
              child: _body(
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNumberController.dispose();
  }

  Widget _body(context) {
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      builder: (BuildContext blocContext,
          PhoneNumberSignInState phoneNumberSignInState) {

        if(phoneNumberSignInState.displayLoadingIndicator)
          return  const JumpingDotsLoadingIndicator(
            color: Colors.white,
          );

        else if (phoneNumberSignInState.displaySmsCodeForm)
          return Container(
            height: MediaQuery.of(blocContext).size.height,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          ConfirmPhoneNumberText + ": " + phoneNumberSignInState
                              .phoneNumber,
                          style: Theme.of(blocContext).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  if (phoneNumberSignInState.isInProgress)
                    const JumpingDotsLoadingIndicator(
                      color: Colors.white,
                      )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                EnterSMSCodeText,
                                style: Theme.of(blocContext).textTheme.bodyText2,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: PinCodeTextField(
                                  autofocus: true,
                                  controller: controller,
                                  hideCharacter: false,
                                  highlight: true,
                                  highlightColor: Colors.black,
                                  defaultBorderColor: Colors.grey,
                                  hasTextBorderColor: Colors.grey,
                                  maxLength: PhoneNumberSignInCubit.smsCodeLength,
                                  hasError: hasError,
                                  onTextChanged: (text) {
                                    setState(() {
                                      hasError = false;
                                    });

                                  },
                                  onDone: (text) {
                                    print("DONE $text");
                                    print("DONE CONTROLLER ${controller.text}");
                                    blocContext
                                        .read<PhoneNumberSignInCubit>()
                                        .smsCodeChanged(
                                      smsCode: controller.text,
                                    );
                                    blocContext
                                        .read<PhoneNumberSignInCubit>()
                                        .verifySmsCode();
                                  },
                                  pinBoxWidth: 36,
                                  pinBoxHeight: 48,
                                  hasUnderline: false,
                                  wrapAlignment: WrapAlignment.spaceAround,
                                  pinBoxDecoration: ProvidedPinBoxDecoration
                                      .defaultPinBoxDecoration,
                                  pinTextStyle: TextStyle(fontSize: 22.0),
                                  pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
//                    pinBoxColor: Colors.green[100],
                                  pinTextAnimatedSwitcherDuration:
                                  Duration(milliseconds: 300),
//                    highlightAnimation: true,
                                  highlightAnimationBeginColor: Colors.black,
                                  highlightAnimationEndColor: Colors.white12,
                                  keyboardType: TextInputType.number,
                                  pinBoxRadius: 8.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        else if (phoneNumberSignInState.displayNextButton)
          return Container(
            height: MediaQuery.of(blocContext).size.height,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            LoginHeaderText + " " + AppTitle,
                            style: Theme.of(blocContext).textTheme.headline6,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 32.0,
                    ),

                    /// Country Widget
                    InkWell(
                      onTap: _onTapSelectCountry,
                      child: Container(
                        padding: EdgeInsets.all(
                          8.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              8.0,
                            ),
                            topRight: Radius.circular(
                              8.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        CountryHintText,
                                        style:
                                        Theme.of(blocContext).textTheme.caption,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_countryName ( $_countryCode )',
                                        style: Theme.of(blocContext)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 24.0,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ),

                    /// Phone Widget
                    Container(
                      //padding: EdgeInsets.all(8.0,),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            8.0,
                          ),
                          bottomRight: Radius.circular(
                            8.0,
                          ),
                        ),
                      ),

                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: PhoneNumberHintText,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 0.0,
                          ),
                        ),
                        onChanged: (String? val) {
                          if(val == null) return;
                          this.enableContinueButton = _validateCredentials();
                          if(mounted) {
                            setState(() {

                            });
                          }
                        },
                      ),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    ///signin button

                    /// Flatbutton implementation with disable and enable feature color-auto adjust.
                    /// Textbutton Flatbutton depricated
                    TextButton(
                      onPressed: this.enableContinueButton
                          ? () => _onTapContinue(blocContext)
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey[50],
                        padding: EdgeInsets.all(
                          8.0,
                        ),
                        minimumSize: Size(240.0, 48),
                      ),
                      child: const Text(
                        ContinueButtonText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        else
          return Container(
            child: Center(
              child: Text("No information to show..."),
            ),
          );
      },
    );
  }

  _onTapSelectCountry() async {
    await showDialog<Map<String, String>>(
        context: context,
        builder: (buildContext) {
          return Material(
            elevation: 8.0,
            child: Container(
              width: MediaQuery.of(buildContext).size.width * 0.8,
              height: MediaQuery.of(buildContext).size.height * 0.7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: supportedCountriesMap.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  List<String> countryNameList =
                      supportedCountriesMap.keys.toList();
                  List<String> countryCodeList =
                      supportedCountriesMap.values.toList();
                  if (index == 0) {
                    return ListTile(
                      onTap: () {
                        Navigator.of(buildContext).pop({
                          countryNameList[index - 1]: countryCodeList[index - 1]
                        });
                      },
                      leading: InkWell(
                        onTap: () {
                          Navigator.of(buildContext).pop(null);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              SelectCountryText,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListTile(
                    onTap: () {
                      Navigator.of(buildContext).pop({
                        countryNameList[index - 1]: countryCodeList[index - 1]
                      });
                    },
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                              '${countryNameList[index-1]} ( ${countryCodeList[index-1]} )'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }).then((countryMap) {
      if (mounted) {
        setState(() {
          this._countryCode = countryMap?.values.first ?? this._countryCode;
          this._countryName = countryMap?.keys.first ?? this._countryName;
        });
      }
    });
  }

  bool _validateCredentials() {
    if (_phoneNumberController.text.isEmpty) return false;
    if (_countryCode.isEmpty) return false;
    return true;
  }

  _onTapContinue(BuildContext context) async {
    bool isValid = _validateCredentials();
    if (!isValid) return;

    String phoneNumber = '$_countryCode' + '${_phoneNumberController.text}';
    context.read<PhoneNumberSignInCubit>().phoneNumberChanged(
      phoneNumber: phoneNumber,
    );
    /// Shared pref -> country code + phone number  store.
    SharedPreferences _sp = await SharedPreferences.getInstance();
    await _sp.setString(
      "Number_p",
      phoneNumber,
    );

    context
        .read<
        PhoneNumberSignInCubit>()
        .signInWithPhoneNumber();

    /// Navigate to Verify phone number
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VerifyPhoneNumber(),
    //   ),
    // );
  }

}
