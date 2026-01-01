import 'package:flutter/material.dart';
import 'homeadmin.dart';
import 'homeuser.dart';

// LOGIN PAGE (FRONTEND-ONLY, SAME AS NEWS APP)
class login extends StatefulWidget {
  const login({super.key});

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  final _form = GlobalKey<FormState>();

  String _enteredId = "";
  String _selectedRole = "user"; // default role

  void handleLogin() {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();

      // TEMP: frontend-only navigation (same as original project)
      if (_selectedRole == "admin") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homeadmin()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homeuser()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "The Book App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 96, 3, 119),
      ),
      body: Form(
        key: _form,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Welcome!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 96, 3, 119),
                  ),
                ),
                const SizedBox(height: 40),

                // ID FIELD
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Enter your ID",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredId = value!;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  "Choose your role:",
                  style: TextStyle(fontSize: 18),
                ),

                // ADMIN RADIO
                RadioListTile<String>(
                  title: const Text("Admin"),
                  value: "admin",
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),

                // USER RADIO
                RadioListTile<String>(
                  title: const Text("User"),
                  value: "user",
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // LOGIN BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 96, 3, 119),
                    padding:
                        const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: handleLogin,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
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
