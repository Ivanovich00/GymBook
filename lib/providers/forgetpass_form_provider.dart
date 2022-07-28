import 'package:flutter/material.dart';

class ForgotPassFormProvider extends ChangeNotifier{

  GlobalKey<FormState> formForgotKey = new GlobalKey<FormState>();

  String requestType = 'PASSWORD_RESET';
  String email = '';

  bool _isLoadingForgot = false;
  bool get isLoading => _isLoadingForgot;
  set isLoading(bool value){
    _isLoadingForgot = value;
    notifyListeners();
  }

  bool isValidForm(){
    return formForgotKey.currentState?.validate() ?? false;
  }

}