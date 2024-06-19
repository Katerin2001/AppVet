import 'package:flutter/material.dart';

// Importar autentificación
import 'autentificacion.dart';

class MyColors {
  static const Color colorPrimario = Color.fromARGB(250, 73, 212, 164);
  static const Color colorSecundario = Color.fromARGB(255, 0, 130, 89);
  static const Color colorTerciario = Color.fromARGB(255, 4, 43, 67);
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario', style: TextStyle(color: MyColors.colorPrimario, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView( // Envuelve el cuerpo con SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32),
                _buildTextField(
                  controller: nombreController,
                  labelText: 'Nombre',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: emailController,
                  labelText: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: passwordController,
                  labelText: 'Contraseña',
                  obscureText: true,
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirmar Contraseña',
                  obscureText: true,
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    _registerUser(context);
                  },
                  child: Text('Registrarse', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    primary: MyColors.colorPrimario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: MyColors.colorPrimario,
          ),
        ),
        labelStyle: TextStyle(color: MyColors.colorTerciario),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        return null;
      },
    );
  }

  //Funcion que usa el servicio de autentificacion para registrar un usuario
  void _registerUser(BuildContext context) {
    final _auth = AuthService();
    if (_formKey.currentState?.validate() ?? false) {
      // Registrar al usuario en Firebase
      _auth.registrarUsuario(
        nombreController.text,
        emailController.text,
        passwordController.text,
      );

      // Mostrar un diálogo de alerta al usuario
      _showSnackbar(context, 'Usuario registrado con éxito', MyColors.colorPrimario);
      Navigator.pop(context);
    }
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: color,
      ),
    );
  }
}
