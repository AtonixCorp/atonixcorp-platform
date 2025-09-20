import React from 'react';
import {
  Box,
  Container,
  Typography,
  Link,
  IconButton,
  Divider,
} from '@mui/material';
import {
  Twitter,
  GitHub,
  LinkedIn,
  Business as BusinessIcon,
} from '@mui/icons-material';

const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  const socialLinks = [
    { name: 'Twitter', icon: <Twitter />, url: 'https://twitter.com/AtonixCorp' },
    { name: 'GitHub', icon: <GitHub />, url: 'https://github.com/AtonixCorp' },
    { name: 'LinkedIn', icon: <LinkedIn />, url: 'https://linkedin.com/company/atonixcorp' },
  ];

  const quickLinks = [
    { name: 'Projects', path: '/projects' },
    { name: 'Teams', path: '/teams' },
    { name: 'Focus Areas', path: '/focus-areas' },
    { name: 'Resources', path: '/resources' },
  ];

  return (
    <Box
      component="footer"
      sx={{
        backgroundColor: 'primary.main',
        color: 'white',
        py: 6,
        mt: 'auto',
      }}
    >
      <Container maxWidth="lg">
        <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, gap: 4 }}>
          {/* Company Info */}
          <Box sx={{ flex: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <BusinessIcon sx={{ mr: 1, fontSize: 32 }} />
              <Typography variant="h5" component="div" fontWeight={700}>
                AtonixCorp
              </Typography>
            </Box>
            <Typography variant="body2" sx={{ mb: 3, lineHeight: 1.6 }}>
              A forward-thinking infrastructure and systems engineering organization 
              dedicated to building secure, scalable, and autonomous cloud solutions.
            </Typography>
            <Box>
              {socialLinks.map((social) => (
                <IconButton
                  key={social.name}
                  component="a"
                  href={social.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  sx={{
                    color: 'white',
                    mr: 1,
                    '&:hover': {
                      backgroundColor: 'rgba(255, 255, 255, 0.1)',
                    },
                  }}
                >
                  {social.icon}
                </IconButton>
              ))}
            </Box>
          </Box>

          {/* Quick Links */}
          <Box sx={{ flex: 1 }}>
            <Typography variant="h6" component="div" fontWeight={600} sx={{ mb: 2 }}>
              Quick Links
            </Typography>
            {quickLinks.map((link) => (
              <Link
                key={link.name}
                href={link.path}
                color="inherit"
                underline="hover"
                sx={{
                  display: 'block',
                  mb: 1,
                  opacity: 0.8,
                  '&:hover': { opacity: 1 },
                }}
              >
                {link.name}
              </Link>
            ))}
          </Box>

          {/* Focus Areas */}
          <Box sx={{ flex: 1 }}>
            <Typography variant="h6" component="div" fontWeight={600} sx={{ mb: 2 }}>
              Focus Areas
            </Typography>
            {['Agriculture', 'Fintech', 'Medical Research', 'Security', 'Big Data', 'Cloud Computing'].map((area) => (
              <Typography
                key={area}
                variant="body2"
                sx={{
                  display: 'block',
                  mb: 1,
                  opacity: 0.8,
                }}
              >
                {area}
              </Typography>
            ))}
          </Box>

          {/* Contact Info */}
          <Box sx={{ flex: 1 }}>
            <Typography variant="h6" component="div" fontWeight={600} sx={{ mb: 2 }}>
              Contact
            </Typography>
            <Typography variant="body2" sx={{ mb: 1, opacity: 0.8 }}>
              Samuel (Project Manager)
            </Typography>
            <Link
              href="mailto:guxegdsa@atonixcorp.com"
              color="inherit"
              underline="hover"
              sx={{ fontSize: '0.875rem', opacity: 0.8 }}
            >
              guxegdsa@atonixcorp.com
            </Link>
          </Box>
        </Box>

        <Divider sx={{ my: 4, backgroundColor: 'rgba(255, 255, 255, 0.2)' }} />

        <Box
          sx={{
            display: 'flex',
            flexDirection: { xs: 'column', md: 'row' },
            justifyContent: 'space-between',
            alignItems: 'center',
            textAlign: { xs: 'center', md: 'left' },
          }}
        >
          <Typography variant="body2" sx={{ opacity: 0.8 }}>
            © {currentYear} AtonixCorp. All rights reserved.
          </Typography>
          <Typography variant="body2" sx={{ opacity: 0.8, mt: { xs: 1, md: 0 } }}>
            Leading the way in technological evolution
          </Typography>
        </Box>
      </Container>
    </Box>
  );
};

export default Footer;