import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String defaultDatabaseName = 'gopher_eye.db';
  static Future<void> initDatabase(
      {String databaseName = defaultDatabaseName}) async {
    String databasePath = join(await getDatabasesPath(), databaseName);
    await openDatabase(databasePath, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE images (
          id TEXT PRIMARY KEY,
          image_file_path TEXT,
          status TEXT NOT NULL
        )
      ''');
    } catch (e) {
      debugPrint('Failed to create "images" table: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE masks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image_id TEXT NOT NULL,
          FOREIGN KEY (image_id) REFERENCES images (id)
        )
      ''');
    } catch (e) {
      debugPrint('Failed to create "masks" table: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE mask_points (
          mask_id INTEGER NOT NULL,
          path_order INTEGER NOT NULL,
          x REAL NOT NULL,
          y REAL NOT NULL,
          FOREIGN KEY (mask_id) REFERENCES masks (id)
        )
      ''');
    } catch (e) {
      debugPrint('Failed to create "mask_points" table: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE bounding_boxes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image_id TEXT NOT NULL,
          FOREIGN KEY (image_id) REFERENCES images (id)
        )
      ''');
    } catch (e) {
      debugPrint('Failed to create "bounding_boxes" table: $e');
    }

    try {
      await db.execute('''
        CREATE TABLE bounding_box_corners (
          bounding_box_id TEXT NOT NULL,
          x1 REAL NOT NULL,
          y1 REAL NOT NULL,
          x2 REAL NOT NULL,
          y2 REAL NOT NULL,
          FOREIGN KEY (bounding_box_id) REFERENCES bounding_boxes (bounding_box_id)
        )
      ''');
    } catch (e) {
      debugPrint('Failed to create "bounding_box_corners" table: $e');
    }
  }

  static Future<void> insertImage(ImageData image,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    await database.insert(
        'images',
        {
          'id': image.id,
          'image_file_path': image.image,
          'status': image.status
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

      await insertMasks(image.id!, image.masks ?? [], databaseName: databaseName);
      await insertBoundingBoxes(image.id!, image.boundingBoxes ?? [], databaseName: databaseName);
  }

  static Future<void> insertMasks(String imageId, List<List<double>> masks,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    try {
      for (List<double> mask in masks) {
        int maskId = await database.insert('masks', {'image_id': imageId});
        database = await openDatabase(dbPath);
        for (int i = 0; i < mask.length; i += 2) {
          await database.insert(
              'mask_points',
              {
                'mask_id': maskId,
                'path_order': (i ~/ 2) + 1,
                'x': mask[i],
                'y': mask[i + 1]
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    } catch (e) {
      debugPrint('Failed to insert masks: $e');
    }
  }

  static Future<void> insertBoundingBoxes(
      String imageId, List<List<double>> boundingBoxes,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    for (List<double> boundingBox in boundingBoxes) {
      int boundingBoxId =
          await database.insert('bounding_boxes', {'image_id': imageId});
      await database.insert('bounding_box_corners', {
        'bounding_box_id': boundingBoxId,
        'x1': boundingBox[0],
        'y1': boundingBox[1],
        'x2': boundingBox[2],
        'y2': boundingBox[3]
      });
    }
  }

  static Future<List<String>> getPlantIds(
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    List<Map<String, Object?>> results = await database.query('images');

    List<String> plantIds = [];
    for (Map<String, Object?> result in results) {
      plantIds.add(result['id'] as String);
    }

    return plantIds;
  }

  static Future<List<ImageData>> getAllImages(
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    List<Map<String, Object?>> results = await database.query('images', columns: ["id"]);

    List<ImageData> images = [];
    for (Map<String, Object?> result in results) {
      ImageData? image = await getImage(result['id'] as String, databaseName: databaseName);
      if (image != null) {
        images.add(image);
      }
    }

    return images;
  }

  static Future<ImageData?> getImage(String imageId,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    List<Map<String, Object?>> results = await database.query('images',
        where: 'id = ?', whereArgs: [imageId], limit: 1);

    if (results.isEmpty) {
      return null;
    }

    List<List<double>> masks = await getMasks(imageId, databaseName: databaseName);
    List<List<double>> boundingBoxes = await getBoundingBoxes(imageId, databaseName: databaseName);

    Map<String, Object?> result = results.first;
    return ImageData(
        id: result['id'] as String,
        image: result['image_file_path'] as String,
        status: result['status'] as String,
        masks: masks,
        boundingBoxes: boundingBoxes);
  }

  static Future<List<List<double>>> getMasks(String imageId,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    List<Map<String, Object?>> results = await database.rawQuery('''
          SELECT img.id AS 'image_id', m.id AS 'mask_id', mp.path_order AS 'order', mp.x AS x, mp.y AS y
          FROM images AS img
          LEFT JOIN masks AS m ON img.id = m.image_id
          LEFT JOIN mask_points AS mp ON m.id = mp.mask_id
          WHERE img.id = '$imageId';
          ORDER BY m.id, mp.path_order
        ''');

    if (results.length == 1) {
      return [];
    }

    List<int> maskIds =
        results.map((e) => e['mask_id'] as int).toSet().toList();

    List<List<double>> masks = [];
    for (int maskId in maskIds) {
      List<double> mask = results
          .where((e) => e['mask_id'] == maskId)
          .map((e) => [e['x'] as double, e['y'] as double])
          .toList()
          .expand((e) => e)
          .toList();
      masks.add(mask);
    }

    return masks;
  }

  static Future<List<List<double>>> getBoundingBoxes(String imageId,
      {String databaseName = defaultDatabaseName}) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    Database database = await openDatabase(dbPath);

    List<Map<String, Object?>> results = await database.rawQuery('''
          SELECT img.id AS 'image_id', bb.id AS 'bounding_box_id', bbc.x1 AS x1, bbc.y1 AS y1, bbc.x2 AS x2, bbc.y2 AS y2
          FROM images AS img
          LEFT JOIN bounding_boxes AS bb ON img.id = bb.image_id
          LEFT JOIN bounding_box_corners AS bbc ON bb.id = bbc.bounding_box_id
          WHERE img.id = '$imageId';
          ORDER BY bb.id
        ''');

    if (results.length == 1) {
      return [];
    }

    List<int> boundingBoxIds =
        results.map((e) => e['bounding_box_id'] as int).toSet().toList();

    List<List<double>> boundingBoxes = [];
    for (int boundingBoxId in boundingBoxIds) {
      List<double> boundingBox = results
          .where((e) => e['bounding_box_id'] == boundingBoxId)
          .map((e) => [
                e['x1'] as double,
                e['y1'] as double,
                e['x2'] as double,
                e['y2'] as double
              ])
          .toList()
          .expand((e) => e)
          .toList();
      boundingBoxes.add(boundingBox);
    }

    return boundingBoxes;
  }
}
