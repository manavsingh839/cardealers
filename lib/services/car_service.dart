import '../data/app_data_store.dart';
import '../models/car_model.dart';

abstract class CarSearchQuery {
  final String? searchQuery;
  final String? condition; // 'Used' | 'New'
  final String? brand;
  final String? city;
  final String? fuelType;
  final String? transmission;
  final String? bodyType;
  final String? ownerCount;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? maxKm;
  final String? dealerId;
  final String sortBy; // 'Latest Added' | 'Price: Low to High' | 'Price: High to Low' | 'Year: Newest First' | 'Most Viewed'

  CarSearchQuery({
    this.searchQuery,
    this.condition,
    this.brand,
    this.city,
    this.fuelType,
    this.transmission,
    this.bodyType,
    this.ownerCount,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxKm,
    this.dealerId,
    this.sortBy = 'Latest Added',
  });
}

class CarFilterParams extends CarSearchQuery {
  CarFilterParams({
    super.searchQuery,
    super.condition,
    super.brand,
    super.city,
    super.fuelType,
    super.transmission,
    super.bodyType,
    super.ownerCount,
    super.minPrice,
    super.maxPrice,
    super.minYear,
    super.maxYear,
    super.maxKm,
    super.dealerId,
    super.sortBy,
  });
}

abstract class ICarSearchService {
  List<CarModel> searchCars(CarSearchQuery query);
  CarModel? getCarById(String id);
  List<CarModel> getFeaturedCars();
  List<CarModel> getCarsByDealer(String dealerId);
}

class CarService implements ICarSearchService {
  final AppDataStore _dataStore = AppDataStore();

  @override
  List<CarModel> searchCars(CarSearchQuery query) {
    var list = _dataStore.cars.where((car) => car.status == 'available').toList();

    // Text search query
    if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
      final term = query.searchQuery!.trim().toLowerCase();
      list = list.where((car) =>
        car.title.toLowerCase().contains(term) ||
        car.brand.toLowerCase().contains(term) ||
        car.model.toLowerCase().contains(term) ||
        car.variant.toLowerCase().contains(term) ||
        car.city.toLowerCase().contains(term)
      ).toList();
    }

    // Condition filter
    if (query.condition != null && query.condition != 'All Conditions') {
      list = list.where((car) => car.condition.toLowerCase() == query.condition!.toLowerCase()).toList();
    }

    // Brand filter
    if (query.brand != null && query.brand != 'All Brands') {
      list = list.where((car) => car.brand.toLowerCase() == query.brand!.toLowerCase()).toList();
    }

    // City filter
    if (query.city != null && query.city != 'All Cities') {
      list = list.where((car) => car.city.toLowerCase() == query.city!.toLowerCase()).toList();
    }

    // Fuel Type filter
    if (query.fuelType != null && query.fuelType != 'All Fuels') {
      list = list.where((car) => car.fuelType.toLowerCase() == query.fuelType!.toLowerCase()).toList();
    }

    // Transmission filter
    if (query.transmission != null && query.transmission != 'All Transmissions') {
      list = list.where((car) => car.transmission.toLowerCase() == query.transmission!.toLowerCase()).toList();
    }

    // Body Type filter
    if (query.bodyType != null && query.bodyType != 'All Body Types') {
      list = list.where((car) => car.bodyType.toLowerCase() == query.bodyType!.toLowerCase()).toList();
    }

    // Owner Count filter
    if (query.ownerCount != null && query.ownerCount != 'Any Ownership') {
      list = list.where((car) => car.ownersCount.toLowerCase() == query.ownerCount!.toLowerCase()).toList();
    }

    // Dealer filter
    if (query.dealerId != null && query.dealerId!.isNotEmpty) {
      list = list.where((car) => car.dealerId == query.dealerId).toList();
    }

    // Price range
    if (query.minPrice != null) {
      list = list.where((car) => car.price >= query.minPrice!).toList();
    }
    if (query.maxPrice != null) {
      list = list.where((car) => car.price <= query.maxPrice!).toList();
    }

    // Manufacturing year
    if (query.minYear != null) {
      list = list.where((car) => car.year >= query.minYear!).toList();
    }
    if (query.maxYear != null) {
      list = list.where((car) => car.year <= query.maxYear!).toList();
    }

    // Max Km
    if (query.maxKm != null && query.maxKm! > 0) {
      list = list.where((car) => car.kilometers <= query.maxKm!).toList();
    }

    // Sorting
    switch (query.sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Year: Newest First':
        list.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'Most Viewed':
        list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
        break;
      case 'Latest Added':
      default:
        // Featured cars first, then newest createdAt
        list.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return list;
  }

  @override
  CarModel? getCarById(String id) {
    try {
      return _dataStore.cars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<CarModel> getFeaturedCars() {
    return _dataStore.cars.where((c) => c.isFeatured && c.status == 'available').toList();
  }

  @override
  List<CarModel> getCarsByDealer(String dealerId) {
    return _dataStore.cars.where((c) => c.dealerId == dealerId).toList();
  }

  void saveCar(CarModel car) {
    final existing = getCarById(car.id);
    if (existing != null) {
      _dataStore.updateCar(car);
    } else {
      _dataStore.addCar(car);
    }
  }

  void deleteCar(String carId) {
    _dataStore.deleteCar(carId);
  }

  void markAsSold(String carId) {
    final car = getCarById(carId);
    if (car != null) {
      _dataStore.updateCar(car.copyWith(status: 'sold'));
    }
  }

  void toggleFeatured(String carId, bool isFeatured) {
    _dataStore.toggleCarFeatured(carId, isFeatured);
  }
}
