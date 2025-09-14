# safehaven

A new Flutter project.

## Getting Started

# SafeHaven - Personal Safety Flutter App

SafeHaven is a comprehensive personal safety application built with Flutter, featuring modern architecture, professional design, and robust backend integration with Supabase.

## Features

 **Authentication System**
- Email/password authentication
- User registration with email verification
- Password reset functionality
- Profile management

 **Modern Design**
- Material 3 design system
- Light/dark theme support
- Professional color schemes
- Responsive layouts

 **Technical Features**
- Go Router navigation with authentication guards
- Riverpod state management
- Supabase backend integration
- Form validation utilities
- Custom reusable widgets

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/                 # Home screens
│   │   ├── splash_screen.dart
│   │   └── home_screen.dart
│   └── user/                 # User management screens
│       └── profile_screen.dart
├── services/                 # Business logic services
│   ├── supabase_service.dart # Supabase configuration
│   ├── auth_service.dart     # Authentication service
│   └── router_service.dart   # Navigation service
├── utils/                    # Utilities and helpers
│   ├── app_theme.dart        # Theme configuration
│   └── validators.dart       # Form validation
└── widgets/                  # Reusable widgets
    └── common/
        └── custom_button.dart
```

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### 1. Clone and Setup Project

```bash
# Clone the repository
git clone <your-repo-url>
cd SafeHaven

# Install dependencies
flutter pub get
```

### 2. Supabase Configuration

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings > API
3. Update `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Database Setup

Create the following tables in your Supabase database:

```sql
-- Enable RLS (Row Level Security)
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy for profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 4. Run the Application

```bash
# Run on debug mode
flutter run

# Build for release
flutter build apk  # For Android
flutter build ios  # For iOS
```

## Key Dependencies

- `flutter_riverpod`: State management
- `go_router`: Declarative routing
- `supabase_flutter`: Backend integration
- `loading_animation_widget`: Loading indicators
- `fluttertoast`: Toast notifications
- `image_picker`: Image selection
- `http`: HTTP requests
- `json_annotation`: JSON serialization

## App Architecture

### State Management
- **Riverpod**: Used for dependency injection and state management
- **Providers**: Centralized service management
- **Consumer Widgets**: Reactive UI updates

### Navigation
- **Go Router**: Declarative routing with authentication guards
- **Route Protection**: Automatic redirection based on auth state
- **Deep Linking**: Support for URL-based navigation

### Backend Integration
- **Supabase**: Authentication, database, and real-time features
- **Auth Service**: Centralized authentication management
- **Error Handling**: Comprehensive error handling and user feedback

### UI/UX Design
- **Material 3**: Modern design system
- **Responsive Design**: Works on different screen sizes
- **Accessibility**: Screen reader support and semantic labels
- **Dark Mode**: Automatic system theme detection

## Screens Overview

### Authentication Flow
- **Splash Screen**: App initialization and auth check
- **Login Screen**: Email/password authentication
- **Register Screen**: User registration with validation

### Main Application
- **Home Screen**: Dashboard with navigation tabs
  - Home: Welcome and quick actions
  - Emergency: Emergency features (placeholder)
  - Location: Location tracking (placeholder)
  - Contacts: Emergency contacts (placeholder)
  - Settings: App settings (placeholder)
- **Profile Screen**: User profile management

## Validation System

The app includes comprehensive form validation:

- **Email**: Format validation with regex
- **Password**: Minimum 8 characters, letters and numbers
- **Phone**: 10-15 digit validation with formatting
- **Name**: Letters and spaces only, minimum 2 characters
- **Confirm Password**: Password matching validation

## Theming

Professional Material 3 theme with:

- **Primary Colors**: Deep blue (#1565C0) for trust and security
- **Secondary Colors**: Teal accent for balance
- **Surface Colors**: Clean whites and subtle grays
- **Typography**: Clear, readable font hierarchy
- **Elevation**: Subtle shadows for depth

## Security Features

- **Row Level Security**: Database-level access control
- **Authentication Guards**: Route-level protection
- **Input Validation**: Client and server-side validation
- **Secure Storage**: Encrypted token storage

## Development Notes

### Customization Points
1. **Colors**: Update `lib/utils/app_theme.dart`
2. **Routes**: Modify `lib/services/router_service.dart`
3. **Validation**: Extend `lib/utils/validators.dart`
4. **Services**: Add new services in `lib/services/`

### Future Enhancements
- Emergency contact management
- Location tracking and sharing
- Real-time messaging
- Push notifications
- Biometric authentication
- Offline support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please create an issue on the GitHub repository or contact the development team.

---

**Note**: Remember to replace placeholder Supabase credentials with your actual project credentials before running the app.
