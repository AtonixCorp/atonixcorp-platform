# AtonixCorp Platform

AtonixCorp is a forward-thinking infrastructure and systems engineering organization dedicated to building secure, scalable, and autonomous cloud solutions. We design and deploy resilient architectures that adapt seamlessly across diverse environments—from smart cities to high-performance clusters. With a strong emphasis on edge computing, next-generation observability, and future-ready design, our mission is to empower organizations with infrastructure that evolves intelligently, operates reliably, and unlocks new frontiers in connectivity and computation.

## [FEATURES] Features

- **Project Showcase**: Interactive project listings with detailed views, filtering, and search
- **Team Profiles**: Comprehensive team information with skills, achievements, and member details
- **Focus Areas**: Technology focus areas with solutions, technologies, and use cases
- **Resource Center**: Documentation, tools, tutorials, and guides
- **Community Portal**: User authentication, discussions, and member interactions
- **Contact System**: Contact forms, office locations, and team member information
- **Responsive Design**: Mobile-first design with Material-UI components
- **Real-time API**: Django REST Framework with automatic API documentation

## [ARCHITECTURE] Architecture

### Backend (Django)
- **Framework**: Django 5.2.6 with Django REST Framework
- **Database**: SQLite (development), PostgreSQL-ready for production
- **Authentication**: Token-based authentication with Django's built-in auth
- **API**: RESTful API with automatic serialization and filtering
- **Media**: File upload support for images and documents

### Frontend (React)
- **Framework**: React 19.x with TypeScript
- **UI Library**: Material-UI (MUI) v7.x
- **Routing**: React Router DOM for client-side routing
- **State Management**: React Context for authentication
- **HTTP Client**: Axios with automatic error handling and token management
- **Build Tool**: Create React App with TypeScript template

## [STRUCTURE] Project Structure

```
atonixcorp-platform/
├── backend/                    # Django backend
│   ├── atonixcorp/            # Main Django project
│   │   ├── settings.py        # Django settings
│   │   ├── urls.py           # URL routing
│   │   └── auth_views.py     # Authentication views
│   ├── projects/             # Projects app
│   ├── teams/                # Teams app
│   ├── focus_areas/          # Focus areas app
│   ├── resources/            # Resources app
│   ├── contact/              # Contact app
│   ├── manage.py             # Django management script
│   └── requirements.txt      # Python dependencies
├── frontend/                 # React frontend
│   ├── src/
│   │   ├── components/       # Reusable components
│   │   ├── pages/           # Page components
│   │   ├── services/        # API services
│   │   ├── contexts/        # React contexts
│   │   ├── types/           # TypeScript type definitions
│   │   └── data/            # Mock data and utilities
│   ├── public/              # Static assets
│   └── package.json         # Node.js dependencies
└── README.md               # This file
```

## [SETUP] Installation & Setup

### Prerequisites

- Python 3.11+ with pip
- Node.js 18+ with npm
- Git

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd atonixcorp-platform
   ```

2. **Create and activate virtual environment**
   ```bash
   python -m venv .venv
   
   # On Windows
   .venv\Scripts\activate
   
   # On macOS/Linux
   source .venv/bin/activate
   ```

3. **Install Python dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

4. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

5. **Create superuser (optional)**
   ```bash
   python manage.py createsuperuser
   ```

6. **Populate with sample data**
   ```bash
   python manage.py populate_data
   ```

7. **Start Django development server**
   ```bash
   python manage.py runserver
   ```
   
   The backend API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install Node.js dependencies**
   ```bash
   npm install
   ```

3. **Start React development server**
   ```bash
   npm start
   ```
   
   The frontend will be available at `http://localhost:3000`

## [DEVELOPMENT] Development

### Backend Development

- **Django Admin**: Access at `http://localhost:8000/admin`
- **API Documentation**: Available at `http://localhost:8000/api/`
- **Database**: SQLite file located at `backend/db.sqlite3`

### Frontend Development

- **Live Reload**: Automatic browser refresh on code changes
- **TypeScript**: Full type checking and IntelliSense
- **Material-UI**: Consistent design system with theming

### Available Scripts

#### Backend
- `python manage.py runserver` - Start development server
- `python manage.py migrate` - Run database migrations
- `python manage.py makemigrations` - Create new migrations
- `python manage.py populate_data` - Load sample data
- `python manage.py createsuperuser` - Create admin user

#### Frontend
- `npm start` - Start development server
- `npm run build` - Build for production
- `npm test` - Run tests
- `npm run eject` - Eject from Create React App

## [API] API Endpoints

### Authentication
- `POST /api/auth/login/` - User login
- `POST /api/auth/signup/` - User registration
- `POST /api/auth/logout/` - User logout
- `GET /api/auth/me/` - Get current user info

### Core Resources
- `GET /api/projects/` - List all projects
- `GET /api/projects/{slug}/` - Get project details
- `GET /api/teams/` - List all teams
- `GET /api/teams/{slug}/` - Get team details
- `GET /api/focus-areas/` - List all focus areas
- `GET /api/focus-areas/{slug}/` - Get focus area details
- `GET /api/resources/` - List all resources
- `GET /api/contact-persons/` - List contact persons
- `GET /api/office-locations/` - List office locations

## [FEATURES] Features Overview

### Project Management
- Project listings with filtering and search
- Detailed project views with technologies and features
- Status tracking and progress indicators
- GitHub integration and live demo links

### Team Showcase
- Team profiles with mission statements
- Member listings with roles and skills
- Achievement tracking and statistics
- Skill proficiency indicators

### Focus Areas
- Technology focus areas with detailed descriptions
- Solution catalogs with benefits and use cases
- Technology stack overviews
- Interactive solution exploration

### Resource Center
- Categorized resource library
- Documentation and tutorial access
- Tool recommendations and guides
- Featured content highlighting

### Community Features
- User authentication and profiles
- Community discussions and interactions
- Member directory and networking
- Badge and reputation systems

## [DEPLOY] Deployment

### Production Checklist

1. **Environment Variables**
   - Set `DEBUG = False` in Django settings
   - Configure production database (PostgreSQL recommended)
   - Set secure `SECRET_KEY`
   - Configure `ALLOWED_HOSTS`

2. **Database**
   - Migrate to PostgreSQL for production
   - Set up database backups
   - Configure connection pooling

3. **Static Files**
   - Configure static file serving
   - Set up CDN for media files
   - Enable compression

4. **Security**
   - Configure HTTPS
   - Set up CORS properly
   - Enable security headers
   - Configure authentication tokens

5. **Frontend Build**
   ```bash
   cd frontend
   npm run build
   ```

### Docker Deployment (Recommended)

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DEBUG=False
      - DATABASE_URL=postgresql://user:pass@db:5432/atonixcorp
    depends_on:
      - db
  
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=atonixcorp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## [TESTING] Testing

### Backend Testing
```bash
cd backend
python manage.py test
```

### Frontend Testing
```bash
cd frontend
npm test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## [LICENSE] License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## [BUILT] Built With

- [Django](https://djangoproject.com/) - Backend framework
- [Django REST Framework](https://django-rest-framework.org/) - API framework
- [React](https://reactjs.org/) - Frontend framework
- [TypeScript](https://typescriptlang.org/) - Type safety
- [Material-UI](https://mui.com/) - UI components
- [PostgreSQL](https://postgresql.org/) - Database (production)
- [SQLite](https://sqlite.org/) - Database (development)

## [SUPPORT] Support

For support and questions:
- Email: support@atonixcorp.com
- Documentation: Available in the application
- Issues: Create a GitHub issue

---

**AtonixCorp Platform** - Showcasing innovation through technology

## Architecture

- **Frontend**: React.js with modern tooling
- **Backend**: Django with Django REST Framework
- **Database**: PostgreSQL
- **Deployment**: Docker containers

## Project Structure

```
atonixcorp-platform/
├── frontend/          # React.js application
├── backend/           # Django application
├── docker-compose.yml # Development environment
└── README.md         # This file
```

## About AtonixCorp

AtonixCorp is a forward-thinking infrastructure and systems engineering organization dedicated to building secure, scalable, and autonomous cloud solutions. We design and deploy resilient architectures that adapt seamlessly across diverse environments—from smart cities to high-performance clusters.

## Getting Started

### Prerequisites

- Node.js (v18+)
- Python (v3.9+)
- PostgreSQL
- Docker (optional, for containerized development)

### Development Setup

1. Clone the repository
2. Set up the backend (see `backend/README.md`)
3. Set up the frontend (see `frontend/README.md`)

### Quick Start with Docker

```bash
docker-compose up -d
```

## Features

- **Project Showcase**: Display all AtonixCorp projects with detailed information
- **Team Management**: Showcase teams like Pioneers and Unity Developers
- **Focus Areas**: Highlight specialization areas (Agriculture, Fintech, Medical Research, etc.)
- **Resource Center**: Development guidelines, contributing guides, and support
- **Community Links**: Integration with social platforms and communication channels
- **Contact System**: Direct communication with project managers and technical leads

## Contact

- Project Manager: Samuel (guxegdsa@atonixcorp.com)
- Technical Lead: Samuel (guxegdsa@atonixcorp.com)