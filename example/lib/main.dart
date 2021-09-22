import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_conversations/twilio_conversations.dart';
import 'package:twilio_conversations_example/conversations/conversations_notifier.dart';
import 'package:twilio_conversations_example/conversations/conversations_page.dart';
import 'package:twilio_conversations_example/models/twilio_chat_token_request.dart';
import 'package:twilio_conversations_example/services/backend_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Twilio Conversations Example'),
        ),
        body: Center(
          child: Column(
            children: [
              // _buildUserIdField(),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return ChangeNotifierProvider<ConversationsNotifier>(
      create: (_) => ConversationsNotifier(),
      child: Consumer<ConversationsNotifier>(
        builder: (BuildContext context, conversationsNotifier, Widget? child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: conversationsNotifier.identityController,
                onChanged: conversationsNotifier.updateIdentity,
              ),
              ElevatedButton(
                onPressed: conversationsNotifier.identity.isNotEmpty &&
                        !conversationsNotifier.isClientInitialized
                    ? () async {
                        await TwilioConversations.debug(
                            dart: true, native: true, sdk: false);

                        final jwtToken = (await BackendService.createToken(
                                TwilioChatTokenRequest(
                                    identity: conversationsNotifier.identity)))
                            ?.token; // <Set your JWT token here>

                        if (jwtToken == null) {
                          return;
                        }

                        if (jwtToken.isEmpty) {
                          _showInvalidJWTDialog(context);
                          return;
                        }
                        await conversationsNotifier.create(jwtToken: jwtToken);
                      }
                    : null,
                child: Text('Start Client'),
              ),
              ElevatedButton(
                onPressed: conversationsNotifier.isClientInitialized
                    ? () async {
                        await conversationsNotifier.shutdown();
                      }
                    : null,
                child: Text('Shutdown Client'),
              ),
              ElevatedButton(
                onPressed: conversationsNotifier.isClientInitialized
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationsPage(
                              conversationsNotifier: conversationsNotifier,
                            ),
                          ),
                        )
                    : null,
                child: Text('See My Conversations'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInvalidJWTDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error: No JWT provided'),
        content: Text(
            'To create the conversations client, a JWT must be supplied on line 44 of `main.dart`'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}