import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa el paquete para utilizar TextInputFormatter
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Importar Productos
import 'BdProductos.dart';

class MyColors {
  static const Color colorPrimario = Color.fromARGB(250, 73, 212, 164);
  static const Color colorSecundario = Color.fromARGB(255, 0, 130, 89);
  static const Color colorTerciario = Color.fromARGB(255, 4, 43, 67);
}

class IngresoElementosScreen extends StatefulWidget {
  @override
  _IngresoElementosScreenState createState() => _IngresoElementosScreenState();
}

class _IngresoElementosScreenState extends State<IngresoElementosScreen> {
  String _tipo = 'Alimentos'; // Valor por defecto
  File? _imagen;

  TextEditingController _nombreController = TextEditingController();
  TextEditingController _precioController = TextEditingController();

  final ProductService _productService = ProductService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Referencia a BdProductos

  Future<void> _getImage() async {
  try {
    final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  } catch (e) {
    print('Error al seleccionar la imagen: $e');
  }
}

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _tipo = 'Alimentos';
      _precioController.clear();
      _imagen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingresar Datos',
          style: TextStyle(
            color: MyColors.colorPrimario,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 25),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.colorPrimario,
                      ),
                    ),
                    labelStyle: TextStyle(color: MyColors.colorTerciario),
                  ),
                  onChanged: (value) {
                    // No es necesario actualizar el controlador manualmente aquí
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),
                DropdownButtonFormField(
                  value: _tipo,
                  onChanged: (value) {
                    setState(() {
                      _tipo = value.toString();
                    });
                  },
                  items: ['Alimentos','Accesorios', 'Higiene', 'Medicamentos', 'Doctores'].map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    hoverColor: MyColors.colorPrimario,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.colorPrimario,
                      ),
                    ),
                    labelStyle: TextStyle(color: MyColors.colorTerciario),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioController,
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: MyColors.colorPrimario,
                            ),
                          ),
                          labelStyle: TextStyle(color: MyColors.colorTerciario),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                        ],
                        onChanged: (value) {
                          // No es necesario actualizar el controlador manualmente aquí
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un precio';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _getImage,
                      child: Text('Seleccionar Imagen', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: MyColors.colorPrimario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _limpiarFormulario,
                  child: Text('Limpiar', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _imagen != null) {
                      // Validar que la imagen se haya seleccionado
                      // Validar que el campo de precio sea un número
                      if (double.tryParse(_precioController.text) == null) {
                        // Mostrar un mensaje de error si el campo de precio no es un número
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Por favor, ingrese un valor numérico para el precio'),
                          ),
                        );
                        return;
                      }

                     

                      final imagenTemporal = File(_imagen!.path);


                      

                      
                      // Agregar el producto a la base de datos
                      await _productService.agregarProducto(
                        _nombreController.text,
                        _tipo,
                        _precioController.text,
                        imagenTemporal,
                      );

                      _limpiarFormulario();

                      // Mostrar un mensaje de éxito en verde en la parte inferior de la pantalla
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Producto agregado con éxito'),
                          backgroundColor: MyColors.colorPrimario,
                        ),
                      );

                      
                    } else {
                      // Mostrar un mensaje de error indicando que la imagen es obligatoria
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, selecciona una imagen'),
                        ),
                      );
                    }
                  },
                  child: Text('Enviar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(primary: MyColors.colorPrimario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//Pantalla para editar Recibo Nombre , Precio y Tipo y el Id del producto


class EditarElementoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  EditarElementoScreen({required this.producto});

  @override
  _EditarElementoScreenState createState() => _EditarElementoScreenState();
}

class _EditarElementoScreenState extends State<EditarElementoScreen> {
  String _nombre = '';
  String _tipo = '';
  String _precio = '';
  String _id = '';
  late TextEditingController _nombreController;
  late TextEditingController _precioController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _nombre = widget.producto['Nombre'];
    _tipo = widget.producto['Tipo'];
    _precio = widget.producto['Precio'].toString();
    _id = widget.producto['id'];
    _nombreController = TextEditingController(text: _nombre);
    _precioController = TextEditingController(text: _precio);
  }

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _precioController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Producto',
          style: TextStyle(
            color: MyColors.colorPrimario,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 25),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.colorPrimario,
                      ),
                    ),
                    labelStyle: TextStyle(color: MyColors.colorTerciario),
                  ),
                  onChanged: (value) {
                    
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),
                DropdownButtonFormField(
                  value: _tipo,
                  onChanged: (value) {
                    setState(() {
                      _tipo = value.toString();
                    });
                  },
                  items: ['Alimentos','Accesorios', 'Higiene', 'Medicamentos', 'Doctores'].map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    hoverColor: MyColors.colorPrimario, 
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.colorPrimario,
                      ),
                    ),
                    labelStyle: TextStyle(color: MyColors.colorTerciario),
                  ),
                ),
                SizedBox(height: 25),
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.colorPrimario, // Puedes ajustar el color según tus preferencias
                      ),
                    ),
                    labelStyle: TextStyle(color: MyColors.colorTerciario),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  onChanged: (value) {
                    
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un precio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _limpiarFormulario,
                  child: Text('Limpiar', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Validar que el campo de precio sea un número
                      if (double.tryParse(_precioController.text) == null) {
                        // Mostrar un mensaje de error si el campo de precio no es un número
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Por favor, ingrese un valor numérico para el precio'),
                          ),
                        );
                        return;
                      }

                      
                      await _productService.editarProducto(
                        
                        _nombreController.text,
                        _tipo,
                        _precioController.text,
                        _id,
                      );

                      // Mostrar un mensaje de éxito en verde en la parte inferior de la pantalla
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Producto editado con éxito'),
                          backgroundColor: MyColors.colorPrimario, // Puedes ajustar el color según tus preferencias
                        ),
                      );

                      
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(primary: MyColors.colorPrimario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
