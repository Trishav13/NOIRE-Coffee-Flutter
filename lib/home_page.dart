import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'models/coffee.dart';
import 'providers/coffee_shop_provider.dart';
import 'coffee_details_page.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _category = 'All';
  final ScrollController _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 850;
    final pages = [_buildHome(wide), const CartPage(), const FavoritesPage(), const ProfilePage()];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        _topBar(wide),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(.035, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: KeyedSubtree(key: ValueKey(_selectedIndex), child: pages[_selectedIndex]),
        )),
        if (!wide) _bottomNav(),
      ])),
    );
  }

  Widget _topBar(bool wide) => Container(
    padding: EdgeInsets.symmetric(horizontal: wide ? 54 : 20, vertical: 18),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF29372F)))),
    child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.coffee_rounded, color: Color(0xFF171713), size: 25)),
      const SizedBox(width: 13),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NOIRÉ', style: GoogleFonts.dmSerifDisplay(fontSize: 23, letterSpacing: 2, color: AppColors.white)),
        Text('COFFEE AT ITS FINEST', style: GoogleFonts.poppins(fontSize: 7, letterSpacing: 2.1, color: AppColors.accent)),
      ]),
      const Spacer(),
      if (wide) ...[
        _navItem('Discover', 0), _navItem('Your bag', 1), _navItem('Saved', 2), _navItem('Profile', 3),
        const SizedBox(width: 20),
      ],
      IconButton(tooltip: 'Search', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())), icon: const Icon(Icons.search, color: AppColors.white)),
      Consumer<CoffeeShopProvider>(builder: (_, shop, __) => Stack(clipBehavior: Clip.none, children: [
        IconButton(onPressed: () => setState(() => _selectedIndex = 1), icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.white)),
        if (shop.cart.isNotEmpty) Positioned(right: 3, top: 2, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: Text('${shop.cart.length}', style: const TextStyle(color: Colors.black, fontSize: 9)))),
      ])),
    ]),
  );

  Widget _navItem(String label, int index) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13),
    child: TextButton(onPressed: () => setState(() => _selectedIndex = index),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _selectedIndex == index ? AppColors.accent : AppColors.secondaryText, fontWeight: FontWeight.w600))),
  );

  Widget _bottomNav() => NavigationBar(
    backgroundColor: const Color(0xFF111A15), indicatorColor: AppColors.primary,
    selectedIndex: _selectedIndex, onDestinationSelected: (i) => setState(() => _selectedIndex = i),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Bag'),
      NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Saved'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ],
  );

  Widget _buildHome(bool wide) => Consumer<CoffeeShopProvider>(builder: (context, shop, _) {
    final products = shop.shop.where((c) {
      if (_category == 'Espresso') return ['Americano', 'Caffè Latte', 'Caramel Macchiato'].contains(c.name);
      if (_category == 'Chilled') return ['Cold Brew', 'Java Chip Frappuccino'].contains(c.name);
      return true;
    }).toList();
    return SingleChildScrollView(
      key: const PageStorageKey('discover'),
      controller: _scroll,
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wide ? 58 : 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: wide ? 42 : 25),
            _hero(wide),
            SizedBox(height: wide ? 70 : 42),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CURATED FOR YOUR MOMENT', style: GoogleFonts.poppins(color: AppColors.accent, letterSpacing: 2.4, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Text('The coffee collection', style: GoogleFonts.dmSerifDisplay(fontSize: wide ? 39 : 29, color: AppColors.white)),
              ])),
              if (wide) Text('SIP SLOW. LIVE WELL.', style: GoogleFonts.poppins(fontSize: 9, letterSpacing: 2, color: AppColors.secondaryText)),
            ]),
            const SizedBox(height: 22),
            Wrap(spacing: 9, children: ['All', 'Espresso', 'Chilled'].map(_categoryChip).toList()),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, box) {
              final count = box.maxWidth > 1100 ? 4 : box.maxWidth > 700 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: wide ? .88 : .68),
                itemBuilder: (_, i) => _productCard(products[i], i),
              );
            }),
            const SizedBox(height: 70),
            Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF1D2920), borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                const Icon(Icons.spa_outlined, color: AppColors.accent, size: 30),
                const SizedBox(width: 18),
                Expanded(child: Text('Good things take time. So does a really good brew.', style: GoogleFonts.dmSerifDisplay(fontSize: wide ? 25 : 19, color: AppColors.white))),
                if (wide) Text('NOIRÉ • EST. 2026', style: GoogleFonts.poppins(color: AppColors.accent, letterSpacing: 2, fontSize: 9)),
              ]),
            ),
            const SizedBox(height: 45),
          ]),
        ),
      )),
    );
  });

  Widget _hero(bool wide) => Container(
    height: wide ? 470 : 510, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF29261F)),
    child: Stack(fit: StackFit.expand, children: [
      Image.network('https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=1800', fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF30281F))),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withOpacity(.88), Colors.black.withOpacity(.5), Colors.transparent]))),
      Positioned(left: wide ? 62 : 25, top: wide ? 65 : 45, bottom: 40, child: SizedBox(width: wide ? 520 : 300, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(border: Border.all(color: AppColors.accent.withOpacity(.7)), borderRadius: BorderRadius.circular(30)), child: Text('THE ART OF SLOW COFFEE', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 9, letterSpacing: 2))),
        const Spacer(),
        Text('A little pause.\nA lot of pleasure.', style: GoogleFonts.dmSerifDisplay(fontSize: wide ? 62 : 43, height: 1.04, color: AppColors.white)),
        const SizedBox(height: 17),
        Text('Thoughtfully sourced beans. Beautifully crafted cups. Made for the moments that matter.', style: GoogleFonts.poppins(fontSize: wide ? 13 : 11, height: 1.8, color: Colors.white.withOpacity(.8))),
        const SizedBox(height: 25),
        Row(children: [
          ElevatedButton.icon(onPressed: () => _scroll.animateTo(560, duration: const Duration(milliseconds: 850), curve: Curves.easeInOutCubic),
            icon: const Icon(Icons.arrow_downward_rounded, size: 16), label: const Text('Explore the menu'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: const Color(0xFF171713), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17))),
          const SizedBox(width: 14),
          Text('CRAFTED WITH INTENTION', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 8, letterSpacing: 1.5)),
        ]),
        const Spacer(),
      ]))),
      if (wide) Positioned(right: 35, bottom: 30, child: Text('01 / SIGNATURE COLLECTION', style: GoogleFonts.poppins(color: Colors.white70, letterSpacing: 2, fontSize: 9))),
    ]),
  );

  Widget _categoryChip(String label) {
    final active = _category == label;
    return ChoiceChip(label: Text(label), selected: active, onSelected: (_) => setState(() => _category = label),
      selectedColor: AppColors.accent, backgroundColor: const Color(0xFF1B251E),
      labelStyle: TextStyle(color: active ? const Color(0xFF171713) : AppColors.secondaryText, fontWeight: FontWeight.w600),
      side: BorderSide(color: active ? AppColors.accent : const Color(0xFF344137)));
  }

  Widget _productCard(Coffee coffee, int index) {
    final photos = [
      'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=900',
      'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=900',
      'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=900',
      'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=900',
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=900',
    ];
    return _HoverCoffeeCard(
      image: photos[index % photos.length],
      child: GestureDetector(
        onTap: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, a, __) => CoffeeDetailsPage(coffee: coffee), transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0,.06), end: Offset.zero).animate(a), child: child)))),
        child: Container(decoration: BoxDecoration(color: const Color(0xFF1A241D), borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFF354035))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Stack(fit: StackFit.expand, children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(photos[index % photos.length], fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFF30281F), child: const Icon(Icons.coffee, size: 45, color: AppColors.accent)))),
              Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.black.withOpacity(.55), shape: BoxShape.circle), child: Icon(coffee.isFavorite ? Icons.favorite : Icons.arrow_outward, color: coffee.isFavorite ? Colors.redAccent : Colors.white, size: 16))),
              Positioned(left: 12, bottom: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.55), borderRadius: BorderRadius.circular(20)), child: Text('★ ${coffee.rating}', style: const TextStyle(color: Colors.white, fontSize: 10)))),
            ])),
            Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(coffee.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: AppColors.white)),
              const SizedBox(height: 4),
              Text(coffee.type, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.secondaryText)),
              const SizedBox(height: 14),
              Row(children: [
                Text('₹${coffee.price.split('.').first}', style: GoogleFonts.poppins(fontSize: 15, color: AppColors.accent, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.add, size: 17, color: Color(0xFF171713))),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _HoverCoffeeCard extends StatefulWidget {
  final Widget child;
  final String image;
  const _HoverCoffeeCard({required this.child, required this.image});
  @override
  State<_HoverCoffeeCard> createState() => _HoverCoffeeCardState();
}
class _HoverCoffeeCardState extends State<_HoverCoffeeCard> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovering = true),
    onExit: (_) => setState(() => hovering = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 260), curve: Curves.easeOut,
      transform: Matrix4.identity()..translate(0.0, hovering ? -8.0 : 0.0)..scale(hovering ? 1.015 : 1.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), boxShadow: hovering ? [BoxShadow(color: AppColors.accent.withOpacity(.16), blurRadius: 24, offset: const Offset(0, 12))] : []),
      child: widget.child),
  );
}
