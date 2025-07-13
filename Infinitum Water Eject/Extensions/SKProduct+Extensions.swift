/*
 * ============================================================================
 * INFINITUM WATER EJECT - STOREKIT PRODUCT EXTENSIONS
 * ============================================================================
 * 
 * FILE: SKProduct+Extensions.swift
 * PURPOSE: Extends StoreKit's SKProduct with convenience properties for pricing
 * AUTHOR: Kevin Doyle Jr.
 * CREATED: [7/5/2025]
 * LAST MODIFIED: [7/9/2025]
 *
 * DESCRIPTION:
 * This file contains extensions to Apple's StoreKit framework, specifically
 * extending the SKProduct class with convenience properties for localized
 * price formatting. This extension simplifies the display of subscription
 * and in-app purchase prices throughout the application by providing
 * properly formatted, locale-aware price strings.
 * 
 * ARCHITECTURE OVERVIEW:
 * - SKProduct Extension: Adds computed properties to StoreKit's SKProduct
 * - Localized Pricing: Provides locale-aware price formatting
 * - Currency Formatting: Uses NumberFormatter for proper currency display
 * - Fallback Handling: Provides fallback display for formatting errors
 * - StoreKit Integration: Seamlessly integrates with existing StoreKit code
 * 
 * KEY COMPONENTS:
 * 1. localizedPrice: Computed property that formats price with proper currency
 * 2. NumberFormatter: Handles currency formatting with locale awareness
 * 3. Price Locale: Uses the product's native price locale for accuracy
 * 4. Error Handling: Provides fallback string if formatting fails
 * 
 * FUNCTIONALITY:
 * - Automatically formats prices in the correct currency for the user's locale
 * - Handles different currency symbols and formatting rules
 * - Provides consistent price display across the entire application
 * - Simplifies subscription and IAP price presentation
 * 
 * USAGE EXAMPLES:
 * - product.localizedPrice // Returns "€9.99" for European users
 * - product.localizedPrice // Returns "$9.99" for US users
 * - product.localizedPrice // Returns "¥999" for Japanese users
 * 
 * DEPENDENCIES:
 * - StoreKit: Apple's in-app purchase and subscription framework
 * - Foundation: Provides NumberFormatter for currency formatting
 * 
 * TODO LIST:
 * - [ ] Add price comparison functionality (original vs discounted)
 * - [ ] Implement price per period calculation (monthly/yearly rates)
 * - [ ] Add price validation and error handling improvements
 * - [ ] Create price formatting options (with/without currency symbol)
 * - [ ] Add support for promotional pricing display
 * - [ ] Implement price history tracking
 * - [ ] Add price localization for custom currencies
 * 
 * FEATURE SUGGESTIONS:
 * - [ ] Add price breakdown display (monthly cost of annual subscription)
 * - [ ] Implement price savings calculation for longer subscriptions
 * - [ ] Create price comparison with competitor apps
 * - [ ] Add price trend analysis and recommendations
 * - [ ] Implement dynamic pricing based on user behavior
 * - [ ] Add price optimization suggestions
 * - [ ] Create price alert system for price changes
 * 
 * TECHNICAL NOTES:
 * - Uses NumberFormatter for robust currency formatting
 * - Respects the product's native price locale for accuracy
 * - Provides graceful fallback for formatting errors
 * - Follows Swift extension best practices
 * - Maintains compatibility with StoreKit updates
 * - Lightweight implementation with minimal overhead
 * 
 * ============================================================================
 */

import StoreKit

// MARK: - SKProduct Price Formatting Extension
// Extends StoreKit's SKProduct class with convenience properties for price formatting
// Simplifies the display of subscription and IAP prices throughout the application

extension SKProduct {
    // MARK: - Localized Price Property
    // Computed property that formats the product price with proper currency formatting
    // Uses the product's native price locale for accurate currency display
    
    /// Returns a properly formatted price string in the product's locale
    /// Automatically handles currency symbols, decimal places, and formatting rules
    /// Provides fallback to raw price string if formatting fails
    var localizedPrice: String {
        // MARK: - Price Formatter Setup
        // Creates a NumberFormatter configured for currency formatting
        // Uses the product's priceLocale for accurate currency display
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency  // Configure for currency formatting
        formatter.locale = priceLocale     // Use product's native price locale
        
        // MARK: - Price Formatting and Fallback
        // Attempts to format the price, falls back to raw price if formatting fails
        // Ensures users always see a price, even if formatting encounters issues
        return formatter.string(from: price) ?? "\(price)"  // Fallback to raw price string
    }
} 
