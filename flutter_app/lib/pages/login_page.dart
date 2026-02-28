import 'package:flutter/material.dart';
import '../services/esp_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void loginUser() async {
    setState(() => loading = true);

    final res = await EspApi.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (res["status"] == "success") {
      Navigator.pushReplacementNamed(context, "/dashboard");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"].toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
              onPressed: loading ? null : loginUser,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/signup"),
              child: Text("Create an account"),
            )
          ],
        ),
      ),
    );
  }
}
