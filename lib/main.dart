import 'package:flutter/material.dart';
import 'package:projeto_bd/app/core/helpers/theme_helper.dart';
import 'package:projeto_bd/app/core/view/home_screen.dart';
import 'package:projeto_bd/app/features/armazem/model/armazem.dart';
import 'package:projeto_bd/app/features/armazem/view/armazem_form.dart';
import 'package:projeto_bd/app/features/armazem/view/armazens_screen.dart';
import 'package:projeto_bd/app/features/categoria/model/categoria.dart';
import 'package:projeto_bd/app/features/categoria/view/categoria_form.dart';
import 'package:projeto_bd/app/features/categoria/view/categorias_screen.dart';
import 'package:projeto_bd/app/features/cliente/model/cliente.dart';
import 'package:projeto_bd/app/features/cliente/view/cliente_form.dart';
import 'package:projeto_bd/app/features/cliente/view/clientes_screen.dart';
import 'package:projeto_bd/app/features/fornecedor/model/fornecedor.dart';
import 'package:projeto_bd/app/features/fornecedor/view/fornecedor_form.dart';
import 'package:projeto_bd/app/features/fornecedor/view/fornecedores_screen.dart';
import 'package:projeto_bd/app/features/pedido/view/pedidos_screen.dart';
import 'package:projeto_bd/app/features/produto/model/produto.dart';
import 'package:projeto_bd/app/features/produto/view/produto_view.dart';
import 'package:projeto_bd/app/features/produto/view/produtos_screen.dart';
import 'package:projeto_bd/app/features/produto/view/produto_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: ThemeHelper.instance,
        builder: (context, child) {
          return MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/add-product': (context) => const ProdutoForm(),
              '/edit-product': (context) => ProdutoForm(
                  produto:
                      ModalRoute.of(context)!.settings.arguments as Produto),
              '/home': (context) => const HomeScreen(),
              '/produtos': (context) => const ProdutosScreen(),
              '/fornecedores': (context) => const FornecedoresScreen(),
              '/add-fornecedor': (context) => const FornecedorForm(),
              '/edit-fornecedor': (context) => FornecedorForm(
                  fornecedor:
                      ModalRoute.of(context)!.settings.arguments as Fornecedor),
              '/categorias': (context) => const CategoriasScreen(),
              '/add-categoria': (context) => const CategoriaForm(),
              '/edit-categoria': (context) => CategoriaForm(
                  categoria:
                      ModalRoute.of(context)!.settings.arguments as Categoria),
              '/produto-view': (context) => ProdutoView(
                  id: ModalRoute.of(context)!.settings.arguments as int),
              '/armazens': (context) => const ArmazensScreen(),
              '/add-armazem': (context) => const ArmazemForm(),
              '/edit-armazem': (context) => ArmazemForm(
                  armazem:
                      ModalRoute.of(context)!.settings.arguments as Armazem),
              '/clientes': (context) => const ClientesScreen(),
              '/add-cliente': (context) => const ClienteForm(),
              '/edit-cliente': (context) => ClienteForm(
                  cliente:
                      ModalRoute.of(context)!.settings.arguments as Cliente),
              '/pedidos': (context) => const PedidosScreen(),
            },
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
              brightness: ThemeHelper.instance.darkMode
                  ? Brightness.dark
                  : Brightness.light,
              // inputDecorationTheme: InputDecorationTheme(
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(10),
              //     borderSide: const BorderSide(color: Colors.deepPurple),
              //   ),
              // ),
            ),
          );
        });
  }
}
