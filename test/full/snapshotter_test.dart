part of ice_test;

snapshotter_tests() {
  group('Snapshotter', () {
    var editor;

    setUp((){
      editor = new Full()
        ..store.storage_key = "ice-test-${currentTestCase.id}";

      editor.store..clear()..['Saved Project'] = {'code': 'asdf'};


      return editor.editorReady;
    });

    tearDown(() {
      editor.remove();
      editor.store..clear()..freeze();
    });

    test('take a snapshot of code', () {
      editor.snapshotter.take();
      expect(editor.store['SNAPSHOT: Saved Project (${Snapshotter.dateStr})'], isNotNull);
    });

    test('Snapshot flag set to true', () {
      editor.snapshotter.take();
      var snapshot = editor.store['SNAPSHOT: Saved Project (${Snapshotter.dateStr})'];
      expect(snapshot['snapshot'], isTrue);
    });

    test('snapshot should have copy of most recent code', () {
      editor.snapshotter.take();
      var snapshot = editor.store['SNAPSHOT: Saved Project (${Snapshotter.dateStr})'];
      expect(snapshot['code'], equals('asdf'));
    });

    test('snapshot should not be taken if code is not changed', () {
      editor.store['SNAPSHOT: Saved Project (2014-08-23 23:08)'] = {'code': 'asdf', 'snapshot': true};
      editor.snapshotter.take();
      var snapshot = editor.store['SNAPSHOT: Saved Project (${Snapshotter.dateStr})'];
      expect(snapshot, isNull);
    });

    test('snapshot deletes the oldest if if 20 snapshots exist', (){
      for (var i=0; i<20; i++) {
        editor.store['SNAPSHOT: Saved Project #$i (2014-08-30: 22:48)'] = {
          'code': 'asdf',
          'snapshot': true
        };
      }

      editor.snapshotter.take();

      var snapshot = editor.store['SNAPSHOT: Saved Project #0 (2014-08-30: 22:48)'];
      expect(snapshot, isNull);
    });


    test('works with parens in the title', () {
      editor.store..clear()..['Parens Project (1)'] = {'code': 'asdf'};
      editor.snapshotter.take();
      expect(editor.store['SNAPSHOT: Parens Project (1) (${Snapshotter.dateStr})'], isNotNull);
    });

    test('works with parens in title when previous snapshot exists', () {
      editor.store
        ..clear()
        ..['SNAPSHOT: Parens Project (1) (2014-11-22: 22:48)'] = {
          'code': 'old code',
          'snapshot': true
          }
        ..['Parens Project (1)'] = {'code': 'asdf'};

      editor.snapshotter.take();
      expect(editor.store['SNAPSHOT: Parens Project (1) (${Snapshotter.dateStr})'], isNotNull);
    });

    // Snapshot mode:
    //   1. Read-only ACE
    //   2. Hide Update button
    //   3. Show a snapshot-mode warning (in-place of update button)
    //       - Leave snapshot when button is clicked
    //   4. Menu button only includes:
    //       - Open
    //       - Make a Copy
    //       - Help
    //   5. Open only shows snapshots (no "real" projects)
    //   6. Make a Copy drop out of snapshot mode.

    // *** START Here ****
    // TODO: do a manual test of snapshots (with or without titles that include parens)
    // TODO: snapshots every 10 minutes, not 8 seconds
  });
}