-- ==============================================================================
-- AutoDealers India — Supabase PostgreSQL Database Schema & Initial Seed
-- Project: cardealer
-- ==============================================================================

-- 1. Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop existing tables if re-running
DROP TABLE IF EXISTS analytics_events CASCADE;
DROP TABLE IF EXISTS enquiries CASCADE;
DROP TABLE IF EXISTS cars CASCADE;
DROP TABLE IF EXISTS dealers CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;

-- ==============================================================================
-- 3. Table: subscription_plans
-- ==============================================================================
CREATE TABLE subscription_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price_monthly NUMERIC NOT NULL,
  car_limit INTEGER NOT NULL,
  is_recommended BOOLEAN DEFAULT false,
  has_featured_listing BOOLEAN DEFAULT false,
  has_priority_placement BOOLEAN DEFAULT false,
  has_advanced_analytics BOOLEAN DEFAULT false,
  features TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 4. Table: dealers
-- ==============================================================================
CREATE TABLE dealers (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  business_name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  phone TEXT NOT NULL,
  whatsapp TEXT NOT NULL,
  email TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT DEFAULT 'India',
  description TEXT,
  gst_number TEXT,
  working_hours TEXT DEFAULT 'Mon - Sat: 9:30 AM - 7:30 PM',
  is_demo BOOLEAN DEFAULT false,
  
  -- Verification Pipeline: pending -> submitted -> approved -> verified
  verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'submitted', 'approved', 'verified', 'rejected')),
  verified_at TIMESTAMPTZ,
  verified_by TEXT,
  
  status TEXT DEFAULT 'approved' CHECK (status IN ('approved', 'suspended')),
  subscription_plan_id TEXT REFERENCES subscription_plans(id) ON DELETE SET NULL,
  subscription_status TEXT DEFAULT 'trial' CHECK (subscription_status IN ('trial', 'active', 'expiring', 'expired', 'suspended')),
  
  trial_start_date TIMESTAMPTZ,
  trial_end_date TIMESTAMPTZ,
  subscription_start_date TIMESTAMPTZ,
  renewal_date TIMESTAMPTZ,
  expiry_date TIMESTAMPTZ,
  
  views_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 5. Table: cars
-- ==============================================================================
CREATE TABLE cars (
  id TEXT PRIMARY KEY,
  dealer_id TEXT NOT NULL REFERENCES dealers(id) ON DELETE CASCADE,
  dealer_name TEXT NOT NULL,
  dealer_city TEXT NOT NULL,
  title TEXT NOT NULL,
  slug TEXT NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  variant TEXT NOT NULL,
  condition TEXT DEFAULT 'Used' CHECK (condition IN ('Used', 'New')),
  price NUMERIC NOT NULL,
  year INTEGER NOT NULL,
  kilometers INTEGER NOT NULL,
  fuel_type TEXT NOT NULL,
  transmission TEXT NOT NULL,
  body_type TEXT NOT NULL,
  owners_count TEXT DEFAULT '1st Owner',
  city TEXT NOT NULL,
  insurance_valid_till TEXT,
  color TEXT DEFAULT 'White',
  engine TEXT,
  description TEXT,
  features TEXT[] DEFAULT '{}',
  images TEXT[] DEFAULT '{}',
  cover_image TEXT,
  
  -- Featured Listing fields (for future monetization)
  is_featured BOOLEAN DEFAULT false,
  featured_start_date TIMESTAMPTZ,
  featured_end_date TIMESTAMPTZ,
  featured_source TEXT,
  featured_payment_id TEXT,
  
  is_approved BOOLEAN DEFAULT true,
  status TEXT DEFAULT 'available' CHECK (status IN ('available', 'sold', 'inactive')),
  
  views_count INTEGER DEFAULT 0,
  phone_clicks INTEGER DEFAULT 0,
  whatsapp_clicks INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 6. Table: enquiries (CRM Leads)
-- ==============================================================================
CREATE TABLE enquiries (
  id TEXT PRIMARY KEY,
  car_id TEXT,
  car_title TEXT,
  dealer_id TEXT NOT NULL REFERENCES dealers(id) ON DELETE CASCADE,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_email TEXT,
  message TEXT,
  source TEXT DEFAULT 'Car Detail Page',
  status TEXT DEFAULT 'New' CHECK (status IN ('New', 'Contacted', 'Interested', 'Converted', 'Closed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- ==============================================================================
-- 7. Table: analytics_events
-- ==============================================================================
CREATE TABLE analytics_events (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL, -- car_view, profile_view, whatsapp_click, phone_click, enquiry_submit
  dealer_id TEXT NOT NULL,
  car_id TEXT,
  source TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 8. Table: admin_settings
-- ==============================================================================
CREATE TABLE admin_settings (
  id TEXT PRIMARY KEY DEFAULT 'platform_settings',
  default_trial_days INTEGER DEFAULT 7,
  dealer_approval_required BOOLEAN DEFAULT false,
  car_approval_required BOOLEAN DEFAULT false,
  max_images_per_car INTEGER DEFAULT 10,
  banner_message TEXT DEFAULT '🚀 Special Offer: Join today and get 7 Days Free Trial with full lead capture features!',
  platform_contact_email TEXT DEFAULT 'support@autodealersindia.com',
  platform_contact_phone TEXT DEFAULT '+91 98765 43210',
  is_razorpay_enabled BOOLEAN DEFAULT false
);

-- ==============================================================================
-- 9. Performance Indexes
-- ==============================================================================
CREATE INDEX idx_cars_dealer_id ON cars(dealer_id);
CREATE INDEX idx_cars_brand ON cars(brand);
CREATE INDEX idx_cars_city ON cars(city);
CREATE INDEX idx_cars_price ON cars(price);
CREATE INDEX idx_cars_is_featured ON cars(is_featured);
CREATE INDEX idx_enquiries_dealer_id ON enquiries(dealer_id);
CREATE INDEX idx_enquiries_status ON enquiries(status);
CREATE INDEX idx_analytics_dealer_id ON analytics_events(dealer_id);

-- ==============================================================================
-- 10. Row Level Security (RLS) Policies
-- ==============================================================================
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE dealers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- Public can read active subscription plans
CREATE POLICY "Public read plans" ON subscription_plans FOR SELECT USING (true);

-- Public can read approved dealers
CREATE POLICY "Public read approved dealers" ON dealers FOR SELECT USING (status = 'approved');

-- Dealers can update their own profile
CREATE POLICY "Dealers update own profile" ON dealers FOR UPDATE USING (auth.uid()::text = user_id);

-- Public can read available, approved cars
CREATE POLICY "Public read cars" ON cars FOR SELECT USING (status = 'available' AND is_approved = true);

-- Dealers can insert/update/delete their own cars
CREATE POLICY "Dealers manage own cars" ON cars FOR ALL USING (auth.uid()::text = dealer_id);

-- Public can submit customer enquiries
CREATE POLICY "Public submit enquiries" ON enquiries FOR INSERT WITH CHECK (true);

-- Dealers can read and update their own enquiries ONLY (Tenant Isolation)
CREATE POLICY "Dealers view own enquiries" ON enquiries FOR SELECT USING (auth.uid()::text = dealer_id);
CREATE POLICY "Dealers update own enquiries" ON enquiries FOR UPDATE USING (auth.uid()::text = dealer_id);

-- Public can log analytics events
CREATE POLICY "Public log analytics" ON analytics_events FOR INSERT WITH CHECK (true);

-- Dealers can read their own analytics events
CREATE POLICY "Dealers view own analytics" ON analytics_events FOR SELECT USING (auth.uid()::text = dealer_id);

-- Public read platform settings
CREATE POLICY "Public read settings" ON admin_settings FOR SELECT USING (true);

-- ==============================================================================
-- 11. Initial Seed Data (10 Indian Dealers, 3 Plans, Realistic Cars)
-- ==============================================================================

-- Plans
INSERT INTO subscription_plans (id, name, price_monthly, car_limit, is_recommended, has_priority_placement, has_advanced_analytics, features)
VALUES 
  ('starter', 'Starter', 499, 10, false, false, false, ARRAY['List up to 10 cars', 'Dealer public profile', 'Direct WhatsApp lead capture', 'Direct Phone call leads', 'Basic enquiry CRM', '7-Day Free Trial included']),
  ('business', 'Business', 999, 30, true, true, true, ARRAY['List up to 30 cars', 'Verified Dealer badge priority', 'Direct WhatsApp & Phone leads', 'Full Enquiry CRM with status stages', 'Detailed Lead ROI & Conversion metrics', 'Lead source performance breakdown', 'Priority customer support']),
  ('pro', 'Pro', 1999, 100, false, true, true, ARRAY['List up to 100 cars', 'Featured car listings included', 'Top tier search placement', 'Priority WhatsApp lead capture', 'Advanced multi-channel analytics', 'Dedicated account manager']);

-- Dealers
INSERT INTO dealers (id, user_id, business_name, slug, logo_url, phone, whatsapp, email, address, city, state, description, is_demo, verification_status, verified_at, verified_by, status, subscription_plan_id, subscription_status, views_count)
VALUES 
  ('dealer_1', 'user_dealer_1', 'Apex Motors', 'apex-motors-muktsar', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=200', '+91 98142 55001', '+919814255001', 'apex@cardealer.com', 'Kotkapura Road, Bypass', 'Muktsar', 'Punjab', 'Muktsar premier pre-owned automotive dealership specializing in inspected, certified SUVs and sedans.', true, 'verified', NOW() - INTERVAL '45 days', 'Super Admin', 'approved', 'business', 'active', 680),
  ('dealer_2', 'user_dealer_2', 'Royal Wheels Autocraft', 'royal-wheels-delhi', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=200', '+91 98110 44002', '+919811044002', 'royalwheels@cardealer.com', 'Ring Road, Naraina Vihar', 'Delhi NCR', 'Delhi', 'Exclusive multi-brand certified used car showroom offering non-accidental guarantee.', true, 'verified', NOW() - INTERVAL '60 days', 'Super Admin', 'approved', 'pro', 'active', 1240),
  ('dealer_3', 'user_dealer_3', 'Grandeur Cars', 'grandeur-cars-mumbai', 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=200', '+91 98200 33003', '+919820033003', 'grandeur@cardealer.com', 'Worli Sea Face, Lower Parel', 'Mumbai', 'Maharashtra', 'Luxury automotive specialists dealing in premium sedans and high-end exotics.', true, 'verified', NOW() - INTERVAL '30 days', 'Super Admin', 'approved', 'pro', 'active', 940),
  ('dealer_4', 'user_dealer_4', 'Silverline Automotive', 'silverline-bengaluru', 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=200', '+91 98450 22004', '+919845022004', 'silverline@cardealer.com', '100 Feet Road, Indiranagar', 'Bengaluru', 'Karnataka', 'Trusted destination for automatic hatchbacks and hybrid crossovers.', true, 'verified', NOW() - INTERVAL '15 days', 'Super Admin', 'approved', 'business', 'trial', 510),
  ('dealer_5', 'user_dealer_5', 'Heritage Motors', 'heritage-motors-chandigarh', 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200', '+91 98150 11005', '+919815011005', 'heritage@cardealer.com', 'Madhya Marg, Sector 26', 'Chandigarh', 'Chandigarh', 'Specializing in rugged 4x4 vehicles, Thar, Scorpio-N, and luxury family cruisers.', true, 'verified', NOW() - INTERVAL '40 days', 'Super Admin', 'approved', 'business', 'active', 820);

-- Cars
INSERT INTO cars (id, dealer_id, dealer_name, dealer_city, title, slug, brand, model, variant, condition, price, year, kilometers, fuel_type, transmission, body_type, owners_count, city, insurance_valid_till, color, engine, description, features, cover_image, is_featured, status, views_count, phone_clicks, whatsapp_clicks)
VALUES 
  ('car_1', 'dealer_1', 'Apex Motors', 'Muktsar', '2023 Maruti Suzuki Swift ZXi Plus Dual Tone', 'maruti-swift-muktsar', 'Maruti Suzuki', 'Swift', 'ZXi+ Dual Tone', 'Used', 765000, 2023, 18400, 'Petrol', 'Manual', 'Hatchback', '1st Owner', 'Muktsar', 'Dec 2026 (Zero Dep)', 'Pearl Arctic White', '1197 cc DualJet K-Series', 'Single handed driven Swift ZXi+ in showroom condition with Apple CarPlay and alloy wheels.', ARRAY['Touchscreen Infotainment', 'Apple CarPlay & Android Auto', 'Alloy Wheels', 'Automatic Climate Control'], 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800', true, 'available', 412, 28, 49),
  ('car_2', 'dealer_2', 'Royal Wheels Autocraft', 'Delhi NCR', '2022 Hyundai Creta 1.4 SX(O) Turbo DCT Panoramic Sunroof', 'hyundai-creta-delhi', 'Hyundai', 'Creta', 'SX(O) Turbo DCT', 'Used', 1580000, 2022, 29500, 'Petrol', 'Automatic', 'SUV', '1st Owner', 'Delhi NCR', 'Comprehensive Till Aug 2027', 'Titan Grey', '1353 cc Turbo GDi Petrol', 'Top of the line Creta Turbo with Voice Controlled Panoramic Sunroof and Bose 8-Speaker Audio.', ARRAY['Panoramic Sunroof', 'Ventilated Front Seats', 'Bose Premium Audio', '6 Airbags'], 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'available', 654, 52, 88),
  ('car_4', 'dealer_5', 'Heritage Motors', 'Chandigarh', '2022 Mahindra Thar 4x4 LX Hard Top Diesel Automatic', 'mahindra-thar-chandigarh', 'Mahindra', 'Thar', 'LX 4x4 AT Hard Top', 'Used', 1695000, 2022, 22800, 'Diesel', 'Automatic', 'SUV', '1st Owner', 'Chandigarh', 'Full Zero Dep Nov 2026', 'Napoli Black', '2184 cc mHawk 130', 'Impeccable Thar 4x4 Hard Top with factory alloys, all terrain tyres, roll cage, and cruise control.', ARRAY['Keyless Entry & Push Start', 'Touchscreen Infotainment', 'Alloy Wheels', 'Cruise Control'], 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'available', 520, 46, 72),
  ('car_5', 'dealer_1', 'Apex Motors', 'Muktsar', '2021 Toyota Fortuner 2.8 4x4 Legender AT Diesel', 'toyota-fortuner-muktsar', 'Toyota', 'Fortuner', 'Legender 4x4 AT', 'Used', 3950000, 2021, 41000, 'Diesel', 'Automatic', 'SUV', '1st Owner', 'Muktsar', 'Valid Till Feb 2027', 'White Pearl Crystal Shine', '2755 cc Turbo Diesel', 'Toyota Fortuner Legender 4x4 with maroon-black interior, ventilated seats, and JBL sound.', ARRAY['Ventilated Seats', 'Touchscreen Infotainment', 'Alloy Wheels', 'Reverse Parking Camera', '6 Airbags'], 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800', true, 'available', 789, 65, 110);

-- Enquiries
INSERT INTO enquiries (id, car_id, car_title, dealer_id, customer_name, customer_phone, customer_email, message, source, status)
VALUES 
  ('enq_1', 'car_1', '2023 Maruti Suzuki Swift ZXi Plus Dual Tone', 'dealer_1', 'Gurpreet Singh', '+91 98141 88220', 'gurpreet.singh@gmail.com', 'Sat Sri Akal ji, car di RC transfer and inspection report mil sakdi hai?', 'Car Detail Page', 'Interested'),
  ('enq_2', 'car_5', '2021 Toyota Fortuner 2.8 4x4 Legender AT Diesel', 'dealer_1', 'Harman Gill', '+91 98722 44331', 'harmangill@yahoo.com', 'Looking to purchase Fortuner for immediate delivery. Can you please share service booklet on WhatsApp?', 'WhatsApp', 'Converted');

-- Admin Settings
INSERT INTO admin_settings (id, default_trial_days, dealer_approval_required, car_approval_required, max_images_per_car, banner_message, platform_contact_email, platform_contact_phone)
VALUES ('platform_settings', 7, false, false, 10, '🚀 Special Offer: Join today and get 7 Days Free Trial with full lead capture features!', 'support@autodealersindia.com', '+91 98765 43210');
