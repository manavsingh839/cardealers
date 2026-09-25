import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';
import '../models/car_model.dart';
import '../models/enquiry_model.dart';
import '../models/analytics_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        print('Supabase notice: Project URL/Anon Key are in placeholder mode.');
        print('AutoDealers SaaS running smoothly in Local/Seed Data Store mode.');
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _instance._isInitialized = true;
      if (kDebugMode) {
        print('Supabase successfully initialized for project "${SupabaseConfig.projectName}".');
      }
    } catch (e) {
      _instance._isInitialized = false;
      if (kDebugMode) {
        print('Supabase initialization notice: $e');
        print('AutoDealers SaaS falling back cleanly to Local Data Store.');
      }
    }
  }

  // --- Real-time & CRUD methods when Supabase is connected ---

  Future<void> insertEnquiry(EnquiryModel enquiry) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('enquiries').insert({
        'id': enquiry.id,
        'car_id': enquiry.carId,
        'car_title': enquiry.carTitle,
        'dealer_id': enquiry.dealerId,
        'customer_name': enquiry.customerName,
        'customer_phone': enquiry.customerPhone,
        'customer_email': enquiry.customerEmail,
        'message': enquiry.message,
        'source': enquiry.source,
        'status': enquiry.status,
        'created_at': enquiry.createdAt.toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) print('Supabase insertEnquiry error: $e');
    }
  }

  Future<void> updateEnquiryStatus(String enquiryId, String status) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('enquiries').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', enquiryId);
    } catch (e) {
      if (kDebugMode) print('Supabase updateEnquiryStatus error: $e');
    }
  }

  Future<void> insertCar(CarModel car) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('cars').upsert({
        'id': car.id,
        'dealer_id': car.dealerId,
        'dealer_name': car.dealerName,
        'dealer_city': car.dealerCity,
        'title': car.title,
        'slug': car.slug,
        'brand': car.brand,
        'model': car.model,
        'variant': car.variant,
        'condition': car.condition,
        'price': car.price,
        'year': car.year,
        'kilometers': car.kilometers,
        'fuel_type': car.fuelType,
        'transmission': car.transmission,
        'body_type': car.bodyType,
        'owners_count': car.ownersCount,
        'city': car.city,
        'insurance_valid_till': car.insuranceValidTill,
        'color': car.color,
        'engine': car.engine,
        'description': car.description,
        'features': car.features,
        'images': car.images,
        'cover_image': car.coverImage,
        'is_featured': car.isFeatured,
        'is_approved': car.isApproved,
        'status': car.status,
        'views_count': car.viewsCount,
        'phone_clicks': car.phoneClicks,
        'whatsapp_clicks': car.whatsappClicks,
        'created_at': car.createdAt.toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) print('Supabase insertCar error: $e');
    }
  }

  Future<void> recordAnalyticsEvent(AnalyticsEvent event) async {
    final c = client;
    if (c == null) return;
    try {
      await c.from('analytics_events').insert({
        'id': event.id,
        'type': event.type,
        'dealer_id': event.dealerId,
        'car_id': event.carId,
        'source': event.source,
        'timestamp': event.timestamp.toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) print('Supabase recordAnalyticsEvent error: $e');
    }
  }
}
