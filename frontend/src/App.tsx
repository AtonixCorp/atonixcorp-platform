import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box } from '@mui/material';

// Components
import Header from './components/Layout/Header';
import Footer from './components/Layout/Footer';

// Context
import { AuthProvider } from './contexts/AuthContext';

// Observability
import { initializeOpenTelemetry } from './observability/telemetry';
import { TelemetryErrorBoundary } from './observability/hooks';

// Pages
import HomePage from './pages/HomePage';
import ProjectsPage from './pages/ProjectsPage';
import ProjectDetailPage from './pages/ProjectDetailPage';
import TeamsPage from './pages/TeamsPage';
import TeamDetailPage from './pages/TeamDetailPage';
import FocusAreasPage from './pages/FocusAreasPage';
import FocusAreaDetailPage from './pages/FocusAreaDetailPage';
import ResourcesPage from './pages/ResourcesPage';
import CommunityPage from './pages/CommunityPage';
import ContactPage from './pages/ContactPage';

// Create custom theme for AtonixCorp
const theme = createTheme({
  palette: {
    primary: {
      main: '#2196f3',
      dark: '#1976d2',
      light: '#64b5f6',
    },
    secondary: {
      main: '#ff5722',
      dark: '#d84315',
      light: '#ff8a65',
    },
    background: {
      default: '#fafafa',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      fontSize: '3rem',
    },
    h2: {
      fontWeight: 600,
      fontSize: '2.5rem',
    },
    h3: {
      fontWeight: 600,
      fontSize: '2rem',
    },
    h4: {
      fontWeight: 500,
      fontSize: '1.75rem',
    },
    h5: {
      fontWeight: 500,
      fontSize: '1.5rem',
    },
    h6: {
      fontWeight: 500,
      fontSize: '1.25rem',
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          borderRadius: 8,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        },
      },
    },
  },
});

function App() {
  useEffect(() => {
    // Initialize telemetry on app startup
    initializeOpenTelemetry();
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <TelemetryErrorBoundary componentName="App">
        <AuthProvider>
          <Router>
            <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
              <Header />
              <Box component="main" sx={{ flex: 1 }}>
                <Routes>
                  <Route path="/" element={<HomePage />} />
                  <Route path="/projects" element={<ProjectsPage />} />
                  <Route path="/projects/:slug" element={<ProjectDetailPage />} />
                  <Route path="/teams" element={<TeamsPage />} />
                  <Route path="/teams/:slug" element={<TeamDetailPage />} />
                  <Route path="/focus-areas" element={<FocusAreasPage />} />
                  <Route path="/focus-areas/:slug" element={<FocusAreaDetailPage />} />
                  <Route path="/resources" element={<ResourcesPage />} />
                  <Route path="/community" element={<CommunityPage />} />
                  <Route path="/contact" element={<ContactPage />} />
                </Routes>
              </Box>
              <Footer />
            </Box>
          </Router>
        </AuthProvider>
      </TelemetryErrorBoundary>
    </ThemeProvider>
  );
}

export default App;
