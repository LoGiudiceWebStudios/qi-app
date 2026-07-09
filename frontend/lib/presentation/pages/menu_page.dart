import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/category.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';
import 'category_products_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/categories'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: 'MENU\'',
            backgroundColor: const Color(0xFF008F30), // Verde richiesto
            icon: Icons.menu_book,
            showStar: false,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontFamily: 'Open Sauce',
            ),
          ),
          Expanded(
            child:
                categories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        24,
                        16,
                        120,
                      ), // Spaziatura laterale ridotta per allargare le card
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            0.90, // Le card del mockup sono leggermente più alte che larghe
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CategoryProductsPage(
                                      categoryId: category.id,
                                      categoryName: category.name,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (category.imageUrl.isNotEmpty)
                                  Image.network(
                                    '${ApiService.serverUrl}${category.imageUrl}',
                                    height: 100,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.fastfood,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                  )
                                else
                                  const Icon(
                                    Icons.fastfood,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                const SizedBox(height: 12),
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Open Sauce',
                                      color: Color(0xFF1E293B),
                                      height: 1.05,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    category.description.isNotEmpty
                                        ? category.description
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Open Sauce',
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
