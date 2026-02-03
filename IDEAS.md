# Dialed In - Ideas & Future Features

This document outlines potential features, improvements, and future updates for the Dialed In coffee tracking application. Ideas are organized by category and priority.

---

## ✅ Recently Completed (February 2026)

### Bean Composition Tracking
**Status:** ✅ Completed  
**Description:** Track arabica and robusta percentages for each bean.
- **Features:**
  - Dual sliders for arabica/robusta percentages (auto-sync to 100%)
  - Display composition on bean detail screen
  - Show composition badge on home screen bean cards
  - Smart formatting (blend vs pure arabica/robusta)
- **UI Integration:**
  - Added to bean add/edit screen
  - Visible on bean cards with grind size
  - Displayed in bean detail info section

### Default Ranking Sort
**Status:** ✅ Completed  
**Description:** Beans now sort by ranking (star rating) by default on home screen.
- **Features:**
  - Highest-rated beans appear first
  - Maintains roast level filtering
  - Manual sort option still available (Default/Ranking toggle)

---

## 🚀 High Priority Features

### 1. Cloud Sync & Backup
**Status:** On Roadmap  
**Description:** Securely back up roast history and sync across devices using cloud storage (Firebase, AWS Amplify, or Supabase).
- **Benefits:** 
  - Data persistence across device changes
  - Multi-device support for users
  - Automatic backup to prevent data loss
- **Implementation Notes:**
  - Implement user authentication (email/social login)
  - Store JSON data in cloud database
  - Handle offline-first sync with conflict resolution

### 2. Smart Scale Integration
**Status:** On Roadmap  
**Description:** Bluetooth support for real-time flow profiling and auto-logging from smart scales.
- **Supported Devices:**
  - Acaia Lunar/Pearl
  - Felicita Arc
  - Timemore Black Mirror
  - Decent Scale
- **Features:**
  - Real-time weight tracking during extraction
  - Automatic shot logging with dose/yield
  - Flow rate visualization
  - Auto-detect extraction start/stop

### 3. Data Export & Import
**Status:** On Roadmap  
**Description:** Download brew logs as CSV/JSON for external analysis and import from other apps.
- **Export Formats:**
  - CSV for spreadsheet analysis
  - JSON for backup/migration
  - PDF reports with charts
- **Import Features:**
  - Bulk bean import from CSV
  - Migration from other coffee apps
  - Backup restore functionality

---

## 📊 Analytics & Insights

### 4. Advanced Analytics Dashboard
**Priority:** High  
**Description:** Comprehensive analytics page with insights across all beans and gear.
- **Metrics:**
  - Total shots pulled over time
  - Average extraction ratio trends
  - Grind size distribution by roast level
  - Success rate by machine/grinder combination
  - Cost per shot calculator (based on bean price)
- **Visualizations:**
  - Time-series charts for key metrics
  - Heat maps for shot success by parameters
  - Correlation analysis (grind vs taste)

### 5. Shot Comparison Tool
**Priority:** Medium  
**Description:** Compare multiple shots side-by-side to identify optimal parameters.
- **Features:**
  - Select 2-4 shots to compare
  - Highlight differences in parameters
  - Visual diff of taste profiles
  - "Clone shot" button to replicate parameters
  - Save comparison as a reference

### 6. Bean Performance Scoring
**Status:** ✅ Partially Implemented  
**Description:** Bean ranking system is in place with manual star ratings.
- **Current Features:**
  - Manual 0-5 star ranking per bean
  - Sortable bean list by ranking
  - Star indicator on bean cards
- **Future Enhancements:**
  - Automated scoring based on shot success
  - Consistency metrics (variance in grind/time)
  - Ease of dialing in (shots to achieve good result)
  - Notes sentiment analysis

---

## 🌍 Social & Community

### 7. Recipe Sharing Platform
**Status:** On Roadmap  
**Description:** Share full bean and recipe deep-links with other Dialed In users.
- **Features:**
  - Generate shareable recipe cards with QR codes
  - Public recipe gallery/marketplace
  - Follow other users and see their best shots
  - Rate and comment on shared recipes
  - Import recipes with one tap

### 8. Community Challenges
**Priority:** Low  
**Description:** Gamification through community challenges and achievements.
- **Challenge Types:**
  - "Dial in under 5 shots" challenge
  - "Try 10 different origins" challenge
  - Monthly grinder/machine spotlight
- **Rewards:**
  - Badges and achievements
  - Leaderboards
  - Featured user profiles

### 9. Roaster Directory & Reviews
**Priority:** Medium  
**Description:** Database of coffee roasters with user reviews and bean recommendations.
- **Features:**
  - Search roasters by location/specialty
  - Link beans to roaster profiles
  - Rate and review roasters
  - Discover new roasters based on preferences
  - Direct links to roaster websites

---

## 🔧 Equipment & Maintenance

### 10. Equipment Maintenance Tracking
**Priority:** Medium  
**Description:** Track maintenance schedules and usage stats for gear.
- **Features:**
  - Log backflushing, descaling, burr changes
  - Reminder notifications for maintenance
  - Shot counter per machine/grinder
  - Maintenance history timeline
  - Parts replacement tracking

### 11. Grinder Burr Aging Analytics
**Priority:** Low  
**Description:** Track how grind behavior changes as burrs wear over time.
- **Metrics:**
  - Grind size drift over burr lifetime
  - Extraction variance by burr age
  - Recommended replacement indicators
  - Before/after burr change comparison

### 12. Equipment Comparison Mode
**Priority:** Low  
**Description:** A/B testing framework to compare machines or grinders.
- **Features:**
  - Split testing with same bean
  - Statistical significance indicators
  - Blind taste test mode
  - Generate comparison reports

---

## 💧 Water & Variables

### 13. Water Profile Tracking
**Status:** On Roadmap  
**Description:** Track detailed water recipes and mineral composition.
- **Parameters:**
  - TDS, GH, KH measurements
  - Mineral composition (Ca, Mg, etc.)
  - Water source/brand
  - Custom water recipes
- **Features:**
  - Link water profile to shots
  - Compare shots with different water
  - Recommended water profiles by bean

### 14. Environmental Factors
**Priority:** Low  
**Description:** Log ambient conditions that affect extraction.
- **Tracked Variables:**
  - Ambient temperature
  - Humidity levels
  - Altitude/barometric pressure
  - Time of day patterns
- **Insights:**
  - Correlate environment with taste
  - Grind adjustment recommendations
  - Seasonal trends

---

## 🎨 UI/UX Enhancements

### 15. Quick Shot Logging
**Priority:** High  
**Description:** Streamlined shot entry for rapid logging during busy mornings.
- **Features:**
  - One-tap quick log with defaults
  - Voice input for parameters
  - Smart watch companion app
  - Shortcuts/widgets for iOS/Android
  - Camera OCR for scale readings

### 16. Dark/Light Theme Toggle
**Priority:** Medium  
**Description:** User preference for dark mode (current default) or light theme.
- **Implementation:**
  - Theme switcher in settings
  - Respect system preferences
  - Maintain brand colors across themes

### 17. Customizable Dashboard
**Priority:** Low  
**Description:** Let users configure their home screen layout.
- **Widgets:**
  - Recent shots
  - Bean collection summary
  - Grind size trends
  - Quick add buttons
  - Stat tiles (total shots, avg ratio, etc.)

### 18. Localization
**Status:** On Roadmap  
**Description:** Multi-language support for global coffee community.
- **Languages (Priority Order):**
  - English (current)
  - Italian
  - Spanish
  - German
  - Japanese
  - Korean
  - Portuguese

---

## 📱 Mobile-Specific Features

### 19. Apple Watch / WearOS App
**Priority:** Medium  
**Description:** Companion app for wearables to time shots and log data hands-free.
- **Features:**
  - Shot timer with haptic feedback
  - Voice dictation for notes
  - Quick glance at recent beans
  - Complication showing last shot time

### 20. AR Bean Preview
**Priority:** Low  
**Description:** Use camera to visualize bean bag and scan labels.
- **Features:**
  - OCR to auto-fill bean details from bag labels
  - AR view of bean info when pointing camera at bag
  - QR code scanning for roaster info

---

## 🧪 Advanced Features

### 21. Machine Learning Recommendations
**Priority:** Medium  
**Description:** AI-powered suggestions based on historical data.
- **Recommendations:**
  - Predicted optimal grind size for new bean
  - Next parameter adjustment suggestions
  - Bean recommendations based on taste preferences
  - Extraction troubleshooting assistant

### 22. Pressure Profiling Support
**Priority:** Low  
**Description:** For advanced machines with pressure profiling capabilities.
- **Features:**
  - Visual pressure curve editor
  - Save/load pressure profiles
  - Associate profiles with beans
  - Flow profiling visualization

### 23. Batch Brew Tracking
**Priority:** Medium  
**Description:** Expand beyond espresso to filter, pour-over, and batch brewing.
- **Brew Methods:**
  - V60, Chemex, Kalita Wave
  - French Press
  - Aeropress
  - Batch brewers
- **Method-Specific Parameters:**
  - Bloom time
  - Pour pattern/technique
  - Agitation method
  - Filter type

### 24. Cupping Sessions
**Priority:** Low  
**Description:** Structured cupping note-taking for evaluating multiple beans.
- **Features:**
  - Side-by-side cupping forms
  - SCA cupping score sheets
  - Compare beans across cupping sessions
  - Export cupping notes

---

## 🔌 Integrations

### 25. Smart Home Integration
**Priority:** Low  
**Description:** Integrate with home automation platforms.
- **Platforms:**
  - HomeKit (iOS)
  - Google Home
  - Alexa
- **Commands:**
  - "Log a shot for [bean name]"
  - "What grind size should I use?"
  - "Start shot timer"

### 26. Calendar Integration
**Priority:** Low  
**Description:** Sync shots and roast dates with calendar apps.
- **Features:**
  - Calendar view of brewing history
  - Roast date reminders
  - Bean freshness notifications
  - Weekly brewing patterns

### 27. Health App Integration
**Priority:** Low  
**Description:** Track caffeine intake in Apple Health / Google Fit.
- **Data:**
  - Caffeine content per shot
  - Daily/weekly consumption tracking
  - Hydration reminders

---

## 🛡️ Data & Privacy

### 28. Local-First Privacy Mode
**Priority:** Medium  
**Description:** Option to keep all data strictly local with no cloud sync.
- **Features:**
  - Encrypted local database
  - Local backup to device storage
  - Export for manual backup
  - Privacy badge/certification

### 29. Data Anonymization for Research
**Priority:** Low  
**Description:** Opt-in anonymous data sharing for coffee research.
- **Use Cases:**
  - Aggregate insights for coffee science
  - Industry trend analysis
  - Contribute to open coffee data project
- **Privacy:**
  - Fully anonymized
  - Opt-in only
  - Transparent data usage policy

---

## 🎓 Education & Learning

### 30. Coffee Knowledge Base
**Priority:** Low  
**Description:** Built-in educational content about coffee and extraction.
- **Content:**
  - Extraction theory guides
  - Troubleshooting common issues
  - Glossary of terms
  - Video tutorials
  - Tips and tricks library

### 31. Guided Dialing-In Wizard
**Priority:** Medium  
**Description:** Step-by-step assistant for beginners to dial in espresso.
- **Features:**
  - Taste diagnosis (sour/bitter/channeling)
  - Suggested parameter changes
  - Decision tree for adjustments
  - Progress tracking from first to dialed shot

---

## 💼 Professional Features

### 32. Cafe/Multi-User Mode
**Priority:** Low  
**Description:** Support for coffee shops to track multiple baristas and stations.
- **Features:**
  - User roles (barista, manager, owner)
  - Shift tracking
  - Bean inventory management
  - Cost tracking and reporting
  - Training mode for new baristas

### 33. Bean Inventory Management
**Priority:** Medium  
**Description:** Track bean stock levels and usage rates.
- **Features:**
  - Current stock quantity
  - Purchase history
  - Low stock alerts
  - Usage rate calculation
  - Reorder reminders
  - Cost per shot analytics

---

## 🐛 Technical Improvements

### 34. Offline Mode Enhancement
**Priority:** High  
**Description:** Robust offline support with sync queue.
- **Features:**
  - Full offline functionality
  - Queue changes for next sync
  - Conflict resolution UI
  - Offline indicator

### 35. Performance Optimization
**Priority:** High  
**Description:** Improve app performance for large datasets.
- **Optimizations:**
  - Lazy loading for large bean lists
  - Database indexing
  - Image caching and compression
  - Pagination for shot history

### 36. Automated Testing
**Priority:** Medium  
**Description:** Expand test coverage for reliability.
- **Testing:**
  - Unit tests for all models
  - Widget tests for UI components
  - Integration tests for user flows
  - E2E testing with patrol/integration_test

---

## 🎁 Nice-to-Have Features

### 37. Bean Subscription Tracking
**Priority:** Low  
**Description:** Manage coffee subscription services.
- Track delivery dates
- Note new beans from subscriptions
- Rate subscription quality

### 38. Gift/Wish List Mode
**Priority:** Low  
**Description:** Share beans and gear you want to try.
- Public wish lists
- Gift recommendations for fellow users
- Integration with retail partners

### 39. Photo Gallery
**Priority:** Low  
**Description:** Visual diary of shots, latte art, and setups.
- Shot photos with EXIF data
- Latte art gallery
- Before/after comparison
- Share to social media

### 40. Brew Method Templates
**Priority:** Medium  
**Description:** Pre-configured templates for popular recipes.
- **Examples:**
  - James Hoffmann's V60 method
  - Onyx Coffee Lab espresso profile
  - Turbo shot recipes
- User can save custom templates

---

## 📝 Implementation Notes

**For Contributors:**
- Features marked "On Roadmap" are already planned in README.md
- Priority levels: High (next 1-3 months), Medium (3-6 months), Low (future)
- Consider user feedback and usage analytics when prioritizing
- Start with features that provide maximum value with minimal complexity

**Community Input:**
- File GitHub issues to discuss specific features
- Upvote issues to influence priority
- Contribute PRs for features you'd like to implement

---

**Last Updated:** 2026-02-03  
**Recent Changes:**
- ✅ Added arabica/robusta percentage tracking
- ✅ Bean composition display on home screen and detail view
- ✅ Default sort by ranking implemented
- 🔧 Fixed Gradle wrapper checksum for Android builds

**Contributors Welcome!** See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines (if exists).
