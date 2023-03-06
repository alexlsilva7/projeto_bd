import 'package:flutter/material.dart';
import 'package:projeto_bd/app/core/components/drawer/main_drawer.dart';
import 'package:projeto_bd/app/features/pedido/controller/pedido_dao.dart';
import 'package:projeto_bd/app/features/pedido/model/pedido.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  List<Pedido> _pedidos = [];

  bool _isLoading = false;
  String msgSeed = '';
  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pedidos = await PedidoDao.getPedidos();
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      setState(() {
        _pedidos = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(routeName: '/pedidos'),
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'seed',
                child: Text('Seed'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('DROP *'),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'seed':
                  try {
                    var q = TextEditingController();
                    final quantidade = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Quantidade'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade',
                          ),
                          controller: q,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              final quantidade = int.tryParse(q.text) ?? 0;
                              Navigator.of(context).pop(quantidade);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    if (quantidade != null) {
                      setState(() {
                        _isLoading = true;
                      });
                      await PedidoDao.seed(quantidade, (msg) {
                        setState(() {
                          msgSeed = msg;
                        });
                      });
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                  _loadPedidos();
                  break;
                case 'clear':
                  try {
                    await PedidoDao.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                  _loadPedidos();
                  break;
              }
            },
          ),
          //add
          IconButton(
            onPressed: () async {
              Navigator.of(context)
                  .pushNamed(
                    '/add-pedido',
                  )
                  .then((value) => _loadPedidos());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(msgSeed),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _pedidos.length,
              itemBuilder: (context, index) {
                final pedido = _pedidos[index];
                return ListTile(
                  title: Text(
                    '${pedido.id} - ${pedido.modoEncomenda == ModoEncomenda.Retirada ? 'Retirada' : 'Entrega'}',
                  ),
                  subtitle: Text(
                      '${pedido.data.day}/${pedido.data.month}/${pedido.data.year}'),
                  onTap: () async {
                    Navigator.of(context)
                        .pushNamed(
                          '/pedido',
                          arguments: pedido,
                        )
                        .then((value) => _loadPedidos());
                  },
                );
              },
            ),
    );
  }
}
