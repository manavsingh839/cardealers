import 'package:flutter/foundation.dart';
import '../data/app_data_store.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

class CarCatalogProvider extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();
  final CarService _carService = CarService();

  String _searchQuery = '';
  String _selectedBrand = 'All Brands';
  String _selectedCity = 'All Cities';
  String _selectedFuel = 'All Fuels';
  String _selectedTransmission = 'All Transmissions';
  String _selectedBodyType = 'All Body Types';
  String _selectedCondition = 'All Conditions';
  String _selectedOwnerCount = 'Any Ownership';
  double? _minPrice;
  double? _maxPrice;
  int? _minYear;
  int? _maxYear;
  String _sortBy = 'Latest Added';

  CarCatalogProvider() {
    _dataStore.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _dataStore.removeListener(notifyListeners);
    super.dispose();
  }

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedBrand => _selectedBrand;
  String get selectedCity => _selectedCity;
  String get selectedFuel => _selectedFuel;
  String get selectedTransmission => _selectedTransmission;
  String get selectedBodyType => _selectedBodyType;
  String get selectedCondition => _selectedCondition;
  String get selectedOwnerCount => _selectedOwnerCount;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  int? get minYear => _minYear;
  int? get maxYear => _maxYear;
  String get sortBy => _sortBy;

  List<CarModel> get featuredCars => _carService.getFeaturedCars();

  List<CarModel> get filteredCars {
    final query = CarFilterParams(
      searchQuery: _searchQuery,
      brand: _selectedBrand,
      city: _selectedCity,
      fuelType: _selectedFuel,
      transmission: _selectedTransmission,
      bodyType: _selectedBodyType,
      condition: _selectedCondition,
      ownerCount: _selectedOwnerCount,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minYear: _minYear,
      maxYear: _maxYear,
      sortBy: _sortBy,
    );
    return _carService.searchCars(query);
  }

  int get totalResultsCount => filteredCars.length;

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setBrand(String brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setFuel(String fuel) {
    _selectedFuel = fuel;
    notifyListeners();
  }

  void setTransmission(String transmission) {
    _selectedTransmission = transmission;
    notifyListeners();
  }

  void setBodyType(String bodyType) {
    _selectedBodyType = bodyType;
    notifyListeners();
  }

  void setCondition(String condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  void setOwnerCount(String ownerCount) {
    _selectedOwnerCount = ownerCount;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setYearRange(int? min, int? max) {
    _minYear = min;
    _maxYear = max;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedBrand = 'All Brands';
    _selectedCity = 'All Cities';
    _selectedFuel = 'All Fuels';
    _selectedTransmission = 'All Transmissions';
    _selectedBodyType = 'All Body Types';
    _selectedCondition = 'All Conditions';
    _selectedOwnerCount = 'Any Ownership';
    _minPrice = null;
    _maxPrice = null;
    _minYear = null;
    _maxYear = null;
    _sortBy = 'Latest Added';
    notifyListeners();
  }
}
