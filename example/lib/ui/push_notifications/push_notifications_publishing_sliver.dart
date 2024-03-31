import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/bool_stream_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PushNotificationsPublishingSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsPublishingSliver({
    required PushNotificationService pushNotificationService,
    Key? key,
  })  : _pushNotificationService = pushNotificationService,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Publishing to '
              '"${Constants.channelNameForPushNotifications}"',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Each message sent contains a push payload, '
                  'in the ably.Message.extras field.'),
            ),
            Row(
              children: [
                BoolStreamButton(
                  stream: _pushNotificationService.hasPushChannelStream,
                  onPressed: _pushNotificationService
                      .publishNotificationMessageToChannel,
                  child: const Text('Notification Message'),
                ),
                BoolStreamButton(
                  stream: _pushNotificationService.hasPushChannelStream,
                  onPressed:
                      _pushNotificationService.publishDataMessageToChannel,
                  child: const Text('Data Message'),
                ),
              ],
            ),
            BoolStreamButton(
              stream: _pushNotificationService.hasPushChannelStream,
              onPressed: _pushNotificationService
                  .publishDataNotificationMessageToChannel,
              child: const Text('Data + Notification Message'),
            ),
          ],
        ),
      );
}
