import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase_options
import 'firebase_options.dart';

// Importar autentificacion
import 'autentificacion.dart';

// Importar la pantalla de usuario
import 'UsuarioPantalla.dart';

// Importar la pantalla de administrador
import 'AdministradorPantalla.dart';

//importar pantalla de registro
import 'RegistrarUsuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}


//Clase para guardar los colores de la aplicacion
class MyColors {
  static const Color colorPrimario = Color.fromARGB(250, 73, 212, 164);
  static const Color colorSecundario = Color.fromARGB(255, 0, 130, 89);
  static const Color colorTerciario = Color.fromARGB(255, 4, 43, 67);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeterinariAPP',
      // Theme
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: MyColors.colorPrimario,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Quitar banner de debug
      debugShowCheckedModeBanner: false,
      home: MyLoginPage(),
    );
  }
}


//Clase para la pantalla de inicio de sesion
class MyLoginPage extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('./assets/LogoInicio.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(35.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: MyColors.colorPrimario,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  LoginForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService(); // Instancia del servicio de autenticación
  
  

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: MyColors.colorPrimario,
                ),
              ),
              labelStyle: TextStyle(color: MyColors.colorTerciario),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: MyColors.colorPrimario,
                ),
              ),
              labelStyle: TextStyle(color: MyColors.colorTerciario),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: MyColors.colorPrimario,
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: () async {
              String username = _usernameController.text.trim();
              String password = _passwordController.text.trim();

              // Llamada a la función de autenticación
              Map<String, String>? userData =
                  await _auth.signInWithCredentials(username, password);

              if (userData != null) {
                // Credenciales válidas
                _showSnackbar(context, "Inicio de Sesion Exitoso", MyColors.colorPrimario);
                
                //Borrar los campos de texto
                _usernameController.clear();
                _passwordController.clear();

                // Navegar a la segunda pantalla enviando los datos de usuario o administrador

                if (userData['tipo'] == 'Admin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminScreen(
                        nombre: userData['nombre']!,
                        tipo: userData['tipo']!,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsuarioScreen(
                        nombre: userData['nombre']!,
                        tipo: userData['tipo']!,
                      ),
                    ),
                  );
                }
              } else {
                // Credenciales inválidas o error
                // Mostrar un mensaje de error en la pantalla que se desvanece después de unos segundos
                _showSnackbar(context, "Error al iniciar sesión", Color.fromARGB(255, 152, 153, 153));
                
              }
            },
            child: Text(
              'Ingresar',
              style: TextStyle(
                color: Colors.white,
                
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: MyColors.colorPrimario,
              padding: EdgeInsets.symmetric(horizontal: 75, vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(),
                ),
              );
              
            },
            child: Text(
              '¿No tienes una cuenta? Registrate aquí',
              style: TextStyle(
                color: MyColors.colorPrimario,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: MyColors.colorPrimario,
              ),
            ),
          ),
        ],
      ),
    );
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
