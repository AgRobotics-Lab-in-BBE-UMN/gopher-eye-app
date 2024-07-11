import 'package:flutter_test/flutter_test.dart';
import 'package:gopher_eye/services/app_database.dart';
import 'package:gopher_eye/image_data.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Test database initialization', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');

      String databasePath = join(await getDatabasesPath(), 'test.db');
      Database db = await openDatabase(databasePath);

      List<String> tables = await db
          .query('sqlite_master', where: 'type = ?', whereArgs: ['table']).then(
              (value) => value.map((e) => e['name'] as String).toList());

      expect(
          tables,
          containsAll([
            'images',
            'masks',
            'mask_points',
            'bounding_boxes',
            'bounding_box_corners'
          ]));
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test image insertion', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image',
          image: null,
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [
              0,
              0,
              1,
              1,
            ],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      AppDatabase.insertImage(image, databaseName: 'test.db');

      String databasePath = join(await getDatabasesPath(), 'test.db');
      Database db = await openDatabase(databasePath);

      List<Map<String, dynamic>> images =
          await db.query('images', where: 'id = ?', whereArgs: ['test_image']);
      // List<Map<String, dynamic>> images = await db.query('images');
      expect(images.length, 1);
      expect(images[0]['id'], 'test_image');
      expect(images[0]['status'], 'test_statues');
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test mask insertion', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [0, 0, 1, 1],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image, databaseName: 'test.db');

      String databasePath = join(await getDatabasesPath(), 'test.db');
      Database db = await openDatabase(databasePath);

      List<Map<String, Object?>> results = await db.rawQuery('''
          SELECT img.id AS 'image_id', m.id AS 'mask_id', mp.path_order AS 'order', mp.x AS x, mp.y AS y
          FROM images AS img
          LEFT JOIN masks AS m ON img.id = m.image_id
          LEFT JOIN mask_points AS mp ON m.id = mp.mask_id
          WHERE img.id = 'test_image_id';
        ''');

      expect(results.length, 6);
      // Test point 0
      expect(results[0]['image_id'], 'test_image_id');
      expect(results[0]['mask_id'], 1);
      expect(results[0]['x'], 0);
      expect(results[0]['y'], 0);

      // Test point 1
      expect(results[1]['image_id'], 'test_image_id');
      expect(results[1]['mask_id'], 1);
      expect(results[1]['x'], 0);
      expect(results[1]['y'], 1);

      // Test point 2
      expect(results[2]['image_id'], 'test_image_id');
      expect(results[2]['mask_id'], 1);
      expect(results[2]['x'], 1);
      expect(results[2]['y'], 1);

      // Test point 3
      expect(results[3]['image_id'], 'test_image_id');
      expect(results[3]['mask_id'], 2);
      expect(results[3]['x'], 0);
      expect(results[3]['y'], 0);

      // Test point 4
      expect(results[4]['image_id'], 'test_image_id');
      expect(results[4]['mask_id'], 2);
      expect(results[4]['x'], 1);
      expect(results[4]['y'], 1);

      // Test point 5
      expect(results[5]['image_id'], 'test_image_id');
      expect(results[5]['mask_id'], 2);
      expect(results[5]['x'], 1);
      expect(results[5]['y'], 0);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test bounding box insertion', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [0, 0, 1, 1],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image, databaseName: 'test.db');

      String databasePath = join(await getDatabasesPath(), 'test.db');
      Database db = await openDatabase(databasePath);

      List<Map<String, Object?>> results = await db.rawQuery('''
          SELECT img.id AS 'image_id', bb.id AS 'bounding_box_id', bbc.x1 AS x1, bbc.y1 AS y1, bbc.x2 AS x2, bbc.y2 AS y2
          FROM images AS img
          LEFT JOIN bounding_boxes AS bb ON img.id = bb.image_id
          LEFT JOIN bounding_box_corners AS bbc ON bb.id = bbc.bounding_box_id
          WHERE img.id = 'test_image_id';
        ''');

      expect(results.length, 2);
      // Test bounding box 0
      expect(results[0]['image_id'], 'test_image_id');
      expect(results[0]['bounding_box_id'], 1);
      expect(results[0]['x1'], 0);
      expect(results[0]['y1'], 0);
      expect(results[0]['x2'], 1);
      expect(results[0]['y2'], 1);

      // Test bounding box 1
      expect(results[1]['image_id'], 'test_image_id');
      expect(results[1]['bounding_box_id'], 2);
      expect(results[1]['x1'], 0.25);
      expect(results[1]['y1'], 0.25);
      expect(results[1]['x2'], 0.75);
      expect(results[1]['y2'], 0.75);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get plant ids', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image1 = ImageData(
          id: 'test_image_id_1',
          image: null,
          status: 'test_statues',
          masks: null,
          boundingBoxes: null);
      ImageData image2 = ImageData(
          id: 'test_image_id_2',
          image: null,
          status: 'test_statues',
          masks: null,
          boundingBoxes: null);

      await AppDatabase.insertImage(image1, databaseName: 'test.db');
      await AppDatabase.insertImage(image2, databaseName: 'test.db');

      List<String> plantIds =
          await AppDatabase.getPlantIds(databaseName: 'test.db');
      expect(plantIds, ['test_image_id_1', 'test_image_id_2']);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get image', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image1 = ImageData(
          id: 'test_image_id',
          image: '',
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [0, 0, 1, 1],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image1, databaseName: 'test.db');

      ImageData? image =
          await AppDatabase.getImage('test_image_id', databaseName: 'test.db');

      expect(image!.id, 'test_image_id');
      expect(image.image, '');
      expect(image.status, 'test_statues');
      expect(image.masks, [
        [0, 0, 0, 1, 1, 1],
        [0, 0, 1, 1, 1, 0]
      ]);
      expect(image.boundingBoxes, [
        [0, 0, 1, 1],
        [0.25, 0.25, 0.75, 0.75]
      ]);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get image with nonexistant image', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image1 = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [0, 0, 1, 1],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image1, databaseName: 'test.db');

      ImageData? image = await AppDatabase.getImage('nonexistant_image_id',
          databaseName: 'test.db');

      expect(image, null);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get masks', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: [
            [0, 0, 0, 1, 1, 1],
            [0, 0, 1, 1, 1, 0]
          ],
          boundingBoxes: [
            [0, 0, 1, 1],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image, databaseName: 'test.db');

      List<List<double>> masks = await AppDatabase.getMasks(image.id as String,
          databaseName: 'test.db');
      expect(masks, [
        [0, 0, 0, 1, 1, 1],
        [0, 0, 1, 1, 1, 0]
      ]);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get null masks', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: null,
          boundingBoxes: null);

      await AppDatabase.insertImage(image, databaseName: 'test.db');

      List<List<double>> masks = await AppDatabase.getMasks(image.id as String,
          databaseName: 'test.db');
      expect(masks, []);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get bounding boxes', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: [
            [0.0, 0.0, 0.0, 1.0, 1.0, 1.0],
            [0.0, 0.0, 1.0, 1.0, 1.0, 0.0]
          ],
          boundingBoxes: [
            [0.0, 0.0, 1.0, 1.0],
            [0.25, 0.25, 0.75, 0.75]
          ]);

      await AppDatabase.insertImage(image, databaseName: 'test.db');
      await AppDatabase.insertBoundingBoxes(
          image.id as String, image.boundingBoxes!,
          databaseName: 'test.db');

      List<List<double>> _ = await AppDatabase.getBoundingBoxes(
          image.id as String,
          databaseName: 'test.db');
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });

  test('Test get null bounding boxes', () async {
    try {
      await AppDatabase.initDatabase(databaseName: 'test.db');
      ImageData image = ImageData(
          id: 'test_image_id',
          image: null,
          status: 'test_statues',
          masks: null,
          boundingBoxes: null);

      await AppDatabase.insertImage(image, databaseName: 'test.db');

      List<List<double>> boundingBoxes = await AppDatabase.getBoundingBoxes(
          image.id as String,
          databaseName: 'test.db');
      expect(boundingBoxes, []);
    } finally {
      await deleteDatabase(join(await getDatabasesPath(), 'test.db'));
    }
  });
}
