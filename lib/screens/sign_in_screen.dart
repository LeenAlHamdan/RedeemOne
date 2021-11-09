// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redeem_one/models/http_exception.dart';
import 'package:redeem_one/providers/user_provider.dart';
import 'package:redeem_one/screens/rest_password_screen.dart';
import 'package:redeem_one/screens/sign_up_screen.dart';
import 'package:redeem_one/screens/user_screen.dart';

import '../widgets/error_dialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signIn';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  var _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();

    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> submitData(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please Fill All Information'),
            duration: Duration(seconds: 2)),
      );
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please Fill All Information'),
            duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .signIn(email, password);
      // print('object');
      Navigator.of(context).pushReplacementNamed(UserScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      showErrorDialog(errorMessage, context);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> google() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .signInWithGoogle();
      Navigator.of(context).pushReplacementNamed(UserScreen.routeName);
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      showErrorDialog(errorMessage, context);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          color: Theme.of(context).backgroundColor,
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Loading...",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                  ],
                ),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //header
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: const CircleAvatar(
                          radius: 150,
                          backgroundColor: Colors.white,
                          child: FittedBox(
                            child: Text(
                              'Welcome to RedeemOne',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      //email
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            labelText: 'email',
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_passwordFocusNode),
                          autofocus: true,
                        ),
                      ),
                      //password
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          obscureText: true,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          onSubmitted: (_) => submitData(context),
                          autofocus: true,
                        ),
                      ),
                      //forget password
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushNamed(RestPasswordScreen.routeName),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(left: 8),
                          child: const Text(
                            'Forget Password ?',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      //login
                      Container(
                        width: double.infinity,
                        height: 75,
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () => submitData(context),
                          child: const Text('Log In'),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            onPrimary: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      //sign in with google
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(left: 8),
                        alignment: Alignment.center,
                        child: const Text(
                          'or sign in with',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      GestureDetector(
                        onTap: google,
                        child: Center(
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: //FittedBox(
                                  // child:
                                  Image.asset('assets/images/google.png')),
                          // ),
                        ),
                      ),
                      //open sign up
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed(SignUpScreen.routeName),
                              child: Text(
                                ' Sign Up',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
