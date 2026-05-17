import 'package:pakeeza_pos/data/database/database_helper.dart';
import 'package:pakeeza_pos/data/models/models.dart';

class MenuRepository {
  Future<List<CategoryModel>> getCategories() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('categories', orderBy: 'sort_order');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<ProductModel>> getProducts(int categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'sort_order',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<VariantModel>> getVariants(int productId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'variants',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'sort_order',
    );
    return rows.map(VariantModel.fromMap).toList();
  }
}
