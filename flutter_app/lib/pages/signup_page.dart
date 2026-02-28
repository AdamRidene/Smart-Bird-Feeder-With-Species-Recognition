import 'package:flutter/material.dart';
import '../services/esp_api.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void signupUser() async {
    setState(() => loading = true);

    final res = await EspApi.signup(
      emailController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (res["status"] == "success") {
      Navigator.pushReplacementNamed(context, "/login");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"].toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : signupUser,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
