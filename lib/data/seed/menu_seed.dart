import 'package:sqflite/sqflite.dart';

/// Seeds the full Pakeeza menu from the restaurant flyer.
Future<void> seedMenuIfNeeded(Database db) async {
  final row = await db.query(
    'meta',
    where: 'key = ?',
    whereArgs: ['menu_seeded'],
    limit: 1,
  );
  if (row.isNotEmpty) return;

  await db.transaction((txn) async {
    final batch = txn.batch();

    final categories = [
      {'id': 1, 'name': 'Special Flavours', 'sort_order': 1},
      {'id': 2, 'name': 'Classic Flavours', 'sort_order': 2},
      {'id': 3, 'name': 'Regular Pizza', 'sort_order': 3},
      {'id': 4, 'name': 'Burgers', 'sort_order': 4},
      {'id': 5, 'name': 'Paratha Roll / Shawarma', 'sort_order': 5},
      {'id': 6, 'name': 'Crispy Chicken', 'sort_order': 6},
      {'id': 7, 'name': 'Others', 'sort_order': 7},
      {'id': 8, 'name': 'Snacks', 'sort_order': 8},
    ];
    for (final c in categories) {
      batch.insert('categories', c);
    }

    var productId = 1;

    void addProduct(int categoryId, String name, int sortOrder) {
      batch.insert('products', {
        'id': productId,
        'category_id': categoryId,
        'name': name,
        'sort_order': sortOrder,
      });
    }

    void addVariant(String name, int price, int sortOrder) {
      batch.insert('variants', {
        'product_id': productId,
        'name': name,
        'price': price,
        'sort_order': sortOrder,
      });
    }

    void nextProduct() => productId++;

    void addPizzas(
      int categoryId,
      List<String> names,
      List<Map<String, int>> sizes,
    ) {
      for (var i = 0; i < names.length; i++) {
        addProduct(categoryId, names[i], i);
        for (var j = 0; j < sizes.length; j++) {
          addVariant(sizes[j].keys.first, sizes[j].values.first, j);
        }
        nextProduct();
      }
    }

    addPizzas(1, [
      'Pakeeza Special Pizza',
      'Cheese sp. Kabab Pizza',
      'Crown Crust Pizza',
      'Kabab Crust Pizza',
      'Malai Boti Pizza',
      'Boxe Fire Pizza',
    ], [
      {'Small': 1100},
      {'Medium': 1100},
      {'Large': 1400},
    ]);

    addPizzas(2, [
      'Creamy Pizza',
      'Behari Pizza',
      'Nawabi Pizza',
      'Pesi-Pesi Pizza',
      'Bar-B.Q Pizza',
    ], [
      {'Small': 500},
      {'Medium': 1000},
      {'Large': 1200},
    ]);

    addPizzas(3, [
      'Tikka Pizza',
      'Fajita Pizza',
      'Hot & Spicy Pizza',
      'Supreme Pizza',
      'Vegetable Pizza',
    ], [
      {'Small': 450},
      {'Large': 1100},
    ]);

    final burgers = [
      ('Pakeeza sp. Burger', 500),
      ('Tawes Burger', 450),
      ('Zinger Burger', 350),
      ('Mighty Burger', 400),
    ];
    for (var i = 0; i < burgers.length; i++) {
      addProduct(4, burgers[i].$1, i);
      addVariant('Regular', burgers[i].$2, 0);
      nextProduct();
    }

    final rolls = [
      ('Chicken Paratha Roll', 250),
      ('Kabab Paratha Roll', 350),
      ('Zinger Paratha Roll', 350),
      ('Malai Boti Roll', 350),
      ('Chicken Shawarma', 300),
    ];
    for (var i = 0; i < rolls.length; i++) {
      addProduct(5, rolls[i].$1, i);
      addVariant('Regular', rolls[i].$2, 0);
      nextProduct();
    }

    final crispy = <(String, List<(String, int)>)>[
      ('Hot Wings', [('Regular', 300), ('Large', 500)]),
      ('Bar-B.Q Wings', [('Regular', 350), ('Large', 600)]),
      ('Drum Sticks', [('Regular', 350)]),
      ('Leg Piece', [('Regular', 400), ('Large', 600)]),
      ('Sandwich sp.', [('Regular', 400)]),
    ];
    for (var i = 0; i < crispy.length; i++) {
      addProduct(6, crispy[i].$1, i);
      for (var j = 0; j < crispy[i].$2.length; j++) {
        addVariant(crispy[i].$2[j].$1, crispy[i].$2[j].$2, j);
      }
      nextProduct();
    }

    final others = <(String, List<(String, int)>)>[
      ('Simple Fries', [('Small', 200), ('Large', 300)]),
      ('Loaded Fries', [('Small', 300), ('Large', 450)]),
      ('Special Pasta', [('Small', 400), ('Large', 600)]),
      ('Macsoni', [('Small', 250), ('Large', 400)]),
      ('Sandwich sp. (Others)', [('Regular', 400)]),
    ];
    for (var i = 0; i < others.length; i++) {
      addProduct(7, others[i].$1, i);
      for (var j = 0; j < others[i].$2.length; j++) {
        addVariant(others[i].$2[j].$1, others[i].$2[j].$2, j);
      }
      nextProduct();
    }

    addProduct(8, 'Snacks', 0);
    addVariant('Regular', 150, 0);
    addVariant('Large', 250, 1);
    nextProduct();

    batch.insert('meta', {'key': 'menu_seeded', 'value': '1'});
    await batch.commit(noResult: true);
  });
}

Future<void> seedDefaultSettings(Database db) async {
  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM settings'),
  );
  if ((count ?? 0) > 0) return;

  final defaults = {
    'shop_name': 'Pakeeza Fast Food & Pizza Point',
    'shop_address': 'Main Gogran Road, Qasim Walla Gogran',
    'shop_phones': '0309-5801055 / 0301-6036024 / 0303-7202125',
    'receipt_footer': 'Thank you — Visit again!',
  };
  final batch = db.batch();
  defaults.forEach((key, value) {
    batch.insert('settings', {'key': key, 'value': value});
  });
  await batch.commit(noResult: true);
}
