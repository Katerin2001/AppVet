import 'package:flutter/material.dart';



//Bd Productos
import 'BdProductos.dart';


//Pantallas crud
import 'PantallasCRUD.dart';

class MyColors {
  static const Color colorPrimario = Color.fromARGB(250, 73, 212, 164);
  static const Color colorSecundario = Color.fromARGB(255, 0, 130, 89);
  static const Color colorTerciario = Color.fromARGB(255, 4, 43, 67);
  
}

class AdminScreen extends StatefulWidget {
  final String nombre;
  final String tipo;

  AdminScreen({required this.nombre, required this.tipo});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  
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
            child: ListView.builder(
              itemCount: _productosEncontrados.length,
              itemBuilder: (context, index) {
                return ProductoListItem(producto: _productosEncontrados[index]);
              },
            ),
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
                'Administrador',
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
          title: Text('Ingresar Elementos', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.colorTerciario)),
          trailing: Icon(Icons.add, color: MyColors.colorTerciario),
          onTap: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IngresoElementosScreen()),
            );
            
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
                //Color verde
                
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


class ProductoListItem extends StatelessWidget {
  final Map<String, dynamic> producto;

  ProductoListItem({required this.producto});

  @override
  Widget build(BuildContext context) {

    
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), 
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Color(0xffeaf1f1),
        ),
        child: ListTile(
          title: Row(
            children: [
              // Parte izquierda con la imagen
              Container(
                width: 80,
                height: 125,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(producto['ZImage'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
              ),
              // Espaciador entre la imagen y el texto
              SizedBox(width: 8),
              // Parte derecha con el nombre, precio y botones
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          '\$${producto['Precio'] ?? '-.--'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MyColors.colorTerciario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botones de edición y eliminación
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: MyColors.colorTerciario),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditarElementoScreen(producto: producto)),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      

                      _mostrarDialogoEliminarProducto(context, producto['id'], producto['Nombre']);



                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEliminarProducto(BuildContext context, String id, String nombre) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Producto'),
          content: Text('¿Estás seguro de que quieres eliminar el producto $nombre?'),
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
                

                ProductService productService = ProductService();
                productService.eliminarProducto(id);

                //Mostramos en la pantalla un mensaje de que se elimino el producto
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Se elimino el producto $nombre'),
                    duration: Duration(seconds: 3),
                    backgroundColor: MyColors.colorPrimario,
                  ),
                );
                
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
