import React from 'react';
import {
  Box,
  Container,
  Typography,
  Button,
  Paper,
} from '@mui/material';
import { Link } from 'react-router-dom';

const HomePage: React.FC = () => {
  return (
    <Box>
      {/* Hero Section */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #2196f3 0%, #1976d2 100%)',
          color: 'white',
          py: 12,
          textAlign: 'center',
        }}
      >
        <Container maxWidth="lg">
          <Typography variant="h1" component="h1" sx={{ mb: 3, fontWeight: 700 }}>
            Welcome to AtonixCorp
          </Typography>
          <Typography variant="h4" component="h2" sx={{ mb: 4, opacity: 0.9, fontWeight: 300 }}>
            Leading the way in technological evolution
          </Typography>
          <Typography variant="h6" sx={{ mb: 5, maxWidth: '800px', mx: 'auto', lineHeight: 1.6 }}>
            A forward-thinking infrastructure and systems engineering organization dedicated to 
            building secure, scalable, and autonomous cloud solutions.
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
            <Button
              component={Link}
              to="/projects"
              variant="contained"
              color="secondary"
              size="large"
              sx={{ px: 4, py: 1.5 }}
            >
              Explore Projects
            </Button>
            <Button
              component={Link}
              to="/teams"
              variant="outlined"
              color="inherit"
              size="large"
              sx={{ px: 4, py: 1.5, borderColor: 'white', '&:hover': { borderColor: 'white' } }}
            >
              Meet Our Teams
            </Button>
          </Box>
        </Container>
      </Box>

      {/* Mission Section */}
      <Container maxWidth="lg" sx={{ py: 8 }}>
        <Typography variant="h3" component="h2" sx={{ mb: 4, textAlign: 'center', fontWeight: 600 }}>
          Our Mission
        </Typography>
        <Typography variant="h6" sx={{ textAlign: 'center', maxWidth: '900px', mx: 'auto', lineHeight: 1.8, color: 'text.secondary' }}>
          We design and deploy resilient architectures that adapt seamlessly across diverse environments—from 
          smart cities to high-performance clusters. With a strong emphasis on edge computing, next-generation 
          observability, and future-ready design, our mission is to empower organizations with infrastructure 
          that evolves intelligently, operates reliably, and unlocks new frontiers in connectivity and computation.
        </Typography>
      </Container>

      {/* Quick Stats */}
      <Box sx={{ backgroundColor: 'background.paper', py: 8 }}>
        <Container maxWidth="lg">
          <Box sx={{ display: 'flex', justifyContent: 'space-around', flexWrap: 'wrap', gap: 4 }}>
            {[
              { number: '5+', label: 'Active Projects' },
              { number: '2', label: 'Expert Teams' },
              { number: '6', label: 'Focus Areas' },
              { number: '100%', label: 'Innovation Driven' },
            ].map((stat, index) => (
              <Box key={index} sx={{ textAlign: 'center' }}>
                <Typography variant="h2" component="div" sx={{ fontWeight: 700, color: 'primary.main', mb: 1 }}>
                  {stat.number}
                </Typography>
                <Typography variant="h6" component="div" sx={{ color: 'text.secondary' }}>
                  {stat.label}
                </Typography>
              </Box>
            ))}
          </Box>
        </Container>
      </Box>

      {/* Call to Action */}
      <Container maxWidth="lg" sx={{ py: 8 }}>
        <Paper
          elevation={0}
          sx={{
            background: 'linear-gradient(135deg, #f5f5f5 0%, #e0e0e0 100%)',
            p: 6,
            textAlign: 'center',
            borderRadius: 4,
          }}
        >
          <Typography variant="h4" component="h2" sx={{ mb: 3, fontWeight: 600 }}>
            Ready to innovate with us?
          </Typography>
          <Typography variant="h6" sx={{ mb: 4, color: 'text.secondary' }}>
            Discover our cutting-edge projects and join us in shaping the future of technology.
          </Typography>
          <Button
            component={Link}
            to="/contact"
            variant="contained"
            color="primary"
            size="large"
            sx={{ px: 4, py: 1.5 }}
          >
            Get In Touch
          </Button>
        </Paper>
      </Container>
    </Box>
  );
};

export default HomePage;