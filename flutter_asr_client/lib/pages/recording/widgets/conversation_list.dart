import 'package:flutter/material.dart';
import 'package:asr_client/models/conversation.dart';
import 'package:asr_client/pages/recording/widgets/ai_response_card.dart';
import 'package:asr_client/pages/recording/widgets/user_bubble.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key, required this.items});

  final List<ConversationItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: switch (item.type) {
              ConversationItemType.userBubble => UserBubble(
                key: ValueKey(item.id),
                item: item,
              ),
              ConversationItemType.aiCard => AiResponseCard(
                key: ValueKey(item.id),
                item: item,
              ),
            },
          ),
        );
      }).toList(),
    );
  }
}
