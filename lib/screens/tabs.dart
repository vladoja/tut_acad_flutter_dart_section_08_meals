import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

const Map<Filter, bool> kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactosFree: false,
  Filter.vegaterian: false,
  Filter.vegan: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoritesMels = [];
  Map<Filter, bool> _selectedFitlers = {
    Filter.glutenFree: false,
    Filter.lactosFree: false,
    Filter.vegaterian: false,
    Filter.vegan: false,
  };

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void _toggleMealFavoritesStatus(Meal meal) {
    final isExisting = _favoritesMels.contains(meal);
    if (isExisting) {
      setState(() {
        _favoritesMels.remove(meal);
        _showInfoMessage('Meal Removed From Favorites');
      });
    } else {
      setState(() {
        _favoritesMels.add(meal);
        _showInfoMessage('Added To Favorites');
      });
    }
  }

  void _selectPage(index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    if (identifier == 'filters') {
      // First POP is to close drawer.
      Navigator.of(context).pop();
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) {
      final result = await Navigator.of(context)
          .push<Map<Filter, bool>>(MaterialPageRoute(builder: (ctx) {
        return const FiltersScreen();
      }));
      setState(() {
        _selectedFitlers = result ?? kInitialFilters;
      });
      print('RESULT: ${result}');
    } else {
      // Closing DRAWER. Going back to Meals.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals.where((element) {
      if (_selectedFitlers[Filter.glutenFree]! && !element.isGlutenFree) {
        return false;
      }
      if (_selectedFitlers[Filter.lactosFree]! && !element.isLactoseFree) {
        return false;
      }
      if (_selectedFitlers[Filter.vegan]! && !element.isVegan) {
        return false;
      }
      if (_selectedFitlers[Filter.vegaterian]! && !element.isVegetarian) {
        return false;
      }
      return true;
    }).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _toggleMealFavoritesStatus,
      availableMeals: availableMeals,
    );
    var activePageTitle = 'Categories';
    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: _favoritesMels,
        onToggleFavorite: _toggleMealFavoritesStatus,
      );
      activePageTitle = 'Your Favorites';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(onSelectScreen: _setScreen),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: 'Categories'),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
