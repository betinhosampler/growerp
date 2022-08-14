/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

/// making screen shots with frames for IOS/Android
/// Android: uses all emulators available showing with the 'flutter emulators' command
/// IOS: all emulators showing with the 'flutter devices' command (need to start first)
void main(List<String> arguments) {
  var emulators = [[]];
  exitCode = 0;
  print('Creating screen images from integration tests');
  const androidDir = 'android/fastlane/metadata/android/en-US/';
  const iosDir = 'ios/fastlane/unframed/en-US/';

  var params = 'emulators';
  if (Platform.isMacOS) params = 'devices';
  Process.run('flutter', [params]).then((ProcessResult rs) async {
    if (!rs.stdout.contains('•')) {
      print('No emulators/devices found');
      exit(rs.exitCode);
    }
    LineSplitter.split(rs.stdout).forEach((line) {
      if (line.contains('•')) emulators.add(line.split('•'));
    });
    // remove empty first one in declaration
    emulators.removeAt(0);
    // add entry to frame the images
    emulators.add(['frameIt']);

    // run integration test by providing path to store screenshots
    Future<void> ProcessEmulator(String imgPath, String emulatorId) async {
      await Future.forEach([
        // start emulator
        {
          'executable': 'flutter',
          'arguments': ['emulators', '--launch', emulatorId],
          'wait': 10
        },
        // run integration test
        {
          'executable': 'flutter',
          'arguments': [
            'drive',
            '--driver=test_driver/menu_test.dart',
            '--target=test_driver/target.dart',
          ],
          'environment': {'imagePrefix': '$imgPath$emulatorId-'}
        },
        // close emulator
        {
          'executable': 'adb',
          'arguments': ['emu', 'kill']
        }
      ], (Map el) async {
        print("executing command ${el['executable']} ${el['arguments']}");
        var result = await Process.start(el['executable'], el['arguments'],
            environment: el['environment']);
        await stdout.addStream(result.stdout);
        if (el['wait'] != null) {
          await Future.delayed(Duration(seconds: el['wait']));
        }
      });
    }

    // clear directory
    var lister = Directory(Platform.isMacOS ? iosDir : androidDir)
        .list(recursive: false);
    lister.listen((file) => {
          if (basename(file.path) != 'keyword.strings' &&
              basename(file.path) != 'images' &&
              basename(file.path) != 'changelogs' &&
              basename(file.path) != 'en-US' && // for ios
              basename(file.path) != 'title.strings')
            file.delete(),
        });

    // process every emulator and then frameit
    await Future.forEach(emulators, (List el) async {
      if (el[0] != 'frameIt') {
        print('====screenshots for emulator ${el[0].trim()}');
        // frameit in last step
        if (el[3].trim() == 'android') {
          await ProcessEmulator(androidDir, el[0].trim());
        } else if (el[2].trim() == 'ios') {
          print('===executing IOS command: flutter drive -d ${el[1].trim()} ');
          var result = await Process.start('flutter', [
            'drive',
            '-d',
            '${el[1].trim()}',
            '--driver=test_driver/menu_test.dart',
            '--target=test_driver/target.dart'
          ], environment: {
            'imagePrefix': '$iosDir${el[0].trim()}-'
          });
          await stdout.addStream(result.stdout);
        }
      } else {
        print('===frame the images');
        late var result;
        if (Platform.isMacOS) {
          result = await Process.start(
            'flutter',
            [
              'pub',
              'global',
              'run',
              'frameit_chrome',
              '--base-dir=ios/fastlane/unframed',
              '--frames-dir=ios/fastlane/frames',
              '--chrome-binary=/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome',
              '--pixel-ratio=2'
            ],
          );
        } else {
          result = await Process.start(
            'flutter',
            [
              'pub',
              'global',
              'run',
              'frameit_chrome',
              '--base-dir=android/fastlane/metadata/android',
              '--frames-dir=android/fastlane/frames',
              '--chrome-binary=/usr/bin/google-chrome-stable',
              '--pixel-ratio=1'
            ],
          );
        }
        await stdout.addStream(result.stdout);
      }
    });
  });
}
