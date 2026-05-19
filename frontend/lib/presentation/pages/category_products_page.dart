import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';
import 'product_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryProductsPage extends StatefulWidget {
  final int categoryId;
  CategoryProductsPage({required this.categoryId});

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/categories/${widget.categoryId}/products',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: 'PRODOTTI',
            backgroundColor: const Color(0xFF008F30),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
                products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                0.70, // Resa più alta per ospitare il prezzo
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailPage(product: product),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
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
                                if (product.imageUrl.isNotEmpty)
                                  Image.network(
                                    '${ApiService.serverUrl}${product.imageUrl}',
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
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Open Sauce',
                                    color: Color(0xFF1E293B),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                if (product.shortDesc.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      product.shortDesc,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Open Sauce',
                                        color: Color(0xFF64748B),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else
                                  const SizedBox(height: 18),
                                const SizedBox(height: 8),
                                Text(
                                  '€${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600, // SemiBold
                                    fontFamily: 'Open Sauce',
                                    color: Color(0xFFE9B416),
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
