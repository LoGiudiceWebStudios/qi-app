import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: 'PRODOTTO',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Immagine centrale 300x300
                  if (product.imageUrl.isNotEmpty)
                    Image.network(
                      '${ApiService.serverUrl}${product.imageUrl}',
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.fastfood,
                            size: 150,
                            color: Colors.grey,
                          ),
                    )
                  else
                    const Icon(Icons.fastfood, size: 150, color: Colors.grey),

                  const SizedBox(height: 32),

                  // Titolo del prodotto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Open Sauce',
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Pulsante (Stile Pillola come in foto)
                  InkWell(
                    onTap: () {
                      // Azione pulsante es. Aggiungi al carrello
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.view_in_ar,
                            color: Color(0xFFE9B416),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Vedi in 3d',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Open Sauce',
                              color: Color(0xFFE9B416),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Sezione Descrizione lunga
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Descrizione',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Open Sauce',
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Nessuna descrizione disponibile per questo prodotto.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Open Sauce',
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Sezione Prezzo qui in basso
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          'Prezzo: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Open Sauce',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '€${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Open Sauce',
                            color: Color(0xFFE9B416),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
