import 'package:flutter/material.dart';

class RegisterFormProvider extends ChangeNotifier{

  GlobalKey<FormState> formKeyRegister = new GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm(){
    return formKeyRegister.currentState?.validate() ?? false;
  }

}

class Register2FormProvider extends ChangeNotifier{

  GlobalKey<FormState> formKeyRegister2 = new GlobalKey<FormState>();

  String nombre = '';
  String apellido = '';
  String edad = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm(){
    return formKeyRegister2.currentState?.validate() ?? false;
  }

}