import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

//Bd Productos
import 'BdProductos.dart';


class MyColors {
  static const Color colorPrimario = Color.fromARGB(250, 73, 212, 164);
  static const Color colorSecundario = Color.fromARGB(255, 0, 130, 89);
  static const Color colorTerciario = Color.fromARGB(255, 4, 43, 67);
  
}


class UsuarioScreen extends StatefulWidget {
  final String nombre;
  final String tipo;

  UsuarioScreen({required this.nombre, required this.tipo});

  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {

  
  List<Map<String, dynamic>> _productosEncontrados = [];

  @override
  void initState() {
    super.initState();
    // Realizar la carga inicial de productos de alimentos al iniciar la pantalla
    _cargarProductos('Alimentos');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
      children: [
        
        Text(
          'VeterinariAPP',
          style: TextStyle(
            color: MyColors.colorPrimario,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Icon(
          Icons.pets,
          color: MyColors.colorPrimario,
        ),
        
      ],
    ),
      ),
      drawer: Drawer(
        child: DrawerContent(nombre: widget.nombre),
      ),
      body: Column(
        children: [
          BuscadorYFiltros(
            onProductosEncontrados: (productos) {
              setState(() {
                _productosEncontrados = productos;
              });
            },
          ),
          Expanded(
            child: ProductosGrid(productos: _productosEncontrados),
          ),
        ],
      ),
    );
  }

  // Función para cargar productos según el filtro
  void _cargarProductos(String filtro) async {
    ProductService productService = ProductService();
    List<Map<String, dynamic>>? encontrados = await productService.searchProducts('', filtro);

    // Actualizamos el estado de la lista de productos encontrados
    setState(() {
      _productosEncontrados = encontrados ?? [];
    });
  }
}

class DrawerContent extends StatelessWidget {
  final String nombre;
  final Uri _url =
      Uri.parse('https://api.whatsapp.com/send/?phone=593979310095&text=Hola,%20Me%20gustaria%20comprar%20algo%20en%20su%20veterinaria');

  DrawerContent({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: MyColors.colorPrimario,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                nombre,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Espacio
              SizedBox(height: 10),
              Text(
                'Cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
        ListTile(
          title: Text(
            'Ver productos',
            style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.colorTerciario),
          ),
          onTap: () {
           
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('Escribenos', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.colorPrimario)),
          trailing: Icon(Icons.message, color: MyColors.colorPrimario), 
          onTap: () {
            
            _launchUrl();
          },
        ),
        ListTile(
          title: Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          trailing: Icon(Icons.exit_to_app, color: Colors.red),
          onTap: () {
            _mostrarDialogoCerrarSesion(context);
          },
        ),
      ],
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _mostrarDialogoCerrarSesion(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Cierra el diálogo
                Navigator.of(context).pop();
                
                
              },
              child: Text('Cancelar', style: TextStyle(color: MyColors.colorPrimario)),
            ),
            TextButton(
              onPressed: () {
                
                Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}




class BuscadorYFiltros extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onProductosEncontrados;
  

  BuscadorYFiltros({required this.onProductosEncontrados});

  @override
  _BuscadorYFiltrosState createState() => _BuscadorYFiltrosState();
}

class _BuscadorYFiltrosState extends State<BuscadorYFiltros> {
  String _filtroSeleccionado = 'Alimentos';
  String _PalabraBuscada = '';
  final TextEditingController _searchController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Buscador
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: MyColors.colorPrimario,
                ),
                
              ),
              hintText: 'Buscar productos...',
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: MyColors.colorPrimario),
                onPressed: () {
                  _PalabraBuscada = _searchController.text;
                  _buscarProductos();
                },
              ),
              labelStyle: TextStyle(color: MyColors.colorTerciario),
            ),
          ),
          SizedBox(height: 16),
          // Botones de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFiltroButton('Alimentos',MyColors.colorPrimario),
                _buildFiltroButton('Accesorios', MyColors.colorPrimario),
                _buildFiltroButton('Higiene', MyColors.colorPrimario),
                _buildFiltroButton('Medicamentos', MyColors.colorPrimario),
                _buildFiltroButton('Doctores', MyColors.colorPrimario),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroButton(String text, Color color) {
    bool isSelected = _filtroSeleccionado == text;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _filtroSeleccionado = text;
            _buscarProductos();

          }
          
          );
        },
        style: ElevatedButton.styleFrom(
          primary: isSelected ? color : Color.fromARGB(255, 192, 194, 194),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  //Funcion que usara el boton de buscar para filtrar los productos dado el filtro seleccionado y la palabra buscada
  void _buscarProductos() async {
  //print('Buscando productos con filtro $_PalabraBuscada y tipo $_filtroSeleccionado');

  ProductService productService = ProductService();
  List<Map<String, dynamic>>? encontrados = await productService.searchProducts(_PalabraBuscada,_filtroSeleccionado);

  //Actualizamos el estado de la lista de productos encontrados
  setState(() {
    
    widget.onProductosEncontrados(encontrados ?? []);
  });
  
}
}

class ProductosGrid extends StatelessWidget {
  final List<Map<String, dynamic>> productos;

  ProductosGrid({required this.productos});

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.colorTerciario),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        return ProductoWidget(producto: productos[index]);
      },
    );
  }
}


class ProductoWidget extends StatelessWidget {
  final Map<String, dynamic> producto;

  ProductoWidget({required this.producto});

  @override
  Widget build(BuildContext context) {

    

   return Card(
  elevation: 4.0,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Flexible(
        flex: 2,
        child: Container(
          
          decoration: BoxDecoration(
            color: Color(0xffeaf1f1),
            image: DecorationImage(
              image: NetworkImage(producto['ZImage'] ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: MyColors.colorPrimario,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                producto['Nombre'] ?? 'Nombre del producto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  color: MyColors.colorTerciario,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Precio:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MyColors.colorTerciario,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '\$${producto['Precio'] ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 14,
                      
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);



  }
}
