import 'package:faker_dart/faker_dart.dart';
import 'package:projeto_bd/app/core/helpers/db_helper.dart';
import 'package:projeto_bd/app/features/cliente/controller/cliente_dao.dart';
import 'package:projeto_bd/app/features/pedido/controller/produto_pedido_dao.dart';
import 'package:projeto_bd/app/features/pedido/model/pedido.dart';
import 'package:projeto_bd/app/features/produto/controller/produto_dao.dart';
import 'package:projeto_bd/app/features/produto/model/produto.dart';

class PedidoDao {
  static Future<List<Pedido>> getPedidos() async {
    final conn = await DbHelper.getConnection();
    final results = await conn.query('SELECT * FROM Pedido');
    final pedidos = results
        .map((row) => Pedido(
              id: row['id'],
              data: row['data'],
              modoEncomenda: row['modoEncomenda'] == 'Retirada'
                  ? ModoEncomenda.Retirada
                  : ModoEncomenda.Entrega,
              status: row['status'] == 'Em preparação'
                  ? Status.emPreparacao
                  : row['status'] == 'Em transporte'
                      ? Status.emTransporte
                      : row['status'] == 'Entregue'
                          ? Status.entregue
                          : row['status'] == 'Aguardando pagamento'
                              ? Status.aguardandoPagamento
                              : Status.pagamentoConfirmado,
              prazoEntrega: row['prazoEntrega'],
              clienteId: row['clienteId'],
            ))
        .toList();

    for (var pedido in pedidos) {
      pedido.produtosPedido = await ProdutoPedidoDAO.getProdutosPedido(pedido);
    }

    await conn.close();
    return pedidos;
  }

  static Future<int?> addPedido(Pedido pedido) async {
    final conn = await DbHelper.getConnection();
    final result = await conn.query(
      'INSERT INTO Pedido (data, modoEncomenda, status, prazoEntrega, clienteId) VALUES (?, ?, ?, ?, ?)',
      [
        pedido.data.toUtc(),
        pedido.modoEncomenda == ModoEncomenda.Retirada ? 'Retirada' : 'Entrega',
        pedido.status == Status.emPreparacao
            ? 'Em preparação'
            : pedido.status == Status.emTransporte
                ? 'Em transporte'
                : pedido.status == Status.entregue
                    ? 'Entregue'
                    : pedido.status == Status.pagamentoConfirmado
                        ? 'Pagamento confirmado'
                        : 'Aguardando pagamento',
        pedido.prazoEntrega.toUtc(),
        pedido.clienteId,
      ],
    );
    final id = result.insertId;
    await conn.close();
    return id;
  }

  static Future<int?> updatePedido(Pedido pedido) async {
    final conn = await DbHelper.getConnection();
    final result = await conn.query(
      'UPDATE Pedido SET data = ?, modoEncomenda = ?, status = ?, prazoEntrega = ?, clienteId = ? WHERE id = ?',
      [
        pedido.data.toUtc(),
        pedido.modoEncomenda == ModoEncomenda.Retirada ? 'Retirada' : 'Entrega',
        pedido.status == Status.emPreparacao
            ? 'Em preparação'
            : pedido.status == Status.emTransporte
                ? 'Em transporte'
                : pedido.status == Status.entregue
                    ? 'Entregue'
                    : pedido.status == Status.pagamentoConfirmado
                        ? 'Pagamento confirmado'
                        : 'Aguardando pagamento',
        pedido.prazoEntrega.toUtc(),
        pedido.clienteId,
        pedido.id,
      ],
    );

    for (var produtoPedido in pedido.produtosPedido!) {
      await ProdutoPedidoDAO.updateProdutoPedido(produtoPedido);
    }

    final rowsAffected = result.affectedRows;
    await conn.close();
    return rowsAffected;
  }

  static Future<Pedido?> getPedido(int id) async {
    final conn = await DbHelper.getConnection();
    final results = await conn.query(
      'SELECT * FROM Pedido WHERE id = ?',
      [id],
    );
    final pedidos = results
        .map((row) => Pedido(
              id: row['id'],
              data: DateTime.parse(row['data']).toLocal(),
              modoEncomenda: row['modoEncomenda'] == 'Retirada'
                  ? ModoEncomenda.Retirada
                  : ModoEncomenda.Entrega,
              status: row['status'] == 'Em preparação'
                  ? Status.emPreparacao
                  : row['status'] == 'Em transporte'
                      ? Status.emTransporte
                      : row['status'] == 'Entregue'
                          ? Status.entregue
                          : row['status'] == 'Aguardando pagamento'
                              ? Status.aguardandoPagamento
                              : Status.pagamentoConfirmado,
              prazoEntrega: DateTime.parse(row['prazoEntrega']).toLocal(),
              clienteId: row['clienteId'],
            ))
        .toList();

    await conn.close();

    final pedido = pedidos.isEmpty ? null : pedidos.first;

    if (pedido != null) {
      pedido.produtosPedido = await ProdutoPedidoDAO.getProdutosPedido(pedido);
    }
    return pedido;
  }

  static Future<int?> deletePedido(int id) async {
    final conn = await DbHelper.getConnection();

    final result = await conn.query(
      'DELETE FROM Pedido WHERE id = ?',
      [id],
    );
    final rowsAffected = result.affectedRows;
    await conn.close();
    return rowsAffected;
  }

  static Future<void> seed(
      int quantidade, void Function(String) onProgress) async {
    Faker faker = Faker.instance;
    faker.setLocale(FakerLocaleType.pt_BR);
    onProgress('Obtendo clientes');
    final clientes = await ClienteDao.getClientes();
    final conn = await DbHelper.getConnection();

    for (var i = 0; i < quantidade; i++) {
      final data = faker.date.between(
        DateTime(2015, 1, 1),
        DateTime(2027, 12, 12),
      );
      final modoEncomenda = faker.datatype.boolean()
          ? ModoEncomenda.Retirada
          : ModoEncomenda.Entrega;
      final status = faker.datatype.boolean()
          ? Status.emPreparacao
          : faker.datatype.boolean()
              ? Status.emTransporte
              : faker.datatype.boolean()
                  ? Status.entregue
                  : faker.datatype.boolean()
                      ? Status.aguardandoPagamento
                      : Status.pagamentoConfirmado;
      final prazoEntrega = data.add(const Duration(days: 3));

      final clienteId =
          clientes[faker.datatype.number(min: 0, max: clientes.length - 1)].id!;
      onProgress('Criando pedido $i de $quantidade');
      await conn.query(
        'INSERT INTO Pedido (data, modoEncomenda, status, prazoEntrega, clienteId) VALUES (?, ?, ?, ?, ?)',
        [
          data.toUtc(),
          modoEncomenda == ModoEncomenda.Retirada ? 'Retirada' : 'Entrega',
          status == Status.emPreparacao
              ? 'Em Preparação'
              : status == Status.emTransporte
                  ? 'Em Transporte'
                  : status == Status.entregue
                      ? 'Entregue'
                      : status == Status.aguardandoPagamento
                          ? 'Aguardando Pagamento'
                          : 'Pagamento Confirmado',
          prazoEntrega.toUtc(),
          clienteId,
        ],
      );
    }
    onProgress('Obtendo pedidos');
    final pedidos = await PedidoDao.getPedidos();
    onProgress('Obtendo produtos');
    final produtos = await ProdutoDao.getProdutos();

    for (var pedido in pedidos) {
      List<Produto> produtosPedido = [];
      final quantidadeProdutos = faker.datatype.number(min: 1, max: 5);
      for (var i = 0; i < quantidadeProdutos; i++) {
        final produto = produtos[faker.datatype.number(
          min: 0,
          max: produtos.length - 1,
        )];
        if (produtosPedido.contains(produto)) {
          i--;
          continue;
        }
      }

      for (var i = 0; i < quantidadeProdutos; i++) {
        onProgress(
            'Criando produto pedido $i de $quantidadeProdutos para o pedido ${pedido.id}');
        final produto = produtosPedido.removeAt(faker.datatype.number(
          min: 0,
          max: produtosPedido.length - 1,
        ));
        final quantidade = faker.datatype.number(min: 1, max: 10);
        await conn.query(
          'INSERT INTO ProdutoPedido (pedidoId, produtoId, quantidade, precoVendaProduto) VALUES (?, ?, ?, ?)',
          [
            pedido.id,
            produto.id,
            quantidade,
            produto.precoVenda,
          ],
        );
      }
    }
    await conn.close();
  }

  static Future<void> clear() async {
    final conn = await DbHelper.getConnection();
    await conn.query('DELETE FROM ProdutoPedido');
    await conn.query('DELETE FROM Pedido');
    await conn.close();
  }

  static Future<int> count() async {
    final conn = await DbHelper.getConnection();
    final result = await conn.query('SELECT COUNT(*) FROM Pedido');
    final count = result.first.values!.first as int;
    await conn.close();
    return count;
  }
}
