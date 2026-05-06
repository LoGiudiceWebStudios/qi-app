import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _MenuSection(
        title: 'Burger Signature',
        items: const ['Qi Smash', 'Double Focus', 'Veg Crunch'],
      ),
      _MenuSection(
        title: 'Piatti Veloci',
        items: const ['Caesar Bowl', 'Wrap Pollo', 'Toast Club'],
      ),
      _MenuSection(
        title: 'Drink',
        items: const ['Lemon Soda', 'Cold Brew', 'Fresh Orange'],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...section.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFF008F30),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuSection {
  final String title;
  final List<String> items;

  const _MenuSection({required this.title, required this.items});
}
