# MusicShare - Rails Application Documentation

## Overview
MusicShare is a Ruby on Rails web application for music discovery, playlist management, and album reviews. It provides a platform for users to explore music, create playlists, write reviews, and discover new albums through a modern web interface.

## Technology Stack

### Backend Framework
- **Ruby**: 3.4.1
- **Rails**: 8.0.2 (latest Rails version with modern features)
- **Database**: PostgreSQL (development/production), SQLite3 (testing)
- **Authentication**: Devise 4.9
- **Web Server**: Puma
- **Background Jobs**: Solid Queue (Rails 8 built-in)
- **Caching**: Solid Cache (Rails 8 built-in)
- **WebSocket**: Solid Cable (Rails 8 built-in)

### Frontend & UI
- **CSS Framework**: Tailwind CSS 4.1/4.2
- **JavaScript**: Hotwire (Turbo + Stimulus)
- **Asset Pipeline**: Propshaft (modern Rails asset pipeline)
- **Import Maps**: For JavaScript module management
- **Icons**: Phosphor Icons 0.3.0
- **Components**: ViewComponent for reusable UI components

### Development & Deployment
- **Process Manager**: Foreman (via bin/dev)
- **Container**: Docker with multi-stage builds
- **Deployment**: Kamal (Rails 8 deployment tool)
- **Development Tools**: 
  - Brakeman (security scanner)
  - RuboCop Rails Omakase (code style)
  - Web Console (development debugging)
- **Version Manager**: mise (configured for Ruby 3.4.1)

## Project Structure

### Key Directories

```
app/
├── components/          # ViewComponent reusable UI components
├── controllers/         # Rails controllers
├── helpers/            # View helpers
├── javascript/         # Stimulus controllers and JS
├── jobs/              # Background job classes
├── mailers/           # Email functionality
├── models/            # ActiveRecord models
└── views/             # ERB templates and layouts

config/
├── environments/      # Environment-specific configuration
├── initializers/      # App initialization code
├── locales/          # Internationalization files
├── deploy.yml        # Kamal deployment configuration
├── database.yml      # Database configuration
└── routes.rb         # URL routing

db/
├── migrate/          # Database migrations
├── schema.rb         # Current database schema
└── seeds.rb          # Seed data

test/
├── components/       # ViewComponent tests
├── controllers/      # Controller tests
├── fixtures/         # Test data
├── models/          # Model tests
└── system/          # System/integration tests
```

## Database Architecture

### Core Entities
- **Users**: Authentication, profiles, roles (admin/user)
- **Artists**: Music artists with bio and profile images
- **Albums**: Music albums with ratings, release dates, cover art
- **Songs**: Individual tracks belonging to albums
- **Genres**: Music genre categorization
- **Playlists**: User-created song collections
- **Reviews**: User reviews and ratings for albums

### Key Relationships
- Many-to-many relationships via mapping tables:
  - `album_artist_mappings` (albums ↔ artists)
  - `song_artist_mappings` (songs ↔ artists)
  - `album_genre_mappings` (albums ↔ genres)
  - `playlist_song_mappings` (playlists ↔ songs)
  - `song_tag_mappings` (songs ↔ metadata tags)
- External links for albums (Spotify, Apple Music, etc.)
- User behavior logging for analytics

## Key Features

### User Features
- User registration and authentication (Devise)
- Profile management with custom usernames and bios
- Album browsing with search, filtering, and sorting
- Playlist creation and management
- Album reviews and ratings
- Music discovery through curated recommendations

### Admin Features
- Admin panel for content management
- Artist and album administration
- User management capabilities

### Search & Discovery
- Advanced search by album name, artist name
- Filtering by genre and minimum rating
- Sorting by various criteria (name, rating, artist)
- Featured album recommendations on homepage

## Component Architecture

### ViewComponents
The application uses ViewComponent for reusable UI elements:
- `AlbumComponent`: Album display cards
- `SongListComponent`: Song listing with controls
- `ButtonComponent`: Consistent button styling
- `ModalComponent`: Popup dialogs
- `FilterByComponent`, `SearchByComponent`, `SortByComponent`: Search UI
- `UserListComponent`, `ReviewListComponent`: List displays

### Concerns
- `Filterable`, `Searchable`, `Sortable`: Shared controller behavior

## Development Workflow

### Getting Started
```bash
# Install dependencies
bundle install

# Start development server (includes CSS watching)
make dev
# or
./bin/dev

# Database setup
docker-compose up -d  # Start PostgreSQL
bin/rails db:create db:migrate db:seed
```

### Database Management
```bash
# Check database connection
make db_check

# Start PostgreSQL container
make db_up

# Run migrations
bin/rails db:migrate

# Reset database
bin/rails db:drop db:create db:migrate db:seed
```

### Development Services
The `Procfile.dev` runs multiple services:
- Rails server on port 3000
- Tailwind CSS watcher for style compilation

## Testing

### Test Framework
- **Minitest**: Rails default testing framework
- **Capybara + Selenium**: System/integration testing
- **Parallel Testing**: Configured for faster test runs

### Test Types
- **Unit Tests**: Model and component testing
- **Controller Tests**: HTTP request/response testing
- **System Tests**: Full browser automation testing
- **Component Tests**: ViewComponent testing

### Running Tests
```bash
# Run all tests
bin/rails test

# Run specific test types
bin/rails test:models
bin/rails test:controllers
bin/rails test:system
```

## Deployment

### Production Setup
- **Container**: Multi-stage Docker build optimized for production
- **Deployment Tool**: Kamal for zero-downtime deployments
- **Database**: PostgreSQL with separate cache/queue databases
- **Assets**: Precompiled with Propshaft
- **Process Management**: Thruster + Puma for serving

### Environment Configuration
- Development: PostgreSQL locally via Docker Compose
- Test: SQLite3 for fast test execution
- Production: PostgreSQL with environment-based configuration

## Configuration Files

### Key Configuration
- `config/application.rb`: Main Rails application configuration
- `config/database.yml`: Multi-environment database setup
- `config/routes.rb`: URL routing and RESTful resources
- `config/deploy.yml`: Kamal deployment configuration
- `Dockerfile`: Production container definition
- `docker-compose.yml`: Development PostgreSQL setup

### Asset Management
- `app/assets/stylesheets/application.css`: Main stylesheet
- `app/assets/builds/tailwind.css`: Compiled Tailwind styles
- `config/importmap.rb`: JavaScript module configuration

## Security Features
- Devise authentication with secure defaults
- Brakeman static security analysis
- Role-based access control (admin/user roles)
- SQL injection protection via ActiveRecord
- CSRF protection enabled by default

## Performance Optimizations
- Database query optimization with includes/joins
- ViewComponent for efficient partial rendering
- Asset compilation and fingerprinting
- Database connection pooling
- Bootsnap for faster boot times

## API Endpoints

### Main Routes
- `GET /` - Homepage with featured albums
- `GET /album` - Album search and discovery
- `GET /album/:id` - Album details page
- `GET /playlist` - Playlist index
- `GET /playlist/:id` - Playlist details
- `GET /profile/:username` - User profiles
- `GET /admin` - Admin panel (admin only)

### RESTful Resources
- `playlists` - Playlist CRUD operations
- `albums`, `songs`, `artists` - Content management
- `reviews` - Album review system
- `users` - User profile management

## Common Development Tasks

### Adding New Features
1. Create migration: `bin/rails generate migration`
2. Update models with associations
3. Add routes in `config/routes.rb`
4. Create/update controllers
5. Build ViewComponents for UI
6. Add tests for new functionality

### Database Changes
1. Generate migration: `bin/rails generate migration AddFieldToModel field:type`
2. Review and modify migration file
3. Run migration: `bin/rails db:migrate`
4. Update model validations and associations
5. Add test fixtures and update tests

### Component Development
1. Generate component: `bin/rails generate component ComponentName`
2. Implement component logic in `.rb` file
3. Create template in `.html.erb` file
4. Add component tests
5. Use component in views: `<%= render ComponentName.new(...) %>`

This documentation provides a comprehensive overview of the MusicShare Rails application architecture, development practices, and deployment configuration.